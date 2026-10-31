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

  @override
  String get addStudent => 'Add Student';

  @override
  String get editStudent => 'Edit Student';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get age => 'Age';

  @override
  String get guardianPhone => 'Guardian Phone';

  @override
  String get notes => 'Notes';

  @override
  String get required => 'Required';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get archive => 'Archive';

  @override
  String get archiveConfirm => 'Archive this student?';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search by name or phone';

  @override
  String get noResults => 'No results';

  @override
  String get saving => 'Saving...';

  @override
  String get saveFailed =>
      'Could not save the student. Your changes are still here; please try again.';

  @override
  String get invalidAge => 'Enter a valid non-negative age.';

  @override
  String get groupName => 'Group name';

  @override
  String get targetGrade => 'Target grade';

  @override
  String get createGroup => 'Create group';

  @override
  String get editGroup => 'Edit group';

  @override
  String get groupDetails => 'Group details';

  @override
  String get addStudents => 'Add students';

  @override
  String get removeStudent => 'Remove student';

  @override
  String removeStudentConfirm(Object studentName) {
    return 'Remove $studentName from this group?';
  }

  @override
  String get activeStudents => 'Active students';

  @override
  String get noEnrolledStudents => 'No students are enrolled in this group.';

  @override
  String get noAvailableStudents => 'There are no students available to add.';

  @override
  String addSelectedStudents(int count) {
    return 'Add selected students ($count)';
  }

  @override
  String get duplicateGroupName => 'A group with this name already exists.';

  @override
  String get groupSaveFailed =>
      'Could not save the group. Your changes are still here; please try again.';

  @override
  String get groupLoadFailed => 'Could not load group data. Please try again.';

  @override
  String get groupSearchHint => 'Search by group name or target grade';

  @override
  String get noGroups => 'No groups yet.';

  @override
  String get noGroupsFound => 'No matching groups found.';

  @override
  String get groupSchedules => 'Group schedules';

  @override
  String get noSchedules => 'No schedules for this group.';

  @override
  String get addSchedule => 'Add schedule';

  @override
  String get editSchedule => 'Edit schedule';

  @override
  String get removeSchedule => 'Remove schedule';

  @override
  String get removeScheduleConfirm =>
      'Remove this schedule? Existing lessons will be kept.';

  @override
  String get weekday => 'Weekday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get startTime => 'Start time';

  @override
  String get endTime => 'End time';

  @override
  String get chooseTime => 'Choose a time';

  @override
  String get scheduleActive => 'Active schedule';

  @override
  String get scheduleInactive => 'Inactive';

  @override
  String get scheduleTimesRequired => 'Choose both a start and end time.';

  @override
  String get invalidTimeRange => 'End time must be later than start time.';

  @override
  String get scheduleConflict =>
      'This time overlaps another active schedule for this weekday.';

  @override
  String get scheduleSaveFailed =>
      'Could not save the schedule. Please try again.';

  @override
  String get scheduleLoadFailed =>
      'Could not load schedules. Please try again.';

  @override
  String get manage => 'Manage';

  @override
  String get groupLessons => 'Group lessons';

  @override
  String get viewAll => 'View all';

  @override
  String get createLesson => 'Create lesson';

  @override
  String get editLesson => 'Edit lesson';

  @override
  String get lessonDetails => 'Lesson details';

  @override
  String get group => 'Group';

  @override
  String get lessonDate => 'Lesson date';

  @override
  String get lessonTime => 'Lesson time';

  @override
  String get lessonStatus => 'Status';

  @override
  String get lessonScheduled => 'Scheduled';

  @override
  String get lessonCanceled => 'Canceled';

  @override
  String get cancellationReason => 'Cancellation reason';

  @override
  String get duplicateLesson =>
      'A lesson already exists for this group, date, and start time.';

  @override
  String get invalidLessonTime => 'End time must be later than start time.';

  @override
  String get lessonFieldsRequired => 'Choose a group and both lesson times.';

  @override
  String get lessonSaveFailed =>
      'Could not save the lesson. Your changes are still here; please try again.';

  @override
  String get lessonLoadFailed => 'Could not load lessons. Please try again.';

  @override
  String get noLessons => 'No lessons yet.';

  @override
  String get attendance => 'Attendance';

  @override
  String get takeAttendance => 'Take attendance';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get notMarked => 'Not marked';

  @override
  String get noAttendanceStudents =>
      'No students are enrolled for this lesson.';

  @override
  String get saveAttendance => 'Save attendance';

  @override
  String get attendanceSaved => 'Attendance saved.';

  @override
  String get attendanceLoadFailed =>
      'Could not load attendance. Please try again.';

  @override
  String get attendanceSaveFailed =>
      'Could not save attendance. Your changes are still here; please try again.';
}
