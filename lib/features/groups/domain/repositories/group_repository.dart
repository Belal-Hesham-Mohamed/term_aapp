import '../../../students/domain/entities/student.dart';
import '../entities/study_group.dart';

abstract class GroupRepository {
  Future<List<StudyGroup>> getGroups();
  Future<List<StudyGroup>> searchGroups(String query);
  Future<StudyGroup> getGroup(int groupId);
  Future<List<Student>> getEnrolledStudents(int groupId);
  Future<List<Student>> getAvailableStudents(int groupId);
  Future<int> createGroup(StudyGroup group);
  Future<void> updateGroup(StudyGroup group);
  Future<void> addStudents(int groupId, List<int> studentIds);
  Future<bool> removeStudent(int groupId, int studentId);
  Future<int> deleteGroup(int groupId);
}

class DuplicateGroupNameException implements Exception {}
