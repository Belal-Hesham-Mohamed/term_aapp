import '../../../lessons/domain/entities/lesson_record.dart';

abstract class HomeRepository {
  Future<String?> getTeacherName();
  Future<List<LessonRecord>> getLessonsForDate(DateTime date);
  Future<int> countGroups();
  Future<int> countStudents();
  Future<int> countLessonsInRange(
    DateTime startInclusive,
    DateTime endExclusive,
  );
}
