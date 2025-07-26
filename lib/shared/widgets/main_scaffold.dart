import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';

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
              context.go('/bookings/$userId');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
