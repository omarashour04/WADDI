import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentStatusPage extends StatefulWidget {
  final String bookingId;
  final String status; // 'success' or 'failure'
  const PaymentStatusPage({required this.bookingId, required this.status, Key? key}) : super(key: key);

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  bool isUpdating = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _updateBookingStatus();
  }

  Future<void> _updateBookingStatus() async {
    setState(() => isUpdating = true);
    try {
      final status = widget.status == 'success' ? 'confirmed' : 'failed';
      await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).update({
        'paymentStatus': status,
        'bookingStatus': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      setState(() => error = 'Failed to update booking: $e');
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.status == 'success';
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Status')),
      body: Center(
        child: isUpdating
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isSuccess ? 'Payment Successful!' : 'Payment Failed',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
      ),
    );
  }
} 