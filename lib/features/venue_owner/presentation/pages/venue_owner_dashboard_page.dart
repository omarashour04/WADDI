import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../venues/domain/entities/venue_entity.dart';
import 'venue_form_page.dart';
import 'room_management_page.dart';
import 'venue_bookings_page.dart';
import 'venue_reports_page.dart';

class VenueOwnerDashboardPage extends StatelessWidget {
  final String ownerId;
  const VenueOwnerDashboardPage({required this.ownerId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venue Owner Dashboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('venues')
            .where('ownerId', isEqualTo: ownerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No venues found.'));
          }
          final venues = snapshot.data!.docs;
          return ListView.builder(
            itemCount: venues.length,
            itemBuilder: (context, i) {
              final data = venues[i].data() as Map<String, dynamic>;
              final venueId = venues[i].id;
              return Card(
                child: ListTile(
                  title: Text(data['name'] ?? 'Venue'),
                  subtitle: Text(data['address'] ?? ''),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VenueFormPage(ownerId: ownerId, venueId: venueId),
                          ),
                        );
                      } else if (value == 'delete') {
                        _deleteVenue(context, venueId);
                      } else if (value == 'rooms') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoomManagementPage(venueId: venueId),
                          ),
                        );
                      } else if (value == 'bookings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VenueBookingsPage(venueId: venueId),
                          ),
                        );
                      } else if (value == 'reports') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VenueReportsPage(venueId: venueId),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      const PopupMenuItem(value: 'rooms', child: Text('Manage Rooms')),
                      const PopupMenuItem(value: 'bookings', child: Text('Bookings')),
                      const PopupMenuItem(value: 'reports', child: Text('Reports')),
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
              builder: (_) => VenueFormPage(ownerId: ownerId),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Venue',
      ),
    );
  }

  void _deleteVenue(BuildContext context, String venueId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Venue'),
        content: const Text('Are you sure you want to delete this venue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('venues').doc(venueId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venue deleted.')));
    }
  }
} 