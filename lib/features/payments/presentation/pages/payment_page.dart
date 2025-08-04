import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/paymob_payment_service.dart';

class PaymentPage extends StatefulWidget {
  final String bookingId;
  final double totalAmount;
  final String userEmail;
  final PaymobPaymentService paymentService;
  const PaymentPage({
    required this.bookingId,
    required this.totalAmount,
    required this.userEmail,
    required this.paymentService,
    super.key,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isLoading = false;
  String? error;

  Future<void> _initiatePaymobPayment() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final paymentUrl = await widget.paymentService.initiatePayment(
        bookingId: widget.bookingId,
        amount: widget.totalAmount,
        userEmail: widget.userEmail,
      );
      if (paymentUrl != null) {
        if (await canLaunchUrl(Uri.parse(paymentUrl))) {
          await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
        } else {
          setState(() => error = 'Could not launch payment URL.');
        }
      } else {
        setState(() => error = 'Failed to get payment URL.');
      }
    } catch (e) {
      setState(() => error = 'Payment initiation failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text('Booking ID: ${widget.bookingId}'),
            Text('Total Amount: ${widget.totalAmount} EGP'),
            const SizedBox(height: 32),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _initiatePaymobPayment,
                    child: const Text('Pay with Paymob'),
                  ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
} 