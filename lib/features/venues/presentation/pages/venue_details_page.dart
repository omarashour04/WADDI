import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/venue_providers.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../../reviews/presentation/providers/review_providers.dart';
import '../../../reviews/domain/entities/review_entity.dart';

class VenueDetailsPage extends ConsumerWidget {
  final String venueId;
  const VenueDetailsPage({required this.venueId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venueAsync = ref.watch(venueProvider(venueId));
    final roomsAsync = ref.watch(roomsForVenueProvider(venueId));
    final reviewsAsync = ref.watch(reviewsForVenueProvider(venueId));
    return Scaffold(
      appBar: AppBar(title: const Text('Venue Details')),
      body: venueAsync.when(
        data: (venue) {
          if (venue == null) return const Center(child: Text('Venue not found.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(venue.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(venue.description),
              const SizedBox(height: 16),
              // Images
              if (venue.images.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: venue.images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(venue.images[i], width: 240, height: 180, fit: BoxFit.cover),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Amenities
              if (venue.amenities != null && venue.amenities!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: venue.amenities!.map((a) => Chip(label: Text(a))).toList(),
                ),
              const SizedBox(height: 16),
              // Reviews
              Text('User Reviews', style: Theme.of(context).textTheme.titleMedium),
              reviewsAsync.when(
                data: (reviews) => reviews.isEmpty
                    ? const Text('No reviews yet.')
                    : Column(
                        children: reviews
                            .map((r) => ListTile(
                                  leading: const Icon(Icons.star, color: Colors.amber),
                                  title: Text(r.comment),
                                  subtitle: Text('Rating: ${r.rating}'),
                                ))
                            .toList(),
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error loading reviews: $e'),
              ),
              const SizedBox(height: 24),
              // Rooms
              Text('Rooms', style: Theme.of(context).textTheme.titleMedium),
              roomsAsync.when(
                data: (rooms) => rooms.isEmpty
                    ? const Text('No rooms available.')
                    : Column(
                        children: rooms
                            .map((room) => _RoomCard(
                                  room: room,
                                  venueId: venueId,
                                ))
                            .toList(),
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error loading rooms: $e'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomEntity room;
  final String venueId;
  const _RoomCard({required this.room, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(room.name),
        subtitle: Text('Capacity: ${room.capacity}\nPrice: ${room.hourlyPrice} SAR/hr'),
        trailing: ElevatedButton(
          onPressed: () {
            // TODO: Navigate to booking flow for this room
          },
          child: const Text('Book'),
        ),
      ),
    );
  }
} 