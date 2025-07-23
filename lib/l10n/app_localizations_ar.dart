// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'يداو ﺔﺼﻨﻣ';

  @override
  String get loginButtonText => 'لﻮﺧﺪﻟا ﻞﻴﺠﺴﺗ';

  @override
  String get emailHint => 'ﻲﻧوﺮﺘﻜﻟﻹا ﺪﻳﺮﺒﻟا ناﻮﻨﻋ';

  @override
  String get passwordHint => 'روﺮﻤﻟا ﺔﻤﻠﻛ';

  @override
  String welcomeMessage(String userName) {
    return 'ﻚﺑ ﻼﻫأ، $userName';
  }
}
