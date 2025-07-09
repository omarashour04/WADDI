import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/routes/app_router.dart';
import 'package:waddi_platform/shared/themes/app_theme.dart';

class WaddiApp extends ConsumerWidget {
  const WaddiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the goRouterProvider to get the GoRouter instance
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'WADDI Platform',
      theme: AppTheme.lightTheme, // Define your light theme
      // darkTheme: AppTheme.darkTheme, // Uncomment if you have a dark theme
      themeMode: ThemeMode.system, // Or ThemeMode.light/dark
      routerConfig: goRouter, // Assign the GoRouter instance to routerConfig
      debugShowCheckedModeBanner: false, // Hide the debug banner in release mode
    );
  }
} 