// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Plateforme WADDI';

  @override
  String get loginButtonText => 'Se connecter';

  @override
  String get emailHint => 'Adresse e-mail';

  @override
  String get passwordHint => 'Mot de passe';

  @override
  String welcomeMessage(String userName) {
    return 'Bienvenue, $userName';
  }
}
