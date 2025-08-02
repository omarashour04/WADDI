import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class VenueOwnerBookingsPage extends ConsumerWidget {
  final String ownerId;
  const VenueOwnerBookingsPage({required this.ownerId, Key? key}) : super(key: key);

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
                            .collection('venues')
                            .doc(venueId)
                            .collection('rooms')
                            .snapshots(),
                        builder: (context, roomSnapshot) {
                          if (roomSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!roomSnapshot.hasData || roomSnapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No rooms found in this venue'),
                            );
                          }

                          final rooms = roomSnapshot.data!.docs;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: rooms.length,
                            itemBuilder: (context, roomIndex) {
                              final roomId = rooms[roomIndex].id;
                              final roomData = rooms[roomIndex].data() as Map<String, dynamic>;
                              final roomName = roomData['name'] ?? 'Unknown Room';

                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('venues')
                                    .doc(venueId)
                                    .collection('rooms')
                                    .doc(roomId)
                                    .collection('bookings')
                                    .orderBy('date', descending: true)
                                    .snapshots(),
                                builder: (context, bookingSnapshot) {
                                  if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                                    return const SizedBox();
                                  }

                                  if (!bookingSnapshot.hasData ||
                                      bookingSnapshot.data!.docs.isEmpty) {
                                    return const SizedBox();
                                  }

                                  final bookings = bookingSnapshot.data!.docs;
                                  return ExpansionTile(
                                    title: Text(roomName),
                                    subtitle: Text('${bookings.length} booking(s)'),
                                    children: bookings.map((booking) {
                                      final bookingData = booking.data() as Map<String, dynamic>;
                                      final bookingDate = bookingData['date'] ?? '';
                                      final timeSlot = bookingData['timeSlot'] ?? '';
                                      final userId = bookingData['userId'] ?? '';
                                      final status = bookingData['status'] ?? 'confirmed';

                                      return ListTile(
                                        title: Text('Date: $bookingDate'),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Time: $timeSlot'),
                                            Text('User: $userId'),
                                            Text('Status: $status'),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getStatusIcon(status),
                                              color: _getStatusColor(status),
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
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
        await bookingRef.update({'status': 'cancelled'});
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
