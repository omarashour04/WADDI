import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waddi_platform/shared/widgets/main_scaffold.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/features/venues/presentation/providers/venue_providers.dart';
import 'package:waddi_platform/features/venues/presentation/providers/geocoding_provider.dart';
import 'package:waddi_platform/features/venues/domain/entities/venue_entity.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/widgets/pull_to_refresh_wrapper.dart';
import '../../../../shared/widgets/lottie_animations.dart';
import '../../../../shared/themes/app_colors.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  bool isGrid = false;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    // Initialize search controller with current query
    searchController = TextEditingController(text: ref.read(venueSearchQueryProvider));

    // Check for query parameter in URL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = GoRouter.of(
        context,
      ).routerDelegate.currentConfiguration.uri.queryParameters['query'];
      if (query != null && query.isNotEmpty) {
        final decodedQuery = Uri.decodeComponent(query);
        searchController.text = decodedQuery;
        ref.read(venueSearchQueryProvider.notifier).state = decodedQuery;
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id ?? '';
    final venuesAsync = ref.watch(filteredVenuesProvider);

    // Update navigation state
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(navigationStateProvider.notifier).updateCurrentRoute('/search');
    // });
    final geocodingService = ref.read(geocodingProvider);

    return MainScaffold(
      currentIndex: 1,
      userId: userId,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or location',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (val) => ref.read(venueSearchQueryProvider.notifier).state = val,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Filter',
                          Icons.filter_list_rounded,
                          AppColors.primary,
                          () => _showFilterDialog(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Location',
                          Icons.location_searching_rounded,
                          AppColors.secondary,
                          () async {
                            final address = searchController.text.trim();
                            if (address.isNotEmpty) {
                              final location = await geocodingService.getLocationFromAddress(address);
                              if (location != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Location found: ${location.latitude}, ${location.longitude}',
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Address not found.')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: PullToRefreshWrapper(
                onRefresh: () async {
                  ref.invalidate(filteredVenuesProvider);
                },
                child: venuesAsync.when(
                  data: (venues) {
                    if (venues.isEmpty) {
                      return LottieNoResultsAnimation(
                        message: 'No venues found. Try adjusting your search or filters.',
                        size: 150,
                      );
                    }
                    return isGrid
                        ? GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: venues.length,
                            itemBuilder: (context, i) => _VenueCard(venue: venues[i]),
                          )
                        : ListView.builder(
                            itemCount: venues.length,
                            itemBuilder: (context, i) => _VenueCard(venue: venues[i]),
                          );
                  },
                  loading: () => _VenueSkeleton(isGrid: isGrid),
                  error: (e, st) => LottieNetworkErrorAnimation(
                    onRetry: () => ref.refresh(filteredVenuesProvider),
                    size: 150,
                  ),
                ),
              ),
            ),
          ],
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
                            label: Text(amenity),
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
                            label: Text(game),
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
          title: Text(venue.name, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(venue.address, style: Theme.of(context).textTheme.bodyMedium),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text(venue.averageRating.toString(), style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          onTap: () {
            // Navigate to venue details page
            context.go('/venues/${venue.id}');
          },
        ),
      ),
    );
  }
}

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
          baseColor: AppColors.grey300,
          highlightColor: AppColors.grey100,
          child: Card(
            child: Container(width: double.infinity, height: 120, color: AppColors.surfaceLight),
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, i) => Shimmer.fromColors(
          baseColor: AppColors.grey300,
          highlightColor: AppColors.grey100,
          child: Card(
            child: ListTile(
              title: Container(height: 16, color: AppColors.surfaceLight),
              subtitle: Container(height: 12, color: AppColors.surfaceLight),
              trailing: Container(width: 40, height: 16, color: AppColors.surfaceLight),
            ),
          ),
        ),
      );
    }
  }
}

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          Icon(Icons.search_off, size: 64, color: AppColors.grey500),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
          ),
          if (onClear != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
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
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.error),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
                onPressed: onRetry,
              ),
            ),
        ],
      ),
    );
  }
}
