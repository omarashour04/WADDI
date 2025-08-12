import 'package:flutter/material.dart';

/// A global error handler widget that displays errors consistently across the app
class GlobalErrorHandler extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onClear;
  final String? title;
  final IconData? icon;
  final Color? color;
  final bool showRetryButton;
  final bool showClearButton;

  const GlobalErrorHandler({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.onClear,
    this.title,
    this.icon,
    this.color,
    this.showRetryButton = true,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.error;
    final effectiveIcon = icon ?? Icons.error_outline;
    final effectiveTitle = title ?? 'Error';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            effectiveIcon,
            size: 64,
            color: effectiveColor,
          ),
          const SizedBox(height: 16),
          Text(
            effectiveTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: effectiveColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (showRetryButton && onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: effectiveColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          if (showClearButton && onClear != null) ...[
            if (showRetryButton && onRetry != null) const SizedBox(height: 8),
            TextButton(
              onPressed: onClear,
              child: Text(
                'Clear Error',
                style: TextStyle(color: effectiveColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A specialized error handler for network/connection issues
class NetworkErrorHandler extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onClear;

  const NetworkErrorHandler({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GlobalErrorHandler(
      errorMessage: errorMessage,
      onRetry: onRetry,
      onClear: onClear,
      title: 'Connection Error',
      icon: Icons.wifi_off,
      color: Colors.orange[600],
      showRetryButton: true,
      showClearButton: true,
    );
  }
}

/// A specialized error handler for permission/access issues
class PermissionErrorHandler extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onClear;

  const PermissionErrorHandler({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GlobalErrorHandler(
      errorMessage: errorMessage,
      onRetry: onRetry,
      onClear: onClear,
      title: 'Access Denied',
      icon: Icons.lock,
      color: Colors.red[600],
      showRetryButton: true,
      showClearButton: true,
    );
  }
}
