import '../../../students/domain/entities/student.dart';
import '../../domain/entities/study_group.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_local_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupLocalDataSource dataSource;

  GroupRepositoryImpl(this.dataSource);

  @override
  Future<List<StudyGroup>> getGroups() => dataSource.getGroups();

  @override
  Future<List<StudyGroup>> searchGroups(String query) =>
      dataSource.getGroups(query);

  @override
  Future<StudyGroup> getGroup(int groupId) => dataSource.getGroup(groupId);

  @override
  Future<List<Student>> getEnrolledStudents(int groupId) =>
      dataSource.getEnrolledStudents(groupId);

  @override
  Future<List<Student>> getAvailableStudents(int groupId) =>
      dataSource.getAvailableStudents(groupId);

  @override
  Future<int> createGroup(StudyGroup group) => dataSource.createGroup(group);

  @override
  Future<void> updateGroup(StudyGroup group) => dataSource.updateGroup(group);

  @override
  Future<void> addStudents(int groupId, List<int> studentIds) =>
      dataSource.addStudents(groupId, studentIds);

  @override
  Future<bool> removeStudent(int groupId, int studentId) =>
      dataSource.removeStudent(groupId, studentId);

  @override
  Future<int> deleteGroup(int groupId) => dataSource.deleteGroup(groupId);
}
