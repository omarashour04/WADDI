import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/local_storage_service.dart';

// Theme provider with persistence
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void setTheme(ThemeMode themeMode) {
    state = themeMode;
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        setTheme(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setTheme(ThemeMode.system);
        break;
      case ThemeMode.system:
        setTheme(ThemeMode.light);
        break;
    }
  }
}

// Navigation state provider
final navigationStateProvider = StateNotifierProvider<NavigationStateNotifier, NavigationState>((
  ref,
) {
  return NavigationStateNotifier();
});

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

  void updateCurrentRoute(String route) {
    // Update navigation state based on route
    int currentIndex = 0;
    switch (route) {
      case '/home':
        currentIndex = 0;
        break;
      case '/venues':
        currentIndex = 1;
        break;
      case '/bookings':
        currentIndex = 2;
        break;
      case '/profile':
        currentIndex = 3;
        break;
      default:
        currentIndex = 0;
    }
    state = state.copyWith(currentIndex: currentIndex);
  }

  void setUserId(String userId) {
    state = state.copyWith(userId: userId);
  }
}

// Local storage service provider
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
    print('DEBUG: NavigationHistoryNotifier.addRoute called with: $route');
    print('DEBUG: Current state before adding: $state');

    // Don't add duplicate consecutive routes
    if (state.isEmpty || state.last != route) {
      state = [...state, route];
      print('DEBUG: Route added, new state: $state');
      _saveState();
    } else {
      print('DEBUG: Route not added (duplicate): $route');
    }
  }

  void removeLastRoute() {
    if (state.length > 1) {
      state = state.sublist(0, state.length - 1);
      _saveState();
    }
  }

  // Stack-based navigation methods
  void popRoute() {
    print('DEBUG: NavigationHistoryNotifier.popRoute called');
    print('DEBUG: Current state before popping: $state');
    
    if (state.isNotEmpty) {
      state = state.sublist(0, state.length - 1);
      print('DEBUG: Route popped, new state: $state');
      _saveState();
    } else {
      print('DEBUG: No routes to pop');
    }
  }

  String? getTopRoute() {
    print('DEBUG: NavigationHistoryNotifier.getTopRoute called');
    print('DEBUG: Current state: $state');
    
    if (state.isNotEmpty) {
      final topRoute = state.last;
      print('DEBUG: Returning top route: $topRoute');
      return topRoute;
    }
    print('DEBUG: No routes available');
    return null;
  }

  // Peek at the top of the stack without popping
  String? peekTopRoute() {
    print('DEBUG: NavigationHistoryNotifier.peekTopRoute called');
    print('DEBUG: Current state: $state');
    
    if (state.isNotEmpty) {
      final topRoute = state.last;
      print('DEBUG: Peeking top route: $topRoute');
      return topRoute;
    }
    print('DEBUG: No routes available to peek');
    return null;
  }

  // Get stack size
  int get stackSize {
    return state.length;
  }

  String? getPreviousRoute() {
    print('DEBUG: NavigationHistoryNotifier.getPreviousRoute called');
    print('DEBUG: Current state: $state');
    print('DEBUG: State length: ${state.length}');

    if (state.length > 1) {
      final previousRoute = state[state.length - 2];
      print('DEBUG: Returning previous route: $previousRoute');
      return previousRoute;
    }
    print('DEBUG: No previous route available');
    return null;
  }

  void clearHistory() {
    state = ['/home'];
    _saveState();
  }

  void replaceCurrentRoute(String route) {
    if (state.isNotEmpty) {
      state = [...state.sublist(0, state.length - 1), route];
    } else {
      state = [route];
    }
    _saveState();
  }

  void removeRoute(String route) {
    state = state.where((r) => r != route).toList();
    _saveState();
  }

  // Restore state from saved data
  Future<void> restoreState(List<String> savedHistory) async {
    if (savedHistory.isNotEmpty) {
      state = savedHistory;
      await _saveState();
    }
  }
}
