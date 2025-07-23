import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/review_entity.dart';
import '../../data/repositories/review_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final reviewRepositoryProvider = Provider((ref) => ReviewRepositoryImpl(firestore: FirebaseFirestore.instance));

final reviewsForVenueProvider = FutureProvider.family<List<ReviewEntity>, String>((ref, venueId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsForVenue(venueId);
});

final reviewsForUserProvider = FutureProvider.family<List<ReviewEntity>, String>((ref, userId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsForUser(userId);
}); 