import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/booking_providers.dart';
import '../../domain/entities/booking_entity.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/shared/widgets/main_scaffold.dart';

class BookingsPage extends ConsumerWidget {
  final String userId;
  const BookingsPage({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsForUserProvider(userId));
    // Get userId from user provider if needed
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id ?? '';
    return MainScaffold(
      currentIndex: 2,
      userId: currentUserId,
      child: Scaffold(
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
          context.go('/booking-details/${booking.id}');
        },
      ),
    );
  }
}
