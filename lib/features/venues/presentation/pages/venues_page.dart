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

class VenuesPage extends ConsumerStatefulWidget {
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
    CameraPosition? _searchedCameraPosition;
    return MainScaffold(
      currentIndex: 0,
      userId: userId,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SingleChildScrollView(
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 240, // Increased height to accommodate cards
                        child: venuesAsync.when(
                          data: (venues) {
                            if (venues.isEmpty) {
                              return const Center(child: Text('No venues available'));
                            }
                            // Take first 4 venues for featured section
                            final featuredVenues = venues.take(4).toList();
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: featuredVenues.length,
                              itemBuilder: (context, index) {
                                final venue = featuredVenues[index];
                                return Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        // Navigate to venue details page
                                        context.go('/venues/${venue.id}');
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Image section - reduced flex
                                          Expanded(
                                            flex: 2, // Reduced from 3 to 2
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                                color: AppColors.primaryLight,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.games,
                                                  size: 40, // Reduced from 48 to 40
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Content section - increased flex
                                          Expanded(
                                            flex: 3, // Increased from 2 to 3
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    venue.name,
                                                    style: Theme.of(context).textTheme.titleMedium
                                                        ?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.textPrimary,
                                                        ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2), // Reduced from 4 to 2
                                                  Text(
                                                    'Book your spot now!',
                                                    style: Theme.of(context).textTheme.bodySmall
                                                        ?.copyWith(
                                                          color: AppColors.textSecondary,
                                                          fontSize: 11, // Reduced font size
                                                        ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const Spacer(), // Push rating to bottom
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        size: 14, // Reduced from 16 to 14
                                                        color: Colors.amber,
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ), // Reduced from 4 to 2
                                                      Text(
                                                        venue.averageRating.toString(),
                                                        style: Theme.of(context).textTheme.bodySmall
                                                            ?.copyWith(
                                                              fontSize: 11, // Reduced font size
                                                            ),
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
                              },
                            );
                          },
                          loading: () => ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 12),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                            color: AppColors.primaryLight,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.games,
                                              size: 40,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 16,
                                                width: 120,
                                                color: Colors.grey[300],
                                              ),
                                              const SizedBox(height: 2),
                                              Container(
                                                height: 12,
                                                width: 100,
                                                color: Colors.grey[300],
                                              ),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                                  const SizedBox(width: 2),
                                                  Container(
                                                    height: 12,
                                                    width: 20,
                                                    color: Colors.grey[300],
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
                              );
                            },
                          ),
                          error: (e, st) => const Center(child: Text('Error loading venues')),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to booking flow
                            context.go('/venues');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.textOnSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Book Now',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Quick Access',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to favorites
                            context.go('/favorites');
                          },
                          icon: const Icon(Icons.favorite),
                          label: const Text('Favorites'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tertiary,
                            foregroundColor: AppColors.textOnTertiary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _VenueCard extends StatelessWidget {
  final VenueEntity venue;
  const _VenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Venue card for ${venue.name}, average rating ${venue.averageRating}',
      button: true,
      child: Card(
        child: ListTile(
          title: Text(
            venue.name,
            style: Theme.of(context).textTheme.titleMedium,
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          subtitle: Text(
            venue.address,
            style: Theme.of(context).textTheme.bodyMedium,
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text(
                venue.averageRating.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textScaleFactor: MediaQuery.textScaleFactorOf(context),
              ),
            ],
          ),
          onTap: () {
            context.go('/venues/${venue.id}/rooms');
          },
        ),
      ),
    );
  }
}

// Add this widget for skeleton loading
class _VenueSkeleton extends StatelessWidget {
  final bool isGrid;
  const _VenueSkeleton({this.isGrid = false});
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
