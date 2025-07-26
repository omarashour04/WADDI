import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waddi_platform/firebase_options.dart';
import 'package:waddi_platform/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );

    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    rethrow;
  }

  runApp(const ProviderScope(child: WaddiApp()));
}
