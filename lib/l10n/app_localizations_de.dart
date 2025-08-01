// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'WADDI Plattform';

  @override
  String get loginButtonText => 'Anmelden';

  @override
  String get emailHint => 'E-Mail-Adresse';

  @override
  String get passwordHint => 'Passwort';

  @override
  String welcomeMessage(String userName) {
    return 'Willkommen, $userName';
  }
}
