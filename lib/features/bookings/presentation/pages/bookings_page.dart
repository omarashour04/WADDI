import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_providers.dart';
import '../../domain/entities/booking_entity.dart';

class BookingsPage extends ConsumerWidget {
  final String userId;
  const BookingsPage({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsForUserProvider(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, i) => _BookingCard(booking: bookings[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Venue: ${booking.venueId}'),
        subtitle: Text('Room: ${booking.roomId}\nStatus: ${booking.bookingStatus}'),
        trailing: Text('${booking.totalAmount} SAR'),
        onTap: () {
          // TODO: Navigate to booking details
        },
      ),
    );
  }
} 