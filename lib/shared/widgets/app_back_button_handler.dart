import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_state_service.dart';

class AppBackButtonHandler extends ConsumerWidget {
  final Widget child;
  final String? fallbackRoute;

  const AppBackButtonHandler({super.key, required this.child, this.fallbackRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        // Handle back button press
        _handleBackButton(context, ref);
      },
      child: child,
    );
  }

  void _handleBackButton(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    // Define navigation hierarchy
    final navigationHierarchy = {
      '/venues': null, // Root level
      '/search': '/venues',
      '/profile': '/venues',
      '/bookings': '/venues',
      '/admin': '/venues',
      '/users': '/venues',
      '/reviews': '/venues',
      '/support': '/venues',
      '/login': '/venues',
      '/register': '/venues',
      '/reset-password': '/venues',
    };

    // Check if current location is in hierarchy
    String? targetRoute;

    // Handle nested routes first
    if (location.startsWith('/venues/') && location.contains('/rooms')) {
      // From rooms page, go back to venue details
      final venueId = location.split('/')[2];
      targetRoute = '/venues/$venueId';
    } else if (location.startsWith('/venues/') && !location.contains('/rooms')) {
      // From venue details, go back to venues list
      targetRoute = '/venues';
    } else if (location.startsWith('/booking-details/')) {
      // From booking details, go back to bookings list
      targetRoute = '/venues';
    } else if (location.startsWith('/booking-confirmation')) {
      // From booking confirmation, go back to venues
      targetRoute = '/venues';
    } else {
      // Check exact matches first
      if (navigationHierarchy.containsKey(location)) {
        targetRoute = navigationHierarchy[location];
      } else {
        // Check pattern matches for dynamic routes
        for (final entry in navigationHierarchy.entries) {
          final pattern = entry.key;
          if (location.startsWith(pattern)) {
            targetRoute = entry.value;
            break;
          }
        }
      }
    }

    // Update navigation state
    ref.read(navigationStateProvider.notifier).updateCurrentRoute(targetRoute ?? '/venues');

    // If we have a target route, navigate there
    if (targetRoute != null) {
      context.go(targetRoute);
    } else if (fallbackRoute != null) {
      // Use fallback route if provided
      context.go(fallbackRoute!);
    } else if (location == '/venues') {
      // If we're at the root level, show exit confirmation
      _showExitConfirmation(context);
    } else {
      // Default fallback to venues
      context.go('/venues');
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Exit the app
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
