import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/widgets/smart_back_button.dart';
import '../../../bookings/domain/entities/booking_entity.dart';

class VenueBookingsPage extends StatelessWidget {
  final String venueId;
  const VenueBookingsPage({required this.venueId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venue Bookings'), leading: SmartBackButton()),
      body: StreamBuilder<QuerySnapshot>(
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No bookings found for this venue'),
                ],
              ),
            );
          }

          final bookings = bookingSnapshot.data!.docs;

          // Group bookings by room
          final Map<String, List<QueryDocumentSnapshot>> bookingsByRoom =
              <String, List<QueryDocumentSnapshot>>{};
          for (final booking in bookings) {
            final data = booking.data() as Map<String, dynamic>;
            final roomId = data['roomId'] ?? 'Unknown Room';
            bookingsByRoom.putIfAbsent(roomId, () => <QueryDocumentSnapshot>[]).add(booking);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookingsByRoom.length,
            itemBuilder: (context, index) {
              final roomId = bookingsByRoom.keys.elementAt(index);
              final roomBookings = bookingsByRoom[roomId] ?? [];

              return ExpansionTile(
                title: Text(
                  'Room: ${roomBookings.isNotEmpty ? (roomBookings.first.data() as Map<String, dynamic>)['roomName'] ?? roomId : roomId}',
                ),
                subtitle: Text(
                  '${roomBookings.length} booking${roomBookings.length == 1 ? '' : 's'}',
                ),
                children: roomBookings.map((booking) {
                  final data = booking.data() as Map<String, dynamic>;
                  final bookingEntity = BookingEntity.fromMap(data, booking.id);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text('User: ${data['userId'] ?? 'Unknown'}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${_formatDate(bookingEntity.startTime)}'),
                          Text(
                            'Time: ${_formatTime(bookingEntity.startTime)} - ${_formatTime(bookingEntity.endTime)}',
                          ),
                          Text('Status: ${_getStatusText(bookingEntity.status)}'),
                          Text('Price: \$${bookingEntity.totalPrice.toStringAsFixed(2)}'),
                          if (data['notes'] != null && data['notes'].isNotEmpty)
                            Text('Notes: ${data['notes']}'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'cancel') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Cancel Booking'),
                                content: const Text(
                                  'Are you sure you want to cancel this booking?',
                                ),
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
                              try {
                                await booking.reference.update({
                                  'status': 'cancelled',
                                  'updatedAt': FieldValue.serverTimestamp(),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Booking cancelled successfully')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to cancel booking: $e')),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'cancel',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Cancel Booking'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
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
}
