import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/venue_entity.dart';
import '../../data/repositories/venue_repository_impl.dart';

final venueRepositoryProvider = Provider<VenueRepositoryImpl>((ref) {
  return VenueRepositoryImpl(firestore: FirebaseFirestore.instance);
});

final venuesProvider = FutureProvider<List<VenueEntity>>((ref) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getAllVenues();
});

final venueProvider = FutureProvider.family<VenueEntity?, String>((ref, venueId) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getVenueById(venueId);
}); 