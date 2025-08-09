import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'core/services/android_back_button_service.dart';
import 'shared/providers/shared_providers.dart';
import 'features/accessibility/presentation/providers/accessibility_provider.dart';
import 'shared/services/offline_mode_service.dart';
import 'shared/services/notification_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Skip App Check and Crashlytics for web platform
  if (!kIsWeb) {
    // Temporarily disable App Check to fix storage issues
    // await FirebaseAppCheck.instance.activate(
    //   androidProvider: AndroidProvider.debug,
    //   appleProvider: AppleProvider.debug,
    // );

    // Initialize Crashlytics error forwarding (mobile only)
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  print('Firebase initialized successfully');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    _initializeApp();
    
    // Initialize Android back button service after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(goRouterProvider);
      final container = ProviderScope.containerOf(context);
      AndroidBackButtonService.initialize(router, container);
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize offline mode service
      await OfflineModeService.instance.initialize();

      // Initialize other services
      ref.read(themeProvider);
      ref.read(languageProvider);
      final auth = ref.read(authProvider);
      if (auth.user != null && !auth.isGuestUser) {
        await NotificationService.initializePushForUser(uid: auth.user!.id);
      }

      // Handle FCM messages
      // Foreground
      FirebaseMessaging.onMessage.listen((message) {
        if (!mounted) return;
        final notif = message.notification;
        final text = notif?.title ?? notif?.body ?? 'New notification';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text)),
        );
      });
      // App opened from background via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final bookingId = message.data['bookingId'];
        if (bookingId != null && mounted) {
          ref.read(goRouterProvider).go('/booking-details/$bookingId');
        }
      });
      // App launched from terminated via notification tap
      final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMsg != null) {
        final bookingId = initialMsg.data['bookingId'];
        if (bookingId != null && mounted) {
          // Delay until router ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(goRouterProvider).go('/booking-details/$bookingId');
          });
        }
      }
      
      // Initialize accessibility settings after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(accessibilityProvider.notifier).detectAndApplyDeviceSettings(context);
        }
      });
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  @override
  void dispose() {
    // Cleanup if needed
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _saveAppState();
        break;
      case AppLifecycleState.resumed:
        _restoreAppState();
        break;
      default:
        break;
    }
  }

  Future<void> _saveAppState() async {
    try {
      // Save app state if needed
      print('App state saved');
    } catch (e) {
      print('Failed to save app state: $e');
    }
  }

  Future<void> _restoreAppState() async {
    try {
      // Restore app state if needed
      print('App state restored');
    } catch (e) {
      print('Failed to restore app state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(languageProvider);
    final accessibilitySettings = ref.watch(accessibilityProvider);

    return MaterialApp.router(
      title: 'WADDI Platform',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        textTheme: ThemeData.light(useMaterial3: true).textTheme.apply(
          bodyColor: accessibilitySettings.highContrastEnabled ? Colors.black : null,
          displayColor: accessibilitySettings.highContrastEnabled ? Colors.black : null,
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: ThemeData.dark(useMaterial3: true).textTheme.apply(
          bodyColor: accessibilitySettings.highContrastEnabled ? Colors.white : null,
          displayColor: accessibilitySettings.highContrastEnabled ? Colors.white : null,
        ),
      ),
      themeMode: currentTheme,
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        // Apply accessibility settings globally
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            boldText: accessibilitySettings.boldTextEnabled,
            highContrast: accessibilitySettings.highContrastEnabled, textScaler: TextScaler.linear(accessibilitySettings.textScaleFactor),
            disableAnimations: !accessibilitySettings.showAnimations,
          ),
          child: child!,
        );
      },
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
