import '../entities/support_ticket_entity.dart';

abstract class SupportTicketRepository {
  Future<SupportTicketEntity?> getTicketById(String id);
  Future<List<SupportTicketEntity>> getTicketsForUser(String userId);
  Future<void> createTicket(SupportTicketEntity ticket);
  Future<void> updateTicket(SupportTicketEntity ticket);
  Future<void> deleteTicket(String id);
} 