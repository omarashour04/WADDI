import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _navigationHistoryKey = 'navigation_history';
  static const String _currentRouteKey = 'current_route';
  static const String _lastAppStateKey = 'last_app_state';

  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Save navigation history
  Future<void> saveNavigationHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_navigationHistoryKey, history);
  }

  // Get navigation history
  Future<List<String>> getNavigationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_navigationHistoryKey) ?? ['/home'];
  }

  // Save current route
  Future<void> saveCurrentRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentRouteKey, route);
  }

  // Get current route
  Future<String> getCurrentRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentRouteKey) ?? '/home';
  }

  // Save complete app state
  Future<void> saveAppState({
    required String currentRoute,
    required List<String> navigationHistory,
    Map<String, dynamic>? additionalState,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save individual components
    await prefs.setString(_currentRouteKey, currentRoute);
    await prefs.setStringList(_navigationHistoryKey, navigationHistory);

    // Save additional state as JSON
    if (additionalState != null) {
      await prefs.setString(_lastAppStateKey, jsonEncode(additionalState));
    }
  }

  // Get complete app state
  Future<Map<String, dynamic>> getAppState() async {
    final prefs = await SharedPreferences.getInstance();

    final currentRoute = prefs.getString(_currentRouteKey) ?? '/home';
    final navigationHistory = prefs.getStringList(_navigationHistoryKey) ?? ['/home'];
    final additionalStateJson = prefs.getString(_lastAppStateKey);

    Map<String, dynamic> additionalState = {};
    if (additionalStateJson != null) {
      try {
        additionalState = jsonDecode(additionalStateJson) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, use empty map
        additionalState = {};
      }
    }

    return {
      'currentRoute': currentRoute,
      'navigationHistory': navigationHistory,
      'additionalState': additionalState,
    };
  }

  // Clear all app state
  Future<void> clearAppState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_navigationHistoryKey);
    await prefs.remove(_currentRouteKey);
    await prefs.remove(_lastAppStateKey);
  }
}
