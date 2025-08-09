import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../data/repositories/venue_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final venueRepositoryProvider = Provider(
  (ref) => VenueRepositoryImpl(firestore: FirebaseFirestore.instance),
);

// Cache for venues to reduce Firestore calls
final _venuesCache = <String, List<VenueEntity>>{};

final allVenuesProvider = FutureProvider<List<VenueEntity>>((ref) async {
  try {
    final cacheKey = 'all_venues';
    if (_venuesCache.containsKey(cacheKey)) {
      return _venuesCache[cacheKey]!;
    }

  final repo = ref.watch(venueRepositoryProvider);
    final venues = await repo.getAllVenues();
    _venuesCache[cacheKey] = venues;
    return venues;
  } catch (e, stackTrace) {
    print('Error loading venues: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
});

final venueProvider = FutureProvider.family<VenueEntity?, String>((ref, id) async {
  try {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getVenueById(id);
  } catch (e, stackTrace) {
    print('Error loading venue $id: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
});

final roomsForVenueProvider = FutureProvider.family<List<RoomEntity>, String>((ref, venueId) async {
  try {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getRoomsForVenue(venueId);
  } catch (e, stackTrace) {
    print('Error loading rooms for venue $venueId: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
});

final roomProvider = FutureProvider.family<RoomEntity?, String>((ref, roomId) async {
  try {
    final repo = ref.watch(venueRepositoryProvider);
    return repo.getRoomById(roomId);
  } catch (e, stackTrace) {
    print('Error loading room $roomId: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
});

// Search and filter state
final venueSearchQueryProvider = StateProvider<String>((ref) => '');
final venueFilterProvider = StateProvider<VenueFilter>((ref) => VenueFilter());

// Optimized filtered venues provider with caching
final filteredVenuesProvider = FutureProvider<List<VenueEntity>>((ref) async {
  try {
  final repo = ref.watch(venueRepositoryProvider);
  final query = ref.watch(venueSearchQueryProvider);
  final filter = ref.watch(venueFilterProvider);

    // Create cache key based on query and filter
    final cacheKey = '${query}_${filter.hashCode}';
    if (_venuesCache.containsKey(cacheKey)) {
      return _venuesCache[cacheKey]!;
    }

    // Perform search and filter directly (removed compute isolation)
    final venues = await repo.searchAndFilterVenues(query: query, filter: filter);
    _venuesCache[cacheKey] = venues;
    return venues;
  } catch (e, stackTrace) {
    print('Error in filteredVenuesProvider: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
});

// Cache invalidation provider
final cacheInvalidationProvider = Provider((ref) {
  return () {
    _venuesCache.clear();
  };
});

class VenueFilter {
  final double? minRating;
  final String? priceRange;
  final List<String>? amenities;
  final List<String>? gameTypes;
  final bool? openEndedOnly;

  VenueFilter({this.minRating, this.priceRange, this.amenities, this.gameTypes, this.openEndedOnly});

  @override
  int get hashCode {
    return Object.hash(minRating, priceRange, amenities, gameTypes, openEndedOnly);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VenueFilter &&
        other.minRating == minRating &&
        other.priceRange == priceRange &&
        other.amenities == amenities &&
        other.gameTypes == gameTypes &&
        other.openEndedOnly == openEndedOnly;
  }
}
