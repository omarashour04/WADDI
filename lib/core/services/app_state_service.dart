import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStateService {
  static const String _currentRouteKey = 'current_route';
  static const String _navigationHistoryKey = 'navigation_history';
  static const String _lastActiveTimeKey = 'last_active_time';
  static const String _appSessionIdKey = 'app_session_id';

  // Save current route and navigation state
  static Future<void> saveCurrentState({
    required String currentRoute,
    required List<String> navigationHistory,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentRouteKey, currentRoute);
    await prefs.setStringList(_navigationHistoryKey, navigationHistory);
    await prefs.setInt(_lastActiveTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get saved state
  static Future<Map<String, dynamic>> getSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final currentRoute = prefs.getString(_currentRouteKey) ?? '/venues';
    final navigationHistory = prefs.getStringList(_navigationHistoryKey) ?? ['/venues'];
    final lastActiveTime = prefs.getInt(_lastActiveTimeKey) ?? 0;
    final sessionId = prefs.getString(_appSessionIdKey);

    return {
      'currentRoute': currentRoute,
      'navigationHistory': navigationHistory,
      'lastActiveTime': lastActiveTime,
      'sessionId': sessionId,
    };
  }

  // Generate new session ID
  static Future<String> generateSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString(_appSessionIdKey, sessionId);
    return sessionId;
  }

  // Check if app was recently active (within last 24 hours)
  static Future<bool> wasRecentlyActive() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveTime = prefs.getInt(_lastActiveTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final hoursSinceLastActive = (now - lastActiveTime) / (1000 * 60 * 60);

    return hoursSinceLastActive < 24;
  }

  // Clear saved state (for app restart)
  static Future<void> clearSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentRouteKey);
    await prefs.remove(_navigationHistoryKey);
    await prefs.remove(_lastActiveTimeKey);
    await prefs.remove(_appSessionIdKey);
  }

  // Save specific page state (for complex pages like booking flow)
  static Future<void> savePageState(String pageKey, Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('page_state_$pageKey', jsonEncode(state));
  }

  // Get specific page state
  static Future<Map<String, dynamic>?> getPageState(String pageKey) async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString('page_state_$pageKey');
    if (stateJson != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(stateJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Clear specific page state
  static Future<void> clearPageState(String pageKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('page_state_$pageKey');
  }
}

// Riverpod provider for app state service
final appStateServiceProvider = Provider<AppStateService>((ref) {
  return AppStateService();
});

// Provider to track current navigation state
final navigationStateProvider = StateNotifierProvider<NavigationStateNotifier, NavigationState>((
  ref,
) {
  return NavigationStateNotifier();
});

class NavigationState {
  final String currentRoute;
  final List<String> navigationHistory;
  final DateTime lastActiveTime;
  final String? sessionId;

  NavigationState({
    required this.currentRoute,
    required this.navigationHistory,
    required this.lastActiveTime,
    this.sessionId,
  });

  NavigationState copyWith({
    String? currentRoute,
    List<String>? navigationHistory,
    DateTime? lastActiveTime,
    String? sessionId,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier()
    : super(
        NavigationState(
          currentRoute: '/venues',
          navigationHistory: ['/venues'],
          lastActiveTime: DateTime.now(),
        ),
      );

  void updateCurrentRoute(String route) {
    final newHistory = List<String>.from(state.navigationHistory);
    if (newHistory.last != route) {
      newHistory.add(route);
      // Keep only last 10 routes to prevent memory issues
      if (newHistory.length > 10) {
        newHistory.removeAt(0);
      }
    }

    state = state.copyWith(
      currentRoute: route,
      navigationHistory: newHistory,
      lastActiveTime: DateTime.now(),
    );

    // Save state asynchronously
    _saveState();
  }

  void goBack() {
    if (state.navigationHistory.length > 1) {
      final newHistory = List<String>.from(state.navigationHistory);
      newHistory.removeLast();
      final previousRoute = newHistory.last;

      state = state.copyWith(
        currentRoute: previousRoute,
        navigationHistory: newHistory,
        lastActiveTime: DateTime.now(),
      );

      _saveState();
    }
  }

  void clearHistory() {
    state = state.copyWith(navigationHistory: [state.currentRoute], lastActiveTime: DateTime.now());
    _saveState();
  }

  Future<void> _saveState() async {
    await AppStateService.saveCurrentState(
      currentRoute: state.currentRoute,
      navigationHistory: state.navigationHistory,
    );
  }

  Future<void> loadSavedState() async {
    final savedState = await AppStateService.getSavedState();
    final wasActive = await AppStateService.wasRecentlyActive();

    if (wasActive && savedState['sessionId'] != null) {
      state = NavigationState(
        currentRoute: savedState['currentRoute'],
        navigationHistory: List<String>.from(savedState['navigationHistory']),
        lastActiveTime: DateTime.fromMillisecondsSinceEpoch(savedState['lastActiveTime']),
        sessionId: savedState['sessionId'],
      );
    } else {
      // Generate new session if app was not recently active
      final sessionId = await AppStateService.generateSessionId();
      state = state.copyWith(sessionId: sessionId);
      await _saveState();
    }
  }
}
