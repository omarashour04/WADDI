import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketEntity {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final String category;
  final String status;
  final List<String>? attachments;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<Map<String, dynamic>>? responses;

  SupportTicketEntity({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.category,
    required this.status,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.responses,
  });

  factory SupportTicketEntity.fromMap(Map<String, dynamic> data, String documentId) {
    return SupportTicketEntity(
      id: documentId,
      userId: data['userId'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? '',
      attachments: data['attachments'] != null ? List<String>.from(data['attachments']) : null,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      responses: data['responses'] != null ? List<Map<String, dynamic>>.from(data['responses']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'subject': subject,
      'description': description,
      'category': category,
      'status': status,
      'attachments': attachments,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'responses': responses,
    };
  }
} 