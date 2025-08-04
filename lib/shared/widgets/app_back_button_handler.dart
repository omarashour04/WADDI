import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shared_providers.dart';

class AppBackButtonHandler extends ConsumerStatefulWidget {
  final Widget child;
  final String? fallbackRoute;

  const AppBackButtonHandler({super.key, required this.child, this.fallbackRoute});

  @override
  ConsumerState<AppBackButtonHandler> createState() => _AppBackButtonHandlerState();
}

class _AppBackButtonHandlerState extends ConsumerState<AppBackButtonHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('DEBUG: WillPopScope onWillPop called');
        _handleBackButton(context, ref);
        return false; // Prevent default back behavior
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          print('DEBUG: PopScope onPopInvoked called, didPop: $didPop');
          if (didPop) return;
          _handleBackButton(context, ref);
        },
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            print('DEBUG: Focus onKeyEvent called: ${event.logicalKey}');
            if (event.logicalKey == LogicalKeyboardKey.goBack) {
              print('DEBUG: Back key detected via Focus');
              _handleBackButton(context, ref);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: widget.child,
        ),
      ),
    );
  }

  @override
  Future<bool> didPopRoute() async {
    print('DEBUG: didPopRoute called - Android back button pressed');
    _handleBackButton(context, ref);
    return true; // Prevent default back behavior
  }

  void _handleBackButton(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final navigationHistory = ref.read(navigationHistoryProvider);
    final stackSize = ref.read(navigationHistoryProvider.notifier).stackSize;

    print('DEBUG: Back button pressed at location: $location');
    print('DEBUG: Stack size: $stackSize');
    print(
      'DEBUG: Navigation history summary: ${ref.read(navigationHistoryProvider.notifier).historySummary}',
    );

    // Stack-based navigation: pop current route and navigate to top of stack
    if (stackSize > 1) {
      print('DEBUG: Popping current route from stack');
      ref.read(navigationHistoryProvider.notifier).popRoute();

      final topRoute = ref.read(navigationHistoryProvider.notifier).getTopRoute();
      print('DEBUG: Navigating to top of stack: $topRoute');

      if (topRoute != null) {
        context.go(topRoute);
      } else {
        print('DEBUG: No top route available, going to home');
        context.go('/home');
      }
    } else {
      // Stack has only one route, check if we're at a root level
      final rootRoutes = ['/home', '/venues', '/profile', '/admin'];
      final isAtRoot = rootRoutes.any((route) => location == route || location.startsWith(route));

      if (isAtRoot) {
        print('DEBUG: At root level, showing exit confirmation');
        _showExitConfirmation(context);
      } else {
        print('DEBUG: No history, navigating to home');
        context.go('/home');
      }
    }

    // Periodically cleanup history to prevent memory issues
    if (stackSize > 40) {
      print('DEBUG: History getting large, performing cleanup');
      ref.read(navigationHistoryProvider.notifier).cleanupHistory();
    }
  }

  void _showExitConfirmation(BuildContext context) {
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
