import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<List<NotificationEntity>> getUserNotifications(String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<String?> getFCMToken();
  Future<void> saveFCMToken(String userId, String token);
  Future<void> requestPermission();
  Future<void> createBookingReminder(String userId, String bookingId, String venueName, DateTime bookingTime);
  Future<void> createVenueUpdateNotification(String userId, String venueId, String venueName, String updateMessage);
  Future<void> createPromotionNotification(String userId, String title, String message, Map<String, dynamic>? data);
} 