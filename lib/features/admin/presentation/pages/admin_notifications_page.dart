import 'package:flutter/material.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Message:'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Send to All Users'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Send to Venue Owners'),
            ),
          ],
        ),
      ),
    );
  }
} 