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
  String welcomeBack(Object teacherName) {
    return 'مرحبًا بعودتك، $teacherName!';
  }

  @override
  String get homeOverviewSubtitle => 'إليك ملخصًا سريعًا لنشاطك اليومي.';

  @override
  String get homeSummary => 'ملخصك';

  @override
  String get homeRetry => 'حاول مرة أخرى';

  @override
  String get teacherNameFallback => 'المدرس';

  @override
  String get todaysLessons => 'دروس اليوم';

  @override
  String get noLessonsToday => 'لا توجد دروس مجدولة اليوم.';

  @override
  String get homeLoadFailed =>
      'تعذر تحميل ملخص الصفحة الرئيسية. حاول مرة أخرى.';

  @override
  String get totalGroups => 'إجمالي المجموعات';

  @override
  String get totalStudents => 'إجمالي الطلاب';

  @override
  String get lessonsThisWeek => 'دروس هذا الأسبوع';

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
  String get allGrades => 'الكل';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get schedule => 'الجدول';

  @override
  String get delete => 'حذف';

  @override
  String get deleteStudent => 'حذف الطالب';

  @override
  String deleteStudentConfirm(Object studentName) {
    return 'هل تريد حذف $studentName نهائيًا مع سجلات تسجيله بالمجموعات وحضوره؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get studentDeleted => 'تم حذف الطالب والسجلات المرتبطة به.';

  @override
  String get studentDeleteFailed => 'تعذر حذف الطالب. لم يتم تغيير البيانات.';

  @override
  String get deleteGroup => 'حذف المجموعة';

  @override
  String deleteGroupConfirm(Object groupName) {
    return 'هل تريد حذف $groupName نهائيًا مع دروسها ومواعيدها وحضورها وتسجيلات الطلاب؟ ستبقى سجلات الطلاب. لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get groupDeleted => 'تم حذف المجموعة والسجلات المرتبطة بها.';

  @override
  String get groupDeleteFailed => 'تعذر حذف المجموعة. لم يتم تغيير البيانات.';

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
  String get activeStudents => 'الطلاب';

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
      'تم حفظ الطالب، لكن تعذر تسجيله بالمجموعة. أعد محاولة التسجيل دون إنشاء طالب آخر.';

  @override
  String get invalidPhone => 'أدخل رقم هاتف محمول مصرياً صحيحاً.';

  @override
  String get ageOutOfRange => 'يجب أن يكون العمر بين 4 و30 عاماً.';

  @override
  String get gradePrimary1 => 'الصف الأول الابتدائي';

  @override
  String get gradePrimary2 => 'الصف الثاني الابتدائي';

  @override
  String get gradePrimary3 => 'الصف الثالث الابتدائي';

  @override
  String get gradePrimary4 => 'الصف الرابع الابتدائي';

  @override
  String get gradePrimary5 => 'الصف الخامس الابتدائي';

  @override
  String get gradePrimary6 => 'الصف السادس الابتدائي';

  @override
  String get gradePreparatory1 => 'الصف الأول الإعدادي';

  @override
  String get gradePreparatory2 => 'الصف الثاني الإعدادي';

  @override
  String get gradePreparatory3 => 'الصف الثالث الإعدادي';

  @override
  String get gradeSecondary1 => 'الصف الأول الثانوي';

  @override
  String get gradeSecondary2 => 'الصف الثاني الثانوي';

  @override
  String get gradeSecondary3 => 'الصف الثالث الثانوي';

  @override
  String legacyGrade(String grade) {
    return 'صف قديم: $grade';
  }

  @override
  String get duplicateSameStudent => 'هذا هو الطالب نفسه';

  @override
  String get reviewExistingStudent => 'مراجعة الطالب الموجود';

  @override
  String get studentEnrolledSuccess => 'تمت إضافة الطالب إلى المجموعة.';

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

  @override
  String legacyStudentNameRetained(String name) {
    return 'الاسم القديم: $name. سيبقى كما هو ما لم تُدخل أجزاء الاسم الثلاثة.';
  }

  @override
  String get openExistingStudentPrompt => 'هل تريد فتح سجل الطالب الموجود؟';

  @override
  String get openExistingStudent => 'فتح سجل الطالب';

  @override
  String get retryEnrollment => 'إعادة محاولة التسجيل';

  @override
  String get invalidGrade => 'اختر صفًا من القائمة.';

  @override
  String get groupScheduleSetup => 'إعداد جدول المجموعة';

  @override
  String get groupScheduleRequired =>
      'أضف موعدًا أسبوعيًا واحدًا على الأقل للمتابعة.';

  @override
  String get continueToStudents => 'المتابعة إلى الطلاب';

  @override
  String get finishSetupLater => 'إنهاء لاحقًا';

  @override
  String get groupSetupComplete => 'اكتمل إعداد المجموعة';

  @override
  String get configuredSchedules => 'المواعيد الأسبوعية';

  @override
  String get enrolledStudentCount => 'الطلاب المسجلون';

  @override
  String get openGroupDetails => 'فتح تفاصيل المجموعة';

  @override
  String get done => 'تم';

  @override
  String studentGradeMismatchWarning(String targetGrade) {
    return 'بعض الطلاب المحددين ليسوا في $targetGrade. يمكنك تسجيلهم رغم ذلك.';
  }

  @override
  String get finishSetupWithoutStudents => 'إنهاء الإعداد دون طلاب';

  @override
  String get groupSetupSaveFailed => 'تعذر حفظ إعداد المجموعة. حاول مرة أخرى.';

  @override
  String get groupSetupIncomplete => 'الإعداد غير مكتمل — متابعة الإعداد';
}
