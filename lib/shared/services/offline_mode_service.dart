import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class OfflineModeService {
  static OfflineModeService? _instance;
  static OfflineModeService get instance => _instance ??= OfflineModeService._();

  OfflineModeService._();

  bool _isOnline = true;
  bool _isInitialized = false;

  // Stream controller for connectivity changes
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize the offline mode service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check initial connectivity
      _isOnline = await _checkConnectivity();
      _isInitialized = true;

      // Listen to connectivity changes
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;
        
        if (wasOnline != _isOnline) {
          if (kDebugMode) {
            print('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
          }
          _connectivityController.add(_isOnline);
        }
      });

      if (kDebugMode) {
        print('OfflineModeService initialized. Initial state: ${_isOnline ? 'Online' : 'Offline'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing OfflineModeService: $e');
      }
      _isOnline = false;
    }
  }

  /// Check if device is currently online
  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return false;
    }
  }

  /// Get current online status
  bool get isOnline => _isOnline;

  /// Check if a specific operation is allowed in offline mode
  bool isOperationAllowed(OfflineOperation operation) {
    if (_isOnline) return true;

    // Define which operations are allowed offline
    switch (operation) {
      case OfflineOperation.viewBookings:
      case OfflineOperation.viewBookingDetails:
      case OfflineOperation.viewProfile:
      case OfflineOperation.editProfile:
      case OfflineOperation.viewSettings:
      case OfflineOperation.viewAccessibilitySettings:
        return true; // These operations are allowed offline
      
      case OfflineOperation.browseVenues:
      case OfflineOperation.viewVenueDetails:
      case OfflineOperation.bookVenue:
      case OfflineOperation.searchVenues:
      case OfflineOperation.viewFavorites:
      case OfflineOperation.addToFavorites:
      case OfflineOperation.removeFromFavorites:
      case OfflineOperation.cancelBooking:
      case OfflineOperation.addReview:
      case OfflineOperation.viewNotifications:
      case OfflineOperation.adminOperations:
      case OfflineOperation.venueOwnerOperations:
        return false; // These operations require internet
    }
  }

  /// Get offline mode message for restricted operations
  String getOfflineMessage(OfflineOperation operation) {
    switch (operation) {
      case OfflineOperation.browseVenues:
        return 'Venue browsing is not available offline. Please check your internet connection.';
      
      case OfflineOperation.viewVenueDetails:
        return 'Venue details are not available offline. Please check your internet connection.';
      
      case OfflineOperation.bookVenue:
        return 'Booking is not available offline. Please check your internet connection.';
      
      case OfflineOperation.searchVenues:
        return 'Search is not available offline. Please check your internet connection.';
      
      case OfflineOperation.viewFavorites:
        return 'Favorites are not available offline. Please check your internet connection.';
      
      case OfflineOperation.addToFavorites:
        return 'Adding to favorites requires internet connection.';
      
      case OfflineOperation.removeFromFavorites:
        return 'Removing from favorites requires internet connection.';
      
      case OfflineOperation.cancelBooking:
        return 'Canceling bookings requires internet connection.';
      
      case OfflineOperation.addReview:
        return 'Adding reviews requires internet connection.';
      
      case OfflineOperation.viewNotifications:
        return 'Notifications are not available offline. Please check your internet connection.';
      
      case OfflineOperation.adminOperations:
        return 'Admin operations require internet connection.';
      
      case OfflineOperation.venueOwnerOperations:
        return 'Venue owner operations require internet connection.';
      
      default:
        return 'This operation is not available offline. Please check your internet connection.';
    }
  }

  /// Store user bookings for offline access
  Future<void> storeUserBookingsForOffline(List<Map<String, dynamic>> bookings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsData = {
        'bookings': bookings,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString('offline_user_bookings', jsonEncode(bookingsData));
      
      if (kDebugMode) {
        print('Stored ${bookings.length} user bookings for offline access');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing user bookings for offline: $e');
      }
    }
  }

  /// Get user bookings for offline access
  Future<List<Map<String, dynamic>>> getOfflineUserBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsString = prefs.getString('offline_user_bookings');
      
      if (bookingsString == null) return [];

      final bookingsData = jsonDecode(bookingsString) as Map<String, dynamic>;
      final timestamp = bookingsData['timestamp'] as int;
      final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
      
      // Offline bookings are valid for 24 hours
      if (cacheAge.inHours < 24) {
        final bookings = bookingsData['bookings'] as List;
        return bookings.cast<Map<String, dynamic>>();
      } else {
        // Remove expired data
        await prefs.remove('offline_user_bookings');
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving offline user bookings: $e');
      }
      return [];
    }
  }

  /// Store user profile for offline access
  Future<void> storeUserProfileForOffline(Map<String, dynamic> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = {
        'profile': profile,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString('offline_user_profile', jsonEncode(profileData));
      
      if (kDebugMode) {
        print('Stored user profile for offline access');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing user profile for offline: $e');
      }
    }
  }

  /// Get user profile for offline access
  Future<Map<String, dynamic>?> getOfflineUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString('offline_user_profile');
      
      if (profileString == null) return null;

      final profileData = jsonDecode(profileString) as Map<String, dynamic>;
      final timestamp = profileData['timestamp'] as int;
      final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
      
      // Offline profile is valid for 24 hours
      if (cacheAge.inHours < 24) {
        return profileData['profile'] as Map<String, dynamic>;
      } else {
        // Remove expired data
        await prefs.remove('offline_user_profile');
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving offline user profile: $e');
      }
      return null;
    }
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('offline_user_bookings');
      await prefs.remove('offline_user_profile');
      
      if (kDebugMode) {
        print('Cleared all offline data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing offline data: $e');
      }
    }
  }

  /// Get offline mode statistics
  Future<Map<String, dynamic>> getOfflineStats() async {
    try {
      final offlineBookings = await getOfflineUserBookings();
      final offlineProfile = await getOfflineUserProfile();
      
      return {
        'is_online': _isOnline,
        'offline_bookings_count': offlineBookings.length,
        'has_offline_profile': offlineProfile != null,
        'last_sync': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivityController.close();
  }
}

/// Enum for different operations that can be restricted in offline mode
enum OfflineOperation {
  // Allowed offline
  viewBookings,
  viewBookingDetails,
  viewProfile,
  editProfile,
  viewSettings,
  viewAccessibilitySettings,
  
  // Requires internet
  browseVenues,
  viewVenueDetails,
  bookVenue,
  searchVenues,
  viewFavorites,
  addToFavorites,
  removeFromFavorites,
  cancelBooking,
  addReview,
  viewNotifications,
  adminOperations,
  venueOwnerOperations,
} 