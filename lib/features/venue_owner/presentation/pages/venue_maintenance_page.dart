import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/smart_back_button.dart';

class VenueMaintenancePage extends StatefulWidget {
  final String venueId;
  const VenueMaintenancePage({required this.venueId, super.key});

  @override
  State<VenueMaintenancePage> createState() => _VenueMaintenancePageState();
}

class _VenueMaintenancePageState extends State<VenueMaintenancePage> {
  bool isVenueClosedForMaintenance = false;
  Map<String, bool> roomMaintenanceStatus = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceStatus();
  }

  Future<void> _loadMaintenanceStatus() async {
    try {
      setState(() => isLoading = true);
      
      // Load venue maintenance status
      final venueDoc = await FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.venueId)
          .get();
      
      if (venueDoc.exists) {
        final venueData = venueDoc.data()!;
        isVenueClosedForMaintenance = venueData['isClosedForMaintenance'] ?? false;
      }

      // Load room maintenance status
      final roomsSnapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.venueId)
          .collection('rooms')
          .get();

      for (final roomDoc in roomsSnapshot.docs) {
        final roomData = roomDoc.data();
        roomMaintenanceStatus[roomDoc.id] = roomData['isClosedForMaintenance'] ?? false;
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        error = 'Failed to load maintenance status: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateVenueMaintenanceStatus(bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.venueId)
          .update({
        'isClosedForMaintenance': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() => isVenueClosedForMaintenance = value);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value 
              ? 'Venue marked as closed for maintenance' 
              : 'Venue marked as open'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating venue status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateRoomMaintenanceStatus(String roomId, bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.venueId)
          .collection('rooms')
          .doc(roomId)
          .update({
        'isClosedForMaintenance': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() => roomMaintenanceStatus[roomId] = value);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value 
              ? 'Room marked as closed for maintenance' 
              : 'Room marked as open'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating room status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Status'),
        leading: SmartBackButton(),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error loading maintenance status'),
                      const SizedBox(height: 8),
                      Text(error!, style: TextStyle(color: Colors.red[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMaintenanceStatus,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue Maintenance Status
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    color: isVenueClosedForMaintenance ? Colors.orange : Colors.green,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Venue Status',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          isVenueClosedForMaintenance 
                                            ? 'Closed for Maintenance' 
                                            : 'Open for Business',
                                          style: TextStyle(
                                            color: isVenueClosedForMaintenance ? Colors.orange[700] : Colors.green[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isVenueClosedForMaintenance,
                                    onChanged: _updateVenueMaintenanceStatus,
                                    activeColor: Colors.orange,
                                  ),
                                ],
                              ),
                              if (isVenueClosedForMaintenance)
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Venue is currently closed for maintenance. Users will not be able to book any rooms.',
                                          style: TextStyle(color: Colors.orange[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Room Maintenance Status
                      Text(
                        'Room Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (roomMaintenanceStatus.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No Rooms Found',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add rooms to your venue to manage their maintenance status.',
                                  style: TextStyle(color: Colors.grey[500]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...roomMaintenanceStatus.entries.map((entry) {
                          final roomId = entry.key;
                          final isClosed = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                Icons.meeting_room,
                                color: isClosed ? Colors.orange : Colors.green,
                              ),
                              title: Text('Room: $roomId'),
                              subtitle: Text(
                                isClosed ? 'Closed for Maintenance' : 'Open for Booking',
                                style: TextStyle(
                                  color: isClosed ? Colors.orange[700] : Colors.green[700],
                                ),
                              ),
                              trailing: Switch(
                                value: isClosed,
                                onChanged: (value) => _updateRoomMaintenanceStatus(roomId, value),
                                activeColor: Colors.orange,
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
} 