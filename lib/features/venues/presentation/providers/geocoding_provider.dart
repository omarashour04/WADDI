import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

final geocodingProvider = Provider((ref) => GeocodingService());

class GeocodingService {
  Future<Location?> getLocationFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return locations.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 