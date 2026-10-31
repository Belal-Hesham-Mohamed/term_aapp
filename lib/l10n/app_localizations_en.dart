// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TERM';

  @override
  String get home => 'Home';

  @override
  String get students => 'Students';

  @override
  String get groups => 'Groups';

  @override
  String get lessons => 'Lessons';

  @override
  String get more => 'More';

  @override
  String get noStudents => 'No students found.';

  @override
  String get grade => 'Grade';

  @override
  String get error => 'Error';
}
