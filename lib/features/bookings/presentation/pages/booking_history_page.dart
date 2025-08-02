import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_providers.dart';
import '../../domain/entities/booking_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingHistoryPage extends ConsumerWidget {
  final String userId;
  const BookingHistoryPage({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsForUserProvider(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Booking History')),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const _EmptyState(message: 'No bookings found. Book your first venue!');
          }
          bookings.sort((a, b) => a.startTime.compareTo(b.startTime));
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, i) => _BookingHistoryCard(booking: bookings[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _ErrorState(
          message: 'Something went wrong. Please try again.',
          onRetry: () => ref.refresh(bookingsForUserProvider(userId)),
        ),
      ),
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  final BookingEntity booking;
  const _BookingHistoryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = booking.startTime.isAfter(DateTime.now());
    return Semantics(
      label: 'Booking card for room ${booking.roomId}, status ${booking.status}',
      button: true,
      child: Card(
        child: ListTile(
          title: Text(
            'Room: ${booking.roomId}',
            style: Theme.of(context).textTheme.titleMedium,
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          subtitle: Text(
            'Date: ${booking.startTime}\nStatus: ${booking.actualStatus}',
            style: Theme.of(context).textTheme.bodyMedium,
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          trailing: isUpcoming
              ? TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Booking'),
                        content: const Text('Are you sure you want to cancel this booking?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection('bookings')
                          .doc(booking.id)
                          .update({'bookingStatus': 'cancelled', 'updatedAt': Timestamp.now()});
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
                    }
                  },
                  child: const Text('Cancel', semanticsLabel: 'Cancel booking'),
                )
              : null,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Booking Details'),
                content: Text(
                  'Room: ${booking.roomId}\nVenue: ${booking.venueId}\nDate: ${booking.startTime}\nDuration: ${booking.durationHours}h\nTotal: ${booking.totalPrice} EGP\nStatus: ${booking.actualStatus}',
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  const _EmptyState({required this.message, this.onAction, this.actionLabel});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          if (onAction != null && actionLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                onPressed: onAction,
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorState({required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[700]),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: onRetry,
              ),
            ),
        ],
      ),
    );
  }
}
