import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
final navigationStateProvider = StateNotifierProvider<NavigationHistoryNotifier, List<String>>((ref) {
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
final navigationHistoryProvider = StateNotifierProvider<NavigationHistoryNotifier, List<String>>((ref) {
  return NavigationHistoryNotifier(ref.read(localStorageProvider));
});

class NavigationHistoryNotifier extends StateNotifier<List<String>> {
  final LocalStorageService _localStorage;
  bool _isInitialized = false;

  NavigationHistoryNotifier(this._localStorage) : super(['/home']) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final savedHistory = await _localStorage.getNavigationHistory();
      if (savedHistory.isNotEmpty) {
        state = savedHistory;
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

  void addRoute(String route) {
    // Don't add duplicate consecutive routes
    if (state.isEmpty || state.last != route) {
      state = [...state, route];
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

  void clearHistory() {
    state = ['/home'];
    _saveState();
  }

  void updateCurrentRoute(String route) {
    // Update the current route by adding it to the history
    addRoute(route);
  }

  int get stackSize => state.length;
}
