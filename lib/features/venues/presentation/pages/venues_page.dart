import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/venue_providers.dart';
import '../../domain/entities/venue_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/geocoding_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:waddi_platform/shared/widgets/main_scaffold.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import '../../../../core/services/app_state_service.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../../shared/widgets/pull_to_refresh_wrapper.dart';
import '../../../../shared/widgets/lottie_animations.dart';
import '../../../../shared/widgets/firebase_image_widget.dart';
import '../../../../shared/widgets/smart_back_button.dart';
import 'package:waddi_platform/shared/providers/shared_providers.dart';
import 'package:waddi_platform/shared/widgets/offline_mode_widget.dart';
import 'package:waddi_platform/shared/services/offline_mode_service.dart';

class VenuesPage extends ConsumerStatefulWidget {
  const VenuesPage({super.key});

  @override
  ConsumerState<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends ConsumerState<VenuesPage> {
  bool isGrid = false;
  int selectedTab = 0; // 0: List/Grid, 1: Map

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id ?? '';
    final venuesAsync = ref.watch(filteredVenuesProvider);
    final searchController = TextEditingController(text: ref.read(venueSearchQueryProvider));
    final filter = ref.watch(venueFilterProvider);
    final geocodingService = ref.read(geocodingProvider);
    CameraPosition? searchedCameraPosition;

    // Update navigation state when page is built
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(navigationStateProvider.notifier).updateCurrentRoute('/venues');
    // });

    return MainScaffold(
      currentIndex: 1, // Venues tab
      userId: userId,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          title: const Text('Venues'),
          elevation: 0,
          leading: SmartBackButton(),
        ),
        body: OfflineModeWidget(
          operation: OfflineOperation.browseVenues,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Search Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for venues',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (query) {
                              if (query.trim().isNotEmpty) {
                                // Navigate to search page with the query
                                context.go('/search?query=${Uri.encodeComponent(query.trim())}');
                              }
                            },
                            onTap: () {
                              // Navigate to search page when tapped
                              context.go('/search');
                            },
                            readOnly: true, // Make it read-only so it acts as a button
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          // Navigate to search page with filter dialog
                          context.go('/search');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.location_searching),
                        tooltip: 'Search by address',
                        onPressed: () {
                          // Navigate to search page for location search
                          context.go('/search');
                        },
                      ),
                    ],
                  ),
                ),
                // Featured Venues Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Venues',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300, // Fixed reasonable height
                        child: venuesAsync.when(
                          data: (venues) {
                            print('DEBUG: Loaded ${venues.length} venues');
                            for (var venue in venues) {
                              print('DEBUG: Venue ${venue.name} - Images: ${venue.images}');
                            }
                            final featuredVenues = venues.take(4).toList();
                            if (featuredVenues.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No venues found',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Please try again later',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: featuredVenues.length,
                              itemBuilder: (context, index) {
                                final venue = featuredVenues[index];
                                return _VenueCard(venue: venue);
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading venues',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(color: Colors.red[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please try again later',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        double? minRating = ref.read(venueFilterProvider).minRating;
        String? priceRange = ref.read(venueFilterProvider).priceRange;
        List<String> selectedAmenities = List<String>.from(
          ref.read(venueFilterProvider).amenities ?? [],
        );
        List<String> selectedGameTypes = List<String>.from(
          ref.read(venueFilterProvider).gameTypes ?? [],
        );
        // Example options - in real app, fetch from Firestore or config
        final amenitiesOptions = ['WiFi', 'Parking', 'Cafeteria', 'Locker Room', 'Showers'];
        final gameTypesOptions = ['Football', 'Basketball', 'Tennis', 'Padel', 'Volleyball'];
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Filters'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<double>(
                    value: minRating,
                    hint: const Text('Min Rating'),
                    items: [null, 3.0, 4.0, 4.5, 5.0]
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r == null ? 'Any' : r.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => minRating = val),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: priceRange,
                    hint: const Text('Price'),
                    items: [
                      null,
                      'Low',
                      'Medium',
                      'High',
                    ].map((p) => DropdownMenuItem(value: p, child: Text(p ?? 'Any'))).toList(),
                    onChanged: (val) => setState(() => priceRange = val),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Amenities:', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Wrap(
                    spacing: 8,
                    children: amenitiesOptions
                        .map(
                          (amenity) => FilterChip(
                            label: Text(
                              amenity,
                              textScaleFactor: MediaQuery.textScaleFactorOf(context),
                            ),
                            selected: selectedAmenities.contains(amenity),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedAmenities.add(amenity);
                                } else {
                                  selectedAmenities.remove(amenity);
                                }
                              });
                            },
                            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: Theme.of(context).colorScheme.primary,
                            showCheckmark: true,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Game Types:', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Wrap(
                    spacing: 8,
                    children: gameTypesOptions
                        .map(
                          (game) => FilterChip(
                            label: Text(
                              game,
                              textScaleFactor: MediaQuery.textScaleFactorOf(context),
                            ),
                            selected: selectedGameTypes.contains(game),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedGameTypes.add(game);
                                } else {
                                  selectedGameTypes.remove(game);
                                }
                              });
                            },
                            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: Theme.of(context).colorScheme.primary,
                            showCheckmark: true,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(venueFilterProvider.notifier).state = VenueFilter(
                    minRating: minRating,
                    priceRange: priceRange,
                    amenities: selectedAmenities,
                    gameTypes: selectedGameTypes,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VenueCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;
  final String subtitle;
  const VenueCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
    this.subtitle = 'Book your spot now!',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 4 / 3, // Match screenshot aspect ratio
                  child: FirebaseImageWidget(
                    imageUrl: imageUrl.isNotEmpty
                        ? imageUrl
                        : 'https://picsum.photos/300/200?random=${name.hashCode}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
}

// Add this widget for skeleton loading
class _VenueSkeleton extends StatelessWidget {
  final bool isGrid;
  const _VenueSkeleton({required this.isGrid});
  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 6,
        itemBuilder: (context, i) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            child: Container(width: double.infinity, height: 120, color: Colors.white),
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, i) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            child: ListTile(
              title: Container(height: 16, color: Colors.white),
              subtitle: Container(height: 12, color: Colors.white),
              trailing: Container(width: 40, height: 16, color: Colors.white),
            ),
          ),
        ),
      );
    }
  }
}

class _VenueCard extends StatelessWidget {
  final VenueEntity venue;

  const _VenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    final imageUrl = venue.images.isNotEmpty ? venue.images.first : '';

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => context.go('/venues/${venue.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: FirebaseImageWidget(imageUrl: imageUrl),
                ),
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
                        venue.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Maintenance status indicator
                      if (venue.isClosedForMaintenance)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.engineering, size: 12, color: Colors.orange[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Under Maintenance',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Flexible(
                        child: Text(
                          venue.description,
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
                            venue.averageRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${venue.totalReviews})',
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
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onClear;
  const _EmptyState({required this.message, this.onClear});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          if (onClear != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                onPressed: onClear,
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorState({required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[700]),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: onRetry,
              ),
            ),
        ],
      ),
    );
  }
}
