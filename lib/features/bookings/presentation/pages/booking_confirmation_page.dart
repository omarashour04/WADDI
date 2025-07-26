import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';

class BookingConfirmationPage extends ConsumerWidget {
  final String bookingId;
  final String venueName;
  final String roomName;
  final DateTime bookingDate;
  final int durationHours;
  final double totalPrice;

  const BookingConfirmationPage({
    super.key,
    required this.bookingId,
    required this.venueName,
    required this.roomName,
    required this.bookingDate,
    required this.durationHours,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: Container(
        color: AppColors.backgroundLight,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.go('/venues'),
                  ),
                  Expanded(
                    child: Text(
                      'Booking Confirmed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Confirmation Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 60),
                    ),

                    const SizedBox(height: 24),

                    // Success Message
                    Text(
                      'Your booking is confirmed!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Thank you for your reservation. Your booking details are below, and a confirmation email has been sent to your registered email address.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Booking Details
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Details',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Booking Details Grid
                          _BookingDetailRow(label: 'Booking ID', value: '#$bookingId'),
                          _BookingDetailRow(label: 'Venue', value: venueName),
                          _BookingDetailRow(label: 'Room', value: roomName),
                          _BookingDetailRow(
                            label: 'Date & Time',
                            value: _formatDateTime(bookingDate, durationHours),
                          ),
                          _BookingDetailRow(
                            label: 'Duration',
                            value: '$durationHours hour${durationHours > 1 ? 's' : ''}',
                          ),
                          _BookingDetailRow(
                            label: 'Total Price',
                            value: 'SAR ${totalPrice.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    Column(
                      children: [
                        // View Booking Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to booking details
                              context.go('/booking-details/$bookingId');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.textOnSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'View Booking',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Add to Calendar Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Add to calendar functionality
                              _addToCalendar(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add to Calendar',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Back to Home Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              context.go('/venues');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Back to Home',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date, int durationHours) {
    final startTime = date;
    final endTime = date.add(Duration(hours: durationHours));

    final dateFormat = '${_getMonthName(startTime.month)} ${startTime.day}, ${startTime.year}';
    final startTimeFormat =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeFormat =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    return '$dateFormat, $startTimeFormat - $endTimeFormat';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _addToCalendar(BuildContext context) {
    // Show a snackbar for now - in a real app, this would integrate with calendar APIs
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calendar integration coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _BookingDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _BookingDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
