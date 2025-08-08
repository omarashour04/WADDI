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
  final String status; // 'pending', 'approved', 'rejected'
  final bool isClosedForMaintenance;
  final String openTime; // Format: "09:00"
  final String closeTime; // Format: "22:00"
  final int timeSlotDuration; // Duration in minutes (30, 60, etc.)
  final bool allowOpenEndedBookings; // Allow customers to book without end time
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
    required this.status,
    required this.isClosedForMaintenance,
    required this.openTime,
    required this.closeTime,
    required this.timeSlotDuration,
    required this.allowOpenEndedBookings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VenueEntity.fromMap(Map<String, dynamic> data, String documentId) {
    try {
      print('DEBUG: Parsing venue data for document $documentId');
      print('DEBUG: Data keys: ${data.keys.toList()}');
      
      // Check for required fields
      if (data['name'] == null) {
        print('DEBUG: Missing name field for venue $documentId');
        throw Exception('Missing name field');
      }
      
      return VenueEntity(
        id: documentId,
        name: data['name'] ?? 'Unnamed Venue',
        description: data['description'] ?? '',
        address: data['address'] ?? '',
        location: data['location'] is GeoPoint
            ? data['location']
            : (data['location'] != null &&
                      data['location']['latitude'] != null &&
                      data['location']['longitude'] != null
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
        hourlyPriceRange: data['hourlyPriceRange'] != null
            ? Map<String, dynamic>.from(data['hourlyPriceRange'])
            : {'min': 0, 'max': 0},
        capacityRange: data['capacityRange'] != null
            ? Map<String, dynamic>.from(data['capacityRange'])
            : {'min': 0, 'max': 0},
        operatingHours: data['operatingHours'] != null
            ? (data['operatingHours'] is Map 
                ? Map<String, dynamic>.from(data['operatingHours'])
                : {'general': data['operatingHours'].toString()})
            : {},
        blockedDates: data['blockedDates'] != null
            ? List<Timestamp>.from(data['blockedDates'])
            : [],
        status: data['status'] ?? 'pending',
        isClosedForMaintenance: data['isClosedForMaintenance'] ?? false,
        openTime: data['openTime'] ?? '00:00',
        closeTime: data['closeTime'] ?? '00:00',
        timeSlotDuration: data['timeSlotDuration'] ?? 30,
        allowOpenEndedBookings: data['allowOpenEndedBookings'] ?? false,
        createdAt: data['createdAt'] is Timestamp ? data['createdAt'] : Timestamp.now(),
        updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] : Timestamp.now(),
      );
    } catch (e, stackTrace) {
      print('DEBUG: Error parsing venue $documentId: $e');
      print('DEBUG: Stack trace: $stackTrace');
      print('DEBUG: Raw data: $data');
      
      // Return a default venue entity instead of throwing
      return VenueEntity(
        id: documentId,
        name: 'Error loading venue',
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
        status: 'pending',
        isClosedForMaintenance: false,
        openTime: '00:00',
        closeTime: '00:00',
        timeSlotDuration: 30,
        allowOpenEndedBookings: false,
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
      'status': status,
      'isClosedForMaintenance': isClosedForMaintenance,
      'openTime': openTime,
      'closeTime': closeTime,
      'timeSlotDuration': timeSlotDuration,
      'allowOpenEndedBookings': allowOpenEndedBookings,
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
  final bool isClosedForMaintenance;

  const VenueRoom({
    required this.id,
    required this.name,
    required this.capacity,
    required this.amenities,
    this.isClosedForMaintenance = false,
  });

  @override
  List<Object?> get props => [id, name, capacity, amenities, isClosedForMaintenance];
}
