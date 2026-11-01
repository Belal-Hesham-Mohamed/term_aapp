import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:term/core/di/injection.dart';
import 'package:term/core/navigation/main_navigation.dart';
import 'package:term/features/attendance/domain/entities/attendance_entry.dart';
import 'package:term/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:term/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:term/features/groups/domain/entities/study_group.dart';
import 'package:term/features/groups/domain/repositories/group_repository.dart';
import 'package:term/features/groups/presentation/cubit/group_cubit.dart';
import 'package:term/features/lessons/domain/entities/lesson_record.dart';
import 'package:term/features/lessons/domain/repositories/lesson_repository.dart';
import 'package:term/features/lessons/presentation/cubit/lesson_cubit.dart';
import 'package:term/features/lessons/presentation/pages/lessons_page.dart';
import 'package:term/features/schedules/domain/entities/group_schedule.dart';
import 'package:term/features/schedules/domain/repositories/schedule_repository.dart';
import 'package:term/features/schedules/presentation/cubit/schedule_cubit.dart';
import 'package:term/features/students/domain/entities/student.dart';
import 'package:term/l10n/app_localizations.dart';

void main() {
  final locator = getIt;
  final lessonDate = DateTime(2026, 3, 2);
  final group = StudyGroup(
    id: 7,
    name: 'Physics',
    targetGrade: '10',
    notes: null,
    createdAt: 1,
    updatedAt: 1,
  );
  final lesson = LessonRecord(
    id: 11,
    groupId: group.id,
    groupName: group.name,
    groupGrade: group.targetGrade,
    scheduledDate: lessonDate.millisecondsSinceEpoch,
    startTime: '09:00',
    endTime: '10:00',
    isManual: true,
    isCanceled: false,
    cancellationReason: null,
  );

  tearDown(() async => locator.reset());

  testWidgets('group details navigate through lessons to attendance', (
    tester,
  ) async {
    locator.registerFactory<GroupCubit>(() => GroupCubit(_Groups(group)));
    locator.registerFactory<ScheduleCubit>(() => ScheduleCubit(_Schedules()));
    locator.registerFactory<LessonCubit>(() => LessonCubit(_Lessons(lesson)));
    locator.registerFactory<AttendanceCubit>(
      () => AttendanceCubit(_Attendance()),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainNavigation(),
      ),
    );
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Physics').first);
    await tester.pumpAndSettle();
    expect(find.text('Weekly Schedule'), findsOneWidget);
    expect(find.text('Upcoming Lessons'), findsOneWidget);
    await tester.tap(find.textContaining('09:00').first);
    await tester.pumpAndSettle();
    expect(find.text('Lesson details'), findsOneWidget);
    await tester.tap(find.text('Take attendance'));
    await tester.pumpAndSettle();
    expect(find.text('Attendance'), findsOneWidget);
    expect(
      find.text('No students are enrolled for this lesson.'),
      findsOneWidget,
    );
  });

  testWidgets('main Lessons page shows the localized empty upcoming state', (
    tester,
  ) async {
    locator.registerFactory<LessonCubit>(
      () => LessonCubit(
        _Lessons(lesson, upcomingLessons: const []),
        clock: () => DateTime(2026, 3, 1, 8),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LessonsPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('No upcoming lessons in the next 30 days.'),
      findsOneWidget,
    );
  });

  testWidgets('main Lessons page displays group, grade, weekday, and times', (
    tester,
  ) async {
    locator.registerFactory<LessonCubit>(
      () => LessonCubit(_Lessons(lesson), clock: () => DateTime(2026, 3, 1, 8)),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LessonsPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Grade: 10'), findsOneWidget);
    expect(find.textContaining('Lesson time: 09:00–10:00'), findsOneWidget);
  });
}

class _Groups implements GroupRepository {
  final StudyGroup group;
  _Groups(this.group);
  @override
  Future<List<StudyGroup>> getGroups() async => [group];
  @override
  Future<List<StudyGroup>> searchGroups(String query) async => [group];
  @override
  Future<StudyGroup> getGroup(int groupId) async => group;
  @override
  Future<List<Student>> getEnrolledStudents(int groupId) async => [];
  @override
  Future<List<Student>> getAvailableStudents(int groupId) async => [];
  @override
  Future<int> createGroup(StudyGroup group) async => 1;
  @override
  Future<void> updateGroup(StudyGroup group) async {}
  @override
  Future<void> addStudents(int groupId, List<int> studentIds) async {}
  @override
  Future<bool> removeStudent(int groupId, int studentId) async => true;
  @override
  Future<int> deleteGroup(int groupId) async => 1;
}

class _Schedules implements ScheduleRepository {
  @override
  Future<List<GroupSchedule>> getSchedules(int groupId) async => [];
  @override
  Future<int> createSchedule(GroupSchedule schedule) async => 1;
  @override
  Future<void> updateSchedule(GroupSchedule schedule) async {}
  @override
  Future<bool> removeSchedule(int scheduleId) async => true;
}

class _Lessons implements LessonRepository {
  final LessonRecord lesson;
  final List<LessonRecord>? upcomingLessons;
  _Lessons(this.lesson, {this.upcomingLessons});
  @override
  Future<List<LessonRecord>> getLessons({int? groupId}) async =>
      upcomingLessons ?? [lesson];
  @override
  Future<List<LessonRecord>> getUpcomingLessons({
    int? groupId,
    required DateTime from,
  }) async => upcomingLessons ?? [lesson];
  @override
  Future<int> generateUpcomingLessons(DateTime now) async => 0;
  @override
  Future<LessonRecord> getLesson(int lessonId) async => lesson;
  @override
  Future<int> createLesson(LessonRecord lesson) async => 1;
  @override
  Future<void> updateLesson(LessonRecord lesson) async {}
}

class _Attendance implements AttendanceRepository {
  @override
  Future<List<AttendanceEntry>> getLessonRoster(int lessonId) async => [];
  @override
  Future<void> saveAttendance(int lessonId, Map<int, String> statuses) async {}
}
