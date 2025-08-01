import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/smart_back_button.dart';

class VenueBookingsPage extends StatelessWidget {
  final String venueId;
  const VenueBookingsPage({required this.venueId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue Bookings'),
        leading: SmartBackButton(),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return const Center(child: Text('No rooms found.'));
          }
          final rooms = roomSnapshot.data!.docs;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, i) {
              final roomId = rooms[i].id;
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('venues')
                    .doc(venueId)
                    .collection('rooms')
                    .doc(roomId)
                    .collection('bookings')
                    .snapshots(),
                builder: (context, bookingSnapshot) {
                  if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  if (!bookingSnapshot.hasData || bookingSnapshot.data!.docs.isEmpty) {
                    return const SizedBox();
                  }
                  final bookings = bookingSnapshot.data!.docs;
                  return ExpansionTile(
                    title: Text('Room: ${rooms[i]['name'] ?? roomId}'),
                    children: bookings.map((b) {
                      final data = b.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text('User: ${data['userId'] ?? ''}'),
                        subtitle: Text('Date: ${data['date'] ?? ''} | Time: ${data['timeSlot'] ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () async {
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
                              await b.reference.delete();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
                            }
                          },
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
    );
  }
} 