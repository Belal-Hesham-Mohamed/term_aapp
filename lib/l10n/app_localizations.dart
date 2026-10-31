import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TERM'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @noStudents.
  ///
  /// In en, this message translates to:
  /// **'No students found.'**
  String get noStudents;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @addStudent.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get addStudent;

  /// No description provided for @editStudent.
  ///
  /// In en, this message translates to:
  /// **'Edit Student'**
  String get editStudent;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @guardianPhone.
  ///
  /// In en, this message translates to:
  /// **'Guardian Phone'**
  String get guardianPhone;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @archiveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive this student?'**
  String get archiveConfirm;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the student. Your changes are still here; please try again.'**
  String get saveFailed;

  /// No description provided for @invalidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative age.'**
  String get invalidAge;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @targetGrade.
  ///
  /// In en, this message translates to:
  /// **'Target grade'**
  String get targetGrade;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// No description provided for @groupDetails.
  ///
  /// In en, this message translates to:
  /// **'Group details'**
  String get groupDetails;

  /// No description provided for @addStudents.
  ///
  /// In en, this message translates to:
  /// **'Add students'**
  String get addStudents;

  /// No description provided for @removeStudent.
  ///
  /// In en, this message translates to:
  /// **'Remove student'**
  String get removeStudent;

  /// No description provided for @removeStudentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {studentName} from this group?'**
  String removeStudentConfirm(Object studentName);

  /// No description provided for @activeStudents.
  ///
  /// In en, this message translates to:
  /// **'Active students'**
  String get activeStudents;

  /// No description provided for @noEnrolledStudents.
  ///
  /// In en, this message translates to:
  /// **'No students are enrolled in this group.'**
  String get noEnrolledStudents;

  /// No description provided for @noAvailableStudents.
  ///
  /// In en, this message translates to:
  /// **'There are no students available to add.'**
  String get noAvailableStudents;

  /// No description provided for @addNewStudent.
  ///
  /// In en, this message translates to:
  /// **'Add New Student'**
  String get addNewStudent;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s name'**
  String get fatherName;

  /// No description provided for @familyName.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyName;

  /// No description provided for @duplicateStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate student'**
  String get duplicateStudentTitle;

  /// No description provided for @duplicateStudentMessage.
  ///
  /// In en, this message translates to:
  /// **'A student with this name and grade already exists: {names}. Review the existing student or confirm this is a different student.'**
  String duplicateStudentMessage(Object names);

  /// No description provided for @differentStudent.
  ///
  /// In en, this message translates to:
  /// **'This is a different student'**
  String get differentStudent;

  /// No description provided for @studentCreatedEnrollmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Student created, but could not be added to this group. Add the existing student from the enrollment list.'**
  String get studentCreatedEnrollmentFailed;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Egyptian mobile number.'**
  String get invalidPhone;

  /// No description provided for @ageOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Age must be between 4 and 30.'**
  String get ageOutOfRange;

  /// No description provided for @gradePrimary1.
  ///
  /// In en, this message translates to:
  /// **'First Primary'**
  String get gradePrimary1;

  /// No description provided for @gradePrimary2.
  ///
  /// In en, this message translates to:
  /// **'Second Primary'**
  String get gradePrimary2;

  /// No description provided for @gradePrimary3.
  ///
  /// In en, this message translates to:
  /// **'Third Primary'**
  String get gradePrimary3;

  /// No description provided for @gradePrimary4.
  ///
  /// In en, this message translates to:
  /// **'Fourth Primary'**
  String get gradePrimary4;

  /// No description provided for @gradePrimary5.
  ///
  /// In en, this message translates to:
  /// **'Fifth Primary'**
  String get gradePrimary5;

  /// No description provided for @gradePrimary6.
  ///
  /// In en, this message translates to:
  /// **'Sixth Primary'**
  String get gradePrimary6;

  /// No description provided for @gradePreparatory1.
  ///
  /// In en, this message translates to:
  /// **'First Preparatory'**
  String get gradePreparatory1;

  /// No description provided for @gradePreparatory2.
  ///
  /// In en, this message translates to:
  /// **'Second Preparatory'**
  String get gradePreparatory2;

  /// No description provided for @gradePreparatory3.
  ///
  /// In en, this message translates to:
  /// **'Third Preparatory'**
  String get gradePreparatory3;

  /// No description provided for @gradeSecondary1.
  ///
  /// In en, this message translates to:
  /// **'First Secondary'**
  String get gradeSecondary1;

  /// No description provided for @gradeSecondary2.
  ///
  /// In en, this message translates to:
  /// **'Second Secondary'**
  String get gradeSecondary2;

  /// No description provided for @gradeSecondary3.
  ///
  /// In en, this message translates to:
  /// **'Third Secondary'**
  String get gradeSecondary3;

  /// No description provided for @legacyGrade.
  ///
  /// In en, this message translates to:
  /// **'Legacy grade: {grade}'**
  String legacyGrade(Object grade);

  /// No description provided for @duplicateSameStudent.
  ///
  /// In en, this message translates to:
  /// **'This is the same student'**
  String get duplicateSameStudent;

  /// No description provided for @reviewExistingStudent.
  ///
  /// In en, this message translates to:
  /// **'Review existing student'**
  String get reviewExistingStudent;

  /// No description provided for @studentEnrolledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Student added to the group.'**
  String get studentEnrolledSuccess;

  /// No description provided for @addSelectedStudents.
  ///
  /// In en, this message translates to:
  /// **'Add selected students ({count})'**
  String addSelectedStudents(int count);

  /// No description provided for @duplicateGroupName.
  ///
  /// In en, this message translates to:
  /// **'A group with this name already exists.'**
  String get duplicateGroupName;

  /// No description provided for @groupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the group. Your changes are still here; please try again.'**
  String get groupSaveFailed;

  /// No description provided for @groupLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load group data. Please try again.'**
  String get groupLoadFailed;

  /// No description provided for @groupSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by group name or target grade'**
  String get groupSearchHint;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet.'**
  String get noGroups;

  /// No description provided for @noGroupsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching groups found.'**
  String get noGroupsFound;

  /// No description provided for @groupSchedules.
  ///
  /// In en, this message translates to:
  /// **'Group schedules'**
  String get groupSchedules;

  /// No description provided for @noSchedules.
  ///
  /// In en, this message translates to:
  /// **'No schedules for this group.'**
  String get noSchedules;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add schedule'**
  String get addSchedule;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit schedule'**
  String get editSchedule;

  /// No description provided for @removeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Remove schedule'**
  String get removeSchedule;

  /// No description provided for @removeScheduleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this schedule? Existing lessons will be kept.'**
  String get removeScheduleConfirm;

  /// No description provided for @weekday.
  ///
  /// In en, this message translates to:
  /// **'Weekday'**
  String get weekday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get chooseTime;

  /// No description provided for @scheduleActive.
  ///
  /// In en, this message translates to:
  /// **'Active schedule'**
  String get scheduleActive;

  /// No description provided for @scheduleInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get scheduleInactive;

  /// No description provided for @scheduleTimesRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose both a start and end time.'**
  String get scheduleTimesRequired;

  /// No description provided for @invalidTimeRange.
  ///
  /// In en, this message translates to:
  /// **'End time must be later than start time.'**
  String get invalidTimeRange;

  /// No description provided for @scheduleConflict.
  ///
  /// In en, this message translates to:
  /// **'This time overlaps another active schedule for this weekday.'**
  String get scheduleConflict;

  /// No description provided for @scheduleSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the schedule. Please try again.'**
  String get scheduleSaveFailed;

  /// No description provided for @scheduleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load schedules. Please try again.'**
  String get scheduleLoadFailed;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @groupLessons.
  ///
  /// In en, this message translates to:
  /// **'Group lessons'**
  String get groupLessons;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @createLesson.
  ///
  /// In en, this message translates to:
  /// **'Create lesson'**
  String get createLesson;

  /// No description provided for @editLesson.
  ///
  /// In en, this message translates to:
  /// **'Edit lesson'**
  String get editLesson;

  /// No description provided for @lessonDetails.
  ///
  /// In en, this message translates to:
  /// **'Lesson details'**
  String get lessonDetails;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @lessonDate.
  ///
  /// In en, this message translates to:
  /// **'Lesson date'**
  String get lessonDate;

  /// No description provided for @lessonTime.
  ///
  /// In en, this message translates to:
  /// **'Lesson time'**
  String get lessonTime;

  /// No description provided for @lessonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get lessonStatus;

  /// No description provided for @lessonScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get lessonScheduled;

  /// No description provided for @lessonCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get lessonCanceled;

  /// No description provided for @cancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancellationReason;

  /// No description provided for @duplicateLesson.
  ///
  /// In en, this message translates to:
  /// **'A lesson already exists for this group, date, and start time.'**
  String get duplicateLesson;

  /// No description provided for @invalidLessonTime.
  ///
  /// In en, this message translates to:
  /// **'End time must be later than start time.'**
  String get invalidLessonTime;

  /// No description provided for @lessonFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a group and both lesson times.'**
  String get lessonFieldsRequired;

  /// No description provided for @lessonSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the lesson. Your changes are still here; please try again.'**
  String get lessonSaveFailed;

  /// No description provided for @lessonLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load lessons. Please try again.'**
  String get lessonLoadFailed;

  /// No description provided for @noLessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons yet.'**
  String get noLessons;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @takeAttendance.
  ///
  /// In en, this message translates to:
  /// **'Take attendance'**
  String get takeAttendance;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @notMarked.
  ///
  /// In en, this message translates to:
  /// **'Not marked'**
  String get notMarked;

  /// No description provided for @noAttendanceStudents.
  ///
  /// In en, this message translates to:
  /// **'No students are enrolled for this lesson.'**
  String get noAttendanceStudents;

  /// No description provided for @saveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Save attendance'**
  String get saveAttendance;

  /// No description provided for @attendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved.'**
  String get attendanceSaved;

  /// No description provided for @attendanceLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load attendance. Please try again.'**
  String get attendanceLoadFailed;

  /// No description provided for @attendanceSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save attendance. Your changes are still here; please try again.'**
  String get attendanceSaveFailed;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklySchedule;

  /// No description provided for @addWeeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Weekly Schedule'**
  String get addWeeklySchedule;

  /// No description provided for @editWeeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Weekly Schedule'**
  String get editWeeklySchedule;

  /// No description provided for @recurringWeeklyDescription.
  ///
  /// In en, this message translates to:
  /// **'This appointment repeats every week on the selected weekday.'**
  String get recurringWeeklyDescription;

  /// No description provided for @upcomingLessons.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Lessons'**
  String get upcomingLessons;

  /// No description provided for @noUpcomingLessons.
  ///
  /// In en, this message translates to:
  /// **'No upcoming lessons in the next 30 days.'**
  String get noUpcomingLessons;

  /// No description provided for @addExceptionalLesson.
  ///
  /// In en, this message translates to:
  /// **'Add Exceptional Lesson'**
  String get addExceptionalLesson;

  /// No description provided for @exceptionalLessonDescription.
  ///
  /// In en, this message translates to:
  /// **'This creates a lesson on one date only and does not change the weekly schedule.'**
  String get exceptionalLessonDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
