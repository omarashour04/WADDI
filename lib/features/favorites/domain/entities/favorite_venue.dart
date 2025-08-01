import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteVenue {
  final String id;
  final String userId;
  final String venueId;
  final String venueName;
  final String venueAddress;
  final List<String> venueImages;
  final double averageRating;
  final int totalReviews;
  final DateTime addedAt;

  FavoriteVenue({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.venueName,
    required this.venueAddress,
    required this.venueImages,
    required this.averageRating,
    required this.totalReviews,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'venueId': venueId,
      'venueName': venueName,
      'venueAddress': venueAddress,
      'venueImages': venueImages,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory FavoriteVenue.fromMap(Map<String, dynamic> map, String id) {
    return FavoriteVenue(
      id: id,
      userId: map['userId'] ?? '',
      venueId: map['venueId'] ?? '',
      venueName: map['venueName'] ?? '',
      venueAddress: map['venueAddress'] ?? '',
      venueImages: List<String>.from(map['venueImages'] ?? []),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }
} 