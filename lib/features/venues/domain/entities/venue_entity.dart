import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VenueEntity {
  final String id;
  final String name;
  final String description;
  final String address;
  final GeoPoint location;
  final String contactPhone;
  final String contactEmail;
  final List<String> images;
  final List<String> amenities;
  final String ownerId;
  final double averageRating;
  final int totalReviews;
  final Map<String, dynamic> hourlyPriceRange;
  final Map<String, dynamic> capacityRange;
  final Map<String, dynamic> operatingHours;
  final List<Timestamp> blockedDates;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  VenueEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.location,
    required this.contactPhone,
    required this.contactEmail,
    required this.images,
    required this.amenities,
    required this.ownerId,
    required this.averageRating,
    required this.totalReviews,
    required this.hourlyPriceRange,
    required this.capacityRange,
    required this.operatingHours,
    required this.blockedDates,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VenueEntity.fromMap(Map<String, dynamic> data, String documentId) {
    try {
      return VenueEntity(
        id: documentId,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        address: data['address'] ?? '',
        location: data['location'] is GeoPoint
            ? data['location']
            : (data['location'] != null && data['location']['latitude'] != null && data['location']['longitude'] != null
                ? GeoPoint(
                    (data['location']['latitude'] as num).toDouble(),
                    (data['location']['longitude'] as num).toDouble(),
                  )
                : GeoPoint(0, 0)),
        contactPhone: data['contactPhone'] ?? '',
        contactEmail: data['contactEmail'] ?? '',
        images: data['images'] != null ? List<String>.from(data['images']) : [],
        amenities: data['amenities'] != null ? List<String>.from(data['amenities']) : [],
        ownerId: data['ownerId'] ?? '',
        averageRating: (data['averageRating'] ?? 0.0).toDouble(),
        totalReviews: (data['totalReviews'] ?? 0),
        hourlyPriceRange: data['hourlyPriceRange'] != null ? Map<String, dynamic>.from(data['hourlyPriceRange']) : {'min': 0, 'max': 0},
        capacityRange: data['capacityRange'] != null ? Map<String, dynamic>.from(data['capacityRange']) : {'min': 0, 'max': 0},
        operatingHours: data['operatingHours'] != null ? Map<String, dynamic>.from(data['operatingHours']) : {},
        blockedDates: data['blockedDates'] != null ? List<Timestamp>.from(data['blockedDates']) : [],
        createdAt: data['createdAt'] is Timestamp ? data['createdAt'] : Timestamp.now(),
        updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] : Timestamp.now(),
      );
    } catch (e, st) {
      print('VenueEntity.fromMap error for doc $documentId: $e\n$st');
      return VenueEntity(
        id: documentId,
        name: '',
        description: '',
        address: '',
        location: GeoPoint(0, 0),
        contactPhone: '',
        contactEmail: '',
        images: [],
        amenities: [],
        ownerId: '',
        averageRating: 0.0,
        totalReviews: 0,
        hourlyPriceRange: {'min': 0, 'max': 0},
        capacityRange: {'min': 0, 'max': 0},
        operatingHours: {},
        blockedDates: [],
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'location': location,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'images': images,
      'amenities': amenities,
      'ownerId': ownerId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'hourlyPriceRange': hourlyPriceRange,
      'capacityRange': capacityRange,
      'operatingHours': operatingHours,
      'blockedDates': blockedDates,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class VenueRoom extends Equatable {
  final String id;
  final String name;
  final int capacity;
  final List<String> amenities;

  const VenueRoom({
    required this.id,
    required this.name,
    required this.capacity,
    required this.amenities,
  });

  @override
  List<Object?> get props => [id, name, capacity, amenities];
} 