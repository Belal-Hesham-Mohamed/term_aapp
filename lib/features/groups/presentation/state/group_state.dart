import '../../../students/domain/entities/student.dart';
import '../../domain/entities/study_group.dart';

abstract class GroupState {}

class GroupLoading extends GroupState {}

class GroupListLoaded extends GroupState {
  final List<StudyGroup> groups;
  final String query;
  GroupListLoaded(this.groups, {this.query = ''});
}

class GroupDetailsLoading extends GroupState {}

class GroupDetailsLoaded extends GroupState {
  final StudyGroup group;
  final List<Student> students;
  GroupDetailsLoaded(this.group, this.students);
}

class GroupAvailableStudentsLoaded extends GroupState {
  final List<Student> students;
  GroupAvailableStudentsLoaded(this.students);
}

class GroupFailure extends GroupState {
  final String message;
  GroupFailure(this.message);
}
