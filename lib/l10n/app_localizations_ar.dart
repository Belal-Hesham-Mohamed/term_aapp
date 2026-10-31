// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'TERM';

  @override
  String get home => 'الرئيسية';

  @override
  String get students => 'الطلاب';

  @override
  String get groups => 'المجموعات';

  @override
  String get lessons => 'الدروس';

  @override
  String get more => 'المزيد';

  @override
  String get noStudents => 'لا يوجد طلاب';

  @override
  String get grade => 'الصف';

  @override
  String get error => 'خطأ';
}
