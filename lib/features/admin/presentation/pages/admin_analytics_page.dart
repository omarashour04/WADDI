import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class AdminAnalyticsPage extends ConsumerWidget {
  const AdminAnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainScaffold(
      currentIndex: 3, // Profile tab
      userId: '',
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: const Text('Analytics'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/admin'),
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
                      'Platform Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor your platform performance and revenue',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Revenue Overview
              Text(
                'Revenue Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final bookings = snapshot.data?.docs ?? [];
                  final totalRevenue = _calculateTotalRevenue(bookings);
                  final monthlyRevenue = _calculateMonthlyRevenue(bookings);
                  final totalBookings = bookings.length;
                  final confirmedBookings = bookings.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['bookingStatus'] == 'confirmed';
                  }).length;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          context,
                          title: 'Total Revenue',
                          value: '\$${totalRevenue.toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          context,
                          title: 'Monthly Revenue',
                          value: '\$${monthlyRevenue.toStringAsFixed(2)}',
                          icon: Icons.trending_up,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          context,
                          title: 'Total Bookings',
                          value: totalBookings.toString(),
                          icon: Icons.book_online,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          context,
                          title: 'Confirmed Bookings',
                          value: confirmedBookings.toString(),
                          icon: Icons.check_circle,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Recent Bookings
              Text(
                'Recent Bookings',
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

                  final bookings = snapshot.data?.docs ?? [];

                  if (bookings.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('No recent bookings'),
                    );
                  }

                  return Column(
                    children: bookings.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final bookingId = doc.id;
                      final status = data['bookingStatus'] as String? ?? 'pending';
                      final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
                      final createdAt = data['createdAt'] as Timestamp?;
                      final userId = data['userId'] as String? ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.book_online, color: _getStatusColor(status)),
                          ),
                          title: Text('Booking: ${bookingId.substring(0, 8)}...'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User: ${userId.length > 20 ? userId.substring(0, 20) + '...' : userId}',
                              ),
                              Text('Amount: \$${amount.toStringAsFixed(2)}'),
                              Text('Status: ${status.toUpperCase()}'),
                              if (createdAt != null) ...[
                                Text('Created: ${_formatDate(createdAt)}'),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Popular Venues
              Text(
                'Popular Venues',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('venues').snapshots(),
                builder: (context, venuesSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
                    builder: (context, bookingsSnapshot) {
                      if (venuesSnapshot.connectionState == ConnectionState.waiting ||
                          bookingsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final venues = venuesSnapshot.data?.docs ?? [];
                      final bookings = bookingsSnapshot.data?.docs ?? [];

                      // Calculate venue popularity based on bookings
                      final venueStats = <String, int>{};
                      for (final booking in bookings) {
                        final data = booking.data() as Map<String, dynamic>;
                        final venueId = data['venueId'] as String?;
                        if (venueId != null) {
                          venueStats[venueId] = (venueStats[venueId] ?? 0) + 1;
                        }
                      }

                      // Sort venues by popularity
                      final sortedVenues = venues.toList()
                        ..sort((a, b) {
                          final aBookings = venueStats[a.id] ?? 0;
                          final bBookings = venueStats[b.id] ?? 0;
                          return bBookings.compareTo(aBookings);
                        });

                      return Column(
                        children: sortedVenues.take(5).map((venue) {
                          final data = venue.data() as Map<String, dynamic>;
                          final venueName = data['name'] as String? ?? 'Unknown Venue';
                          final bookings = venueStats[venue.id] ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.store, color: Colors.blue),
                              ),
                              title: Text(venueName),
                              subtitle: Text('$bookings bookings'),
                              trailing: Text(
                                '${((bookings / (bookingsSnapshot.data?.docs.length ?? 1)) * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
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
  }) {
    return IntrinsicHeight(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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

  double _calculateMonthlyRevenue(List<QueryDocumentSnapshot> bookings) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    double total = 0;
    for (final booking in bookings) {
      final data = booking.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'] as Timestamp?;
      if (createdAt != null) {
        final bookingDate = createdAt.toDate();
        if (bookingDate.isAfter(startOfMonth)) {
          total += (data['totalAmount'] as num?)?.toDouble() ?? 0;
        }
      }
    }
    return total;
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
}
