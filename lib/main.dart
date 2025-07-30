import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'core/services/app_state_service.dart';
import 'core/services/android_back_button_service.dart';
import 'shared/providers/shared_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Skip App Check and Crashlytics for web platform
  if (!kIsWeb) {
    // Temporarily disable App Check to fix loading issues
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
    WidgetsBinding.instance.addObserver(this);
    _restoreAppState();
    
    // Initialize Android back button service after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(goRouterProvider);
      final container = ProviderScope.containerOf(context);
      AndroidBackButtonService.initialize(router, container);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      final appStateService = ref.read(appStateServiceProvider);
      await appStateService.saveAppState();
    } catch (e) {
      print('Failed to save app state: $e');
    }
  }

  Future<void> _restoreAppState() async {
    try {
      final appStateService = ref.read(appStateServiceProvider);
      await appStateService.restoreAppState();
    } catch (e) {
      print('Failed to restore app state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final currentTheme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'WADDI Platform',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: currentTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
