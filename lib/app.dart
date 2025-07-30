import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:waddi_platform/routes/app_router.dart';
import 'package:waddi_platform/shared/themes/app_theme.dart';
import 'package:waddi_platform/l10n/app_localizations.dart';
import 'package:waddi_platform/shared/widgets/app_back_button_handler.dart';
import 'package:waddi_platform/shared/providers/shared_providers.dart';

class WaddiApp extends ConsumerWidget {
  const WaddiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.read(goRouterProvider);
    final currentTheme = ref.watch(themeProvider);

    return AppBackButtonHandler(
      child: MaterialApp.router(
        title: 'WADDI Platform',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: currentTheme,
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
        // Localization setup
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
