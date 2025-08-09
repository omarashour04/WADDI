import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../shared/providers/shared_providers.dart';

// Auth pages
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/change_password_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
// Core feature pages
import '../features/venues/presentation/pages/venues_page.dart';
import '../features/venues/presentation/pages/rooms_page.dart';
import '../features/users/presentation/pages/users_page.dart';
import '../features/bookings/presentation/pages/booking_confirmation_page.dart';
import '../features/bookings/presentation/pages/booking_details_page.dart';
import '../features/bookings/presentation/pages/user_bookings_page.dart';
import '../features/reviews/presentation/pages/reviews_page.dart';
import '../features/support/presentation/pages/support_tickets_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/admin_users_page.dart';
import '../features/admin/presentation/pages/admin_venues_page.dart';
import '../features/admin/presentation/pages/admin_bookings_page.dart';
import '../features/admin/presentation/pages/admin_analytics_page.dart';
import '../features/admin/presentation/pages/admin_content_page.dart';
import '../features/admin/presentation/pages/admin_notifications_page.dart';
import '../features/venue_owner/presentation/pages/venue_owner_dashboard_page.dart';
import '../features/venue_owner/presentation/pages/venue_form_page.dart';
import '../features/venue_owner/presentation/pages/room_management_page.dart';
import '../features/venue_owner/presentation/pages/venue_bookings_page.dart';
import '../features/venue_owner/presentation/pages/venue_reports_page.dart';
import '../features/venue_owner/presentation/pages/venue_maintenance_page.dart';
import '../features/venue_owner/presentation/pages/venue_owner_bookings_page.dart';
import '../features/venue_owner/presentation/pages/venue_owner_reports_page.dart';
import '../features/venue_owner/presentation/pages/venue_owner_maintenance_page.dart';
import 'package:waddi_platform/features/search/presentation/pages/search_page.dart';
import '../features/venues/presentation/pages/venue_details_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/admin/presentation/pages/admin_create_venue_owner_page.dart';
import '../features/admin/presentation/pages/admin_database_setup_page.dart';
import '../features/admin/presentation/pages/email_test_page.dart';
import '../features/bookings/presentation/widgets/booking_form.dart';
import '../features/venues/presentation/pages/advanced_search_page.dart';
import '../features/venues/presentation/pages/venues_map_page.dart';
import '../features/favorites/presentation/pages/favorites_page.dart';
import '../features/venue_owner/presentation/pages/room_form_page.dart';
import '../features/accessibility/presentation/pages/accessibility_settings_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/bookings/presentation/pages/user_check_in_scanner_page.dart';
import '../features/venue_owner/presentation/pages/room_qr_poster_page.dart';

