import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phoneNumber;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final int points;
  final String? venueId;
  final List<String>? fcmTokens;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.points = 0,
    this.venueId,
    this.fcmTokens,
  });

  factory UserEntity.fromMap(Map<String, dynamic> data, String documentId) {
    return UserEntity(
      id: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      phoneNumber: data['phoneNumber'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      points: (data['points'] ?? 0),
      venueId: data['venueId'],
      fcmTokens: data['fcmTokens'] != null ? List<String>.from(data['fcmTokens']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'points': points,
      'venueId': venueId,
      'fcmTokens': fcmTokens,
    };
  }
} 