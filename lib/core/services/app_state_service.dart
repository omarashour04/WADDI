import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_storage_service.dart';
import '../../shared/providers/shared_providers.dart';

class AppStateService {
  final LocalStorageService _localStorage;
  final ProviderContainer _container;

  AppStateService(this._localStorage, this._container);

  // Save app state when app is paused/closed
  Future<void> saveAppState() async {
    try {
      final navigationHistory = _container.read(navigationHistoryProvider);
      final navigationState = _container.read(navigationStateProvider);

      await _localStorage.saveAppState(
        currentRoute: _getCurrentRouteFromState(navigationState),
        navigationHistory: navigationHistory,
        additionalState: {
          'timestamp': DateTime.now().toIso8601String(),
          'appVersion': '1.0.0', // You can get this from your app info
        },
      );

      print('App state saved successfully');
    } catch (e) {
      print('Failed to save app state: $e');
    }
  }

  // Restore app state when app is resumed/opened
  Future<void> restoreAppState() async {
    try {
      final savedState = await _localStorage.getAppState();

      // Restore navigation history
      final savedHistory = savedState['navigationHistory'] as List<String>?;
      if (savedHistory != null && savedHistory.isNotEmpty) {
        await _container.read(navigationHistoryProvider.notifier).restoreState(savedHistory);
      }

      // Restore current route
      final savedRoute = savedState['currentRoute'] as String?;
      if (savedRoute != null) {
        _container.read(navigationStateProvider.notifier).updateCurrentRoute(savedRoute);
      }

      print('App state restored successfully');
    } catch (e) {
      print('Failed to restore app state: $e');
    }
  }

  // Clear all saved app state
  Future<void> clearAppState() async {
    try {
      await _localStorage.clearAppState();
      _container.read(navigationHistoryProvider.notifier).clearHistory();
      print('App state cleared successfully');
    } catch (e) {
      print('Failed to clear app state: $e');
    }
  }

  // Get app state info
  Future<Map<String, dynamic>> getAppStateInfo() async {
    try {
      final savedState = await _localStorage.getAppState();
      return savedState;
    } catch (e) {
      print('Failed to get app state info: $e');
      return {};
    }
  }

  // Helper method to get current route from navigation state
  String _getCurrentRouteFromState(NavigationState navigationState) {
    switch (navigationState.currentIndex) {
      case 0:
        return '/home';
      case 1:
        return '/venues';
      case 2:
        return '/bookings';
      case 3:
        return '/profile';
      default:
        return '/home';
    }
  }
}

// App state service provider
final appStateServiceProvider = Provider<AppStateService>((ref) {
  final localStorage = ref.read(localStorageProvider);
  return AppStateService(localStorage, ref.container);
});
