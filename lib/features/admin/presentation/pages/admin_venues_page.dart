import 'package:flutter/material.dart';

class AdminVenuesPage extends StatelessWidget {
  const AdminVenuesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venue Management')),
      body: ListView.builder(
        itemCount: 10, // Placeholder
        itemBuilder: (context, i) => ListTile(
          leading: const Icon(Icons.store),
          title: Text('Venue $i'),
          subtitle: const Text('Status: Pending'),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
              const PopupMenuItem(value: 'approve', child: Text('Approve')),
              const PopupMenuItem(value: 'reject', child: Text('Reject')),
            ],
          ),
        ),
      ),
    );
  }
} 