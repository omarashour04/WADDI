import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
// Auth pages
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
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

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/venues',
      builder: (context, state) => VenuesPage(),
    ),
    GoRoute(
      path: '/venues/:venueId/rooms',
      builder: (context, state) => RoomsPage(venueId: state.pathParameters['venueId']!),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => UsersPage(),
    ),
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
  initialLocation: '/login',
);

final goRouterProvider = Provider<GoRouter>((ref) => appRouter); 