import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/notification_popup.dart';

class NotificationService {
  static const String _lastNotificationKey = 'last_notification_id';
  static const String _lastNotificationTimeKey = 'last_notification_time';

  // Check for new notifications and show them
  static Future<void> checkAndShowNotifications(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastNotificationId = prefs.getString(_lastNotificationKey) ?? '';
      final lastNotificationTime = prefs.getInt(_lastNotificationTimeKey) ?? 0;

      // Get the most recent notification
      final notificationsQuery = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (notificationsQuery.docs.isEmpty) return;

      final latestNotification = notificationsQuery.docs.first;
      final notificationData = latestNotification.data();
      final notificationId = latestNotification.id;
      final createdAt = notificationData['createdAt'] as Timestamp?;

      if (createdAt == null) return;

      // Check if this is a new notification
      if (notificationId != lastNotificationId || 
          createdAt.millisecondsSinceEpoch > lastNotificationTime) {
        
        final message = notificationData['message'] as String? ?? '';
        final target = notificationData['target'] as String? ?? 'all_users';
        
        // Show notification if it's for all users or venue owners
        if (target == 'all_users' || target == 'venue_owners') {
          await _showNotification(context, message, target);
          
          // Save the notification info
          await prefs.setString(_lastNotificationKey, notificationId);
          await prefs.setInt(_lastNotificationTimeKey, createdAt.millisecondsSinceEpoch);
        }
      }
    } catch (e) {
      print('Error checking notifications: $e');
    }
  }

  // Request permission and register FCM token to users/{uid}.fcmTokens
  static Future<void> initializePushForUser({required String uid}) async {
    try {
      final messaging = FirebaseMessaging.instance;
      // iOS/Android13+ permission
      final settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
      if (kDebugMode) {
        print('FCM permission: ${settings.authorizationStatus}');
      }
      final token = await messaging.getToken();
      if (token != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        await userRef.set({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        await userRef.set({
          'fcmTokens': FieldValue.arrayUnion([newToken]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      if (kDebugMode) {
        print('FCM init failed: $e');
      }
    }
  }

  // Show notification popup
  static Future<void> _showNotification(
    BuildContext context, 
    String message, 
    String target
  ) async {
    if (!context.mounted) return;

    final title = target == 'all_users' 
        ? 'Broadcast Message' 
        : 'Venue Owner Update';

    await showNotificationPopup(
      context: context,
      message: message,
      title: title,
      onClose: () {
        Navigator.of(context).pop();
      },
    );
  }

  // Get all notifications for a user
  static Stream<QuerySnapshot> getNotificationsStream() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get unread notifications count
  static Future<int> getUnreadNotificationsCount() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();
      
      return query.docs.length;
    } catch (e) {
      print('Error getting unread notifications count: $e');
      return 0;
    }
  }
} 