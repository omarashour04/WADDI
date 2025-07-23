import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'How do I book a room?', 'a': 'Go to the venue details, select a room, and follow the booking flow.'},
      {'q': 'How do I pay?', 'a': 'You can pay securely via Paymob after booking.'},
      {'q': 'How do I contact support?', 'a': 'Use the contact form in the app to submit a support ticket.'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.separated(
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) => ListTile(
          title: Text(faqs[i]['q']!),
          subtitle: Text(faqs[i]['a']!),
        ),
      ),
    );
  }
} 