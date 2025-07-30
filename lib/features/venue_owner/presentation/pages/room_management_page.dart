import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'room_form_page.dart';

class RoomManagementPage extends StatelessWidget {
  final String venueId;
  const RoomManagementPage({required this.venueId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('venues')
            .doc(venueId)
            .collection('rooms')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No rooms found.'));
          }
          final rooms = snapshot.data!.docs;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, i) {
              final data = rooms[i].data() as Map<String, dynamic>;
              final roomId = rooms[i].id;
              return Card(
                child: ListTile(
                  title: Text(data['name'] ?? 'Room'),
                  subtitle: Text('Capacity: ${data['capacity'] ?? '-'} | Price: ${data['hourlyPrice'] ?? '-'} EGP'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoomFormPage(venueId: venueId, roomId: roomId),
                          ),
                        );
                      } else if (value == 'delete') {
                        _deleteRoom(context, venueId, roomId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoomFormPage(venueId: venueId),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Room',
      ),
    );
  }

  void _deleteRoom(BuildContext context, String venueId, String roomId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('venues').doc(venueId).collection('rooms').doc(roomId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room deleted.')));
    }
  }
} 