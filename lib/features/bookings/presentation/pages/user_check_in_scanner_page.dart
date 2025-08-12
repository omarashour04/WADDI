import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../../../../shared/widgets/main_scaffold.dart';

class UserCheckInScannerPage extends ConsumerStatefulWidget {
  const UserCheckInScannerPage({super.key});

  @override
  ConsumerState<UserCheckInScannerPage> createState() => _UserCheckInScannerPageState();
}

class _UserCheckInScannerPageState extends ConsumerState<UserCheckInScannerPage> {
  bool _processing = false;
  String? _error;

  Future<void> _handleScan(String raw) async {
    if (_processing) return;
    setState(() {
      _processing = true;
      _error = null;
    });
    try {
      // QR payload expected: base64Url(json{"v":1,"vid":"...","rid":"..."}) OR raw json
      String jsonStr;
      try {
        jsonStr = utf8.decode(base64Url.decode(raw));
      } catch (_) {
        jsonStr = raw; // maybe it is plain json
      }
      final Map<String, dynamic> data = json.decode(jsonStr) as Map<String, dynamic>;
      if ((data['vid'] ?? '').toString().isEmpty || (data['rid'] ?? '').toString().isEmpty) {
        throw Exception('Invalid QR');
      }
      final venueId = data['vid'] as String;
      final roomId = data['rid'] as String;
      final userId = ref.read(authProvider).user?.id ?? '';
      if (userId.isEmpty) throw Exception('Not authenticated');
      await ref
          .read(bookingStateProvider.notifier)
          .checkInByRoomScan(userId: userId, venueId: venueId, roomId: roomId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checked in successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 2, // Scan tab is at index 2
      userId: ref.read(authProvider).user?.id ?? '',
      child: Scaffold(
        appBar: AppBar(title: const Text('Scan Room QR to Check In')),
        body: Column(
          children: [
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final codes = capture.barcodes;
                  if (codes.isNotEmpty) {
                    final raw = codes.first.rawValue;
                    if (raw != null) {
                      _handleScan(raw);
                    }
                  }
                },
              ),
            ),
            if (_processing)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}


