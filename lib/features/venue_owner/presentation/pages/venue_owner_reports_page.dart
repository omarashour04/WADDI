import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class VenueOwnerReportsPage extends ConsumerWidget {
  final String ownerId;
  const VenueOwnerReportsPage({required this.ownerId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainScaffold(
      currentIndex: 2, // Reports tab
      userId: ownerId,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Venue Reports'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
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
                    Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No venues found'),
                    Text('Add venues to see reports'),
                  ],
                ),
              );
            }

            final venues = venueSnapshot.data!.docs;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOverallStats(context, venues),
                const SizedBox(height: 24),
                _buildVenueReports(context, venues),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, List<QueryDocumentSnapshot> venues) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Statistics',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Venues',
                    venues.length.toString(),
                    Icons.business,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _getTotalRooms(venues),
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        context,
                        'Total Rooms',
                        snapshot.data?.toString() ?? '0',
                        Icons.meeting_room,
                        Colors.blue,
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
                    future: _getTotalBookings(venues),
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        context,
                        'Total Bookings',
                        snapshot.data?.toString() ?? '0',
                        Icons.book,
                        Colors.green,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<double>(
                    future: _getTotalRevenue(venues),
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        context,
                        'Total Revenue',
                        'EGP ${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                        Icons.attach_money,
                        Colors.orange,
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

  Widget _buildStatCard(
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

  Widget _buildVenueReports(BuildContext context, List<QueryDocumentSnapshot> venues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Venue Reports',
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
                FutureBuilder<Map<String, dynamic>>(
                  future: _getVenueStats(venueId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final stats = snapshot.data ?? {};
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildVenueStat(
                                  context,
                                  'Rooms',
                                  stats['rooms']?.toString() ?? '0',
                                  Icons.meeting_room,
                                ),
                              ),
                              Expanded(
                                child: _buildVenueStat(
                                  context,
                                  'Bookings',
                                  stats['bookings']?.toString() ?? '0',
                                  Icons.book,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildVenueStat(
                                  context,
                                  'Revenue',
                                  'EGP ${stats['revenue']?.toStringAsFixed(2) ?? '0.00'}',
                                  Icons.attach_money,
                                ),
                              ),
                              Expanded(
                                child: _buildVenueStat(
                                  context,
                                  'Avg Rating',
                                  '${stats['avgRating']?.toStringAsFixed(1) ?? '0.0'} (${stats['totalReviews'] ?? 0})',
                                  Icons.star,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildVenueStat(BuildContext context, String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<int> _getTotalRooms(List<QueryDocumentSnapshot> venues) async {
    int totalRooms = 0;
    for (final venue in venues) {
      final roomsSnapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(venue.id)
          .collection('rooms')
          .get();
      totalRooms += roomsSnapshot.docs.length;
    }
    return totalRooms;
  }

  Future<int> _getTotalBookings(List<QueryDocumentSnapshot> venues) async {
    int totalBookings = 0;
    for (final venue in venues) {
      final roomsSnapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(venue.id)
          .collection('rooms')
          .get();

      for (final room in roomsSnapshot.docs) {
        final bookingsSnapshot = await FirebaseFirestore.instance
            .collection('venues')
            .doc(venue.id)
            .collection('rooms')
            .doc(room.id)
            .collection('bookings')
            .get();
        totalBookings += bookingsSnapshot.docs.length;
      }
    }
    return totalBookings;
  }

  Future<double> _getTotalRevenue(List<QueryDocumentSnapshot> venues) async {
    double totalRevenue = 0.0;
    for (final venue in venues) {
      final roomsSnapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(venue.id)
          .collection('rooms')
          .get();

      for (final room in roomsSnapshot.docs) {
        final bookingsSnapshot = await FirebaseFirestore.instance
            .collection('venues')
            .doc(venue.id)
            .collection('rooms')
            .doc(room.id)
            .collection('bookings')
            .get();

        for (final booking in bookingsSnapshot.docs) {
          final bookingData = booking.data() as Map<String, dynamic>;
          final price = bookingData['price'] ?? 0.0;
          totalRevenue += price;
        }
      }
    }
    return totalRevenue;
  }

  Future<Map<String, dynamic>> _getVenueStats(String venueId) async {
    final roomsSnapshot = await FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('rooms')
        .get();

    int totalBookings = 0;
    double totalRevenue = 0.0;

    for (final room in roomsSnapshot.docs) {
      final bookingsSnapshot = await FirebaseFirestore.instance
          .collection('venues')
          .doc(venueId)
          .collection('rooms')
          .doc(room.id)
          .collection('bookings')
          .get();

      totalBookings += bookingsSnapshot.docs.length;

      for (final booking in bookingsSnapshot.docs) {
        final bookingData = booking.data() as Map<String, dynamic>;
        final price = bookingData['price'] ?? 0.0;
        totalRevenue += price;
      }
    }

    // Calculate actual average rating from reviews
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('venueId', isEqualTo: venueId)
        .get();

    double avgRating = 0.0;
    int totalReviews = reviewsSnapshot.docs.length;

    if (totalReviews > 0) {
      double totalRating = 0.0;
      for (final review in reviewsSnapshot.docs) {
        final reviewData = review.data() as Map<String, dynamic>;
        final rating = reviewData['rating'] ?? 0.0;
        totalRating += rating;
      }
      avgRating = totalRating / totalReviews;
    }

    return {
      'rooms': roomsSnapshot.docs.length,
      'bookings': totalBookings,
      'revenue': totalRevenue,
      'avgRating': avgRating,
      'totalReviews': totalReviews,
    };
  }
}
