import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waddi_platform/shared/widgets/main_scaffold.dart';
import 'package:waddi_platform/shared/widgets/smart_back_button.dart';
import 'package:waddi_platform/shared/widgets/custom_button.dart';
import 'package:waddi_platform/shared/widgets/loading_indicator.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/shared/themes/app_typography.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/features/bookings/presentation/providers/booking_providers.dart';
import 'package:waddi_platform/shared/providers/shared_providers.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingsPage extends ConsumerWidget {
  final String userId;

  const BookingsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MainScaffold(
      currentIndex: 2,
      userId: userId,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SmartBackButton(),
                const SizedBox(width: 12),
                Text('My Bookings', style: AppTypography.headlineMedium),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final bookingsAsync = ref.watch(bookingsForUserProvider(userId));

                return RefreshIndicator(
                  onRefresh: () async {
                    // Invalidate the cache to refresh data
                    ref.invalidate(bookingsForUserProvider(userId));
                  },
                  child: bookingsAsync.when(
                    data: (bookings) {
                      if (bookings.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return _buildBookingCard(context, booking);
                        },
                      );
                    },
                    loading: () => Center(child: LoadingIndicator()),
                    error: (error, stack) => _buildErrorState(context, ref, error.toString()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No bookings yet', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Start exploring venues and make your first booking!',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(onPressed: () => context.go('/venues'), label: 'Browse Venues'),
              const SizedBox(width: 16),
              // Debug button to create test bookings
              if (kDebugMode)
                CustomButton(
                  onPressed: () => _createTestBookings(context),
                  label: 'Create Test Bookings',
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _createTestBookings(BuildContext context) {
    // Create test bookings for the current user
    final testBookings = [
      {
        'userId': userId,
        'venueId': 'Mr.Monkey',
        'roomId': 'Room 1',
        'startTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1, hours: 2))),
        'durationHours': 2,
        'roomFee': 25.0,
        'reservationFee': 5.0,
        'totalAmount': 30.0,
        'paymentStatus': 'paid',
        'bookingStatus': 'confirmed',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'userId': userId,
        'venueId': 'Plus Ninety',
        'roomId': 'Room 2',
        'startTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3, hours: 3))),
        'durationHours': 3,
        'roomFee': 35.0,
        'reservationFee': 5.0,
        'totalAmount': 40.0,
        'paymentStatus': 'pending',
        'bookingStatus': 'pending',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    ];

    // Add test bookings to Firestore
    for (final bookingData in testBookings) {
      FirebaseFirestore.instance.collection('bookings').add(bookingData);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test bookings created! Refresh the page to see them.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text('Something went wrong', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text(error, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: () => ref.refresh(bookingsForUserProvider(userId)),
            label: 'Try Again',
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, dynamic booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Venue ${booking.venueId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _buildStatusChip(context, booking.bookingStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text('Room: ${booking.roomId}', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              'Date: ${_formatDate(booking.startTime.toDate())}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Time: ${_formatTime(booking.startTime.toDate())} - ${_formatTime(booking.endTime.toDate())}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${booking.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                CustomButton(
                  onPressed: () => context.go('/booking-details/${booking.id}'),
                  label: 'View Details',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmed';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
