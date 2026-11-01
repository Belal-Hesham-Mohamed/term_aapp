import 'package:flutter_test/flutter_test.dart';
import 'package:term/core/database/database_helper.dart';
import 'package:term/features/groups/data/datasources/group_local_datasource.dart';
import 'package:term/features/groups/data/repositories/group_repository_impl.dart';
import 'package:term/features/home/data/datasources/home_local_datasource.dart';
import 'package:term/features/home/data/repositories/home_repository_impl.dart';
import 'package:term/features/home/domain/entities/home_date_rules.dart';
import 'package:term/features/home/domain/repositories/home_repository.dart';
import 'package:term/features/home/presentation/cubit/home_cubit.dart';
import 'package:term/features/home/presentation/state/home_state.dart';
import 'package:term/features/lessons/data/datasources/lesson_local_datasource.dart';
import 'package:term/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:term/features/lessons/domain/entities/lesson_record.dart';
import 'package:term/features/students/data/datasources/student_local_datasource.dart';
import 'package:term/features/students/data/repositories/student_repository_impl.dart';

void main() {
  late DatabaseHelper database;

  setUp(() async {
    database = DatabaseHelper();
    await database.initInMemory();
  });

  tearDown(() async => database.db.close());

  HomeRepository buildRepository() => HomeRepositoryImpl(
    dataSource: HomeLocalDataSource(database),
    groups: GroupRepositoryImpl(GroupLocalDataSource(database)),
    students: StudentRepositoryImpl(StudentLocalDataSource(database)),
    lessons: LessonRepositoryImpl(LessonLocalDataSource(database)),
  );

  Future<int> addGroup(String name, DateTime now) =>
      database.db.insert('groups', {
        'name': name,
        'target_grade': 'primary_1',
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });

  test(
    'home summary returns sorted non-canceled lessons, unique counts, and Saturday week totals without writes',
    () async {
      final now = DateTime(2026, 3, 4, 8, 0); // Wednesday
      final firstGroup = await addGroup('Morning', now);
      final secondGroup = await addGroup('Evening', now);
      final studentA = await database.db.insert('students', {
        'name': 'Student A',
        'grade': 'primary_1',
        'created_at': 1,
        'updated_at': 1,
      });
      final studentB = await database.db.insert('students', {
        'name': 'Student B',
        'grade': 'primary_2',
        'created_at': 1,
        'updated_at': 1,
      });
      await database.db.insert('group_students', {
        'group_id': firstGroup,
        'student_id': studentA,
        'enrolled_at': 1,
      });
      await database.db.insert('group_students', {
        'group_id': secondGroup,
        'student_id': studentA,
        'enrolled_at': 1,
      });
      await database.db.insert('group_students', {
        'group_id': secondGroup,
        'student_id': studentB,
        'enrolled_at': 1,
      });
      await database.db.insert('app_settings', {
        'key': HomeLocalDataSource.teacherNameKey,
        'value': '  Sara  ',
      });

      final beforeSaturday = DateTime(2026, 2, 27);
      final saturday = DateTime(2026, 2, 28);
      final today = DateTime(2026, 3, 4);
      final friday = DateTime(2026, 3, 6);
      final nextSaturday = DateTime(2026, 3, 7);
      Future<void> lesson(
        int groupId,
        DateTime date,
        String time, {
        bool canceled = false,
      }) async {
        await database.db.insert('lessons', {
          'group_id': groupId,
          'scheduled_date': date.millisecondsSinceEpoch,
          'start_time': time,
          'end_time': '23:00',
          'is_manual': 1,
          'is_canceled': canceled ? 1 : 0,
        });
      }

      await lesson(firstGroup, DateTime(2026, 3, 4, 16), '11:00');
      await lesson(secondGroup, today, '09:00');
      await lesson(secondGroup, today, '08:00', canceled: true);
      await lesson(firstGroup, saturday, '10:00');
      await lesson(firstGroup, friday, '10:00');
      await lesson(firstGroup, nextSaturday, '10:00');
      await lesson(firstGroup, beforeSaturday, '10:00');
      await database.db.insert('group_schedules', {
        'group_id': firstGroup,
        'weekday': 4,
        'start_time': '15:00',
        'end_time': '16:00',
        'active': 1,
      });
      final persistedLessons = await database.db.query(
        'lessons',
        orderBy: 'id',
      );

      final cubit = HomeCubit(buildRepository(), clock: () => now);
      await cubit.loadSummary();
      final state = cubit.state as HomeLoaded;
      expect(state.summary.teacherName, 'Sara');
      expect(state.summary.totalGroups, 2);
      expect(state.summary.totalStudents, 2);
      expect(state.summary.lessonsThisWeek, 4);
      expect(state.summary.todaysLessons.map((item) => item.startTime), [
        '09:00',
        '11:00',
      ]);
      expect(state.summary.todaysLessons.map((item) => item.groupName), [
        'Evening',
        'Morning',
      ]);
      expect(
        state.summary.todaysLessons.map((item) => item.id).toSet().length,
        2,
      );
      expect(
        await database.db.query('lessons', orderBy: 'id'),
        persistedLessons,
      );
      await cubit.close();
    },
  );

  test(
    'empty database and missing teacher name load as an empty summary',
    () async {
      final cubit = HomeCubit(
        buildRepository(),
        clock: () => DateTime(2026, 3, 4),
      );
      await cubit.loadSummary();
      final state = cubit.state as HomeLoaded;
      expect(state.summary.teacherName, isNull);
      expect(state.summary.todaysLessons, isEmpty);
      expect(state.summary.totalGroups, 0);
      expect(state.summary.totalStudents, 0);
      expect(state.summary.lessonsThisWeek, 0);
      await cubit.close();
    },
  );

  test(
    'Saturday through Friday week boundaries are local and end-exclusive',
    () {
      expect(
        HomeDateRules.weekStart(DateTime(2026, 3, 4, 22)),
        DateTime(2026, 2, 28),
      );
      expect(
        HomeDateRules.weekEndExclusive(DateTime(2026, 3, 4)),
        DateTime(2026, 3, 7),
      );
    },
  );

  test('repository failure produces a home error state', () async {
    final cubit = HomeCubit(_FailingHomeRepository());
    await cubit.loadSummary();
    expect(cubit.state, isA<HomeFailure>());
    await cubit.close();
  });
}

class _FailingHomeRepository implements HomeRepository {
  @override
  Future<int> countGroups() async => throw StateError('group count failed');
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
