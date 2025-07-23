import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore firestore;
  ReviewRepositoryImpl({required this.firestore});

  @override
  Future<ReviewEntity?> getReviewById(String id) async {
    final doc = await firestore.collection('reviews').doc(id).get();
    if (!doc.exists) return null;
    return ReviewEntity.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<ReviewEntity>> getReviewsForVenue(String venueId) async {
    final snapshot = await firestore.collection('reviews').where('venueId', isEqualTo: venueId).get();
    return snapshot.docs.map((doc) => ReviewEntity.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<ReviewEntity>> getReviewsForUser(String userId) async {
    final snapshot = await firestore.collection('reviews').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => ReviewEntity.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> createReview(ReviewEntity review) async {
    await firestore.collection('reviews').doc(review.id).set(review.toMap());
  }

  @override
  Future<void> updateReview(ReviewEntity review) async {
    await firestore.collection('reviews').doc(review.id).update(review.toMap());
  }

  @override
  Future<void> deleteReview(String id) async {
    await firestore.collection('reviews').doc(id).delete();
  }
} 