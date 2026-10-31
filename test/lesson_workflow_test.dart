import 'package:flutter_test/flutter_test.dart';
import 'package:term/core/database/database_helper.dart';
import 'package:term/features/attendance/data/datasources/attendance_local_datasource.dart';
import 'package:term/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:term/features/lessons/data/datasources/lesson_local_datasource.dart';
import 'package:term/features/lessons/data/repositories/lesson_repository_impl.dart';
import 'package:term/features/lessons/domain/entities/lesson_record.dart';
import 'package:term/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:term/features/lessons/presentation/cubit/lesson_cubit.dart';
import 'package:term/features/lessons/presentation/state/lesson_state.dart';
import 'package:term/features/schedules/data/datasources/schedule_local_datasource.dart';
import 'package:term/features/schedules/data/repositories/schedule_repository_impl.dart';
import 'package:term/features/schedules/domain/entities/group_schedule.dart';
import 'package:term/features/schedules/domain/repositories/schedule_repository.dart';

void main() {
  late DatabaseHelper database;
  late ScheduleRepository schedules;
  late LessonRepository lessons;
  late AttendanceRepositoryImpl attendance;
  late int groupId;

  setUp(() async {
    database = DatabaseHelper();
    await database.initInMemory();
    schedules = ScheduleRepositoryImpl(ScheduleLocalDataSource(database));
    lessons = LessonRepositoryImpl(LessonLocalDataSource(database));
    attendance = AttendanceRepositoryImpl(AttendanceLocalDataSource(database));
    final now = DateTime.now().millisecondsSinceEpoch;
    groupId = await database.db.insert('groups', {
      'name': 'Physics',
      'target_grade': '10',
      'created_at': now,
      'updated_at': now,
    });
  });

  tearDown(() async => database.db.close());

  GroupSchedule schedule({
    int id = 0,
    int weekday = 1,
    String start = '09:00',
    String end = '10:00',
    bool active = true,
  }) => GroupSchedule(
    id: id,
    groupId: groupId,
    weekday: weekday,
    startTime: start,
    endTime: end,
    active: active,
  );

  LessonRecord lesson({
    int id = 0,
    int? date,
    String start = '09:00',
    String end = '10:00',
  }) => LessonRecord(
    id: id,
    groupId: groupId,
    groupName: 'Physics',
    scheduledDate: date ?? DateTime(2026, 4, 1).millisecondsSinceEpoch,
    startTime: start,
    endTime: end,
    isManual: true,
    isCanceled: false,
    cancellationReason: null,
  );

  Future<int> addStudent(String name) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await database.db.insert('students', {
      'name': name,
      'grade': '10',
      'created_at': now,
      'updated_at': now,
    });
    await database.db.insert('group_students', {
      'group_id': groupId,
      'student_id': id,
      'enrolled_at': now,
    });
    return id;
  }

  test(
    'schedules create, update, conflict-check, and remove without changing lesson history',
    () async {
      final scheduleId = await schedules.createSchedule(schedule());
      final lessonId = await lessons.createLesson(lesson());
      await expectLater(
        schedules.createSchedule(schedule(start: '09:30', end: '10:30')),
        throwsA(isA<ScheduleConflictException>()),
      );
      await expectLater(
        schedules.createSchedule(schedule(start: '11:00', end: '10:30')),
        throwsA(isA<ArgumentError>()),
      );
      await schedules.updateSchedule(
        schedule(id: scheduleId, weekday: 2, start: '11:00', end: '12:00'),
      );
      expect((await schedules.getSchedules(groupId)).single.weekday, 2);
      expect(await schedules.removeSchedule(scheduleId), isTrue);
      expect(
        (await lessons.getLesson(lessonId)).scheduledDate,
        lesson().scheduledDate,
      );
    },
  );

  test('inactive schedules may overlap and can be edited or removed', () async {
    await schedules.createSchedule(schedule());
    final id = await schedules.createSchedule(
      schedule(start: '09:15', end: '09:45', active: false),
    );
    expect(await schedules.getSchedules(groupId), hasLength(2));
    await schedules.updateSchedule(
      schedule(id: id, start: '09:15', end: '09:45', active: false),
    );
    expect(await schedules.removeSchedule(id), isTrue);
  });

  test(
    'lessons create, list, edit, preserve manual status, and reject duplicates',
    () async {
      final id = await lessons.createLesson(lesson());
      await expectLater(
        lessons.createLesson(lesson()),
        throwsA(isA<DuplicateLessonException>()),
      );
      final editedDate = DateTime(2026, 4, 2).millisecondsSinceEpoch;
      await lessons.updateLesson(
        LessonRecord(
          id: id,
          groupId: groupId,
          groupName: 'Physics',
          scheduledDate: editedDate,
          startTime: '10:00',
          endTime: '11:00',
          isManual: true,
          isCanceled: true,
          cancellationReason: 'Teacher unavailable',
        ),
      );
      final result = await lessons.getLesson(id);
      expect(result.scheduledDate, editedDate);
      expect(result.startTime, '10:00');
      expect(result.isManual, isTrue);
      expect(result.isCanceled, isTrue);
      expect(result.cancellationReason, 'Teacher unavailable');
      expect((await lessons.getLessons(groupId: groupId)).single.id, id);
      expect(await lessons.getLessons(), hasLength(1));
    },
  );

  test(
    'attendance creates and edits without duplicate rows and retains removed-student history',
    () async {
      final studentId = await addStudent('Nour');
      final lessonId = await lessons.createLesson(lesson());
      var roster = await attendance.getLessonRoster(lessonId);
      expect(roster, hasLength(1));
      expect(roster.single.status, isNull);
      await attendance.saveAttendance(lessonId, {studentId: 'present'});
      await attendance.saveAttendance(lessonId, {studentId: 'absent'});
      expect((await database.db.query('attendance_records')).length, 1);
      await database.db.update(
        'students',
        {'archived_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [studentId],
      );
      await database.db.delete(
        'group_students',
        where: 'group_id = ? AND student_id = ?',
        whereArgs: [groupId, studentId],
      );
      roster = await attendance.getLessonRoster(lessonId);
      expect(roster, hasLength(1));
      expect(roster.single.student.name, 'Nour');
      expect(roster.single.status, 'absent');
    },
  );

  test('lesson cubit rejects an end time before its start', () async {
    final cubit = LessonCubit(lessons);
    final saved = await cubit.saveLesson(
      groupId: groupId,
      scheduledDate: DateTime(2026, 4, 1),
      startTime: '10:00',
      endTime: '09:00',
      isCanceled: false,
    );
    expect(saved, isFalse);
    expect(cubit.state, isA<LessonFailure>());
    expect(await database.db.query('lessons'), isEmpty);
    await cubit.close();
  });

  test('attendance transaction rolls back if a status is invalid', () async {
    final studentId = await addStudent('Rami');
    final lessonId = await lessons.createLesson(lesson());
    await expectLater(
      attendance.saveAttendance(lessonId, {
        studentId: 'present',
        studentId + 100: 'late',
      }),
      throwsArgumentError,
    );
    expect(await database.db.query('attendance_records'), isEmpty);
  });
}
