import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum NotificationType {
  bookingReminder,
  venueUpdate,
  promotion,
  system,
  maintenance,
}

class NotificationEntity {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? venueId;
  final String? bookingId;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? scheduledFor;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.venueId,
    this.bookingId,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.scheduledFor,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'venueId': venueId,
      'bookingId': bookingId,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledFor': scheduledFor != null ? Timestamp.fromDate(scheduledFor!) : null,
    };
  }

  factory NotificationEntity.fromMap(Map<String, dynamic> map, String id) {
    return NotificationEntity(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      venueId: map['venueId'],
      bookingId: map['bookingId'],
      data: map['data'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      scheduledFor: map['scheduledFor'] != null 
          ? (map['scheduledFor'] as Timestamp).toDate() 
          : null,
    );
  }

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? venueId,
    String? bookingId,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? scheduledFor,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      venueId: venueId ?? this.venueId,
      bookingId: bookingId ?? this.bookingId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.bookingReminder:
        return Icons.event;
      case NotificationType.venueUpdate:
        return Icons.update;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.maintenance:
        return Icons.engineering;
      case NotificationType.system:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.bookingReminder:
        return Colors.blue;
      case NotificationType.venueUpdate:
        return Colors.green;
      case NotificationType.promotion:
        return Colors.orange;
      case NotificationType.maintenance:
        return Colors.red;
      case NotificationType.system:
        return Colors.grey;
    }
  }
} 