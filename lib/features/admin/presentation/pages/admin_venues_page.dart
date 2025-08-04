import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class AdminVenuesPage extends ConsumerStatefulWidget {
  const AdminVenuesPage({super.key});

  @override
  ConsumerState<AdminVenuesPage> createState() => _AdminVenuesPageState();
}

class _AdminVenuesPageState extends ConsumerState<AdminVenuesPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 3, // Profile tab
      userId: '',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: const Text('Venue Management'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/admin'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Navigate to venue form page
                context.push('/admin/venues/add');
              },
              tooltip: 'Add New Venue',
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search venues...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pending', 'pending'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Approved', 'approved'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Rejected', 'rejected'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Venues List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('venues').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No venues found'),
                        ],
                      ),
                    );
                  }

                  // Filter venues based on search and status
                  final filteredVenues = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] as String?)?.toLowerCase() ?? '';
                    final status = data['status'] as String? ?? 'pending';
                    
                    final matchesSearch = name.contains(_searchQuery.toLowerCase());
                    final matchesStatus = _statusFilter == 'all' || status == _statusFilter;
                    
                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filteredVenues.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No venues match your search'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredVenues.length,
                    itemBuilder: (context, index) {
                      final doc = filteredVenues[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final venueId = doc.id;
                      final name = data['name'] as String? ?? 'Unknown Venue';
                      final description = data['description'] as String? ?? 'No description';
                      final status = data['status'] as String? ?? 'pending';
                      final ownerId = data['ownerId'] as String? ?? '';
                      final createdAt = data['createdAt'] as Timestamp?;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(status).withOpacity(0.1),
                            child: Icon(
                              Icons.store,
                              color: _getStatusColor(status),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Owner: ${ownerId.length > 8 ? '${ownerId.substring(0, 8)}...' : ownerId}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (createdAt != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Created: ${_formatDate(createdAt)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleMenuAction(value, venueId, data),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              if (status == 'pending') ...[
                                const PopupMenuItem(
                                  value: 'approve',
                                  child: Row(
                                    children: [
                                      Icon(Icons.check, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Approve'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'reject',
                                  child: Row(
                                    children: [
                                      Icon(Icons.close, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Reject'),
                                    ],
                                  ),
                                ),
                              ],
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete'),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleMenuAction(String action, String venueId, Map<String, dynamic> data) async {
    try {
      switch (action) {
        case 'view':
          // Navigate to venue details
          context.go('/venues/$venueId');
          break;
        case 'approve':
          await _approveVenue(venueId);
          break;
        case 'reject':
          await _rejectVenue(venueId);
          break;
        case 'edit':
          // Navigate to edit venue page
          context.go('/admin/venues/$venueId/edit');
          break;
        case 'delete':
          await _deleteVenue(venueId);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _approveVenue(String venueId) async {
    try {
      await FirebaseFirestore.instance
          .collection('venues')
          .doc(venueId)
          .update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venue approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      throw Exception('Failed to approve venue: $e');
    }
  }

  Future<void> _rejectVenue(String venueId) async {
    try {
      await FirebaseFirestore.instance
          .collection('venues')
          .doc(venueId)
          .update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venue rejected successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      throw Exception('Failed to reject venue: $e');
    }
  }

  Future<void> _deleteVenue(String venueId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Venue'),
        content: const Text('Are you sure you want to delete this venue? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('venues')
            .doc(venueId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venue deleted successfully!'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        throw Exception('Failed to delete venue: $e');
      }
    }
  }
} 