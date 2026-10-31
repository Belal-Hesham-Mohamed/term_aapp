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

  @override
  String get addStudent => 'إضافة طالب';

  @override
  String get editStudent => 'تعديل طالب';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get age => 'العمر';

  @override
  String get guardianPhone => 'رقم ولي الأمر';

  @override
  String get notes => 'ملاحظات';

  @override
  String get required => 'مطلوب';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get archive => 'أرشفة';

  @override
  String get archiveConfirm => 'هل تريد أرشفة هذا الطالب؟';

  @override
  String get search => 'بحث';

  @override
  String get searchHint => 'بحث بالاسم أو رقم الهاتف';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get saveFailed => 'تعذر حفظ بيانات الطالب. تغييراتك ما زالت موجودة، حاول مرة أخرى.';

  @override
  String get invalidAge => 'أدخل عمراً صحيحاً غير سالب.';
}
