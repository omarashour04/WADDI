import 'package:cloud_firestore/cloud_firestore.dart';

class BookingEntity {
  final String id;
  final String userId;
  final String venueId;
  final String roomId;
  final String venueName;
  final String roomName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationHours;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final int? rating;
  final String? review;

  BookingEntity({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.roomId,
    required this.venueName,
    required this.roomName,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.rating,
    this.review,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'venueId': venueId,
      'roomId': roomId,
      'venueName': venueName,
      'roomName': roomName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationHours': durationHours,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
      'rating': rating,
      'review': review,
    };
  }

  factory BookingEntity.fromMap(Map<String, dynamic> map, String id) {
    return BookingEntity(
      id: id,
      userId: map['userId'] ?? '',
      venueId: map['venueId'] ?? '',
      roomId: map['roomId'] ?? '',
      venueName: map['venueName'] ?? '',
      roomName: map['roomName'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      durationHours: map['durationHours'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      notes: map['notes'],
      rating: map['rating'],
      review: map['review'],
    );
  }

  BookingEntity copyWith({
    String? id,
    String? userId,
    String? venueId,
    String? roomId,
    String? venueName,
    String? roomName,
    DateTime? startTime,
    DateTime? endTime,
    int? durationHours,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    int? rating,
    String? review,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      venueId: venueId ?? this.venueId,
      roomId: roomId ?? this.roomId,
      venueName: venueName ?? this.venueName,
      roomName: roomName ?? this.roomName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }

  // Calculate the actual status based on time and current status
  String get actualStatus {
    final now = DateTime.now();
    
    // If already cancelled, return cancelled
    if (status == 'cancelled') return 'cancelled';
    
    // If booking time has passed, mark as completed
    if (endTime.isBefore(now)) return 'completed';
    
    // If booking is in progress (started but not ended)
    if (startTime.isBefore(now) && endTime.isAfter(now)) return 'in_progress';
    
    // If booking is in the future, return the original status
    return status;
  }

  // Check if booking is upcoming (future booking)
  bool get isUpcoming {
    return startTime.isAfter(DateTime.now()) && status != 'cancelled';
  }

  // Check if booking is past (completed)
  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  // Check if booking is in progress
  bool get isInProgress {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now) && status != 'cancelled';
  }

  bool get canCancel => isUpcoming && status == 'confirmed';
  bool get canReview => isPast && status == 'completed' && rating == null;
} 