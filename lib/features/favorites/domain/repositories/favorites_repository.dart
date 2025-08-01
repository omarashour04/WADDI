import '../entities/favorite_venue.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteVenue>> getUserFavorites(String userId);
  Future<bool> isVenueFavorited(String userId, String venueId);
  Future<void> addToFavorites(FavoriteVenue favorite);
  Future<void> removeFromFavorites(String userId, String venueId);
  Future<void> clearAllFavorites(String userId);
} 