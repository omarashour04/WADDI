import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/support_ticket_providers.dart';
import '../../domain/entities/support_ticket_entity.dart';

class SupportTicketsPage extends ConsumerWidget {
  final String userId;
  const SupportTicketsPage({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsForUserProvider(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Support Tickets')),
      body: ticketsAsync.when(
        data: (tickets) {
          if (tickets.isEmpty) {
            return const Center(child: Text('No support tickets found.'));
          }
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, i) => _TicketCard(ticket: tickets[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
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