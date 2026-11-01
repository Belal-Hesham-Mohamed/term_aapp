import 'package:term/features/home/domain/repositories/home_repository.dart';
import 'package:term/features/lessons/domain/entities/lesson_record.dart';

class EmptyHomeRepository implements HomeRepository {
  const EmptyHomeRepository();

  @override
  Future<int> countGroups() async => 0;

  @override
  Future<int> countLessonsInRange(
    DateTime startInclusive,
    DateTime endExclusive,
  ) async => 0;

  @override
  Future<int> countStudents() async => 0;

  @override
  Future<List<LessonRecord>> getLessonsForDate(DateTime date) async => [];

  @override
  Future<String?> getTeacherName() async => null;
}
