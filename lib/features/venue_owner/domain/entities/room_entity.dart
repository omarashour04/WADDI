import 'package:cloud_firestore/cloud_firestore.dart';

class RoomEntity {
  final String id;
  final String venueId;
  final String name;
  final String description;
  final int capacity;
  final double hourlyPrice;
  final String equipment;
  final List<String> images;
  final bool isClosedForMaintenance;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomEntity({
    required this.id,
    required this.venueId,
    required this.name,
    required this.description,
    required this.capacity,
    required this.hourlyPrice,
    required this.equipment,
    required this.images,
    this.isClosedForMaintenance = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoomEntity.fromMap(Map<String, dynamic> map, String id) {
    return RoomEntity(
      id: id,
      venueId: map['venueId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      capacity: map['capacity'] ?? 0,
      hourlyPrice: (map['hourlyPrice'] ?? 0.0).toDouble(),
      equipment: map['equipment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isClosedForMaintenance: map['isClosedForMaintenance'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'venueId': venueId,
      'name': name,
      'description': description,
      'capacity': capacity,
      'hourlyPrice': hourlyPrice,
      'equipment': equipment,
      'images': images,
      'isClosedForMaintenance': isClosedForMaintenance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  RoomEntity copyWith({
    String? id,
    String? venueId,
    String? name,
    String? description,
    int? capacity,
    double? hourlyPrice,
    String? equipment,
    List<String>? images,
    bool? isClosedForMaintenance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      hourlyPrice: hourlyPrice ?? this.hourlyPrice,
      equipment: equipment ?? this.equipment,
      images: images ?? this.images,
      isClosedForMaintenance: isClosedForMaintenance ?? this.isClosedForMaintenance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 