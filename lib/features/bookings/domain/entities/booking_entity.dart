import 'package:cloud_firestore/cloud_firestore.dart';

class BookingEntity {
  final String id;
  final String userId;
  final String venueId;
  final String roomId;
  final Timestamp startTime;
  final Timestamp endTime;
  final int durationHours;
  final double roomFee;
  final double reservationFee;
  final double totalAmount;
  final String paymentStatus;
  final String bookingStatus;
  final String? paymentIntentId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  BookingEntity({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.roomId,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.roomFee,
    required this.reservationFee,
    required this.totalAmount,
    required this.paymentStatus,
    required this.bookingStatus,
    this.paymentIntentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingEntity.fromMap(Map<String, dynamic> data, String documentId) {
    return BookingEntity(
      id: documentId,
      userId: data['userId'] ?? '',
      venueId: data['venueId'] ?? '',
      roomId: data['roomId'] ?? '',
      startTime: data['startTime'],
      endTime: data['endTime'],
      durationHours: data['durationHours'] ?? 0,
      roomFee: (data['roomFee'] ?? 0.0).toDouble(),
      reservationFee: (data['reservationFee'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? '',
      bookingStatus: data['bookingStatus'] ?? '',
      paymentIntentId: data['paymentIntentId'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'venueId': venueId,
      'roomId': roomId,
      'startTime': startTime,
      'endTime': endTime,
      'durationHours': durationHours,
      'roomFee': roomFee,
      'reservationFee': reservationFee,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'paymentIntentId': paymentIntentId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
} 