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
      
      // Validate and repair offline data on initialization
      await validateAndRepairOfflineData();
      
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
      
      // Validate that all data is JSON serializable
      final jsonString = jsonEncode(bookingsData);
      await prefs.setString('offline_user_bookings', jsonString);
      
      if (kDebugMode) {
        print('Stored ${bookings.length} user bookings for offline access');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing user bookings for offline: $e');
        // Log the problematic data for debugging
        try {
          for (int i = 0; i < bookings.length; i++) {
            final booking = bookings[i];
            jsonEncode(booking); // Test each booking individually
          }
        } catch (jsonError) {
          print('JSON serialization error in booking: $jsonError');
        }
      }
    }
  }

  /// Get user bookings for offline access
  Future<List<Map<String, dynamic>>> getOfflineUserBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsString = prefs.getString('offline_user_bookings');
      
      if (bookingsString == null || bookingsString.isEmpty) return [];

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
        if (kDebugMode) {
          print('Offline bookings expired, removed from storage');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving offline user bookings: $e');
      }
      // Clear corrupted data
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('offline_user_bookings');
        if (kDebugMode) {
          print('Cleared corrupted offline bookings data');
        }
      } catch (clearError) {
        if (kDebugMode) {
          print('Error clearing corrupted offline data: $clearError');
        }
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

  /// Clear all offline data (useful for logout or data corruption)
  Future<void> clearAllOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('offline_user_bookings');
      await prefs.remove('offline_user_profile');
      
      if (kDebugMode) {
        print('All offline data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing offline data: $e');
      }
    }
  }

  /// Check if offline data exists and is valid
  Future<bool> hasValidOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check bookings
      final bookingsString = prefs.getString('offline_user_bookings');
      if (bookingsString != null && bookingsString.isNotEmpty) {
        final bookingsData = jsonDecode(bookingsString) as Map<String, dynamic>;
        final timestamp = bookingsData['timestamp'] as int;
        final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
        
        if (cacheAge.inHours < 24) {
          return true;
        }
      }
      
      // Check profile
      final profileString = prefs.getString('offline_user_profile');
      if (profileString != null && profileString.isNotEmpty) {
        final profileData = jsonDecode(profileString) as Map<String, dynamic>;
        final timestamp = profileData['timestamp'] as int;
        final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
        
        if (cacheAge.inHours < 24) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking offline data validity: $e');
      }
      return false;
    }
  }

  /// Get offline data statistics
  Future<Map<String, dynamic>> getOfflineDataStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = <String, dynamic>{};
      
      // Check bookings
      final bookingsString = prefs.getString('offline_user_bookings');
      if (bookingsString != null && bookingsString.isNotEmpty) {
        final bookingsData = jsonDecode(bookingsString) as Map<String, dynamic>;
        final timestamp = bookingsData['timestamp'] as int;
        final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
        final bookings = bookingsData['bookings'] as List;
        
        stats['bookings'] = {
          'count': bookings.length,
          'age_hours': cacheAge.inHours,
          'is_valid': cacheAge.inHours < 24,
        };
      }
      
      // Check profile
      final profileString = prefs.getString('offline_user_profile');
      if (profileString != null && profileString.isNotEmpty) {
        final profileData = jsonDecode(profileString) as Map<String, dynamic>;
        final timestamp = profileData['timestamp'] as int;
        final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
        
        stats['profile'] = {
          'age_hours': cacheAge.inHours,
          'is_valid': cacheAge.inHours < 24,
        };
      }
      
      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting offline data stats: $e');
      }
      return {};
    }
  }

  /// Validate and repair offline data
  Future<bool> validateAndRepairOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool needsRepair = false;
      
      // Validate bookings data
      final bookingsString = prefs.getString('offline_user_bookings');
      if (bookingsString != null && bookingsString.isNotEmpty) {
        try {
          final bookingsData = jsonDecode(bookingsString) as Map<String, dynamic>;
          final timestamp = bookingsData['timestamp'] as int;
          final bookings = bookingsData['bookings'] as List;
          
          // Check if data structure is valid
          if (bookings is! List) {
            needsRepair = true;
          } else {
            // Validate each booking
            for (final booking in bookings) {
              if (booking is! Map<String, dynamic>) {
                needsRepair = true;
                break;
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Bookings data corrupted: $e');
          }
          needsRepair = true;
        }
      }
      
      // Validate profile data
      final profileString = prefs.getString('offline_user_profile');
      if (profileString != null && profileString.isNotEmpty) {
        try {
          final profileData = jsonDecode(profileString) as Map<String, dynamic>;
          if (profileData is! Map<String, dynamic>) {
            needsRepair = true;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Profile data corrupted: $e');
          }
          needsRepair = true;
        }
      }
      
      // Repair if needed
      if (needsRepair) {
        if (kDebugMode) {
          print('Repairing corrupted offline data...');
        }
        await clearAllOfflineData();
        return false; // Data was corrupted and cleared
      }
      
      return true; // Data is valid
    } catch (e) {
      if (kDebugMode) {
        print('Error validating offline data: $e');
      }
      // If validation itself fails, clear data to be safe
      await clearAllOfflineData();
      return false;
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