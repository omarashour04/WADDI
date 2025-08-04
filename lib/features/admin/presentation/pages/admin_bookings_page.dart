import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class AdminBookingsPage extends ConsumerStatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  ConsumerState<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends ConsumerState<AdminBookingsPage> {
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
          title: const Text('Booking Management'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/admin'),
          ),
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
                      hintText: 'Search bookings...',
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
                  const SizedBox(height: 16),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pending', 'pending'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Confirmed', 'confirmed'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Completed', 'completed'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Cancelled', 'cancelled'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bookings List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_online_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No bookings found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter bookings based on search and status
                  final filteredBookings = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['bookingStatus'] as String? ?? 'pending';
                    final searchLower = _searchQuery.toLowerCase();
                    
                    // Status filter
                    if (_statusFilter != 'all' && status != _statusFilter) {
                      return false;
                    }
                    
                    // Search filter
                    if (_searchQuery.isNotEmpty) {
                      final bookingId = doc.id.toLowerCase();
                      final userId = (data['userId'] as String? ?? '').toLowerCase();
                      final roomId = (data['roomId'] as String? ?? '').toLowerCase();
                      
                      return bookingId.contains(searchLower) ||
                             userId.contains(searchLower) ||
                             roomId.contains(searchLower);
                    }
                    
                    return true;
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final doc = filteredBookings[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final bookingId = doc.id;
                      final status = data['bookingStatus'] as String? ?? 'pending';
                      final userId = data['userId'] as String? ?? '';
                      final roomId = data['roomId'] as String? ?? '';
                      final startTime = data['startTime'] as Timestamp?;
                      final endTime = data['endTime'] as Timestamp?;
                      final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
                      final createdAt = data['createdAt'] as Timestamp?;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.book_online,
                              color: _getStatusColor(status),
                            ),
                          ),
                          title: Text(
                            'Booking: $bookingId',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('User: ${userId.length > 20 ? '${userId.substring(0, 20)}...' : userId}'),
                              Text('Room: $roomId'),
                              if (startTime != null && endTime != null) ...[
                                Text('Time: ${_formatDateTime(startTime)} - ${_formatTime(endTime)}'),
                              ],
                              Text('Amount: \$${totalAmount.toStringAsFixed(2)}'),
                              Text('Status: ${status.toUpperCase()}'),
                              if (createdAt != null) ...[
                                Text('Created: ${_formatDate(createdAt)}'),
                              ],
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleMenuAction(value, bookingId, data),
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
                                  value: 'confirm',
                                  child: Row(
                                    children: [
                                      Icon(Icons.check, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Confirm'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'cancel',
                                  child: Row(
                                    children: [
                                      Icon(Icons.close, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Cancel'),
                                    ],
                                  ),
                                ),
                              ],
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
          _statusFilter = selected ? value : 'all';
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action, String bookingId, Map<String, dynamic> data) {
    switch (action) {
      case 'view':
        // Show booking details
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Booking Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: $bookingId'),
                Text('User: ${data['userId'] ?? 'N/A'}'),
                Text('Room: ${data['roomId'] ?? 'N/A'}'),
                Text('Status: ${data['bookingStatus'] ?? 'N/A'}'),
                Text('Amount: \$${(data['totalAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                if (data['startTime'] != null)
                  Text('Start: ${_formatDateTime(data['startTime'])}'),
                if (data['endTime'] != null)
                  Text('End: ${_formatDateTime(data['endTime'])}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
        break;
      case 'confirm':
        _confirmBooking(bookingId);
        break;
      case 'cancel':
        _cancelBooking(bookingId);
        break;
      case 'delete':
        _deleteBooking(bookingId);
        break;
    }
  }

  Future<void> _confirmBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'bookingStatus': 'confirmed',
        'updatedAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming booking: $e')),
      );
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'bookingStatus': 'cancelled',
        'updatedAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking cancelled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling booking: $e')),
      );
    }
  }

  Future<void> _deleteBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Booking'),
        content: Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting booking: $e')),
        );
      }
    }
  }
} 