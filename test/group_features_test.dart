import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:term/core/database/database_helper.dart';
import 'package:term/core/di/injection.dart';
import 'package:term/features/groups/data/datasources/group_local_datasource.dart';
import 'package:term/features/groups/data/repositories/group_repository_impl.dart';
import 'package:term/features/groups/domain/entities/study_group.dart';
import 'package:term/features/groups/domain/repositories/group_repository.dart';
import 'package:term/features/groups/presentation/cubit/group_cubit.dart';
import 'package:term/features/groups/presentation/state/group_state.dart';
import 'package:term/features/schedules/presentation/cubit/schedule_cubit.dart';
import 'package:term/features/lessons/presentation/cubit/lesson_cubit.dart';
import 'package:term/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:term/features/students/domain/entities/student.dart';

void main() {
  late DatabaseHelper database;
  late GroupRepository repository;

  setUp(() async {
    database = DatabaseHelper();
    await database.initInMemory();
    repository = GroupRepositoryImpl(GroupLocalDataSource(database));
  });

  tearDown(() async => database.db.close());

  Future<int> addGroup(String name, {String grade = 'Grade 7', String? notes}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return repository.createGroup(
      StudyGroup(
        id: 0,
        name: name,
        targetGrade: grade,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> addStudent(
    String name, {
    String grade = '7',
    bool archived = false,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return database.db.insert('students', {
      'name': name,
      'grade': grade,
      'created_at': now,
      'updated_at': now,
      'archived_at': archived ? now : null,
    });
  }

  test('creates and retrieves group including empty groups', () async {
    final id = await addGroup('Morning', notes: 'Before school');
    final groups = await repository.getGroups();
    expect(groups, hasLength(1));
    expect(groups.single.id, id);
    expect(groups.single.notes, 'Before school');
    expect(groups.single.activeStudentCount, 0);
  });

  test('rejects empty required values and duplicate names', () async {
    final cubit = GroupCubit(repository);
    expect(await cubit.saveGroup(name: ' ', targetGrade: '7'), isFalse);
    expect(await cubit.saveGroup(name: 'Morning', targetGrade: ' '), isFalse);
    await addGroup('Morning');
    expect(await cubit.saveGroup(name: 'Morning', targetGrade: '8'), isFalse);
    expect(cubit.lastSaveWasDuplicate, isTrue);
    await cubit.close();
  });

  test(
    'database also rejects duplicate names and duplicate membership safely',
    () async {
      final group = await addGroup('Unique');
      await expectLater(
        addGroup('Unique'),
        throwsA(isA<DuplicateGroupNameException>()),
      );
      final student = await addStudent('Student');
      await repository.addStudents(group, [student]);
      await repository.addStudents(group, [student]);
      expect(await repository.getEnrolledStudents(group), hasLength(1));
    },
  );

  test(
    'updates metadata, clears notes, and preserves creation timestamp',
    () async {
      final id = await addGroup('Morning', notes: 'Keep');
      final created = (await repository.getGroup(id)).createdAt;
      await repository.updateGroup(
        StudyGroup(
          id: id,
          name: 'Morning 2',
          targetGrade: '8',
          notes: ' ',
          createdAt: created,
          updatedAt: created,
        ),
      );
      final updated = await repository.getGroup(id);
      expect(updated.name, 'Morning 2');
      expect(updated.targetGrade, '8');
      expect(updated.notes, isNull);
      expect(updated.createdAt, created);
      expect(updated.updatedAt, greaterThanOrEqualTo(created));
    },
  );

  test(
    'supports multiple memberships and removing only one relationship',
    () async {
      final firstGroup = await addGroup('First');
      final secondGroup = await addGroup('Second');
      final student = await addStudent('Laila');
      await repository.addStudents(firstGroup, [student]);
      await repository.addStudents(secondGroup, [student]);
      expect((await repository.getEnrolledStudents(firstGroup)), hasLength(1));
      expect((await repository.getEnrolledStudents(secondGroup)), hasLength(1));
      expect(await repository.removeStudent(firstGroup, student), isTrue);
      expect(await repository.removeStudent(firstGroup, student), isFalse);
      expect(await repository.getEnrolledStudents(firstGroup), isEmpty);
      expect((await repository.getEnrolledStudents(secondGroup)), hasLength(1));
      expect(
        await database.db.query(
          'students',
          where: 'id = ?',
          whereArgs: [student],
        ),
        hasLength(1),
      );
    },
  );

  test(
    'adds multiple students, ignores duplicate IDs, excludes archived students, counts active roster',
    () async {
      final group = await addGroup('Mixed');
      final activeA = await addStudent('A');
      final activeB = await addStudent('B');
      final archived = await addStudent('C', archived: true);
      expect(await repository.getAvailableStudents(group), hasLength(2));
      await repository.addStudents(group, [
        activeA,
        activeB,
        activeA,
        archived,
      ]);
      expect(await repository.getEnrolledStudents(group), hasLength(2));
      expect((await repository.getGroup(group)).activeStudentCount, 2);
      expect(await repository.getAvailableStudents(group), isEmpty);
    },
  );

  test(
    'searches by group name and target grade; clearing restores all groups',
    () async {
      await addGroup('Morning', grade: 'Grade 9');
      await addGroup('Evening', grade: 'Grade 10');
      expect((await repository.searchGroups('Morn')).single.name, 'Morning');
      expect((await repository.searchGroups('10')).single.name, 'Evening');
      expect(await repository.searchGroups(''), hasLength(2));
    },
  );

  test('debounced out of order searches keep the latest results', () async {
    final fake = _DelayedRepository();
    final cubit = GroupCubit(fake);
    await cubit.searchGroups('older');
    await Future<void>.delayed(const Duration(milliseconds: 320));
    await cubit.searchGroups('newer');
    await Future<void>.delayed(const Duration(milliseconds: 320));
    fake.searches['newer']!.complete([_group('newer')]);
    await Future<void>.delayed(Duration.zero);
    fake.searches['older']!.complete([_group('older')]);
    await Future<void>.delayed(Duration.zero);
    expect((cubit.state as GroupListLoaded).groups.single.name, 'newer');
    await cubit.close();
  });

  test('GroupCubit reports repository failures', () async {
    final fake = _DelayedRepository()..failGroupLoads = true;
    final cubit = GroupCubit(fake);
    await cubit.loadGroups();
    expect(cubit.state, isA<GroupFailure>());
    await cubit.close();
  });

  test(
    'dependency registration constructs a GroupCubit from the shared database helper',
    () async {
      final locator = GetIt.asNewInstance();
      locator.registerSingleton<DatabaseHelper>(database);
      registerGroupDependencies(locator);
      registerScheduleDependencies(locator);
      registerLessonDependencies(locator);
      registerAttendanceDependencies(locator);
      final groupCubit = locator<GroupCubit>();
      final scheduleCubit = locator<ScheduleCubit>();
      final lessonCubit = locator<LessonCubit>();
      final attendanceCubit = locator<AttendanceCubit>();
      expect(groupCubit, isA<GroupCubit>());
      expect(scheduleCubit, isA<ScheduleCubit>());
      expect(lessonCubit, isA<LessonCubit>());
      expect(attendanceCubit, isA<AttendanceCubit>());
      await groupCubit.close();
      await scheduleCubit.close();
      await lessonCubit.close();
      await attendanceCubit.close();
      await locator.reset();
    },
  );
}

StudyGroup _group(String name) => StudyGroup(
  id: 1,
  name: name,
  targetGrade: '7',
  notes: null,
  createdAt: 1,
  updatedAt: 1,
);

class _DelayedRepository implements GroupRepository {
  final Map<String, Completer<List<StudyGroup>>> searches = {};
  bool failGroupLoads = false;
  @override
  Future<List<StudyGroup>> getGroups() async {
    if (failGroupLoads) throw StateError('database failure');
    return [];
  }

  @override
  Future<List<StudyGroup>> searchGroups(String query) =>
      (searches[query] = Completer<List<StudyGroup>>()).future;
  @override
  Future<StudyGroup> getGroup(int groupId) async => _group('group');
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
}
