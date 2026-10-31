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
}
