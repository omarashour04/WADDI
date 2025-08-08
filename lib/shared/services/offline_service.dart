import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineService {
  static const String _offlineVenuesKey = 'offline_venues';
  static const String _offlineRoomsKey = 'offline_rooms';
  static const String _pendingBookingsKey = 'pending_bookings';
  static const String _lastSyncKey = 'last_sync';
  
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();

  OfflineService._();

  /// Check if device is online
  Future<bool> isOnline() async {
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

  /// Store venue data for offline access
  Future<void> storeVenueForOffline(Map<String, dynamic> venueData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final venueId = venueData['id'] ?? venueData['venueId'] ?? '';
      
      if (venueId.isEmpty) return;

      // Get existing offline venues
      final existingVenuesString = prefs.getString(_offlineVenuesKey) ?? '{}';
      final existingVenues = jsonDecode(existingVenuesString) as Map<String, dynamic>;
      
      // Add/update venue
      existingVenues[venueId] = {
        'data': venueData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(_offlineVenuesKey, jsonEncode(existingVenues));
      
      if (kDebugMode) {
        print('Stored venue $venueId for offline access');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing venue for offline: $e');
      }
    }
  }

  /// Get offline venue data
  Future<Map<String, dynamic>?> getOfflineVenue(String venueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final venuesString = prefs.getString(_offlineVenuesKey) ?? '{}';
      final venues = jsonDecode(venuesString) as Map<String, dynamic>;
      
      final venueData = venues[venueId];
      if (venueData != null) {
        final timestamp = venueData['timestamp'] as int;
        final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
        
        // Offline data is valid for 24 hours
        if (cacheAge.inHours < 24) {
          if (kDebugMode) {
            print('Retrieved offline venue data for $venueId');
          }
          return venueData['data'] as Map<String, dynamic>;
        } else {
          // Remove expired data
          venues.remove(venueId);
          await prefs.setString(_offlineVenuesKey, jsonEncode(venues));
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving offline venue: $e');
      }
      return null;
    }
  }

  /// Store rooms data for offline access
  Future<void> storeRoomsForOffline(String venueId, List<Map<String, dynamic>> roomsData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing offline rooms
      final existingRoomsString = prefs.getString(_offlineRoomsKey) ?? '{}';
      final existingRooms = jsonDecode(existingRoomsString) as Map<String, dynamic>;
      
      // Add/update rooms for venue
      existingRooms[venueId] = {
        'data': roomsData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(_offlineRoomsKey, jsonEncode(existingRooms));
      
      if (kDebugMode) {
        print('Stored rooms for venue $venueId for offline access');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing rooms for offline: $e');
      }
    }
  }

  /// Get offline rooms data
  Future<List<Map<String, dynamic>>?> getOfflineRooms(String venueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsString = prefs.getString(_offlineRoomsKey) ?? '{}';
      final rooms = jsonDecode(roomsString) as Map<String, dynamic>;
      
      final roomsData = rooms[venueId];
      if (roomsData != null) {
        final timestamp = roomsData['timestamp'] as int;
        final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
        
        // Offline data is valid for 24 hours
        if (cacheAge.inHours < 24) {
          if (kDebugMode) {
            print('Retrieved offline rooms data for venue $venueId');
          }
          final data = roomsData['data'] as List;
          return data.cast<Map<String, dynamic>>();
        } else {
          // Remove expired data
          rooms.remove(venueId);
          await prefs.setString(_offlineRoomsKey, jsonEncode(rooms));
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving offline rooms: $e');
      }
      return null;
    }
  }

  /// Store pending booking for later synchronization
  Future<void> storePendingBooking(Map<String, dynamic> bookingData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing pending bookings
      final pendingBookingsString = prefs.getString(_pendingBookingsKey) ?? '[]';
      final pendingBookings = jsonDecode(pendingBookingsString) as List;
      
      // Add new pending booking
      pendingBookings.add({
        'data': bookingData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      });
      
      await prefs.setString(_pendingBookingsKey, jsonEncode(pendingBookings));
      
      if (kDebugMode) {
        print('Stored pending booking for later sync');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error storing pending booking: $e');
      }
    }
  }

  /// Get all pending bookings
  Future<List<Map<String, dynamic>>> getPendingBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingBookingsString = prefs.getString(_pendingBookingsKey) ?? '[]';
      final pendingBookings = jsonDecode(pendingBookingsString) as List;
      
      return pendingBookings.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving pending bookings: $e');
      }
      return [];
    }
  }

  /// Remove pending booking after successful sync
  Future<void> removePendingBooking(String bookingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingBookingsString = prefs.getString(_pendingBookingsKey) ?? '[]';
      final pendingBookings = jsonDecode(pendingBookingsString) as List;
      
      pendingBookings.removeWhere((booking) => 
        (booking['id'] ?? '') == bookingId
      );
      
      await prefs.setString(_pendingBookingsKey, jsonEncode(pendingBookings));
      
      if (kDebugMode) {
        print('Removed pending booking $bookingId after sync');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing pending booking: $e');
      }
    }
  }

  /// Sync pending bookings when online
  Future<void> syncPendingBookings(Future<void> Function(Map<String, dynamic>) syncFunction) async {
    if (!await isOnline()) {
      if (kDebugMode) {
        print('Cannot sync: device is offline');
      }
      return;
    }

    try {
      final pendingBookings = await getPendingBookings();
      
      if (pendingBookings.isEmpty) {
        if (kDebugMode) {
          print('No pending bookings to sync');
        }
        return;
      }

      if (kDebugMode) {
        print('Syncing ${pendingBookings.length} pending bookings');
      }

      for (final pendingBooking in pendingBookings) {
        try {
          await syncFunction(pendingBooking['data'] as Map<String, dynamic>);
          await removePendingBooking(pendingBooking['id'] as String);
        } catch (e) {
          if (kDebugMode) {
            print('Error syncing booking ${pendingBooking['id']}: $e');
          }
        }
      }

      if (kDebugMode) {
        print('Completed pending bookings sync');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during pending bookings sync: $e');
      }
    }
  }

  /// Update last sync timestamp
  Future<void> updateLastSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last sync timestamp: $e');
      }
    }
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey);
      
      if (lastSyncString != null) {
        return DateTime.parse(lastSyncString);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last sync timestamp: $e');
      }
      return null;
    }
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlineVenuesKey);
      await prefs.remove(_offlineRoomsKey);
      await prefs.remove(_pendingBookingsKey);
      await prefs.remove(_lastSyncKey);
      
      if (kDebugMode) {
        print('Cleared all offline data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing offline data: $e');
      }
    }
  }

  /// Get offline data statistics
  Future<Map<String, dynamic>> getOfflineStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final venuesString = prefs.getString(_offlineVenuesKey) ?? '{}';
      final roomsString = prefs.getString(_offlineRoomsKey) ?? '{}';
      final pendingBookingsString = prefs.getString(_pendingBookingsKey) ?? '[]';
      
      final venues = jsonDecode(venuesString) as Map<String, dynamic>;
      final rooms = jsonDecode(roomsString) as Map<String, dynamic>;
      final pendingBookings = jsonDecode(pendingBookingsString) as List;
      
      final lastSync = await getLastSync();
      return {
        'offline_venues': venues.length,
        'offline_rooms': rooms.length,
        'pending_bookings': pendingBookings.length,
        'last_sync': lastSync?.toIso8601String(),
        'is_online': await isOnline(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
} 