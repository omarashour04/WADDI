import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/features/auth/presentation/providers/auth_provider.dart';

// Theme provider for managing light/dark mode
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              currentTheme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.textOnPrimary,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).state = currentTheme == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
            tooltip: currentTheme == ThemeMode.dark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/venues');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              if (!isGuest) {
                context.go('/bookings/$userId');
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
                          context.go('/login');
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                );
              }
              break;
            case 3:
              if (!isGuest) {
                context.go('/profile');
              } else {
                // Show dialog for guest users
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Login Required'),
                    content: const Text('Please log in to access your profile.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/login');
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                );
              }
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          if (!isGuest) const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          if (!isGuest) const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
