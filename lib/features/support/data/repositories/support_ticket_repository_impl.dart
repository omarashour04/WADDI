import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/repositories/support_ticket_repository.dart';

class SupportTicketRepositoryImpl implements SupportTicketRepository {
  final FirebaseFirestore firestore;
  SupportTicketRepositoryImpl({required this.firestore});

  @override
  Future<SupportTicketEntity?> getTicketById(String id) async {
    final doc = await firestore.collection('supportTickets').doc(id).get();
    if (!doc.exists) return null;
    return SupportTicketEntity.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<SupportTicketEntity>> getTicketsForUser(String userId) async {
    final snapshot = await firestore.collection('supportTickets').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => SupportTicketEntity.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> createTicket(SupportTicketEntity ticket) async {
    await firestore.collection('supportTickets').doc(ticket.id).set(ticket.toMap());
  }

  @override
  Future<void> updateTicket(SupportTicketEntity ticket) async {
    await firestore.collection('supportTickets').doc(ticket.id).update(ticket.toMap());
  }

  @override
  Future<void> deleteTicket(String id) async {
    await firestore.collection('supportTickets').doc(id).delete();
  }
} 