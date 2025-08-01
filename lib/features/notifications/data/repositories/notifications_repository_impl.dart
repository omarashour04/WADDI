import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Future<List<NotificationEntity>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => NotificationEntity.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }

  @override
  Future<void> saveFCMToken(String userId, String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});
    } catch (e) {
      throw Exception('Failed to save FCM token: $e');
    }
  }

  @override
  Future<void> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      throw Exception('Failed to request notification permission: $e');
    }
  }

  @override
  Future<void> createBookingReminder(String userId, String bookingId, 
      String venueName, DateTime bookingTime) async {
    try {
      final reminderTime = bookingTime.subtract(const Duration(hours: 1));
      
      final notification = NotificationEntity(
        id: '',
        userId: userId,
        title: 'Booking Reminder',
        message: 'Your booking at $venueName is in 1 hour',
        type: NotificationType.bookingReminder,
        bookingId: bookingId,
        scheduledFor: reminderTime,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create booking reminder: $e');
    }
  }

  @override
  Future<void> createVenueUpdateNotification(String userId, String venueId, 
      String venueName, String updateMessage) async {
    try {
      final notification = NotificationEntity(
        id: '',
        userId: userId,
        title: 'Venue Update',
        message: updateMessage,
        type: NotificationType.venueUpdate,
        venueId: venueId,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create venue update notification: $e');
    }
  }

  @override
  Future<void> createPromotionNotification(String userId, String title, 
      String message, Map<String, dynamic>? data) async {
    try {
      final notification = NotificationEntity(
        id: '',
        userId: userId,
        title: title,
        message: message,
        type: NotificationType.promotion,
        data: data,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create promotion notification: $e');
    }
  }
} 