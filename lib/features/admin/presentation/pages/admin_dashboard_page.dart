import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('User Management'),
            onTap: () => context.go('/admin/users'),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Venue Management'),
            onTap: () => context.go('/admin/venues'),
          ),
          ListTile(
            leading: const Icon(Icons.book_online),
            title: const Text('Booking Management'),
            onTap: () => context.go('/admin/bookings'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () => context.go('/admin/analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Content Management'),
            onTap: () => context.go('/admin/content'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Broadcast Notifications'),
            onTap: () => context.go('/admin/notifications'),
          ),
        ],
      ),
    );
  }
} 