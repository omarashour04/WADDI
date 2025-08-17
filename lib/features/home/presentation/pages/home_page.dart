import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/themes/app_colors.dart';
import '../../../../shared/widgets/main_scaffold.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../venues/presentation/providers/venue_providers.dart';
import '../../../venues/domain/entities/venue_entity.dart';
import '../../../bookings/presentation/providers/booking_provider.dart';
import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../../shared/widgets/firebase_image_widget.dart';
import '../../../../shared/widgets/offline_mode_widget.dart';
import '../../../../shared/services/offline_mode_service.dart';
import 'dart:ui'; // Added for ImageFilter

// Provider to get user's past booked venues
final userPastBookedVenuesProvider = FutureProvider.family<List<VenueEntity>, String>((ref, userId) async {
  if (userId.isEmpty) return [];
  
  try {
    final bookingRepository = ref.read(bookingRepositoryProvider);
    final userBookings = await bookingRepository.getUserBookings(userId);
    
    // Get completed/past bookings
    final pastBookings = userBookings.where((booking) => 
      booking.actualStatus == 'completed' || 
      (booking.isPast && booking.status != 'cancelled')
    ).toList();
    
    if (pastBookings.isEmpty) return [];
    
    // Get unique venue IDs from past bookings
    final venueIds = pastBookings.map((booking) => booking.venueId).toSet().toList();
    
    // Get venue details for these IDs
    final venueRepository = ref.read(venueRepositoryProvider);
    final venues = <VenueEntity>[];
    
    for (final venueId in venueIds) {
      try {
        final venue = await venueRepository.getVenueById(venueId);
        if (venue != null) {
          venues.add(venue);
        }
      } catch (e) {
        // Skip venues that can't be loaded
        continue;
      }
    }
    
    // Sort by most recent booking first
    venues.sort((a, b) {
      final aBookings = pastBookings.where((booking) => booking.venueId == a.id).toList();
      final bBookings = pastBookings.where((booking) => booking.venueId == b.id).toList();
      
      if (aBookings.isEmpty && bBookings.isEmpty) return 0;
      if (aBookings.isEmpty) return 1;
      if (bBookings.isEmpty) return -1;
      
      final aLastBooking = aBookings
          .map((booking) => booking.startTime)
          .reduce((value, element) => value.isAfter(element) ? value : element);
      
      final bLastBooking = bBookings
          .map((booking) => booking.startTime)
          .reduce((value, element) => value.isAfter(element) ? value : element);
      
      return bLastBooking.compareTo(aLastBooking);
    });
    
    return venues;
  } catch (e) {
    print('Error getting user past booked venues: $e');
    return [];
  }
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _hasCheckedNotifications = false;

  @override
  void initState() {
    super.initState();
    // Check for notifications after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotifications();
    });
  }

  Future<void> _checkNotifications() async {
    if (_hasCheckedNotifications) return;

    final authState = ref.read(authProvider);
    // Only check notifications for authenticated users (not guests)
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      await NotificationService.checkAndShowNotifications(context);
      setState(() {
        _hasCheckedNotifications = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isGuest = authState.isGuestUser;
    final user = authState.user;
    
    // Get venues data
    final venuesAsync = ref.watch(filteredVenuesProvider);
    final pastBookedVenuesAsync = isGuest || user == null 
        ? null 
        : ref.watch(userPastBookedVenuesProvider(user.id));

    return MainScaffold(
      currentIndex: 0,
      userId: user?.id ?? '',
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              // Beautiful App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.onSurface,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Welcome to WADDI',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primaryContainer.withOpacity(0.3),
                          theme.colorScheme.secondaryContainer.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Search and Filter Section
              SliverToBoxAdapter(
                child: Container(
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
                          decoration: InputDecoration(
                            hintText: 'Search venues...',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
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
                          onSubmitted: (query) {
                            if (query.trim().isNotEmpty) {
                              context.go('/search?query=${Uri.encodeComponent(query.trim())}');
                            }
                          },
                          onTap: () => context.go('/search'),
                          readOnly: true,
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
                              () => context.go('/search'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Featured Venues Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isGuest || pastBookedVenuesAsync == null 
                                ? Icons.star_rounded
                                : Icons.history_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isGuest || pastBookedVenuesAsync == null 
                                ? 'Featured Venues'
                                : 'Your Previous Venues',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _buildFeaturedVenuesSection(
                          isGuest: isGuest,
                          pastBookedVenuesAsync: pastBookedVenuesAsync,
                          venuesAsync: venuesAsync,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              
              // All Venues Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'All Venues',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      venuesAsync.when(
                        data: (venues) {
                          if (venues.isEmpty) {
                            return _buildEmptyVenuesState();
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: venues.length,
                            itemBuilder: (context, index) {
                              final venue = venues[index];
                              return _VenueGridCard(venue: venue);
                            },
                          );
                        },
                        loading: () => _buildVenuesLoadingState(),
                        error: (error, stackTrace) => _buildVenuesErrorState(error),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedVenuesSection({
    required bool isGuest,
    required AsyncValue<List<VenueEntity>>? pastBookedVenuesAsync,
    required AsyncValue<List<VenueEntity>> venuesAsync,
  }) {
    // For guests, show all venues
    if (isGuest) {
      return venuesAsync.when(
        data: (venues) {
          final featuredVenues = venues.take(4).toList();
          if (featuredVenues.isEmpty) {
            return _buildEmptyState('No venues found', 'Please try again later');
          }
          return _buildHorizontalVenueList(featuredVenues);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState('Error loading venues', 'Please try again later'),
      );
    }

    // For authenticated users, show past booked venues if available
    if (pastBookedVenuesAsync != null) {
      return pastBookedVenuesAsync.when(
        data: (pastBookedVenues) {
          if (pastBookedVenues.isNotEmpty) {
            // Show past booked venues (up to 4)
            final featuredVenues = pastBookedVenues.take(4).toList();
            return _buildHorizontalVenueList(featuredVenues, showBookedBadge: true);
          } else {
            // No past bookings, show all venues
            return venuesAsync.when(
              data: (venues) {
                final featuredVenues = venues.take(4).toList();
                if (featuredVenues.isEmpty) {
                  return _buildEmptyState('No venues found', 'Please try again later');
                }
                return _buildHorizontalVenueList(featuredVenues);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState('Error loading venues', 'Please try again later'),
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          // Fallback to all venues if there's an error loading past bookings
          return venuesAsync.when(
            data: (venues) {
              final featuredVenues = venues.take(4).toList();
              if (featuredVenues.isEmpty) {
                return _buildEmptyState('No venues found', 'Please try again later');
              }
              return _buildHorizontalVenueList(featuredVenues);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState('Error loading venues', 'Please try again later'),
          );
        },
      );
    }

    // Fallback to all venues
    return venuesAsync.when(
      data: (venues) {
        final featuredVenues = venues.take(4).toList();
        if (featuredVenues.isEmpty) {
          return _buildEmptyState('No venues found', 'Please try again later');
        }
        return _buildHorizontalVenueList(featuredVenues);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState('Error loading venues', 'Please try again later'),
    );
  }

  Widget _buildHorizontalVenueList(List<VenueEntity> venues, {bool showBookedBadge = false}) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: venues.length,
      itemBuilder: (context, index) {
        final venue = venues[index];
        return _VenueCard(venue: venue, showBookedBadge: showBookedBadge);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 64, color: AppColors.grey500),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
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
                  style: theme.textTheme.labelMedium?.copyWith(
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

  Widget _buildEmptyVenuesState() {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.location_city_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No venues available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new venues',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenuesLoadingState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading venues...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenuesErrorState(Object error) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading venues',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
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
        bool openEndedOnly = ref.read(venueFilterProvider).openEndedOnly ?? false;
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
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Open‑ended only'),
                    subtitle: const Text('Show venues that allow open‑ended bookings'),
                    value: openEndedOnly,
                    onChanged: (v) => setState(() => openEndedOnly = v),
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
                    openEndedOnly: openEndedOnly,
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
  final bool showBookedBadge;

  const _VenueCard({required this.venue, this.showBookedBadge = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = venue.images.isNotEmpty ? venue.images.first : '';

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/venues/${venue.id}'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
                        decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with overlay
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        FirebaseImageWidget(imageUrl: imageUrl),
                        // Gradient overlay for better text readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Booked badge
                        if (showBookedBadge)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accentLight,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Booked',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Rating badge
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  venue.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
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
                // Content Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Venue name
                        Text(
                          venue.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Maintenance status indicator
                        if (venue.isClosedForMaintenance)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.engineering_rounded,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Under Maintenance',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Description
                        Flexible(
                          child: Text(
                            venue.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Bottom info row
                        Row(
                          children: [
                            // Reviews count
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${venue.totalReviews} reviews',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Price indicator
                            if (venue.hourlyPriceRange.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  venue.hourlyPriceRange.toString(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                ),
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
      ),
    );
  }
}

class _VenueGridCard extends StatelessWidget {
  final VenueEntity venue;

  const _VenueGridCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = venue.images.isNotEmpty ? venue.images.first : '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/venues/${venue.id}'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with overlay
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        FirebaseImageWidget(imageUrl: imageUrl),
                        // Gradient overlay for better text readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Rating badge
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  venue.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Maintenance indicator
                        if (venue.isClosedForMaintenance)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.engineering_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  const Text(
                                    'Maintenance',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
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
                // Content Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Venue name
                        Text(
                          venue.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        
                        // Description
                        Flexible(
                          child: Text(
                            venue.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Bottom info row
                        Row(
                          children: [
                            // Reviews count
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${venue.totalReviews} reviews',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Price indicator
                            if (venue.hourlyPriceRange.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  venue.hourlyPriceRange.toString(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
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
      ),
    );
  }
}
