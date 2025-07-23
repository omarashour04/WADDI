import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatelessWidget {
  final String userId;
  const NotificationsPage({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }
          final notifications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, i) {
              final data = notifications[i].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title'] ?? 'Notification'),
                subtitle: Text(data['body'] ?? ''),
                trailing: Text(
                  data['timestamp'] != null
                      ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'].millisecondsSinceEpoch).toString()
                      : '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 