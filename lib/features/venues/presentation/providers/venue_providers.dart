import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../data/repositories/venue_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final venueRepositoryProvider = Provider((ref) => VenueRepositoryImpl(firestore: FirebaseFirestore.instance));

final allVenuesProvider = FutureProvider<List<VenueEntity>>((ref) async {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getAllVenues();
});

final venueProvider = FutureProvider.family<VenueEntity?, String>((ref, id) async {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getVenueById(id);
});

final roomsForVenueProvider = FutureProvider.family<List<RoomEntity>, String>((ref, venueId) async {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getRoomsForVenue(venueId);
});

// Search and filter state
final venueSearchQueryProvider = StateProvider<String>((ref) => '');
final venueFilterProvider = StateProvider<VenueFilter>((ref) => VenueFilter());

final filteredVenuesProvider = FutureProvider<List<VenueEntity>>((ref) async {
  final repo = ref.watch(venueRepositoryProvider);
  final query = ref.watch(venueSearchQueryProvider);
  final filter = ref.watch(venueFilterProvider);
  return repo.searchAndFilterVenues(query: query, filter: filter);
});

class VenueFilter {
  final double? minRating;
  final String? priceRange;
  final List<String>? amenities;
  final List<String>? gameTypes;
  VenueFilter({this.minRating, this.priceRange, this.amenities, this.gameTypes});
} 