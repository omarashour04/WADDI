import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/firebase_options.dart';
import 'package:waddi_platform/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Skip App Check and Crashlytics for web platform
    if (!kIsWeb) {
      // Initialize Firebase App Check (mobile only)
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );

      // Initialize Crashlytics error forwarding (mobile only)
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Don't rethrow on web to prevent app crash
    if (!kIsWeb) {
      rethrow;
    }
  }

  runApp(const ProviderScope(child: WaddiApp()));
}
