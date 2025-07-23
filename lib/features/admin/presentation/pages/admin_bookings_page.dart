import 'package:flutter/material.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Management')),
      body: ListView.builder(
        itemCount: 10, // Placeholder
        itemBuilder: (context, i) => ListTile(
          leading: const Icon(Icons.book_online),
          title: Text('Booking $i'),
          subtitle: Text('User: user$i | Venue: venue$i'),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('View')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      ),
    );
  }
} 