import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:waddi_platform/shared/providers/shared_providers.dart';

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: currentTheme == ThemeMode.dark ? AppColors.primaryDark : AppColors.primary,
        foregroundColor: currentTheme == ThemeMode.dark ? Colors.white : AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          String targetRoute = '/home';
          switch (index) {
            case 0:
              targetRoute = '/home';
              break;
            case 1:
              targetRoute = '/search';
              break;
            case 2:
              targetRoute = '/venues';
              break;
            case 3:
              if (!isGuest) {
                targetRoute = '/bookings';
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
              break;
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
      ),
    );
  }
}
