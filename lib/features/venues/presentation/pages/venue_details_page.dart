import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/venue_providers.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../../reviews/presentation/providers/review_providers.dart';
import '../../../reviews/domain/entities/review_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';

class VenueDetailsPage extends ConsumerWidget {
  final String venueId;
  const VenueDetailsPage({required this.venueId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venueAsync = ref.watch(venueProvider(venueId));
    final reviewsAsync = ref.watch(reviewsForVenueProvider(venueId));

    return venueAsync.when(
      data: (venue) {
        if (venue == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              title: const Text('Venue Details'),
            ),
            body: const Center(child: Text('Venue not found.')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    try {
                      context.pop();
                    } catch (e) {
                      // If pop fails, navigate to venues page
                      context.go('/venues');
                    }
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Venue Image
                      Image.network(
                        venue.images.isNotEmpty
                            ? venue.images.first
                            : 'https://via.placeholder.com/400x300/4A90E2/FFFFFF?text=Venue+Image',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primary,
                            child: const Icon(Icons.image, size: 100, color: Colors.white),
                          );
                        },
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue Name
                      Text(
                        venue.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Address
                      Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              venue.address ?? '123 Elm Street, Springfield, IL 62704',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Phone
                      Row(
                        children: [
                          Icon(Icons.phone, color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            venue.contactPhone.isNotEmpty ? venue.contactPhone : '(555) 123-4567',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Map Section
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map, size: 40, color: AppColors.primary),
                              const SizedBox(height: 8),
                              Text('Map View', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Amenities Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Amenities',
                          style: TextStyle(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Amenities Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3,
                        children: [
                          _AmenityCard(
                            icon: Icons.games,
                            title: 'Gaming Consoles',
                            color: AppColors.primaryLight,
                          ),
                          _AmenityCard(
                            icon: Icons.wifi,
                            title: 'Free Wi-Fi',
                            color: AppColors.primaryLight,
                          ),
                          _AmenityCard(
                            icon: Icons.local_cafe,
                            title: 'Cafe',
                            color: AppColors.primaryLight,
                          ),
                          _AmenityCard(
                            icon: Icons.local_parking,
                            title: 'Parking',
                            color: AppColors.primaryLight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Reviews Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Reviews',
                          style: TextStyle(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Overall Rating
                      Row(
                        children: [
                          Text(
                            '4.6',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < 4 ? Icons.star : Icons.star_half,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                              ),
                              Text('125 reviews', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rating Distribution
                      _RatingDistribution(),
                      const SizedBox(height: 16),

                      // Individual Reviews
                      reviewsAsync.when(
                        data: (reviews) {
                          if (reviews.isEmpty) {
                            return const Text('No reviews yet.');
                          }
                          return Column(
                            children: reviews
                                .take(2)
                                .map((review) => _ReviewCard(review: review))
                                .toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Text('Error loading reviews: $e'),
                      ),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Check if user is a guest user
                final authState = ref.watch(authProvider);
                if (authState.isGuestUser) {
                  // Show dialog to redirect to login
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Login Required'),
                      content: const Text(
                        'Guest users cannot make bookings. Please log in to continue.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.push('/login');
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                // Navigate to rooms page for authenticated users
                context.go('/venues/$venueId/rooms');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.textOnSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: const Text('Venue Details'),
        ),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AmenityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _AmenityCard({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RatingBar(rating: 5, percentage: 50, count: 62),
        _RatingBar(rating: 4, percentage: 30, count: 38),
        _RatingBar(rating: 3, percentage: 10, count: 12),
        _RatingBar(rating: 2, percentage: 0, count: 0),
        _RatingBar(rating: 1, percentage: 10, count: 12),
      ],
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int rating;
  final double percentage;
  final int count;

  const _RatingBar({required this.rating, required this.percentage, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$rating', style: TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text('$count', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  'U', // Using 'U' as placeholder since we don't have userName
                  style: TextStyle(color: AppColors.textOnPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${review.userId.substring(0, 8)}', // Using userId as placeholder
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '2 weeks ago',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: TextStyle(color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.thumb_up, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('15', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.comment, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('2', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
