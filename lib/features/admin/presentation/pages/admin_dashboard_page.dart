import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainScaffold(
      currentIndex: 3, // Profile tab
      userId: '',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: const Text('Admin Dashboard'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/profile'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome, Admin!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your platform and monitor performance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Statistics Grid
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, usersSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('venues').snapshots(),
                    builder: (context, venuesSnapshot) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                        builder: (context, bookingsSnapshot) {
                          final totalUsers = usersSnapshot.data?.docs.length ?? 0;
                          final totalVenues = venuesSnapshot.data?.docs.length ?? 0;
                          final totalBookings = bookingsSnapshot.data?.docs.length ?? 0;
                          final totalRevenue = _calculateTotalRevenue(bookingsSnapshot.data?.docs ?? []);
                          
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            children: [
                              _buildStatCard(
                                context,
                                title: 'Total Users',
                                value: totalUsers.toString(),
                                icon: Icons.people,
                                color: Colors.blue,
                                onTap: () => context.go('/admin/users'),
                              ),
                              _buildStatCard(
                                context,
                                title: 'Total Venues',
                                value: totalVenues.toString(),
                                icon: Icons.store,
                                color: Colors.green,
                                onTap: () => context.go('/admin/venues'),
                              ),
                              _buildStatCard(
                                context,
                                title: 'Total Bookings',
                                value: totalBookings.toString(),
                                icon: Icons.book_online,
                                color: Colors.orange,
                                onTap: () => context.go('/admin/bookings'),
                              ),
                              _buildStatCard(
                                context,
                                title: 'Total Revenue',
                                value: '\$${totalRevenue.toStringAsFixed(0)}',
                                icon: Icons.attach_money,
                                color: Colors.purple,
                                onTap: () => context.go('/admin/analytics'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Action Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.people,
                    title: 'Manage Users',
                    subtitle: 'View and manage user accounts',
                    color: Colors.blue,
                    onTap: () => context.go('/admin/users'),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.store,
                    title: 'Manage Venues',
                    subtitle: 'Approve and manage venues',
                    color: Colors.green,
                    onTap: () => context.go('/admin/venues'),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.book_online,
                    title: 'Manage Bookings',
                    subtitle: 'View and manage bookings',
                    color: Colors.orange,
                    onTap: () => context.go('/admin/bookings'),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Analytics',
                    subtitle: 'View platform analytics',
                    color: Colors.purple,
                    onTap: () => context.go('/admin/analytics'),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.content_copy,
                    title: 'Content',
                    subtitle: 'Manage platform content',
                    color: Colors.teal,
                    onTap: () => context.go('/admin/content'),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Send broadcast notifications',
                    color: Colors.red,
                    onTap: () => context.go('/admin/notifications'),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .orderBy('createdAt', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('No recent activity'),
                    );
                  }
                  
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.book_online, color: Colors.blue),
                          title: Text('New booking created'),
                          subtitle: Text('Booking ID: ${doc.id}'),
                          trailing: Text(
                            _formatDate(data['createdAt'] as Timestamp?),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Database Maintenance Section
              Text(
                'Database Maintenance',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Database Schema',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add status field to existing venues and clean up guest users',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateVenuesWithStatus(context),
                              icon: const Icon(Icons.update),
                              label: const Text('Update Venues'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _cleanupGuestUsers(context),
                              icon: const Icon(Icons.cleaning_services),
                              label: const Text('Clean Guest Users'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalRevenue(List<QueryDocumentSnapshot> bookings) {
    double total = 0;
    for (final booking in bookings) {
      final data = booking.data() as Map<String, dynamic>;
      total += (data['totalAmount'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _updateVenuesWithStatus(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Updating venues with status field...'),
            ],
          ),
        ),
      );

      // Get all venues and update them
      final venuesRef = FirebaseFirestore.instance.collection('venues');
      final snapshot = await venuesRef.get();
      
      if (snapshot.docs.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No venues found to update')),
        );
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      int updatedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('status')) {
          batch.update(doc.reference, {
            'status': 'approved',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          updatedCount++;
        }
      }

      if (updatedCount > 0) {
        await batch.commit();
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully updated $updatedCount venues with status field'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All venues already have status field')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating venues: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cleanupGuestUsers(BuildContext context) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clean Up Guest Users'),
          content: const Text(
            'This will delete all guest users from the database. This action cannot be undone. Are you sure?'
          ),
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

      if (confirmed != true) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Cleaning up guest users...'),
            ],
          ),
        ),
      );

      // Get all guest users (users with empty email)
      final usersRef = FirebaseFirestore.instance.collection('users');
      final snapshot = await usersRef.where('email', isEqualTo: '').get();
      
      if (snapshot.docs.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No guest users found to clean up')),
        );
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      int deletedCount = 0;

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        deletedCount++;
      }

      await batch.commit();
      
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully deleted $deletedCount guest users'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cleaning up guest users: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 