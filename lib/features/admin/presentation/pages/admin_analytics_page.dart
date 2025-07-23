import 'package:flutter/material.dart';

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Bookings: 1234', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Total Revenue: EGP 567,890', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Active Users: 456', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Popular Venues: Venue A, Venue B', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
} 