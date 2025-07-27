import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../core/services/app_state_service.dart';
// Auth pages
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
// Core feature pages
import '../features/venues/presentation/pages/venues_page.dart';
import '../features/venues/presentation/pages/rooms_page.dart';
import '../features/users/presentation/pages/users_page.dart';
import '../features/bookings/presentation/pages/bookings_page.dart';
import '../features/reviews/presentation/pages/reviews_page.dart';
import '../features/support/presentation/pages/support_tickets_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/admin_users_page.dart';
import '../features/admin/presentation/pages/admin_venues_page.dart';
import '../features/admin/presentation/pages/admin_bookings_page.dart';
import '../features/admin/presentation/pages/admin_analytics_page.dart';
import '../features/admin/presentation/pages/admin_content_page.dart';
import '../features/admin/presentation/pages/admin_notifications_page.dart';
import 'package:waddi_platform/features/search/presentation/pages/search_page.dart';
import '../features/venues/presentation/pages/venue_details_page.dart';
import '../features/bookings/presentation/pages/booking_confirmation_page.dart';
import '../features/bookings/presentation/pages/booking_details_page.dart';

// Helper function to validate if a route is accessible for current auth state
bool _isValidRoute(String route, AuthState authState) {
  // Define protected pages that require authentication
  final protectedPages = [
    '/profile',
    '/bookings',
    '/booking-details',
    '/booking-confirmation',
    '/users',
    '/reviews',
    '/support',
    '/admin',
  ];

  // If user is not authenticated and trying to access protected pages, route is invalid
  if (authState.status == AuthStatus.unauthenticated &&
      protectedPages.any((page) => route.startsWith(page))) {
    return false;
  }

  // If user is authenticated (but not guest) and trying to access auth pages, route is invalid
  if (authState.status == AuthStatus.authenticated &&
      !authState.isGuestUser &&
      (route == '/login' || route == '/register' || route == '/reset-password')) {
    return false;
  }

  return true;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final authState = ref.watch(authProvider);

      print(
        'Router redirect - Location: ${state.matchedLocation}, Auth Status: ${authState.status}, Loading: ${authState.isLoading}',
      );

      // If auth state is still loading, don't redirect yet
      if (authState.isLoading) {
        print('Auth still loading, staying at current location');
        return null;
      }

      // TODO: Implement state restoration in a separate method to avoid conflicts

      print(
        'Router redirect - Location: ${state.matchedLocation}, Auth Status: ${authState.status}, Loading: ${authState.isLoading}',
      );

      // If auth state is still loading, don't redirect yet
      if (authState.isLoading) {
        print('Auth still loading, staying at current location');
        return null;
      }

      // If user is authenticated (but not guest) and trying to access auth pages, redirect to home
      if (authState.status == AuthStatus.authenticated &&
          !authState.isGuestUser &&
          (state.matchedLocation == '/login' ||
              state.matchedLocation == '/register' ||
              state.matchedLocation == '/reset-password')) {
        print('Authenticated user accessing auth page, redirecting to venues');
        return '/venues';
      }

      // Define protected pages that require authentication
      final protectedPages = [
        '/profile',
        '/bookings',
        '/booking-details',
        '/booking-confirmation',
        '/users',
        '/reviews',
        '/support',
        '/admin',
      ];

      // If user is not authenticated and trying to access protected pages, redirect to login
      if (authState.status == AuthStatus.unauthenticated &&
          protectedPages.any((page) => state.matchedLocation.startsWith(page))) {
        print('Unauthenticated user accessing protected page, redirecting to login');
        return '/login';
      }

      // If at root and authenticated, redirect to venues
      if (state.matchedLocation == '/' && authState.status == AuthStatus.authenticated) {
        print('Authenticated user at root, redirecting to venues');
        return '/venues';
      }

      // If at root and not authenticated, redirect to venues (allow guest access)
      if (state.matchedLocation == '/' && authState.status == AuthStatus.unauthenticated) {
        print('Unauthenticated user at root, redirecting to venues (guest access)');
        return '/venues';
      }

      // If at root and authenticated, redirect to venues
      if (state.matchedLocation == '/' && authState.status == AuthStatus.authenticated) {
        print('Authenticated user at root, redirecting to venues');
        return '/venues';
      }

      print('No redirect needed');
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/venues'), child: const Text('Go to Home')),
          ],
        ),
      ),
    ),
    routes: [
      // Root route for loading state
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading...')],
            ),
          ),
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordPage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
      GoRoute(path: '/venues', builder: (context, state) => VenuesPage()),
      GoRoute(
        path: '/venues/:venueId',
        builder: (context, state) => VenueDetailsPage(venueId: state.pathParameters['venueId']!),
      ),
      GoRoute(
        path: '/venues/:venueId/rooms',
        builder: (context, state) => RoomsPage(venueId: state.pathParameters['venueId']!),
      ),
      GoRoute(
        path: '/booking-confirmation',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return BookingConfirmationPage(
            bookingId: queryParams['bookingId'] ?? '123456789',
            venueName: queryParams['venueName'] ?? 'The Pixel Palace',
            roomName: queryParams['roomName'] ?? 'Room 3',
            bookingDate: DateTime.tryParse(queryParams['bookingDate'] ?? '') ?? DateTime.now(),
            durationHours: int.tryParse(queryParams['durationHours'] ?? '2') ?? 2,
            totalPrice: double.tryParse(queryParams['totalPrice'] ?? '50.00') ?? 50.00,
          );
        },
      ),
      GoRoute(
        path: '/booking-details/:bookingId',
        builder: (context, state) =>
            BookingDetailsPage(bookingId: state.pathParameters['bookingId']!),
      ),
      GoRoute(path: '/users', builder: (context, state) => UsersPage()),
      GoRoute(
        path: '/bookings/:userId',
        builder: (context, state) => BookingsPage(userId: state.pathParameters['userId']!),
      ),
      GoRoute(
        path: '/reviews/:venueId',
        builder: (context, state) => ReviewsPage(venueId: state.pathParameters['venueId']!),
      ),
      GoRoute(
        path: '/support/:userId',
        builder: (context, state) => SupportTicketsPage(userId: state.pathParameters['userId']!),
      ),
      GoRoute(path: '/search', builder: (context, state) => SearchPage()),
      GoRoute(
        path: '/admin',
        builder: (context, state) => AdminDashboardPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'admin') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => AdminUsersPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'admin') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/venues',
        builder: (context, state) => AdminVenuesPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'admin') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/bookings',
        builder: (context, state) => AdminBookingsPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'admin') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => AdminAnalyticsPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'admin') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/content',
        builder: (context, state) => AdminContentPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'admin') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => AdminNotificationsPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'admin') {
            return '/login';
          }
          return null;
        },
      ),
    ],
  );
});
