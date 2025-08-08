import 'package:flutter/material.dart';
import '../services/offline_mode_service.dart';

class OfflineModeWidget extends StatelessWidget {
  final OfflineOperation operation;
  final Widget? child;
  final VoidCallback? onRetry;

  const OfflineModeWidget({
    super.key,
    required this.operation,
    this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: OfflineModeService.instance.connectivityStream,
      initialData: OfflineModeService.instance.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        if (isOnline || OfflineModeService.instance.isOperationAllowed(operation)) {
          return child ?? const SizedBox.shrink();
        }

        return _buildOfflineRestriction(context);
      },
    );
  }

  Widget _buildOfflineRestriction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Offline icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off,
              size: 40,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Offline Mode',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Message
          Text(
            OfflineModeService.instance.getOfflineMessage(operation),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Available offline features
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Available Offline:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildOfflineFeature(context, 'View your bookings'),
                _buildOfflineFeature(context, 'View booking details'),
                _buildOfflineFeature(context, 'View and edit profile'),
                _buildOfflineFeature(context, 'Access settings'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Retry button
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Check Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Manual retry text
          Text(
            'Pull down to refresh when connection is restored',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineFeature(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: Colors.blue[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to wrap any operation with offline mode check
class OfflineModeGuard extends StatelessWidget {
  final OfflineOperation operation;
  final Widget child;

  const OfflineModeGuard({
    super.key,
    required this.operation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OfflineModeWidget(
      operation: operation,
      child: child,
    );
  }
}

/// Widget to show offline status in app bar
class OfflineStatusBar extends StatelessWidget {
  const OfflineStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: OfflineModeService.instance.connectivityStream,
      initialData: OfflineModeService.instance.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.orange[100],
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                size: 16,
                color: Colors.orange[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You\'re offline. Some features may be limited.',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 