import 'package:cloud_firestore/cloud_firestore.dart';

class RoomEntity {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final double hourlyPrice;
  final List<String> images;
  final String venueId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  RoomEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.hourlyPrice,
    required this.images,
    required this.venueId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoomEntity.fromMap(Map<String, dynamic> data, String documentId) {
    return RoomEntity(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      capacity: data['capacity'] ?? 0,
      hourlyPrice: (data['hourlyPrice'] ?? 0.0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      venueId: data['venueId'] ?? '',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'capacity': capacity,
      'hourlyPrice': hourlyPrice,
      'images': images,
      'venueId': venueId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
} 