import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waddi_platform/shared/widgets/main_scaffold.dart';
import 'package:waddi_platform/shared/widgets/smart_back_button.dart';
import 'package:waddi_platform/shared/widgets/custom_button.dart';
import 'package:waddi_platform/shared/widgets/custom_text_field.dart';
import 'package:waddi_platform/shared/widgets/loading_indicator.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/shared/themes/app_typography.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/features/venues/presentation/providers/venue_providers.dart';
import 'package:waddi_platform/shared/providers/shared_providers.dart';
import '../../domain/entities/room_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/bookings/presentation/pages/booking_flow_page.dart';

class RoomsPage extends ConsumerStatefulWidget {
  final String venueId;
  const RoomsPage({required this.venueId, super.key});

  @override
  ConsumerState<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends ConsumerState<RoomsPage> {
  RoomEntity? selectedRoom;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsForVenueProvider(widget.venueId));
    final venueAsync = ref.watch(venueProvider(widget.venueId));
    final authState = ref.watch(authProvider);

    // Update navigation state
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(navigationStateProvider.notifier).updateCurrentRoute('/venues/${widget.venueId}/rooms');
    // });
    final userId = authState.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Select Room'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              context.pop();
            } catch (e) {
              // If pop fails, navigate to venues page
              context.go('/venues');
            }
          },
        ),
      ),
      body: venueAsync.when(
        data: (venue) {
          if (venue == null) {
            return const Center(child: Text('Venue not found'));
          }

          return roomsAsync.when(
            data: (rooms) {
              if (rooms.isEmpty) {
                return const _EmptyState(message: 'No rooms found for this venue.');
              }
              return Column(
                children: [
                  // Available Rooms Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Available Rooms',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Rooms List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: rooms.length,
                      itemBuilder: (context, i) {
                        final room = rooms[i];
                        final isSelected = selectedRoom?.id == room.id;
                        return _RoomCard(
                          room: room,
                          venueId: widget.venueId,
                          venueName: venue.name,
                          isSelected: isSelected,
                          onSelect: () {
                            setState(() {
                              selectedRoom = room;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: selectedRoom != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Check if user is a guest user
                  if (authState.isGuestUser) {
                    // Show dialog to redirect to login
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Login Required'),
                        content: const Text(
                          'Guest users cannot make bookings. Please log in to continue.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.push('/login');
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  // Navigate to booking flow for authenticated users
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingFlowPage(venueId: widget.venueId, roomId: selectedRoom!.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textOnSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Confirm Selection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomEntity room;
  final String venueId;
  final String venueName;
  final bool isSelected;
  final VoidCallback onSelect;

  const _RoomCard({
    required this.room,
    required this.venueId,
    required this.venueName,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
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
          // Room Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              color: AppColors.primaryLight,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _getRoomImage(room.name),
            ),
          ),
          // Room Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Popular Badge
                if (room.name.toLowerCase().contains('arena'))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Most Popular',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (room.name.toLowerCase().contains('arena')) const SizedBox(height: 8),
                // Room Name
                Text(
                  room.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Room Description
                Text(
                  _getRoomDescription(room.name),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Select Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${room.hourlyPrice} EGP/hr',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to booking form
                        final queryParams = {
                          'venueId': venueId,
                          'venueName': venueName,
                          'roomId': room.id,
                          'roomName': room.name,
                          'hourlyPrice': room.hourlyPrice.toString(),
                        };

                        final uri = Uri(path: '/book-room', queryParameters: queryParams);
                        context.push(uri.toString());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Book Now'),
                          SizedBox(width: 4),
                          Icon(Icons.book_online, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getRoomImage(String roomName) {
    // Use a placeholder icon instead of hardcoded assets
    return Container(
      color: AppColors.primaryLight,
      child: const Icon(Icons.games, size: 60, color: Colors.white),
    );
  }

  String _getRoomDescription(String roomName) {
    if (roomName.toLowerCase().contains('arena')) {
      return 'Large, open space with multiple gaming stations. Ideal for groups and tournaments.';
    } else if (roomName.toLowerCase().contains('vault')) {
      return 'Private room with high-end PCs and consoles. Perfect for serious gamers.';
    } else {
      return 'Comfortable area with couches and TVs. Great for casual gaming and watching streams.';
    }
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
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          if (onAction != null && actionLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[600]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}
