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
    int? lessonGroupId,
    String? start = '09:00',
    String? end = '10:00',
    bool isCanceled = false,
  }) => LessonRecord(
    id: id,
    groupId: lessonGroupId ?? groupId,
    groupName: 'Physics',
    groupGrade: '10',
    scheduledDate: date ?? DateTime(2026, 4, 1).millisecondsSinceEpoch,
    startTime: start,
    endTime: end,
    isManual: true,
    isCanceled: isCanceled,
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
        schedules.createSchedule(schedule()),
        throwsA(isA<ScheduleConflictException>()),
      );
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

  test(
    '30-day generation creates local Monday and Wednesday occurrences and is idempotent',
    () async {
      await schedules.createSchedule(
        schedule(weekday: DateTime.monday, start: '16:00', end: '17:00'),
      );
      await schedules.createSchedule(
        schedule(weekday: DateTime.wednesday, start: '16:30', end: '17:30'),
      );
      await schedules.createSchedule(
        schedule(weekday: DateTime.friday, active: false),
      );
      final now = DateTime(2026, 3, 1, 13, 45);

      final generated = await lessons.generateUpcomingLessons(now);
      final rows = await lessons.getLessons(groupId: groupId);
      final mondayDates = [
        for (var day = 1; day < 31; day++)
          if (DateTime(2026, 3, day).weekday == DateTime.monday)
            DateTime(2026, 3, day),
      ];
      final wednesdayDates = [
        for (var day = 1; day < 31; day++)
          if (DateTime(2026, 3, day).weekday == DateTime.wednesday)
            DateTime(2026, 3, day),
      ];

      expect(generated, mondayDates.length + wednesdayDates.length);
      expect(rows, hasLength(generated));
      expect(rows.every((row) => row.isManual == false), isTrue);
      expect(
        rows
            .map(
              (row) => DateTime.fromMillisecondsSinceEpoch(
                row.scheduledDate,
              ).weekday,
            )
            .toSet(),
        {DateTime.monday, DateTime.wednesday},
      );
      expect(
        rows.where((row) => row.startTime == '16:00'),
        hasLength(mondayDates.length),
      );
      expect(
        rows.where((row) => row.startTime == '16:30'),
        hasLength(wednesdayDates.length),
      );
      expect(
        rows.every(
          (row) =>
              DateTime.fromMillisecondsSinceEpoch(row.scheduledDate).hour == 0,
        ),
        isTrue,
      );
      expect(await lessons.generateUpcomingLessons(now), 0);
      expect(await lessons.getLessons(groupId: groupId), hasLength(generated));
    },
  );

  test(
    'generation preserves existing manual and canceled generated lesson rows',
    () async {
      final monday = DateTime(2026, 3, 2).millisecondsSinceEpoch;
      final nextMonday = DateTime(2026, 3, 9).millisecondsSinceEpoch;
      await schedules.createSchedule(schedule(weekday: DateTime.monday));
      await database.db.insert('lessons', {
        'group_id': groupId,
        'scheduled_date': monday,
        'start_time': '09:00',
        'end_time': '10:00',
        'is_manual': 1,
        'is_canceled': 1,
        'cancellation_reason': 'One-off canceled lesson',
      });
      final canceledGeneratedId = await database.db.insert('lessons', {
        'group_id': groupId,
        'scheduled_date': nextMonday,
        'start_time': '09:00',
        'end_time': '10:00',
        'is_manual': 0,
        'is_canceled': 1,
        'cancellation_reason': 'Preserve canceled generated lesson',
      });
      final studentId = await addStudent('Attendance history');
      await database.db.insert('attendance_records', {
        'lesson_id': canceledGeneratedId,
        'student_id': studentId,
        'status': 'present',
        'recorded_at': DateTime(2026, 3, 9).millisecondsSinceEpoch,
      });

      await lessons.generateUpcomingLessons(DateTime(2026, 3, 1));
      final manual = await database.db.query(
        'lessons',
        where: 'scheduled_date = ?',
        whereArgs: [monday],
      );
      final generated = await database.db.query(
        'lessons',
        where: 'scheduled_date = ?',
        whereArgs: [nextMonday],
      );
      expect(manual, hasLength(1));
      expect(manual.single['is_manual'], 1);
      expect(manual.single['cancellation_reason'], 'One-off canceled lesson');
      expect(generated, hasLength(1));
      expect(generated.single['is_canceled'], 1);
      expect(
        generated.single['cancellation_reason'],
        'Preserve canceled generated lesson',
      );
      expect(
        await database.db.query(
          'attendance_records',
          where: 'lesson_id = ?',
          whereArgs: [canceledGeneratedId],
        ),
        hasLength(1),
      );
    },
  );

  test(
    'schedule edits add new occurrences without rewriting or deleting old ones',
    () async {
      final scheduleId = await schedules.createSchedule(
        schedule(weekday: DateTime.monday, start: '09:00', end: '10:00'),
      );
      final now = DateTime(2026, 3, 1);
      final mondayCount = await lessons.generateUpcomingLessons(now);
      final mondayRowsBefore = await database.db.query(
        'lessons',
        where: 'group_id = ? AND start_time = ?',
        whereArgs: [groupId, '09:00'],
      );

      await schedules.updateSchedule(
        schedule(
          id: scheduleId,
          weekday: DateTime.wednesday,
          start: '11:00',
          end: '12:00',
        ),
      );
      final newOccurrences = await lessons.generateUpcomingLessons(now);
      expect(newOccurrences, greaterThan(0));
      final mondayRowsAfter = await database.db.query(
        'lessons',
        where: 'group_id = ? AND start_time = ?',
        whereArgs: [groupId, '09:00'],
      );
      expect(mondayRowsAfter, hasLength(mondayRowsBefore.length));
      expect(await lessons.generateUpcomingLessons(now), 0);

      await schedules.updateSchedule(
        schedule(
          id: scheduleId,
          weekday: DateTime.wednesday,
          start: '11:00',
          end: '12:00',
          active: false,
        ),
      );
      expect(await lessons.generateUpcomingLessons(now), 0);
      expect(
        await database.db.query('lessons'),
        hasLength(mondayCount + newOccurrences),
      );
    },
  );

  test(
    'schedule deactivation and removal preserve historical lesson and attendance',
    () async {
      final studentId = await addStudent('Historical student');
      final pastLesson = await lessons.createLesson(
        lesson(date: DateTime(2025, 1, 6).millisecondsSinceEpoch),
      );
      await database.db.insert('attendance_records', {
        'lesson_id': pastLesson,
        'student_id': studentId,
        'status': 'present',
        'recorded_at': DateTime(2025, 1, 6).millisecondsSinceEpoch,
      });
      final scheduleId = await schedules.createSchedule(schedule());
      final beforeLesson = await lessons.getLesson(pastLesson);
      await lessons.generateUpcomingLessons(DateTime(2026, 3, 1));
      await schedules.updateSchedule(schedule(id: scheduleId, active: false));
      await schedules.removeSchedule(scheduleId);
      final afterLesson = await lessons.getLesson(pastLesson);
      final attendanceRows = await database.db.query(
        'attendance_records',
        where: 'lesson_id = ?',
        whereArgs: [pastLesson],
      );
      expect(afterLesson.scheduledDate, beforeLesson.scheduledDate);
      expect(afterLesson.isCanceled, beforeLesson.isCanceled);
      expect(attendanceRows, hasLength(1));
      expect(attendanceRows.single['status'], 'present');
    },
  );

  test(
    'upcoming query orders nearest first and excludes canceled or untimed lessons',
    () async {
      final passedToday = await lessons.createLesson(
        lesson(
          date: DateTime(2026, 3, 1).millisecondsSinceEpoch,
          start: '17:00',
          end: '18:00',
        ),
      );
      final laterToday = await lessons.createLesson(
        lesson(
          date: DateTime(2026, 3, 1).millisecondsSinceEpoch,
          start: '19:00',
          end: '20:00',
        ),
      );
      final later = await lessons.createLesson(
        lesson(
          date: DateTime(2026, 3, 8).millisecondsSinceEpoch,
          start: '11:00',
          end: '12:00',
        ),
      );
      final nearest = await lessons.createLesson(
        lesson(
          date: DateTime(2026, 3, 3).millisecondsSinceEpoch,
          start: '09:00',
          isCanceled: true,
        ),
      );
      final missingTime = await lessons.createLesson(
        lesson(date: DateTime(2026, 3, 4).millisecondsSinceEpoch, start: null),
      );
      final missingEndTime = await lessons.createLesson(
        lesson(date: DateTime(2026, 3, 5).millisecondsSinceEpoch, end: null),
      );
      final invalidTime = await lessons.createLesson(
        lesson(
          date: DateTime(2026, 3, 6).millisecondsSinceEpoch,
          start: '28:00',
          end: '29:00',
        ),
      );
      await lessons.createLesson(
        lesson(date: DateTime(2026, 2, 28).millisecondsSinceEpoch),
      );
      final result = await lessons.getUpcomingLessons(
        groupId: groupId,
        from: DateTime(2026, 3, 1, 18),
      );
      expect(result.map((item) => item.id).toList(), [laterToday, later]);
      expect(result.first.id, isNot(passedToday));
      expect(result.map((item) => item.id), isNot(contains(nearest)));
      expect(result.map((item) => item.id), isNot(contains(missingTime)));
      expect(result.map((item) => item.id), isNot(contains(missingEndTime)));
      expect(result.map((item) => item.id), isNot(contains(invalidTime)));
      expect(result.every((item) => !item.isCanceled), isTrue);
    },
  );

  test(
    'global upcoming lessons combine groups and sort by local date and start time',
    () async {
      final secondGroupId = await database.db.insert('groups', {
        'name': 'Chemistry',
        'target_grade': 'Third Preparatory',
        'created_at': 1,
        'updated_at': 1,
      });
      final firstDate = DateTime(2026, 3, 2).millisecondsSinceEpoch;
      final secondDate = DateTime(2026, 3, 3).millisecondsSinceEpoch;
      final physicsLate = await lessons.createLesson(
        lesson(date: firstDate, start: '16:00', end: '17:00'),
      );
      final chemistry = await lessons.createLesson(
        lesson(
          lessonGroupId: secondGroupId,
          date: secondDate,
          start: '15:00',
          end: '16:00',
        ),
      );
      final physicsEarly = await lessons.createLesson(
        lesson(date: firstDate, start: '15:00', end: '16:00'),
      );

      final allGroups = await lessons.getUpcomingLessons(
        from: DateTime(2026, 3, 1, 8),
      );
      expect(allGroups.map((item) => item.id).toList(), [
        physicsEarly,
        physicsLate,
        chemistry,
      ]);
      expect(allGroups.first.groupName, 'Physics');
      expect(allGroups.first.groupGrade, '10');
      expect(allGroups.last.groupName, 'Chemistry');
      expect(allGroups.last.groupGrade, 'Third Preparatory');

      final oneGroup = await lessons.getUpcomingLessons(
        groupId: secondGroupId,
        from: DateTime(2026, 3, 1, 8),
      );
      expect(oneGroup.map((item) => item.id), [chemistry]);
    },
  );

  test(
    'lesson Cubit loads generated upcoming lessons across every group',
    () async {
      final lessonId = await lessons.createLesson(
        lesson(date: DateTime(2026, 3, 2).millisecondsSinceEpoch),
      );
      final cubit = LessonCubit(lessons, clock: () => DateTime(2026, 3, 1, 8));
      await cubit.loadUpcomingLessons();
      expect(cubit.state, isA<LessonListLoaded>());
      expect((cubit.state as LessonListLoaded).lessons.map((item) => item.id), [
        lessonId,
      ]);
      await cubit.close();
    },
  );

  test('exceptional lesson creation does not alter weekly schedules', () async {
    await schedules.createSchedule(schedule(weekday: DateTime.monday));
    final scheduleRowsBefore = await schedules.getSchedules(groupId);
    final exceptional = lesson(
      date: DateTime(2026, 3, 5).millisecondsSinceEpoch,
    );
    await lessons.createLesson(exceptional);
    final saved = (await lessons.getLessons()).single;
    expect(saved.isManual, isTrue);
    final scheduleRowsAfter = await schedules.getSchedules(groupId);
    expect(scheduleRowsAfter, hasLength(scheduleRowsBefore.length));
    expect(scheduleRowsAfter.single.groupId, scheduleRowsBefore.single.groupId);
    expect(scheduleRowsAfter.single.weekday, scheduleRowsBefore.single.weekday);
    expect(
      scheduleRowsAfter.single.startTime,
      scheduleRowsBefore.single.startTime,
    );
    expect(scheduleRowsAfter.single.endTime, scheduleRowsBefore.single.endTime);
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