// Helper function to check if user needs to change password on first login
Future<bool> _checkFirstLogin(String userId) async {
  try {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      return userData?['isFirstLogin'] == true;
    }
    return false;
  } catch (e) {
    print('Error checking first login: $e');
    return false;
  }
}

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
      final authState = ref.read(authProvider);

      print(
        'Router redirect - Location: ${state.matchedLocation}, Auth Status: ${authState.status}, Loading: ${authState.isLoading}, User: ${authState.user?.name ?? 'null'}',
      );

      // If auth state is still loading, redirect to a simple loading page
      if (authState.isLoading) {
        print('Auth still loading, redirecting to loading page');
        return '/loading';
      }

      // Force redirect to home if stuck on loading page for too long
      if (state.matchedLocation == '/loading') {
        print('Stuck on loading page, forcing redirect to home');
        return '/home';
      }

      // If at root, try to restore last known route
      if (state.matchedLocation == '/') {
        try {
          final localStorage = ref.read(localStorageProvider);
          final lastRoute = await localStorage.getCurrentRoute();

          // Check if user needs to change password on first login
          if (authState.status == AuthStatus.authenticated && authState.user != null) {
            final isFirstLogin = await _checkFirstLogin(authState.user!.id);
            if (isFirstLogin) {
              return '/change-password';
            }
          }

          if (lastRoute != null && lastRoute != '/') {
            print('Restoring last route: $lastRoute');
            return lastRoute;
          }
        } catch (e) {
          print('Error restoring last route: $e');
        }

        // If no last route found, redirect based on user role
        if (authState.status == AuthStatus.authenticated && authState.user != null) {
          if (authState.user!.role == 'admin') {
            print('No last route found, redirecting admin to admin dashboard');
            return '/admin';
          } else if (authState.user!.role == 'venue_owner') {
            print('No last route found, redirecting venue owner to venue dashboard');
            return '/venue-owner';
          }
        }

        print('No last route found, redirecting to home');
        return '/home';
      }

      // If user is authenticated and trying to access auth pages, redirect based on role
      if (authState.status == AuthStatus.authenticated &&
          (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
        print('Authenticated user accessing login/register, redirecting based on role');

        // Redirect based on user role
        if (authState.user?.role == 'admin') {
          return '/admin';
        } else if (authState.user?.role == 'venue_owner') {
          return '/venue-owner';
        } else {
          return '/home';
        }
      }

      // Define protected pages that require authentication (only booking and profile editing)
      final protectedPages = [
        '/bookings',
        '/booking-details',
        '/booking-confirmation',
        '/profile/edit',
      ];

      // If user is not authenticated and trying to access protected pages, redirect to login
      if (authState.status == AuthStatus.unauthenticated &&
          protectedPages.any((page) => state.matchedLocation.startsWith(page))) {
        print('Unauthenticated user accessing protected page, redirecting to login');
        return '/login';
      }

      // Track navigation history for all valid routes
      if (state.matchedLocation != '/loading') {
        print('DEBUG: Adding route to history: ${state.matchedLocation}');
        ref.read(navigationHistoryProvider.notifier).addRoute(state.matchedLocation);

        // Check if history is getting too large and cleanup if needed
        final historySize = ref.read(navigationHistoryProvider.notifier).stackSize;
        if (historySize > 45) {
          print('DEBUG: Navigation history getting large ($historySize), performing cleanup');
          ref.read(navigationHistoryProvider.notifier).cleanupHistory();
        }

        // Save current route for app restart
        ref.read(localStorageProvider).saveCurrentRoute(state.matchedLocation);
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
            ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Go to Home')),
          ],
        ),
      ),
    ),
    routes: [
      // Debug route
      GoRoute(
        path: '/debug',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: Text('Debug Page')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Debug Page - Router is working!'),
                SizedBox(height: 16),
                ElevatedButton(onPressed: () => context.go('/home'), child: Text('Go to Home')),
              ],
            ),
          ),
        ),
      ),
      // Loading route
      GoRoute(path: '/loading', builder: (context, state) => _LoadingPage()),
      // Root route
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
      // Home page route
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);

          // If user is authenticated, redirect based on role
          if (authState.status == AuthStatus.authenticated && authState.user != null) {
            if (authState.user!.role == 'admin') {
              return '/admin';
            } else if (authState.user!.role == 'venue_owner') {
              return '/venue-owner';
            }
          }
          return null;
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.status == AuthStatus.authenticated) {
            // Redirect based on user role
            if (authState.user?.role == 'admin') {
              return '/admin';
            } else if (authState.user?.role == 'venue_owner') {
              return '/venue-owner';
            } else {
              return '/home';
            }
          }
          return null;
        },
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.status != AuthStatus.authenticated) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordPage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfilePage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null) {
            return '/login';
          }
          return null;
        },
      ),
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
        path: '/reviews/:venueId',
        builder: (context, state) => ReviewsPage(venueId: state.pathParameters['venueId']!),
      ),
      GoRoute(
        path: '/support/:userId',
        builder: (context, state) => SupportTicketsPage(userId: state.pathParameters['userId']!),
      ),
      GoRoute(path: '/search', builder: (context, state) => SearchPage()),
      GoRoute(path: '/advanced-search', builder: (context, state) => const AdvancedSearchPage()),
      GoRoute(path: '/venues-map', builder: (context, state) => const VenuesMapPage()),
      GoRoute(path: '/favorites', builder: (context, state) => const FavoritesPage()),
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
        path: '/admin/venues/add',
        builder: (context, state) => VenueFormPage(ownerId: 'admin', venueId: null),
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
        path: '/admin/venues/:venueId/edit',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId']!;
          return VenueFormPage(ownerId: 'admin', venueId: venueId);
        },
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
      GoRoute(
        path: '/admin/email-test',
        builder: (context, state) => const EmailTestPage(),
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
        path: '/admin/create-venue-owner',
        builder: (context, state) => const AdminCreateVenueOwnerPage(),
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
        path: '/admin/database-setup',
        builder: (context, state) => const AdminDatabaseSetupPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'admin') {
            return '/login';
          }
          return null;
        },
      ),
      // Venue Owner Routes
      GoRoute(
        path: '/venue-owner',
        builder: (context, state) {
          final authState = ProviderScope.containerOf(context).read(authProvider);
          final ownerId = authState.user?.id ?? '';
          return VenueOwnerDashboardPage(ownerId: ownerId);
        },
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/venue-owner/venue-form',
        builder: (context, state) {
          final authState = ProviderScope.containerOf(context).read(authProvider);
          final ownerId = authState.user?.id ?? '';
          final venueId = state.uri.queryParameters['venueId'];
          return VenueFormPage(ownerId: ownerId, venueId: venueId);
        },
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/venue-owner/rooms/:venueId',
        builder: (context, state) => RoomManagementPage(venueId: state.pathParameters['venueId']!),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/venue-owner/room-qr',
        builder: (context, state) {
          final venueId = state.uri.queryParameters['venueId'] ?? '';
          final roomId = state.uri.queryParameters['roomId'] ?? '';
          return RoomQrPosterPage(venueId: venueId, roomId: roomId);
        },
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/venue-owner/bookings/:venueId',
        builder: (context, state) => VenueBookingsPage(venueId: state.pathParameters['venueId']!),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/venue-owner/reports/:venueId',
        builder: (context, state) => VenueReportsPage(venueId: state.pathParameters['venueId']!),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/venue-owner/maintenance/:venueId',
        builder: (context, state) =>
            VenueMaintenancePage(venueId: state.pathParameters['venueId']!),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      // Venue Owner General Routes (for bottom navigation)
      GoRoute(
        path: '/venue-owner/bookings',
        builder: (context, state) {
          final authState = ProviderScope.containerOf(context).read(authProvider);
          final ownerId = authState.user?.id ?? '';
          return VenueOwnerBookingsPage(ownerId: ownerId);
        },
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/venue-owner/reports',
        builder: (context, state) {
          final authState = ProviderScope.containerOf(context).read(authProvider);
          final ownerId = authState.user?.id ?? '';
          return VenueOwnerReportsPage(ownerId: ownerId);
        },
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/venue-owner/maintenance',
        builder: (context, state) {
          final authState = ProviderScope.containerOf(context).read(authProvider);
          final ownerId = authState.user?.id ?? '';
          return VenueOwnerMaintenancePage(ownerId: ownerId);
        },
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
      // Booking Routes
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const UserBookingsPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.isGuestUser) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/check-in',
        builder: (context, state) => const UserCheckInScannerPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.isGuestUser) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/book-room',
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return BookingForm(
            venueId: queryParams['venueId'] ?? '',
            venueName: queryParams['venueName'] ?? '',
            roomId: queryParams['roomId'] ?? '',
            roomName: queryParams['roomName'] ?? '',
            hourlyPrice: double.tryParse(queryParams['hourlyPrice'] ?? '0') ?? 0,
            openTime: queryParams['openTime'] ?? '09:00',
            closeTime: queryParams['closeTime'] ?? '22:00',
            timeSlotDuration: int.tryParse(queryParams['timeSlotDuration'] ?? '30') ?? 30,
            allowOpenEndedBookings: queryParams['allowOpenEndedBookings'] == 'true',
          );
        },
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.isGuestUser) {
            return '/login';
          }
          return null;
        },
      ),
      // Search and Discovery Routes
      GoRoute(path: '/search', builder: (context, state) => const AdvancedSearchPage()),
      GoRoute(path: '/venues-map', builder: (context, state) => const VenuesMapPage()),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.isGuestUser) {
            return '/login';
          }
          return null;
        },
      ),
      // Accessibility and Settings Routes
      GoRoute(path: '/accessibility', redirect: (context, state) => '/accessibility-settings'),
      GoRoute(
        path: '/accessibility-settings',
        builder: (context, state) => const AccessibilitySettingsPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.isGuestUser) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/venue-owner/room-form',
        builder: (context, state) {
          final venueId = state.uri.queryParameters['venueId'] ?? '';
          final roomId = state.uri.queryParameters['roomId'];
          return RoomFormPage(venueId: venueId, roomId: roomId);
        },
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final authState = container.read(authProvider);
          if (authState.user == null || authState.user!.role != 'venue_owner') {
            return '/login';
          }
          return null;
        },
      ),
    ],
  );
});

// Loading page widget with timeout
class _LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<_LoadingPage> {
  @override
  void initState() {
    super.initState();
    // Auto-redirect to home after 5 seconds to prevent infinite loading
    Future.delayed(Duration(seconds: 5)).then((_) {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading WADDI Platform...'),
            SizedBox(height: 8),
            Text(
              'Redirecting to home in 5 seconds...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.go('/home'), child: Text('Go to Home Now')),
            SizedBox(height: 8),
            ElevatedButton(onPressed: () => context.go('/debug'), child: Text('Debug Router')),
          ],
        ),
      ),
    );
  }
}
