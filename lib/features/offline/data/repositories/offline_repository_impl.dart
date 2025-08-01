import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/repositories/offline_repository.dart';

class OfflineRepositoryImpl implements OfflineRepository {
  static const String _venuesKey = 'cached_venues';
  static const String _userDataKey = 'cached_user_data';
  static const String _favoritesKey = 'cached_favorites';
  static const String _bookingsKey = 'cached_bookings';
  static const String _lastSyncKey = 'last_sync_timestamp';

  @override
  Future<void> cacheVenues(List<Map<String, dynamic>> venues) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final venuesJson = jsonEncode(venues);
      await prefs.setString(_venuesKey, venuesJson);
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw Exception('Failed to cache venues: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedVenues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final venuesJson = prefs.getString(_venuesKey);
      if (venuesJson != null) {
        final List<dynamic> venuesList = jsonDecode(venuesJson);
        return venuesList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get cached venues: $e');
    }
  }

  @override
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = jsonEncode(userData);
      await prefs.setString(_userDataKey, userDataJson);
    } catch (e) {
      throw Exception('Failed to cache user data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);
      if (userDataJson != null) {
        return jsonDecode(userDataJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get cached user data: $e');
    }
  }

  @override
  Future<void> cacheFavorites(List<Map<String, dynamic>> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = jsonEncode(favorites);
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      throw Exception('Failed to cache favorites: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = jsonDecode(favoritesJson);
        return favoritesList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get cached favorites: $e');
    }
  }

  @override
  Future<void> cacheBookings(List<Map<String, dynamic>> bookings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = jsonEncode(bookings);
      await prefs.setString(_bookingsKey, bookingsJson);
    } catch (e) {
      throw Exception('Failed to cache bookings: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getString(_bookingsKey);
      if (bookingsJson != null) {
        final List<dynamic> bookingsList = jsonDecode(bookingsJson);
        return bookingsList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get cached bookings: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get last sync time: $e');
    }
  }

  @override
  Future<bool> isDataStale(Duration maxAge) async {
    try {
      final lastSync = await getLastSyncTime();
      if (lastSync == null) return true;
      
      final now = DateTime.now();
      final difference = now.difference(lastSync);
      return difference > maxAge;
    } catch (e) {
      return true; // Assume stale if error
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_venuesKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_favoritesKey);
      await prefs.remove(_bookingsKey);
      await prefs.remove(_lastSyncKey);
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> cacheImage(String url, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/cached_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final file = File('${imagesDir.path}/$fileName');
      // In a real implementation, you would download and save the image here
      // For now, we'll just create a placeholder
      await file.writeAsString('cached_image_placeholder');
    } catch (e) {
      throw Exception('Failed to cache image: $e');
    }
  }

  @override
  Future<String?> getCachedImagePath(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/cached_images');
      final file = File('${imagesDir.path}/$fileName');
      
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearImageCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/cached_images');
      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to clear image cache: $e');
    }
  }
} 