import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/support_ticket_providers.dart';
import '../../domain/entities/support_ticket_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketsPage extends StatelessWidget {
  final String userId;
  const SupportTicketsPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Tickets')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('supportTickets')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No support tickets found.'));
          }
          final tickets = snapshot.data!.docs;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, i) {
              final ticket = tickets[i].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(ticket['subject'] ?? ''),
                  subtitle: Text(ticket['description'] ?? ''),
                  trailing: Text(ticket['status'] ?? 'open'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => _NewTicketDialog(userId: userId),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'New Ticket',
      ),
    );
  }
}

class _NewTicketDialog extends StatefulWidget {
  final String userId;
  const _NewTicketDialog({required this.userId});
  @override
  State<_NewTicketDialog> createState() => _NewTicketDialogState();
}

class _NewTicketDialogState extends State<_NewTicketDialog> {
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'General';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Support Ticket'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _category,
            items: ['General', 'Booking', 'Payment', 'Technical', 'Other']
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (val) => setState(() => _category = val!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance.collection('supportTickets').add({
              'userId': widget.userId,
              'subject': _subjectController.text.trim(),
              'description': _descController.text.trim(),
              'category': _category,
              'status': 'open',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket submitted!')),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicketEntity ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(ticket.subject),
        subtitle: Text(ticket.status),
        trailing: ticket.attachments != null && ticket.attachments!.isNotEmpty
            ? Icon(Icons.attachment, color: Colors.blue)
            : null,
        onTap: () {
          // TODO: Show ticket details
        },
      ),
    );
  }
} 