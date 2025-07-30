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
  final bool isGuestUser;

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
    this.isGuestUser = false,
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
      isGuestUser: data['isGuestUser'] ?? false,
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
      'isGuestUser': isGuestUser,
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phoneNumber,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    int? points,
    String? venueId,
    List<String>? fcmTokens,
    bool? isGuestUser,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      points: points ?? this.points,
      venueId: venueId ?? this.venueId,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      isGuestUser: isGuestUser ?? this.isGuestUser,
    );
  }
} 