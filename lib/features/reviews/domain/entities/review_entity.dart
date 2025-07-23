import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewEntity {
  final String id;
  final String userId;
  final String venueId;
  final double rating;
  final String comment;
  final Timestamp createdAt;
  final String? response;
  final Timestamp? respondedAt;

  ReviewEntity({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.response,
    this.respondedAt,
  });

  factory ReviewEntity.fromMap(Map<String, dynamic> data, String documentId) {
    return ReviewEntity(
      id: documentId,
      userId: data['userId'] ?? '',
      venueId: data['venueId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'],
      response: data['response'],
      respondedAt: data['respondedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'venueId': venueId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'response': response,
      'respondedAt': respondedAt,
    };
  }
} 