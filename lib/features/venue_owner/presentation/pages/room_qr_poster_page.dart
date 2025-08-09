import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RoomQrPosterPage extends StatelessWidget {
  final String venueId;
  final String roomId;
  const RoomQrPosterPage({super.key, required this.venueId, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Check-in QR')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('venues').doc(venueId).get(),
        builder: (context, venueSnap) {
          if (venueSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final venueName = venueSnap.data?.data()?['name'] ?? venueId;
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('venues')
                .doc(venueId)
                .collection('rooms')
                .doc(roomId)
                .get(),
            builder: (context, roomSnap) {
              if (roomSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final roomName = roomSnap.data?.data()?['name'] ?? roomId;
              final payload = jsonEncode({'v': 1, 'vid': venueId, 'rid': roomId});
              final encoded = base64Url.encode(utf8.encode(payload));
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(venueName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('Room: $roomName', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 24),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: QrImageView(
                          data: encoded,
                          version: QrVersions.auto,
                          size: 260,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Scan this QR on arrival to check in.'),
                      const SizedBox(height: 8),
                      Text('Venue ID: $venueId • Room ID: $roomId', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // For web, let the browser print. For mobile, users can screenshot.
                              // This is a placeholder. Platform print/share can be added later.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Use system print/share to distribute the QR.')),
                              );
                            },
                            icon: const Icon(Icons.print),
                            label: const Text('Print / Share'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


