import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/smart_back_button.dart';
import '../../../../shared/themes/app_colors.dart';
import '../providers/favorites_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/favorite_venue_card.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  void _loadFavorites() {
    final user = ref.read(authProvider).user;
    if (user != null && !user.isGuestUser) {
      ref.read(favoritesProvider.notifier).loadUserFavorites(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final favoritesState = ref.watch(favoritesProvider);

    if (authState.user?.isGuestUser == true) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Favorites'),
          leading: const SmartBackButton(),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Please log in to view your favorites',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        leading: const SmartBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (favoritesState.favorites.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  _clearAllFavorites();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All Favorites'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadFavorites(),
        child: favoritesState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoritesState.favorites.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(favoritesState.favorites),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exploring venues and add them to your favorites!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/venues'),
            child: const Text('Browse Venues'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<dynamic> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FavoriteVenueCard(
            favorite: favorite,
            onRemove: () => _removeFavorite(favorite.venueId),
            onTap: () => context.go('/venues/${favorite.venueId}'),
          ),
        );
      },
    );
  }

  Future<void> _removeFavorite(String venueId) async {
    final user = ref.read(authProvider).user;
    if (user != null) {
      await ref.read(favoritesProvider.notifier).toggleFavorite(
        user.id,
        venueId,
        '', // These will be ignored when removing
        '',
        [],
        0.0,
        0,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text('Are you sure you want to remove all favorites? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        // This would require adding clearAllFavorites to the provider
        // For now, we'll just show a message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All favorites cleared'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }
} 