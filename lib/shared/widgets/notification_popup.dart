import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class NotificationPopup extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onClose;
  final VoidCallback? onAction;
  final String? actionText;

  const NotificationPopup({
    super.key,
    required this.message,
    this.title,
    this.onClose,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title ?? 'New Message',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (onAction != null && actionText != null) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            actionText!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show notification popup
Future<void> showNotificationPopup({
  required BuildContext context,
  required String message,
  String? title,
  VoidCallback? onClose,
  VoidCallback? onAction,
  String? actionText,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => NotificationPopup(
      message: message,
      title: title,
      onClose: onClose ?? () => Navigator.of(context).pop(),
      onAction: onAction,
      actionText: actionText,
    ),
  );
} 