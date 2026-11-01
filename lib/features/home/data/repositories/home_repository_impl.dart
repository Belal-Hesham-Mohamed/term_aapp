import '../../../groups/domain/repositories/group_repository.dart';
import '../../../lessons/domain/entities/lesson_record.dart';
import '../../../lessons/domain/repositories/lesson_repository.dart';
import '../../../students/domain/repositories/student_repository.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource dataSource;
  final GroupRepository groups;
  final StudentRepository students;
  final LessonRepository lessons;

  HomeRepositoryImpl({
    required this.dataSource,
    required this.groups,
    required this.students,
    required this.lessons,
  });

  @override
  Future<String?> getTeacherName() => dataSource.getTeacherName();

  @override
  Future<List<LessonRecord>> getLessonsForDate(DateTime date) =>
      lessons.getLessonsForDate(date);

  @override
  Future<int> countGroups() => groups.countGroups();

  @override
  Future<int> countStudents() => students.countStudents();

  @override
  Future<int> countLessonsInRange(
    DateTime startInclusive,
    DateTime endExclusive,
  ) => lessons.countLessonsInRange(startInclusive, endExclusive);
}
