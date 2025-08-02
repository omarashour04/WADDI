import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class VenueOwnerMaintenancePage extends ConsumerWidget {
  final String ownerId;
  const VenueOwnerMaintenancePage({required this.ownerId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainScaffold(
      currentIndex: 3, // Maintenance tab
      userId: ownerId,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Venue Maintenance'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddMaintenanceDialog(context),
            ),
          ],
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
                    Icon(Icons.build_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No venues found'),
                    Text('Add venues to manage maintenance'),
                  ],
                ),
              );
            }

            final venues = venueSnapshot.data!.docs;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMaintenanceOverview(context, venues),
                const SizedBox(height: 24),
                _buildVenueMaintenanceList(context, venues),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaintenanceOverview(BuildContext context, List<QueryDocumentSnapshot> venues) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Overview',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getTotalMaintenanceRequests(venues),
                    builder: (context, snapshot) {
                      return _buildMaintenanceStatCard(
                        context,
                        'Total Requests',
                        snapshot.data?.toString() ?? '0',
                        Icons.build,
                        AppColors.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getPendingMaintenanceRequests(venues),
                    builder: (context, snapshot) {
                      return _buildMaintenanceStatCard(
                        context,
                        'Pending',
                        snapshot.data?.toString() ?? '0',
                        Icons.pending,
                        Colors.orange,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getCompletedMaintenanceRequests(venues),
                    builder: (context, snapshot) {
                      return _buildMaintenanceStatCard(
                        context,
                        'Completed',
                        snapshot.data?.toString() ?? '0',
                        Icons.check_circle,
                        Colors.green,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getUrgentMaintenanceRequests(venues),
                    builder: (context, snapshot) {
                      return _buildMaintenanceStatCard(
                        context,
                        'Urgent',
                        snapshot.data?.toString() ?? '0',
                        Icons.warning,
                        Colors.red,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueMaintenanceList(BuildContext context, List<QueryDocumentSnapshot> venues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Venue Maintenance',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...venues.map((venue) {
          final venueData = venue.data() as Map<String, dynamic>;
          final venueId = venue.id;
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
                      .collection('maintenance')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, maintenanceSnapshot) {
                    if (maintenanceSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!maintenanceSnapshot.hasData || maintenanceSnapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No maintenance requests for this venue'),
                      );
                    }

                    final maintenanceRequests = maintenanceSnapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: maintenanceRequests.length,
                      itemBuilder: (context, index) {
                        final request = maintenanceRequests[index];
                        final requestData = request.data() as Map<String, dynamic>;
                        final title = requestData['title'] ?? 'No Title';
                        final description = requestData['description'] ?? 'No Description';
                        final status = requestData['status'] ?? 'pending';
                        final priority = requestData['priority'] ?? 'normal';
                        final createdAt = requestData['createdAt'] as Timestamp?;
                        final assignedTo = requestData['assignedTo'] ?? 'Unassigned';

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(description),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildStatusChip(status),
                                    const SizedBox(width: 8),
                                    _buildPriorityChip(priority),
                                  ],
                                ),
                                if (createdAt != null)
                                  Text(
                                    'Created: ${createdAt.toDate().toString().split(' ')[0]}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                Text(
                                  'Assigned to: $assignedTo',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) =>
                                  _handleMaintenanceAction(context, request.reference, value),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'complete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.check),
                                      SizedBox(width: 8),
                                      Text('Mark Complete'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'in_progress':
        color = Colors.blue;
        label = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    String label;

    switch (priority.toLowerCase()) {
      case 'low':
        color = Colors.green;
        label = 'Low';
        break;
      case 'normal':
        color = Colors.blue;
        label = 'Normal';
        break;
      case 'high':
        color = Colors.orange;
        label = 'High';
        break;
      case 'urgent':
        color = Colors.red;
        label = 'Urgent';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _showAddMaintenanceDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'normal';
    String selectedVenue = '';

    // Get venues for dropdown
    final venuesSnapshot = await FirebaseFirestore.instance
        .collection('venues')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    final venues = venuesSnapshot.docs;
    if (venues.isNotEmpty) {
      selectedVenue = venues.first.id;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Maintenance Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedVenue.isEmpty ? null : selectedVenue,
                decoration: const InputDecoration(labelText: 'Venue'),
                items: venues.map((venue) {
                  final venueData = venue.data() as Map<String, dynamic>;
                  return DropdownMenuItem(
                    value: venue.id,
                    child: Text(venueData['name'] ?? 'Unknown Venue'),
                  );
                }).toList(),
                onChanged: (value) => selectedVenue = value ?? '',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (value) => selectedPriority = value ?? 'normal',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && selectedVenue.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('venues')
                    .doc(selectedVenue)
                    .collection('maintenance')
                    .add({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'priority': selectedPriority,
                      'status': 'pending',
                      'createdAt': FieldValue.serverTimestamp(),
                      'assignedTo': 'Unassigned',
                    });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Maintenance request added')));
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMaintenanceAction(
    BuildContext context,
    DocumentReference requestRef,
    String action,
  ) async {
    switch (action) {
      case 'edit':
        await _showEditMaintenanceDialog(context, requestRef);
        break;
      case 'complete':
        await requestRef.update({'status': 'completed'});
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Request marked as completed')));
        }
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Request'),
            content: const Text('Are you sure you want to delete this maintenance request?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await requestRef.delete();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Request deleted')));
          }
        }
        break;
    }
  }

  Future<void> _showEditMaintenanceDialog(
    BuildContext context,
    DocumentReference requestRef,
  ) async {
    // Get current request data
    final requestDoc = await requestRef.get();
    if (!requestDoc.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request not found')));
      }
      return;
    }

    final requestData = requestDoc.data() as Map<String, dynamic>;

    final titleController = TextEditingController(text: requestData['title'] ?? '');
    final descriptionController = TextEditingController(text: requestData['description'] ?? '');
    String priority = requestData['priority'] ?? 'medium';
    String status = requestData['status'] ?? 'pending';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Maintenance Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (value) => priority = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                onChanged: (value) => status = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
                return;
              }

              await requestRef.update({
                'title': titleController.text.trim(),
                'description': descriptionController.text.trim(),
                'priority': priority,
                'status': status,
                'updatedAt': FieldValue.serverTimestamp(),
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Maintenance request updated successfully')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<int> _getTotalMaintenanceRequests(List<QueryDocumentSnapshot> venues) async {
    int total = 0;
    for (final venue in venues) {
      final snapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(venue.id)
          .collection('maintenance')
          .get();
      total += snapshot.docs.length;
    }
    return total;
  }

  Future<int> _getPendingMaintenanceRequests(List<QueryDocumentSnapshot> venues) async {
    int total = 0;
    for (final venue in venues) {
      final snapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(venue.id)
          .collection('maintenance')
          .where('status', isEqualTo: 'pending')
          .get();
      total += snapshot.docs.length;
    }
    return total;
  }

  Future<int> _getCompletedMaintenanceRequests(List<QueryDocumentSnapshot> venues) async {
    int total = 0;
    for (final venue in venues) {
      final snapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(venue.id)
          .collection('maintenance')
          .where('status', isEqualTo: 'completed')
          .get();
      total += snapshot.docs.length;
    }
    return total;
  }

  Future<int> _getUrgentMaintenanceRequests(List<QueryDocumentSnapshot> venues) async {
    int total = 0;
    for (final venue in venues) {
      final snapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(venue.id)
          .collection('maintenance')
          .where('priority', isEqualTo: 'urgent')
          .get();
      total += snapshot.docs.length;
    }
    return total;
  }
}
