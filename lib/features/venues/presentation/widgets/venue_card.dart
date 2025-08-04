import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/firebase_image_widget.dart';
import '../../domain/entities/venue_entity.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class VenueCard extends ConsumerStatefulWidget {
  final VenueEntity venue;

  const VenueCard({super.key, required this.venue});

  @override
  ConsumerState<VenueCard> createState() => _VenueCardState();
}

class _VenueCardState extends ConsumerState<VenueCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFavoriteStatus();
    });
  }

  void _checkFavoriteStatus() {
    final user = ref.read(authProvider).user;
    if (user != null && !user.isGuestUser) {
      ref.read(favoritesProvider.notifier).checkFavoriteStatus(user.id, widget.venue.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isFavorited = ref.watch(favoritesProvider.notifier).isVenueFavorited(widget.venue.id);
    final imageUrl = widget.venue.images.isNotEmpty ? widget.venue.images.first : '';

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => context.go('/venues/${widget.venue.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with Favorite Button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: FirebaseImageWidget(imageUrl: imageUrl),
                    ),
                  ),
                  
                  // Favorite Button
                  if (authState.user != null && !authState.user!.isGuestUser)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleFavorite(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: isFavorited ? Colors.red : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  
                  // Maintenance Status
                  if (widget.venue.isClosedForMaintenance)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.engineering, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Under Maintenance',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              
              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.venue.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          widget.venue.description,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          Text(
                            widget.venue.averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${widget.venue.totalReviews})',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFavorite() {
    final user = ref.read(authProvider).user;
    if (user != null && !user.isGuestUser) {
      ref.read(favoritesProvider.notifier).toggleFavorite(
        user.id,
        widget.venue.id,
        widget.venue.name,
        widget.venue.address,
        widget.venue.images,
        widget.venue.averageRating,
        widget.venue.totalReviews,
      );
    }
  }
} 