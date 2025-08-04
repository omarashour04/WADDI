import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Provider with automatic system theme detection
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'system';
    switch (themeString) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
      default:
        state = ThemeMode.system;
        break;
    }
  }

  Future<void> setTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    switch (theme) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    await prefs.setString('themeMode', themeString);
    state = theme;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Language Provider with device language detection
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguage');

    if (savedLanguage != null) {
      // Use saved language preference
      state = Locale(savedLanguage);
    } else {
      // Detect device language
      final deviceLocale = await _getDeviceLocale();
      state = deviceLocale;
    }
  }

  Future<Locale> _getDeviceLocale() async {
    try {
      // Get device locale using Platform.localeName
      final String deviceLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;

      // Check if device language is supported
      if (['en', 'ar', 'fr', 'es', 'de'].contains(deviceLocale)) {
        return Locale(deviceLocale);
      }
    } catch (e) {
      print('Error getting device language: $e');
    }

    // Fallback to English
    return const Locale('en');
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
    state = Locale(languageCode);
  }

  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      default:
        return 'English';
    }
  }

  String getLanguageCode(String displayName) {
    switch (displayName) {
      case 'English':
        return 'en';
      case 'العربية':
        return 'ar';
      case 'Français':
        return 'fr';
      case 'Español':
        return 'es';
      case 'Deutsch':
        return 'de';
      default:
        return 'en';
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

// Navigation State Provider (simplified)
final navigationStateProvider = StateNotifierProvider<NavigationHistoryNotifier, List<String>>((
  ref,
) {
  return NavigationHistoryNotifier(ref.read(localStorageProvider));
});

// Local Storage Provider
class LocalStorageService {
  static const String _currentRouteKey = 'current_route';
  static const String _navigationHistoryKey = 'navigation_history';

  Future<void> saveCurrentRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentRouteKey, route);
  }

  Future<String?> getCurrentRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentRouteKey);
  }

  Future<void> saveNavigationHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_navigationHistoryKey, history);
  }

  Future<List<String>> getNavigationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_navigationHistoryKey) ?? [];
  }
}

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Navigation history provider for proper back button behavior
final navigationHistoryProvider = StateNotifierProvider<NavigationHistoryNotifier, List<String>>((
  ref,
) {
  return NavigationHistoryNotifier(ref.read(localStorageProvider));
});

class NavigationHistoryNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _localStorage;
  bool _isInitialized = false;

  // Maximum number of routes to keep in history
  static const int _maxHistorySize = 50;

  // Routes that should not be added to history (transient routes)
  static const Set<String> _transientRoutes = {'/loading', '/error', '/debug'};

  // Routes that should reset the history (main navigation points)
  static const Set<String> _resetRoutes = {'/home', '/venues', '/profile', '/admin'};

  NavigationHistoryNotifier(this._localStorage) : super(['/home']) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final savedHistory = await _localStorage.getNavigationHistory();
      if (savedHistory.isNotEmpty) {
        // Clean up saved history if it's too large
        final cleanedHistory = _cleanupHistory(savedHistory);
        state = cleanedHistory;
      }
      _isInitialized = true;
    } catch (e) {
      // If loading fails, use default state
      state = ['/home'];
      _isInitialized = true;
    }
  }

  Future<void> _saveState() async {
    if (_isInitialized) {
      try {
        await _localStorage.saveNavigationHistory(state);
      } catch (e) {
        // Silently handle save errors
        print('Failed to save navigation history: $e');
      }
    }
  }

  /// Clean up history by removing duplicates and limiting size
  List<String> _cleanupHistory(List<String> history) {
    if (history.isEmpty) return ['/home'];

    // Remove consecutive duplicates
    final cleaned = <String>[];
    String? lastRoute;

    for (final route in history) {
      if (route != lastRoute) {
        cleaned.add(route);
        lastRoute = route;
      }
    }

    // Limit size
    if (cleaned.length > _maxHistorySize) {
      return cleaned.sublist(cleaned.length - _maxHistorySize);
    }

    return cleaned;
  }

  /// Smart route addition with cleanup
  void addRoute(String route) {
    // Don't add transient routes to history
    if (_transientRoutes.contains(route)) {
      return;
    }

    // Don't add duplicate consecutive routes
    if (state.isEmpty || state.last != route) {
      List<String> newHistory = [...state, route];

      // Check if this is a reset route and clean up accordingly
      if (_resetRoutes.contains(route)) {
        // For reset routes, keep only the last few entries to prevent history bloat
        if (newHistory.length > 10) {
          // Keep the last 5 entries plus the new route
          final recentHistory = newHistory.sublist(newHistory.length - 5);
          newHistory = [...recentHistory, route];
        }
      }

      // Apply size limit
      if (newHistory.length > _maxHistorySize) {
        newHistory = newHistory.sublist(newHistory.length - _maxHistorySize);
      }

      state = newHistory;
      _saveState();
    }
  }

  void removeLastRoute() {
    if (state.length > 1) {
      state = state.sublist(0, state.length - 1);
      _saveState();
    }
  }

  void popRoute() {
    if (state.isNotEmpty) {
      state = state.sublist(0, state.length - 1);
      _saveState();
    }
  }

  String? getTopRoute() {
    if (state.isNotEmpty) {
      return state.last;
    }
    return null;
  }

  /// Clear history and reset to home
  void clearHistory() {
    state = ['/home'];
    _saveState();
  }

  /// Smart history cleanup - removes old entries while preserving recent navigation
  void cleanupHistory() {
    if (state.length > _maxHistorySize) {
      // Keep the last 30 entries
      state = state.sublist(state.length - 30);
      _saveState();
    }
  }

  /// Force clear all history and reset to home (useful for debugging)
  void forceClearHistory() {
    print('DEBUG: Force clearing navigation history');
    state = ['/home'];
    _saveState();
  }

  /// Reset history to a clean state with just the current route
  void resetHistory(String currentRoute) {
    print('DEBUG: Resetting navigation history to: $currentRoute');
    state = [currentRoute];
    _saveState();
  }

  /// Update current route with smart handling
  void updateCurrentRoute(String route) {
    // Don't add transient routes
    if (_transientRoutes.contains(route)) {
      return;
    }

    // For reset routes, consider clearing some history
    if (_resetRoutes.contains(route)) {
      // If we're going to a main route, we can clear some history
      if (state.length > 20) {
        // Keep only the last 10 entries
        final recentHistory = state.sublist(state.length - 10);
        state = [...recentHistory, route];
      } else {
        addRoute(route);
      }
    } else {
      addRoute(route);
    }
  }

  /// Get the previous route (useful for back navigation)
  String? getPreviousRoute() {
    if (state.length > 1) {
      return state[state.length - 2];
    }
    return null;
  }

  /// Check if we can go back
  bool get canGoBack => state.length > 1;

  int get stackSize => state.length;

  /// Get a summary of the navigation history for debugging
  String get historySummary {
    if (state.isEmpty) return 'Empty';
    if (state.length <= 5) return state.join(' → ');
    return '${state.take(3).join(' → ')} ... ${state.skip(state.length - 2).join(' → ')} (${state.length} total)';
  }

  /// Get detailed debug information about the navigation history
  Map<String, dynamic> get debugInfo {
    return {
      'totalRoutes': state.length,
      'currentRoute': state.isNotEmpty ? state.last : 'none',
      'previousRoute': getPreviousRoute(),
      'canGoBack': canGoBack,
      'history': state,
      'summary': historySummary,
      'isLarge': state.length > _maxHistorySize,
    };
  }
}
