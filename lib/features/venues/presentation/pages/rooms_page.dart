import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/features/venues/presentation/providers/venue_providers.dart';
import 'package:waddi_platform/features/bookings/presentation/widgets/smart_booking_form.dart';

class RoomsPage extends ConsumerStatefulWidget {
  final String venueId;
  const RoomsPage({required this.venueId, super.key});

  @override
  ConsumerState<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends ConsumerState<RoomsPage> {
  @override
  Widget build(BuildContext context) {
    final venueAsync = ref.watch(venueProvider(widget.venueId));
    final authState = ref.watch(authProvider);

    final userId = authState.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Book Venue'),
        elevation: 0,
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
      ),
      body: venueAsync.when(
        data: (venue) {
          if (venue == null) {
            return const Center(child: Text('Venue not found'));
          }

          // Check if user is a guest user
          if (authState.isGuestUser) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login Required',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Guest users cannot make bookings. Please log in to continue.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          // Show smart booking form for authenticated users
          return SmartBookingForm(
            venueId: widget.venueId,
            venueName: venue.name,
            openTime: venue.openTime,
            closeTime: venue.closeTime,
            timeSlotDuration: venue.timeSlotDuration,
            allowOpenEndedBookings: venue.allowOpenEndedBookings,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
