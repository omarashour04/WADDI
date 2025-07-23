import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VenueReportsPage extends StatelessWidget {
  final String venueId;
  const VenueReportsPage({required this.venueId, Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchReport() async {
    final roomsSnapshot = await FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('rooms')
        .get();
    int totalBookings = 0;
    double totalRevenue = 0.0;
    for (final roomDoc in roomsSnapshot.docs) {
      final bookingsSnapshot = await roomDoc.reference.collection('bookings').get();
      totalBookings += bookingsSnapshot.docs.length;
      for (final booking in bookingsSnapshot.docs) {
        final data = booking.data();
        totalRevenue += (data['price'] ?? 0.0) as double;
      }
    }
    return {
      'totalBookings': totalBookings,
      'totalRevenue': totalRevenue,
      'roomCount': roomsSnapshot.docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venue Reports')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Rooms: ${data['roomCount']}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text('Total Bookings: ${data['totalBookings']}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text('Total Revenue: EGP ${data['totalRevenue'].toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        },
      ),
    );
  }
} 