import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/repositories/notifications_repository_impl.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepositoryImpl>((ref) {
  return NotificationsRepositoryImpl();
});

class NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;

  NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsRepositoryImpl _repository;

  NotificationsNotifier(this._repository) : super(NotificationsState());

  Future<void> loadUserNotifications(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final notifications = await _repository.getUserNotifications(userId);
      final unreadCount = await _repository.getUnreadCount(userId);
      
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
      
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _repository.markAllAsRead(userId);
      
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();
      
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> requestNotificationPermission() async {
    try {
      await _repository.requestPermission();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> saveFCMToken(String userId) async {
    try {
      final token = await _repository.getFCMToken();
      if (token != null) {
        await _repository.saveFCMToken(userId, token);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> createBookingReminder(String userId, String bookingId, 
      String venueName, DateTime bookingTime) async {
    try {
      await _repository.createBookingReminder(userId, bookingId, venueName, bookingTime);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> createVenueUpdateNotification(String userId, String venueId, 
      String venueName, String updateMessage) async {
    try {
      await _repository.createVenueUpdateNotification(userId, venueId, venueName, updateMessage);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> createPromotionNotification(String userId, String title, 
      String message, Map<String, dynamic>? data) async {
    try {
      await _repository.createPromotionNotification(userId, title, message, data);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return NotificationsNotifier(repository);
}); 