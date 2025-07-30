import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SmartBackButton extends StatelessWidget {
  final Color? color;
  final double? size;
  final VoidCallback? onPressed;

  const SmartBackButton({
    Key? key,
    this.color,
    this.size,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: color,
        size: size,
      ),
      onPressed: onPressed ?? () => _handleBackNavigation(context),
    );
  }

  void _handleBackNavigation(BuildContext context) {
    // Use standard back navigation like any normal app
    if (context.canPop()) {
      context.pop();
    } else {
      // If can't pop, go to home as fallback
      context.go('/home');
    }
  }
} 