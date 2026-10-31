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
  String get saveFailed =>
      'تعذر حفظ بيانات الطالب. تغييراتك ما زالت موجودة، حاول مرة أخرى.';

  @override
  String get invalidAge => 'أدخل عمراً صحيحاً غير سالب.';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get targetGrade => 'الصف المستهدف';

  @override
  String get createGroup => 'إنشاء مجموعة';

  @override
  String get editGroup => 'تعديل المجموعة';

  @override
  String get groupDetails => 'تفاصيل المجموعة';

  @override
  String get addStudents => 'إضافة طلاب';

  @override
  String get removeStudent => 'إزالة الطالب';

  @override
  String removeStudentConfirm(Object studentName) {
    return 'هل تريد إزالة $studentName من هذه المجموعة؟';
  }

  @override
  String get activeStudents => 'الطلاب النشطون';

  @override
  String get noEnrolledStudents => 'لا يوجد طلاب مسجلون في هذه المجموعة.';

  @override
  String get noAvailableStudents => 'لا يوجد طلاب متاحون للإضافة.';

  @override
  String get addNewStudent => 'إضافة طالب جديد';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get fatherName => 'اسم الأب';

  @override
  String get familyName => 'اسم العائلة';

  @override
  String get duplicateStudentTitle => 'احتمال وجود طالب مكرر';

  @override
  String duplicateStudentMessage(Object names) {
    return 'يوجد طالب بهذا الاسم والصف بالفعل: $names. راجع الطالب الحالي أو أكد أن هذا طالب مختلف.';
  }

  @override
  String get differentStudent => 'هذا طالب مختلف';

  @override
  String get studentCreatedEnrollmentFailed =>
      'تم إنشاء الطالب، لكن تعذرت إضافته إلى المجموعة. أضف الطالب من قائمة التسجيل.';

  @override
  String addSelectedStudents(int count) {
    return 'إضافة الطلاب المحددين ($count)';
  }

  @override
  String get duplicateGroupName => 'توجد مجموعة أخرى بهذا الاسم.';

  @override
  String get groupSaveFailed =>
      'تعذر حفظ المجموعة. تغييراتك ما زالت موجودة، حاول مرة أخرى.';

  @override
  String get groupLoadFailed => 'تعذر تحميل بيانات المجموعة. حاول مرة أخرى.';

  @override
  String get groupSearchHint => 'ابحث باسم المجموعة أو الصف المستهدف';

  @override
  String get noGroups => 'لا توجد مجموعات بعد.';

  @override
  String get noGroupsFound => 'لم يتم العثور على مجموعات مطابقة.';

  @override
  String get groupSchedules => 'مواعيد المجموعة';

  @override
  String get noSchedules => 'لا توجد مواعيد لهذه المجموعة.';

  @override
  String get addSchedule => 'إضافة موعد';

  @override
  String get editSchedule => 'تعديل الموعد';

  @override
  String get removeSchedule => 'إزالة الموعد';

  @override
  String get removeScheduleConfirm =>
      'هل تريد إزالة هذا الموعد؟ ستظل الدروس الحالية محفوظة.';

  @override
  String get weekday => 'اليوم';

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get startTime => 'وقت البدء';

  @override
  String get endTime => 'وقت الانتهاء';

  @override
  String get chooseTime => 'اختر الوقت';

  @override
  String get scheduleActive => 'موعد نشط';

  @override
  String get scheduleInactive => 'غير نشط';

  @override
  String get scheduleTimesRequired => 'اختر وقت البدء والانتهاء.';

  @override
  String get invalidTimeRange => 'يجب أن يكون وقت الانتهاء بعد وقت البدء.';

  @override
  String get scheduleConflict =>
      'يتداخل هذا الوقت مع موعد نشط آخر في اليوم نفسه.';

  @override
  String get scheduleSaveFailed => 'تعذر حفظ الموعد. حاول مرة أخرى.';

  @override
  String get scheduleLoadFailed => 'تعذر تحميل المواعيد. حاول مرة أخرى.';

  @override
  String get manage => 'إدارة';

  @override
  String get groupLessons => 'دروس المجموعة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get createLesson => 'إنشاء درس';

  @override
  String get editLesson => 'تعديل الدرس';

  @override
  String get lessonDetails => 'تفاصيل الدرس';

  @override
  String get group => 'المجموعة';

  @override
  String get lessonDate => 'تاريخ الدرس';

  @override
  String get lessonTime => 'وقت الدرس';

  @override
  String get lessonStatus => 'الحالة';

  @override
  String get lessonScheduled => 'مجدول';

  @override
  String get lessonCanceled => 'ملغى';

  @override
  String get cancellationReason => 'سبب الإلغاء';

  @override
  String get duplicateLesson =>
      'يوجد درس لهذه المجموعة والتاريخ ووقت البدء بالفعل.';

  @override
  String get invalidLessonTime => 'يجب أن يكون وقت الانتهاء بعد وقت البدء.';

  @override
  String get lessonFieldsRequired => 'اختر المجموعة ووقت البدء والانتهاء.';

  @override
  String get lessonSaveFailed =>
      'تعذر حفظ الدرس. تغييراتك ما زالت موجودة، حاول مرة أخرى.';

  @override
  String get lessonLoadFailed => 'تعذر تحميل الدروس. حاول مرة أخرى.';

  @override
  String get noLessons => 'لا توجد دروس بعد.';

  @override
  String get attendance => 'الحضور';

  @override
  String get takeAttendance => 'تسجيل الحضور';

  @override
  String get present => 'حاضر';

  @override
  String get absent => 'غائب';

  @override
  String get notMarked => 'غير محدد';

  @override
  String get noAttendanceStudents => 'لا يوجد طلاب مسجلون لهذا الدرس.';

  @override
  String get saveAttendance => 'حفظ الحضور';

  @override
  String get attendanceSaved => 'تم حفظ الحضور.';

  @override
  String get attendanceLoadFailed => 'تعذر تحميل الحضور. حاول مرة أخرى.';

  @override
  String get attendanceSaveFailed =>
      'تعذر حفظ الحضور. تغييراتك ما زالت موجودة، حاول مرة أخرى.';

  @override
  String get weeklySchedule => 'الجدول الأسبوعي';

  @override
  String get addWeeklySchedule => 'إضافة موعد أسبوعي';

  @override
  String get editWeeklySchedule => 'تعديل الموعد الأسبوعي';

  @override
  String get recurringWeeklyDescription =>
      'يتكرر هذا الموعد كل أسبوع في اليوم المحدد.';

  @override
  String get upcomingLessons => 'الحصص القادمة';

  @override
  String get noUpcomingLessons =>
      'لا توجد حصص قادمة خلال الثلاثين يوماً المقبلة.';

  @override
  String get addExceptionalLesson => 'إضافة حصة استثنائية';

  @override
  String get exceptionalLessonDescription =>
      'تُنشأ الحصة لهذا التاريخ فقط ولا تغيّر الجدول الأسبوعي.';
}
