import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/shared_providers.dart';

class AndroidBackButtonService {
  static const MethodChannel _channel = MethodChannel('com.waddi.mobile.dev/back_button');
  static GoRouter? _router;
  static ProviderContainer? _container;

  static void initialize(GoRouter router, ProviderContainer container) {
    _router = router;
    _container = container;

    _channel.setMethodCallHandler(_handleMethodCall);

    // Notify Android that Flutter is ready
    _channel.invokeMethod('flutterReady');

    // Test method channel communication
    _channel
        .invokeMethod('test')
        .then((result) {
          print('DEBUG: Method channel test successful');
        })
        .catchError((error) {
          print('DEBUG: Method channel test failed: $error');
        });

    print('DEBUG: AndroidBackButtonService initialized');
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    print('DEBUG: AndroidBackButtonService received method call: ${call.method}');

    if (call.method == 'onBackPressed') {
      print('DEBUG: Android back button event received via method channel');
      _handleBackButton();
    }
  }

  static void _handleBackButton() {
    print('DEBUG: _handleBackButton called');
    print('DEBUG: _router is null: ${_router == null}');
    print('DEBUG: _container is null: ${_container == null}');

    if (_router == null || _container == null) {
      print('DEBUG: Router or container not available');
      return;
    }

    final context = _router!.routerDelegate.navigatorKey.currentContext;
    print('DEBUG: Context is null: ${context == null}');
    if (context == null) {
      print('DEBUG: Context not available');
      return;
    }

    try {
      print('DEBUG: About to get location...');
      final location = _router!.routerDelegate.currentConfiguration.uri.path;
      print('DEBUG: Got location: $location');

      print('DEBUG: About to get navigation history...');
      final navigationHistory = _container!.read(navigationHistoryProvider);
      print('DEBUG: Got navigation history: $navigationHistory');

      print('DEBUG: About to get stack size...');
      final stackSize = _container!.read(navigationHistoryProvider.notifier).stackSize;
      print('DEBUG: Got stack size: $stackSize');

      print('DEBUG: Android back button pressed at location: $location');
      print('DEBUG: Stack size: $stackSize');
      print('DEBUG: Navigation history: $navigationHistory');

      // Stack-based navigation: pop current route and navigate to top of stack
      if (stackSize > 1) {
        print('DEBUG: Popping current route from stack');
        _container!.read(navigationHistoryProvider.notifier).popRoute();

        final topRoute = _container!.read(navigationHistoryProvider.notifier).getTopRoute();
        print('DEBUG: Navigating to top of stack: $topRoute');

        if (topRoute != null) {
          context.go(topRoute);
        } else {
          print('DEBUG: No top route available, going to home');
          context.go('/home');
        }
      } else {
        // Stack has only one route, check if we're at a root level
        final rootRoutes = ['/home', '/venues', '/profile'];
        final isAtRoot = rootRoutes.any((route) => location == route || location.startsWith(route));

        if (isAtRoot) {
          print('DEBUG: At root level, showing exit confirmation');
          _showExitConfirmation(context);
        } else {
          print('DEBUG: No history, navigating to home');
          context.go('/home');
        }
      }
    } catch (e, stackTrace) {
      print('DEBUG: Error in _handleBackButton: $e');
      print('DEBUG: Stack trace: $stackTrace');
      return;
    }
  }

  static void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Exit the app
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
