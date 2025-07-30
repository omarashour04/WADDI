import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../venues/domain/entities/venue_entity.dart';
import 'venue_form_page.dart';
import 'room_management_page.dart';
import 'venue_bookings_page.dart';
import 'venue_reports_page.dart';
import '../../../../shared/themes/app_colors.dart';

class VenueOwnerDashboardPage extends ConsumerWidget {
  final String ownerId;
  const VenueOwnerDashboardPage({required this.ownerId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).bottomNavigationBarTheme.backgroundColor
            : AppColors.primary,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.textOnPrimary,
        title: const Text('My Venues'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('venues')
              .where('ownerId', isEqualTo: ownerId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(context);
            }
            
            final venues = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: venues.length,
              itemBuilder: (context, i) {
                final data = venues[i].data() as Map<String, dynamic>;
                final venueId = venues[i].id;
                return _buildVenueCard(context, data, venueId);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/venue-owner/venue-form?ownerId=$ownerId'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add),
        tooltip: 'Add Venue',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Venues Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first venue',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/venue-owner/venue-form?ownerId=$ownerId'),
            icon: const Icon(Icons.add),
            label: const Text('Add Venue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(BuildContext context, Map<String, dynamic> data, String venueId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Venue Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.business,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          // Venue Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['name'] ?? 'Venue',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(context, value, venueId),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit Venue')),
                        const PopupMenuItem(value: 'rooms', child: Text('Manage Rooms')),
                        const PopupMenuItem(value: 'bookings', child: Text('View Bookings')),
                        const PopupMenuItem(value: 'reports', child: Text('Reports')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data['address'] ?? 'No address',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/venue-owner/rooms/$venueId'),
                        icon: const Icon(Icons.meeting_room),
                        label: const Text('Rooms'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/venue-owner/bookings/$venueId'),
                        icon: const Icon(Icons.book_online),
                        label: const Text('Bookings'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, String venueId) {
    switch (action) {
      case 'edit':
        context.go('/venue-owner/venue-form?ownerId=$ownerId&venueId=$venueId');
        break;
      case 'rooms':
        context.go('/venue-owner/rooms/$venueId');
        break;
      case 'bookings':
        context.go('/venue-owner/bookings/$venueId');
        break;
      case 'reports':
        context.go('/venue-owner/reports/$venueId');
        break;
      case 'delete':
        _deleteVenue(context, venueId);
        break;
    }
  }

  void _deleteVenue(BuildContext context, String venueId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Venue'),
        content: const Text('Are you sure you want to delete this venue? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('venues').doc(venueId).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Venue deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting venue: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
} 