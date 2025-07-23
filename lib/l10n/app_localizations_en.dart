// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WADDI Platform';

  @override
  String get loginButtonText => 'Login';

  @override
  String get emailHint => 'Email Address';

  @override
  String get passwordHint => 'Password';

  @override
  String welcomeMessage(String userName) {
    return 'Welcome, $userName';
  }
}
