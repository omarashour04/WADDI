import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/smart_back_button.dart';

class RoomManagementPage extends StatelessWidget {
  final String venueId;
  const RoomManagementPage({required this.venueId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        leading: SmartBackButton(),
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Capacity: ${data['capacity'] ?? '-'} | Price: ${data['hourlyPrice'] ?? '-'} EGP'),
                      if (data['isClosedForMaintenance'] == true)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.engineering, size: 12, color: Colors.orange[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Under Maintenance',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.go('/venue-owner/room-form?venueId=$venueId&roomId=$roomId');
                      } else if (value == 'delete') {
                        _deleteRoom(context, venueId, roomId);
                      } else if (value == 'qr') {
                        context.go('/venue-owner/room-qr?venueId=$venueId&roomId=$roomId');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      const PopupMenuItem(value: 'qr', child: Text('View/Print QR')),
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
          context.go('/venue-owner/room-form?venueId=$venueId');
        },
        tooltip: 'Add Room',
        child: const Icon(Icons.add),
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
      try {
        await FirebaseFirestore.instance.collection('venues').doc(venueId).collection('rooms').doc(roomId).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room deleted.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting room: $e')),
          );
        }
      }
    }
  }
} 