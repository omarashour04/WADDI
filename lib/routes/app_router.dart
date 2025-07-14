import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/features/auth/presentation/pages/login_page.dart';
import 'package:waddi_platform/features/auth/presentation/pages/register_page.dart';
// Placeholder imports for other pages (implement these pages as needed)
import 'package:waddi_platform/features/venues/presentation/pages/venues_page.dart';
import 'package:waddi_platform/features/bookings/presentation/pages/bookings_page.dart';
import 'package:waddi_platform/features/profile/presentation/pages/profile_page.dart';
import 'package:waddi_platform/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/features/venue_owner/presentation/pages/venue_owner_dashboard_page.dart';

// Private navigators for root and shell routes
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Provider for the GoRouter instance
final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch the authentication state to react to changes (e.g., login/logout)
  final authState = ref.watch(authProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey, // Key for the root navigator
    initialLocation: '/login', // Initial route when the app starts
    redirect: (context, state) {
      // Redirect logic based on authentication status
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      // If not authenticated and not on a login/register page, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      // If authenticated and trying to access login/register pages, redirect to venues
      if (isAuthenticated && isLoggingIn) {
        return '/venues';
      }
      return null; // No redirect needed
    },
    routes: [
      // Public routes (accessible without authentication)
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterPage(),
      ),
      // ShellRoute for persistent UI elements like a bottom navigation bar
      ShellRoute(
        navigatorKey: _shellNavigatorKey, // Key for the shell navigator
        builder: (context, state, child) {
          // This builder wraps the child route with a Scaffold and BottomNavigationBar
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Venues'),
                BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
              currentIndex: _calculateSelectedIndex(state.matchedLocation), // Determine active tab
              onTap: (index) => _onItemTapped(context, index), // Handle tab taps
            ),
          );
        },
        routes: [
          // Routes nested within the ShellRoute (require authentication)
          GoRoute(
            path: '/venues',
            builder: (context, state) => VenuesPage(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => BookingsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => ProfilePage(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => AdminDashboardPage(),
            redirect: (context, state) {
              // Example: Admin guard - redirect non-admins away from the admin page
              if (authState.user?.role != 'admin') {
                return '/venues';
              }
              return null;
            },
          ),
          GoRoute(
            path: '/venue-owner',
            builder: (context, state) => VenueOwnerDashboardPage(), // You need to implement this page
            redirect: (context, state) {
              // Venue owner guard - redirect non-venue-owners away from the venue owner page
              if (authState.user?.role != 'venue_owner') {
                return '/venues';
              }
              return null;
            },
          ),
          // Add more routes within the shell as needed
        ],
      ),
    ],
  );
});

// Helper function to calculate the selected index for the BottomNavigationBar
int _calculateSelectedIndex(String location) {
  if (location.startsWith('/venues')) return 0;
  if (location.startsWith('/bookings')) return 1;
  if (location.startsWith('/profile')) return 2;
  return 0; // Default to the first tab
}

// Helper function to navigate when a BottomNavigationBar item is tapped
void _onItemTapped(BuildContext context, int index) {
  switch (index) {
    case 0:
      GoRouter.of(context).go('/venues');
      break;
    case 1:
      GoRouter.of(context).go('/bookings');
      break;
    case 2:
      GoRouter.of(context).go('/profile');
      break;
  }
} 