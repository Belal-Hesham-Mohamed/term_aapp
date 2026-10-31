import '../../domain/entities/lesson_record.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_local_datasource.dart';

class LessonRepositoryImpl implements LessonRepository {
  final LessonLocalDataSource dataSource;
  LessonRepositoryImpl(this.dataSource);

  @override
  Future<List<LessonRecord>> getLessons({int? groupId}) =>
      dataSource.getLessons(groupId: groupId);
  @override
  Future<LessonRecord> getLesson(int lessonId) =>
      dataSource.getLesson(lessonId);
  @override
  Future<int> createLesson(LessonRecord lesson) =>
      dataSource.createLesson(lesson);
  @override
  Future<void> updateLesson(LessonRecord lesson) =>
      dataSource.updateLesson(lesson);
}
