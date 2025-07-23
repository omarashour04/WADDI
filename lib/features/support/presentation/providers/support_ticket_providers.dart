import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../data/repositories/support_ticket_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final supportTicketRepositoryProvider = Provider((ref) => SupportTicketRepositoryImpl(firestore: FirebaseFirestore.instance));

final ticketsForUserProvider = FutureProvider.family<List<SupportTicketEntity>, String>((ref, userId) async {
  final repo = ref.watch(supportTicketRepositoryProvider);
  return repo.getTicketsForUser(userId);
}); 