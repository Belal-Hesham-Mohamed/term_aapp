import '../entities/lesson_record.dart';

abstract class LessonRepository {
  Future<List<LessonRecord>> getLessons({int? groupId});
  Future<LessonRecord> getLesson(int lessonId);
  Future<int> createLesson(LessonRecord lesson);
  Future<void> updateLesson(LessonRecord lesson);
}

class DuplicateLessonException implements Exception {}
