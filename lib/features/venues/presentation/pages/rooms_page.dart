import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/venue_providers.dart';
import '../../domain/entities/room_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/features/bookings/presentation/pages/booking_flow_page.dart';

class RoomsPage extends ConsumerWidget {
  final String venueId;
  const RoomsPage({required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsForVenueProvider(venueId));
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const _EmptyState(message: 'No rooms found for this venue.');
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, i) => _RoomCard(room: rooms[i], userId: userId, venueId: venueId),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _ErrorState(
          message: 'Something went wrong. Please try again.',
          onRetry: () => ref.refresh(roomsForVenueProvider(venueId)),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomEntity room;
  final String userId;
  final String venueId;
  const _RoomCard({required this.room, required this.userId, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Room card for ${room.name}, capacity ${room.capacity}, price ${room.hourlyPrice} SAR per hour',
      button: true,
      child: Card(
        child: ListTile(
          title: Text(
            room.name,
            style: Theme.of(context).textTheme.titleMedium,
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          subtitle: Text(
            'Capacity: ${room.capacity}\nPrice: ${room.hourlyPrice} SAR/hr',
            style: Theme.of(context).textTheme.bodyMedium,
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          onTap: () async {
            // Navigate to booking flow page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BookingFlowPage(
                  venueId: venueId,
                  roomId: room.id,
                  hourlyPrice: room.hourlyPrice,
                  userId: userId,
                ),
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
          Icon(Icons.meeting_room, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
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
          Text(message, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[700])),
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