import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../bookings/presentation/providers/booking_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class VenueOwnerBookingsPage extends ConsumerWidget {
  final String ownerId;
  const VenueOwnerBookingsPage({required this.ownerId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainScaffold(
      currentIndex: 1, // Bookings tab
      userId: ownerId,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Venue Bookings'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('venues')
              .where('ownerId', isEqualTo: ownerId)
              .snapshots(),
          builder: (context, venueSnapshot) {
            if (venueSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!venueSnapshot.hasData || venueSnapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No venues found'),
                    Text('Add venues to see bookings'),
                  ],
                ),
              );
            }

            final venues = venueSnapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final venueData = venues[index].data() as Map<String, dynamic>;
                final venueId = venues[index].id;
                final venueName = venueData['name'] ?? 'Unknown Venue';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(venueName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Venue ID: $venueId'),
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('bookings')
                            .where('venueId', isEqualTo: venueId)
                            .orderBy('startTime', descending: true)
                            .snapshots(),
                        builder: (context, bookingSnapshot) {
                          if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!bookingSnapshot.hasData || bookingSnapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No bookings found for this venue'),
                            );
                          }

                          final bookings = bookingSnapshot.data!.docs;

                          // Group bookings by room
                          final Map<String, List<QueryDocumentSnapshot>> bookingsByRoom =
                              <String, List<QueryDocumentSnapshot>>{};
                          for (final booking in bookings) {
                            final data = booking.data() as Map<String, dynamic>;
                            final roomId = data['roomId'] ?? 'Unknown Room';
                            bookingsByRoom
                                .putIfAbsent(roomId, () => <QueryDocumentSnapshot>[])
                                .add(booking);
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bookingsByRoom.length,
                            itemBuilder: (context, roomIndex) {
                              final roomId = bookingsByRoom.keys.elementAt(roomIndex);
                              final roomBookings = bookingsByRoom[roomId] ?? [];
                              final roomName = roomBookings.isNotEmpty
                                  ? (roomBookings.first.data()
                                            as Map<String, dynamic>)['roomName'] ??
                                        roomId
                                  : roomId;

                              return ExpansionTile(
                                title: Text(roomName),
                                subtitle: Text('${roomBookings.length} booking(s)'),
                                children: roomBookings.map((booking) {
                                  final data = booking.data() as Map<String, dynamic>;
                                  final bookingEntity = BookingEntity.fromMap(data, booking.id);

                                  return ListTile(
                                    title: Text('User: ${data['userId'] ?? 'Unknown'}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Date: ${_formatDate(bookingEntity.startTime)}'),
                                        Text(
                                          'Time: ${_formatTime(bookingEntity.startTime)} - ${_formatTime(bookingEntity.endTime)}',
                                        ),
                                        Text('Status: ${_getStatusText(bookingEntity.status)}'),
                                        Text(
                                          'Price: \$${bookingEntity.totalPrice.toStringAsFixed(2)}',
                                        ),
                                        if (data['notes'] != null && data['notes'].isNotEmpty)
                                          Text('Notes: ${data['notes']}'),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(bookingEntity.status),
                                          color: _getStatusColor(bookingEntity.status),
                                        ),
                                        if (bookingEntity.status == 'confirmed' && !bookingEntity.isCheckedIn &&
                                            DateTime.now().isBefore(bookingEntity.startTime.add(const Duration(minutes: 15))))
                                          IconButton(
                                            tooltip: 'Check in user',
                                            icon: const Icon(Icons.play_circle, color: Colors.green),
                                            onPressed: () async {
                                              final ownerId = ref.read(authProvider).user?.id ?? '';
                                              try {
                                                await ref.read(bookingStateProvider.notifier).ownerCheckIn(
                                                      bookingId: booking.id,
                                                      ownerUserId: ownerId,
                                                    );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('User checked in')),
                                                  );
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Check-in failed: $e')),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel, color: Colors.red),
                                          onPressed: () =>
                                              _cancelBooking(context, booking.reference),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      case 'in_progress':
        return Icons.play_circle;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelBooking(BuildContext context, DocumentReference bookingRef) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await bookingRef.update({'status': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()});
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Booking cancelled successfully')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error cancelling booking: $e')));
        }
      }
    }
  }
}
