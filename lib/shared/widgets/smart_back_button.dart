import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shared_providers.dart';

class SmartBackButton extends ConsumerWidget {
  final Color? color;
  final double? size;
  final VoidCallback? onPressed;

  const SmartBackButton({Key? key, this.color, this.size, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color, size: size),
      onPressed: onPressed ?? () => _handleBackNavigation(context, ref),
    );
  }

  void _handleBackNavigation(BuildContext context, WidgetRef ref) {
    final navigationHistory = ref.read(navigationHistoryProvider);

    // Stack-based navigation: pop current route and navigate to top of stack
    if (navigationHistory.length > 1) {
      // Use standard back navigation if possible
      if (context.canPop()) {
        context.pop();
      }
      
      // Pop current route from stack
      ref.read(navigationHistoryProvider.notifier).popRoute();
      
      // Navigate to top of stack
      final topRoute = ref.read(navigationHistoryProvider.notifier).getTopRoute();
      if (topRoute != null) {
        context.go(topRoute);
      } else {
        context.go('/home');
      }
    } else {
      // Stack has only one route, go to home
      context.go('/home');
      ref.read(navigationHistoryProvider.notifier).clearHistory();
    }
  }
}
