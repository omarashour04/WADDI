import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/favorite_venue.dart';
import '../../data/repositories/favorites_repository_impl.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepositoryImpl>((ref) {
  return FavoritesRepositoryImpl();
});

class FavoritesState {
  final List<FavoriteVenue> favorites;
  final Map<String, bool> favoriteStatus; // venueId -> isFavorited
  final bool isLoading;
  final String? errorMessage;

  FavoritesState({
    this.favorites = const [],
    this.favoriteStatus = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  FavoritesState copyWith({
    List<FavoriteVenue>? favorites,
    Map<String, bool>? favoriteStatus,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesRepositoryImpl _repository;

  FavoritesNotifier(this._repository) : super(FavoritesState());

  Future<void> loadUserFavorites(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final favorites = await _repository.getUserFavorites(userId);
      final favoriteStatus = <String, bool>{};
      
      for (final favorite in favorites) {
        favoriteStatus[favorite.venueId] = true;
      }
      
      state = state.copyWith(
        favorites: favorites,
        favoriteStatus: favoriteStatus,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> toggleFavorite(String userId, String venueId, String venueName, 
      String venueAddress, List<String> venueImages, double averageRating, int totalReviews) async {
    try {
      final isCurrentlyFavorited = state.favoriteStatus[venueId] ?? false;
      
      if (isCurrentlyFavorited) {
        await _repository.removeFromFavorites(userId, venueId);
        
        final updatedFavorites = state.favorites.where((f) => f.venueId != venueId).toList();
        final updatedStatus = Map<String, bool>.from(state.favoriteStatus);
        updatedStatus[venueId] = false;
        
        state = state.copyWith(
          favorites: updatedFavorites,
          favoriteStatus: updatedStatus,
        );
      } else {
        final favorite = FavoriteVenue(
          id: '',
          userId: userId,
          venueId: venueId,
          venueName: venueName,
          venueAddress: venueAddress,
          venueImages: venueImages,
          averageRating: averageRating,
          totalReviews: totalReviews,
          addedAt: DateTime.now(),
        );
        
        await _repository.addToFavorites(favorite);
        
        final updatedFavorites = [favorite, ...state.favorites];
        final updatedStatus = Map<String, bool>.from(state.favoriteStatus);
        updatedStatus[venueId] = true;
        
        state = state.copyWith(
          favorites: updatedFavorites,
          favoriteStatus: updatedStatus,
        );
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> checkFavoriteStatus(String userId, String venueId) async {
    try {
      final isFavorited = await _repository.isVenueFavorited(userId, venueId);
      final updatedStatus = Map<String, bool>.from(state.favoriteStatus);
      updatedStatus[venueId] = isFavorited;
      
      state = state.copyWith(favoriteStatus: updatedStatus);
    } catch (e) {
      // Silently handle error for status check
    }
  }

  bool isVenueFavorited(String venueId) {
    return state.favoriteStatus[venueId] ?? false;
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return FavoritesNotifier(repository);
}); 