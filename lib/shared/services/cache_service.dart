import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CacheService {
  static const String _availabilityPrefix = 'availability_';
  static const String _venuePrefix = 'venue_';
  static const String _roomsPrefix = 'rooms_';
  static const String _lastUpdatedPrefix = 'last_updated_';
  
  // Cache duration constants
  static const Duration _availabilityCacheDuration = Duration(minutes: 5);
  static const Duration _venueCacheDuration = Duration(hours: 1);
  static const Duration _roomsCacheDuration = Duration(hours: 1);

  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();

  CacheService._();

  /// Cache availability data for a specific venue and date
  Future<void> cacheAvailabilityData({
    required String venueId,
    required DateTime date,
    required Map<String, dynamic> data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getAvailabilityKey(venueId, date);
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'date': date.toIso8601String(),
      };
      
      await prefs.setString(key, jsonEncode(cacheData));
      
      if (kDebugMode) {
        print('Cached availability data for venue $venueId on ${date.toIso8601String()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching availability data: $e');
      }
    }
  }

  /// Get cached availability data for a specific venue and date
  Future<Map<String, dynamic>?> getCachedAvailabilityData({
    required String venueId,
    required DateTime date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getAvailabilityKey(venueId, date);
      final cachedString = prefs.getString(key);
      
      if (cachedString == null) return null;

      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cachedDate = DateTime.parse(cacheData['date'] as String);
      
      // Check if cache is still valid
      final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
      final isSameDate = cachedDate.year == date.year && 
                        cachedDate.month == date.month && 
                        cachedDate.day == date.day;
      
      if (cacheAge < _availabilityCacheDuration && isSameDate) {
        if (kDebugMode) {
          print('Retrieved cached availability data for venue $venueId on ${date.toIso8601String()}');
        }
        return cacheData['data'] as Map<String, dynamic>;
      } else {
        // Cache expired, remove it
        await prefs.remove(key);
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving cached availability data: $e');
      }
      return null;
    }
  }

  /// Cache venue data
  Future<void> cacheVenueData({
    required String venueId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_venuePrefix$venueId';
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(key, jsonEncode(cacheData));
      
      if (kDebugMode) {
        print('Cached venue data for venue $venueId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching venue data: $e');
      }
    }
  }

  /// Get cached venue data
  Future<Map<String, dynamic>?> getCachedVenueData(String venueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_venuePrefix$venueId';
      final cachedString = prefs.getString(key);
      
      if (cachedString == null) return null;

      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      
      // Check if cache is still valid
      final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
      
      if (cacheAge < _venueCacheDuration) {
        if (kDebugMode) {
          print('Retrieved cached venue data for venue $venueId');
        }
        return cacheData['data'] as Map<String, dynamic>;
      } else {
        // Cache expired, remove it
        await prefs.remove(key);
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving cached venue data: $e');
      }
      return null;
    }
  }

  /// Cache rooms data for a venue
  Future<void> cacheRoomsData({
    required String venueId,
    required List<Map<String, dynamic>> data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_roomsPrefix$venueId';
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(key, jsonEncode(cacheData));
      
      if (kDebugMode) {
        print('Cached rooms data for venue $venueId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching rooms data: $e');
      }
    }
  }

  /// Get cached rooms data
  Future<List<Map<String, dynamic>>?> getCachedRoomsData(String venueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_roomsPrefix$venueId';
      final cachedString = prefs.getString(key);
      
      if (cachedString == null) return null;

      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      
      // Check if cache is still valid
      final cacheAge = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
      
      if (cacheAge < _roomsCacheDuration) {
        if (kDebugMode) {
          print('Retrieved cached rooms data for venue $venueId');
        }
        final data = cacheData['data'] as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        // Cache expired, remove it
        await prefs.remove(key);
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving cached rooms data: $e');
      }
      return null;
    }
  }

  /// Batch cache availability data for multiple dates
  Future<void> batchCacheAvailabilityData({
    required String venueId,
    required Map<DateTime, Map<String, dynamic>> dataMap,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final batchData = <String, String>{};
      
      for (final entry in dataMap.entries) {
        final date = entry.key;
        final data = entry.value;
        final key = _getAvailabilityKey(venueId, date);
        
        final cacheData = {
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'date': date.toIso8601String(),
        };
        
        batchData[key] = jsonEncode(cacheData);
      }
      
      // Batch write to SharedPreferences
      for (final entry in batchData.entries) {
        await prefs.setString(entry.key, entry.value);
      }
      
      if (kDebugMode) {
        print('Batch cached availability data for venue $venueId for ${dataMap.length} dates');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error batch caching availability data: $e');
      }
    }
  }

  /// Get cached availability data for multiple dates
  Future<Map<DateTime, Map<String, dynamic>>> getBatchCachedAvailabilityData({
    required String venueId,
    required List<DateTime> dates,
  }) async {
    final result = <DateTime, Map<String, dynamic>>{};
    
    for (final date in dates) {
      final cachedData = await getCachedAvailabilityData(venueId: venueId, date: date);
      if (cachedData != null) {
        result[date] = cachedData;
      }
    }
    
    if (kDebugMode) {
      print('Retrieved batch cached availability data for venue $venueId: ${result.length}/${dates.length} dates found');
    }
    
    return result;
  }

  /// Clear all cached data for a venue
  Future<void> clearVenueCache(String venueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('$_availabilityPrefix$venueId') ||
            key.startsWith('$_venuePrefix$venueId') ||
            key.startsWith('$_roomsPrefix$venueId')) {
          await prefs.remove(key);
        }
      }
      
      if (kDebugMode) {
        print('Cleared all cached data for venue $venueId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing venue cache: $e');
      }
    }
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_availabilityPrefix) ||
            key.startsWith(_venuePrefix) ||
            key.startsWith(_roomsPrefix)) {
          await prefs.remove(key);
        }
      }
      
      if (kDebugMode) {
        print('Cleared all cached data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all cache: $e');
      }
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int availabilityCount = 0;
      int venueCount = 0;
      int roomsCount = 0;
      
      for (final key in keys) {
        if (key.startsWith(_availabilityPrefix)) availabilityCount++;
        if (key.startsWith(_venuePrefix)) venueCount++;
        if (key.startsWith(_roomsPrefix)) roomsCount++;
      }
      
      return {
        'availability_entries': availabilityCount,
        'venue_entries': venueCount,
        'rooms_entries': roomsCount,
        'total_entries': availabilityCount + venueCount + roomsCount,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  String _getAvailabilityKey(String venueId, DateTime date) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$_availabilityPrefix${venueId}_$dateString';
  }
} 