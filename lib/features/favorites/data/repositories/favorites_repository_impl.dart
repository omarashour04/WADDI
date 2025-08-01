import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/favorite_venue.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<FavoriteVenue>> getUserFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FavoriteVenue.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  @override
  Future<bool> isVenueFavorited(String userId, String venueId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('venueId', isEqualTo: venueId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  @override
  Future<void> addToFavorites(FavoriteVenue favorite) async {
    try {
      await _firestore.collection('favorites').add(favorite.toMap());
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String venueId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('venueId', isEqualTo: venueId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  @override
  Future<void> clearAllFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear favorites: $e');
    }
  }
} 