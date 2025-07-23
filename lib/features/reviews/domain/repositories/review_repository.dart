import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<ReviewEntity?> getReviewById(String id);
  Future<List<ReviewEntity>> getReviewsForVenue(String venueId);
  Future<List<ReviewEntity>> getReviewsForUser(String userId);
  Future<void> createReview(ReviewEntity review);
  Future<void> updateReview(ReviewEntity review);
  Future<void> deleteReview(String id);
} 