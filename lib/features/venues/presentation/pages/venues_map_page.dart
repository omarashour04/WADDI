import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/smart_back_button.dart';
import '../../../../shared/themes/app_colors.dart';
import '../providers/venues_provider.dart';
import '../widgets/venue_card.dart';

class VenuesMapPage extends ConsumerStatefulWidget {
  const VenuesMapPage({super.key});

  @override
  ConsumerState<VenuesMapPage> createState() => _VenuesMapPageState();
}

class _VenuesMapPageState extends ConsumerState<VenuesMapPage> {
  bool _showList = false;

  @override
  Widget build(BuildContext context) {
    final venuesAsync = ref.watch(venuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venues Map'),
        leading: const SmartBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _showList = !_showList;
              });
            },
          ),
        ],
      ),
      body: venuesAsync.when(
        data: (venues) {
          if (venues.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No venues found'),
                ],
              ),
            );
          }

          return _showList ? _buildListView(venues) : _buildMapView(venues);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMapView(List<dynamic> venues) {
    return Stack(
      children: [
        // Map placeholder - in a real app, you'd use google_maps_flutter
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Map View'),
                SizedBox(height: 8),
                Text('Google Maps integration would go here'),
              ],
            ),
          ),
        ),
        
        // Venue markers would be added here
        // For now, show a sample marker
        Positioned(
          top: 100,
          left: 50,
          child: _buildMapMarker(venues.first),
        ),
      ],
    );
  }

  Widget _buildMapMarker(dynamic venue) {
    return GestureDetector(
      onTap: () => _showVenueInfo(venue),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 20),
            const SizedBox(width: 4),
            Text(
              venue.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<dynamic> venues) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: venues.length,
      itemBuilder: (context, index) {
        final venue = venues[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VenueCard(venue: venue),
        );
      },
    );
  }

  void _showVenueInfo(dynamic venue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Venue Info
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      venue.address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${venue.averageRating} (${venue.totalReviews} reviews)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              context.go('/venues/${venue.id}');
                            },
                            icon: const Icon(Icons.info),
                            label: const Text('View Details'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              context.go('/venues/${venue.id}/rooms');
                            },
                            icon: const Icon(Icons.book_online),
                            label: const Text('Book Now'),
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
    );
  }
} 