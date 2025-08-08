import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/shared/providers/shared_providers.dart';
import 'package:waddi_platform/shared/services/offline_mode_service.dart';
import 'package:waddi_platform/shared/widgets/offline_mode_widget.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  final int currentIndex;
  final String userId;
  const MainScaffold({
    required this.child,
    required this.currentIndex,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final isGuest = authState.isGuestUser;
    final userRole = authState.user?.role;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: currentTheme == ThemeMode.dark ? AppColors.primaryDark : AppColors.primary,
        foregroundColor: currentTheme == ThemeMode.dark ? Colors.white : AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Offline status bar
          const OfflineStatusBar(),
          // Main content
          Expanded(
            child: SafeArea(child: child),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, userRole, isGuest),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref, String? userRole, bool isGuest) {
    // Venue Owner Navigation
    if (userRole == 'venue_owner') {
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          String targetRoute = '/venue-owner';
          switch (index) {
            case 0:
              targetRoute = '/venue-owner';
              break;
            case 1:
              targetRoute = '/venue-owner/bookings';
              break;
            case 2:
              targetRoute = '/venue-owner/reports';
              break;
            case 3:
              targetRoute = '/venue-owner/maintenance';
              break;
            case 4:
              targetRoute = '/profile';
              break;
          }

          // Check if operation is allowed offline
          final offlineService = OfflineModeService.instance;
          if (!offlineService.isOperationAllowed(OfflineOperation.venueOwnerOperations)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(offlineService.getOfflineMessage(OfflineOperation.venueOwnerOperations)),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          // Add route to navigation history before navigating
          ref.read(navigationHistoryProvider.notifier).addRoute(targetRoute);
          context.go(targetRoute);
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          const BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
          const BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Maintenance'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      );
    }

    // Admin Navigation (placeholder for future implementation)
    if (userRole == 'admin') {
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          String targetRoute = '/admin';
          switch (index) {
            case 0:
              targetRoute = '/admin';
              break;
            case 1:
              targetRoute = '/admin/users';
              break;
            case 2:
              targetRoute = '/admin/venues';
              break;
            case 3:
              targetRoute = '/admin/bookings';
              break;
            case 4:
              targetRoute = '/profile';
              break;
          }

          // Check if operation is allowed offline
          final offlineService = OfflineModeService.instance;
          if (!offlineService.isOperationAllowed(OfflineOperation.adminOperations)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(offlineService.getOfflineMessage(OfflineOperation.adminOperations)),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          // Add route to navigation history before navigating
          ref.read(navigationHistoryProvider.notifier).addRoute(targetRoute);
          context.go(targetRoute);
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          const BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Venues'),
          const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      );
    }

    // Regular User Navigation (existing implementation)
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        String targetRoute = '/home';
        OfflineOperation? operation;
        
        switch (index) {
          case 0:
            targetRoute = '/home';
            break;
          case 1:
            targetRoute = '/search';
            operation = OfflineOperation.searchVenues;
            break;
          case 2:
            targetRoute = '/venues';
            operation = OfflineOperation.browseVenues;
            break;
          case 3:
            if (!isGuest) {
              targetRoute = '/bookings';
              operation = OfflineOperation.viewBookings;
            } else {
              // Show dialog for guest users
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Login Required'),
                  content: const Text('Please log in to view your bookings.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/login');
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              );
              return; // Don't navigate if showing dialog
            }
            break;
          case 4:
            targetRoute = '/profile';
            operation = OfflineOperation.viewProfile;
            break;
        }

        // Check if operation is allowed offline
        if (operation != null) {
          final offlineService = OfflineModeService.instance;
          if (!offlineService.isOperationAllowed(operation)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(offlineService.getOfflineMessage(operation)),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
        }

        // Add route to navigation history before navigating
        ref.read(navigationHistoryProvider.notifier).addRoute(targetRoute);
        context.go(targetRoute);
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        const BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Venues'),
        const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
