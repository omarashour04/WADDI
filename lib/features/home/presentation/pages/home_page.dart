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
    final authState = ref.watch(authProvider);
    final isGuest = authState.status == AuthStatus.unauthenticated;
    final isAdmin = authState.user?.role == 'admin';
    final isVenueOwner = authState.user?.role == 'venue_owner';
    final userId = authState.user?.id ?? '';

    // If user is admin or venue owner, redirect to appropriate dashboard
    if (isAdmin || isVenueOwner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          if (isAdmin) {
            context.go('/admin');
          } else if (isVenueOwner) {
            context.go('/venue-owner');
          }
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final venuesAsync = ref.watch(filteredVenuesProvider);
    final searchController = TextEditingController(text: ref.read(venueSearchQueryProvider));
    final filter = ref.watch(venueFilterProvider);
    
    // Get user's past booked venues if they're authenticated
    final pastBookedVenuesAsync = !isGuest && userId.isNotEmpty 
        ? ref.watch(userPastBookedVenuesProvider(userId))
        : null;

    return MainScaffold(
      currentIndex: 0,
      userId: userId,
      child: Scaffold(
        body: OfflineModeWidget(
          operation: OfflineOperation.browseVenues,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGuest
                            ? 'Welcome to WADDI!'
                            : 'Welcome back, ${authState.user?.name ?? 'User'}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isGuest
                            ? 'Discover amazing venues and book your next adventure'
                            : 'Ready to explore more venues?',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Search Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        onPressed: () => _showFilterDialog(context),
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

                const SizedBox(height: 16),

                // Featured Venues Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGuest || pastBookedVenuesAsync == null 
                            ? 'Featured Venues'
                            : 'Your Previous Venues',
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
                        child: _buildFeaturedVenuesSection(
                          isGuest: isGuest,
                          pastBookedVenuesAsync: pastBookedVenuesAsync,
                          venuesAsync: venuesAsync,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // All Venues Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Venues',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      venuesAsync.when(
                        data: (venues) {
                          if (venues.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No venues available'),
                              ),
                            );
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
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
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
          Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
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
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[600]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
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
                  child: Stack(
                    children: [
                      FirebaseImageWidget(imageUrl: imageUrl),
                      if (showBookedBadge)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Booked',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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

class _VenueGridCard extends StatelessWidget {
  final VenueEntity venue;

  const _VenueGridCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    final imageUrl = venue.images.isNotEmpty ? venue.images.first : '';

    return Card(
      elevation: 2,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Maintenance status indicator
                    if (venue.isClosedForMaintenance)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.engineering, size: 10, color: Colors.orange[700]),
                            const SizedBox(width: 2),
                            Text(
                              'Maintenance',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Flexible(
                      child: Text(
                        venue.description,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 2),
                        Text(
                          venue.averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${venue.totalReviews})',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
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
  }
}
