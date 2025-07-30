import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Provider with automatic system theme detection
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString('theme_mode');
      
      if (themeString != null) {
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
      } else {
        // Default to system theme
        state = ThemeMode.system;
      }
    } catch (e) {
      // Fallback to system theme if there's an error
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;
      
      switch (themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
        default:
          themeString = 'system';
          break;
      }
      
      await prefs.setString('theme_mode', themeString);
      state = themeMode;
    } catch (e) {
      // If saving fails, still update the state
      state = themeMode;
    }
  }

  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.light:
        await setTheme(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setTheme(ThemeMode.system);
        break;
      case ThemeMode.system:
        await setTheme(ThemeMode.light);
        break;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Navigation State Provider
class NavigationState {
  final int currentIndex;
  final String? userId;

  NavigationState({this.currentIndex = 0, this.userId});

  NavigationState copyWith({int? currentIndex, String? userId}) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      userId: userId ?? this.userId,
    );
  }
}

class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier() : super(NavigationState());

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setUserId(String userId) {
    state = state.copyWith(userId: userId);
  }

  Future<void> loadSavedState() async {
    // Load saved navigation state if needed
    // For now, just keep default state
  }
}

final navigationStateProvider = StateNotifierProvider<NavigationStateNotifier, NavigationState>((ref) {
  return NavigationStateNotifier();
}); 