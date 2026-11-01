import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:term/core/database/database_helper.dart';
import 'package:term/features/students/data/datasources/student_local_datasource.dart';
import 'package:term/features/students/data/repositories/student_repository_impl.dart';
import 'package:term/features/students/domain/entities/student.dart';
import 'package:term/features/students/domain/repositories/student_repository.dart';
import 'package:term/features/students/presentation/cubit/student_cubit.dart';
import 'package:term/features/students/presentation/state/student_state.dart';

void main() {
  late DatabaseHelper db;
  late StudentRepository repository;

  setUp(() async {
    db = DatabaseHelper();
    await db.initInMemory();
    repository = StudentRepositoryImpl(StudentLocalDataSource(db));
  });

  tearDown(() async => db.db.close());

  Student makeStudent({
    String name = 'Mona Ali Ahmed',
    String grade = 'primary_1',
    String? firstName = 'Mona',
    String? fatherName = 'Ali',
    String? familyName = 'Ahmed',
    String? phone = '01012345678',
    int? age = 12,
    String? guardian = '01112345678',
    String? notes = 'note',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Student(
      id: 0,
      name: name,
      grade: grade,
      firstName: firstName,
      fatherName: fatherName,
      familyName: familyName,
      phone: phone,
      age: age,
      guardianPhone: guardian,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('creates a student and persists optional data', () async {
    await repository.addStudent(makeStudent());
    final students = await repository.getActiveStudents();
    expect(students, hasLength(1));
    expect(students.single.phone, '+201012345678');
    expect(students.single.name, 'Mona Ali Ahmed');
  });

  test(
    'confirmed same-name and grade student gets an automatic display number',
    () async {
      await repository.addStudent(
        makeStudent(
          name: 'Mona Ali Ahmed',
          firstName: 'Mona',
          fatherName: 'Ali',
          familyName: 'Ahmed',
          grade: 'primary_1',
        ),
      );
      final cubit = StudentCubit(repository);
      final created = await cubit.createStudent(
        firstName: 'Mona',
        fatherName: 'Ali',
        familyName: 'Ahmed',
        grade: 'primary_1',
        phone: '01012345678',
        confirmedDifferentStudent: true,
      );
      expect(created?.name, 'Mona Ali Ahmed');
      expect(created?.displayName, 'Mona Ali Ahmed (2)');
      expect(created?.grade, 'primary_1');
      expect(created?.phone, '+201012345678');
      await cubit.close();
    },
  );

  test('duplicate numbering chooses the next unused display number', () async {
    await repository.addStudent(
      makeStudent(
        name: 'Mona Ali Ahmed',
        firstName: 'Mona',
        fatherName: 'Ali',
        familyName: 'Ahmed',
        grade: 'primary_1',
      ),
    );
    await repository.addStudent(
      makeStudent(
        name: 'Mona Ali Ahmed',
        firstName: 'Mona',
        fatherName: 'Ali',
        familyName: 'Ahmed',
        grade: 'primary_1',
        phone: '01212345678',
      ),
    );
    final cubit = StudentCubit(repository);
    final created = await cubit.createStudent(
      firstName: 'Mona',
      fatherName: 'Ali',
      familyName: 'Ahmed',
      grade: 'primary_1',
      confirmedDifferentStudent: true,
    );
    expect(created?.displayName, 'Mona Ali Ahmed (3)');
    await cubit.close();
  });

  test(
    'duplicate matching collapses spaces, ignores English case, and includes grade',
    () async {
      await repository.addStudent(
        makeStudent(
          name: 'Mona Ali Ahmed',
          firstName: 'Mona',
          fatherName: 'Ali',
          familyName: 'Ahmed',
          grade: 'primary_1',
        ),
      );
      expect(
        await repository.findPotentialDuplicates(
          firstName: '  MONA ',
          fatherName: 'Ali',
          familyName: 'Ahmed',
          grade: 'primary_1',
        ),
        hasLength(1),
      );
      expect(
        await repository.findPotentialDuplicates(
          firstName: 'Mona',
          fatherName: 'Ali',
          familyName: 'Ahmed',
          grade: 'primary_2',
        ),
        isEmpty,
      );
    },
  );

  test(
    'updates student and can clear nullable values after SQLite reload',
    () async {
      final id = await repository.addStudent(makeStudent());
      final original = (await repository.getActiveStudents()).single;
      await repository.updateStudent(
        original.copyWith(
          id: id,
          name: 'Laila Samir Khaled',
          firstName: 'Laila',
          fatherName: 'Samir',
          familyName: 'Khaled',
          phone: null,
          age: null,
          guardianPhone: null,
          notes: null,
        ),
      );
      final loaded = (await repository.getActiveStudents()).single;
      expect(loaded.name, 'Laila Samir Khaled');
      expect(loaded.phone, isNull);
      expect(loaded.age, isNull);
      expect(loaded.guardianPhone, isNull);
      expect(loaded.notes, isNull);
    },
  );

  test('omitted nullable copyWith values preserve existing values', () {
    final original = makeStudent();
    expect(original.copyWith(name: 'Changed').phone, original.phone);
    expect(original.copyWith(name: 'Changed').age, original.age);
  });

  test(
    'existing archive metadata is retained and does not hide students',
    () async {
      final id = await repository.addStudent(makeStudent());
      final archivedAt = DateTime.now().millisecondsSinceEpoch;
      await db.db.update(
        'students',
        {'archived_at': archivedAt},
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(await repository.getActiveStudents(), hasLength(1));
      expect(await repository.searchStudents('Mona'), hasLength(1));
      expect((await repository.getStudentById(id))!.archivedAt, archivedAt);
    },
  );

  test(
    'search matches name and phone; empty query returns all active students',
    () async {
      await repository.addStudent(
        makeStudent(name: 'Mona Ali Ahmed', phone: '01512345678'),
      );
      await repository.addStudent(
        makeStudent(
          name: 'Sara Ali Ahmed',
          firstName: 'Sara',
          phone: '01098765432',
        ),
      );
      expect(
        (await repository.searchStudents('Mon')).single.name,
        'Mona Ali Ahmed',
      );
      expect(
        (await repository.searchStudents('0151')).single.name,
        'Mona Ali Ahmed',
      );
      expect(await repository.searchStudents(''), hasLength(2));
    },
  );

  test(
    'student grade filtering combines with search and preserves search when grade changes',
    () async {
      await repository.addStudent(
        makeStudent(
          name: 'Ahmed Ali Hassan',
          firstName: 'Ahmed',
          fatherName: 'Ali',
          familyName: 'Hassan',
          grade: 'primary_1',
        ),
      );
      await repository.addStudent(
        makeStudent(
          name: 'Ahmed Samir Hassan',
          firstName: 'Ahmed',
          fatherName: 'Samir',
          familyName: 'Hassan',
          grade: 'primary_2',
        ),
      );
      await repository.addStudent(
        makeStudent(
          name: 'Mona Ali Youssef',
          familyName: 'Youssef',
          grade: 'primary_1',
        ),
      );
      final cubit = StudentCubit(repository);
      await cubit.loadStudents();
      await cubit.selectGrade('primary_1');
      expect((cubit.state as StudentLoaded).students, hasLength(2));
      await cubit.searchStudents('Ahmed');
      await Future<void>.delayed(const Duration(milliseconds: 320));
      expect(
        (cubit.state as StudentLoaded).students.map((student) => student.name),
        ['Ahmed Ali Hassan'],
      );
      await cubit.selectGrade('primary_2');
      expect(
        (cubit.state as StudentLoaded).students.map((student) => student.name),
        ['Ahmed Samir Hassan'],
      );
      await cubit.selectGrade(null);
      expect((cubit.state as StudentLoaded).students, hasLength(2));
      await cubit.close();
    },
  );

  test('out of order searches keep the newest result', () async {
    final controlled = _ControlledRepository();
    final cubit = StudentCubit(controlled);
    controlled.active.complete([]);
    await Future<void>.delayed(Duration.zero);
    await cubit.searchStudents('old');
    await Future<void>.delayed(const Duration(milliseconds: 320));
    await cubit.searchStudents('new');
    await Future<void>.delayed(const Duration(milliseconds: 320));
    controlled.searches['new']!.complete([makeStudent(name: 'Newest')]);
    await Future<void>.delayed(Duration.zero);
    controlled.searches['old']!.complete([makeStudent(name: 'Old')]);
    await Future<void>.delayed(Duration.zero);
    expect((cubit.state as StudentLoaded).students.single.name, 'Newest');
    await cubit.close();
  });

  test(
    'repository rejects invalid values even when Cubit validation is bypassed',
    () async {
      final valid = makeStudent();
      await expectLater(
        repository.addStudent(valid.copyWith(phone: '123')),
        throwsFormatException,
      );
      await expectLater(
        repository.addStudent(valid.copyWith(age: 31)),
        throwsFormatException,
      );
      await expectLater(
        repository.addStudent(valid.copyWith(grade: 'Grade 7')),
        throwsFormatException,
      );
      expect(await repository.getActiveStudents(), isEmpty);
    },
  );

  test('Cubit rejects invalid direct creation and update values', () async {
    final cubit = StudentCubit(repository);
    final invalidCreate = await cubit.createStudent(
      firstName: 'Mona',
      fatherName: 'Ali',
      familyName: 'Ahmed',
      grade: 'primary_1',
      phone: 'not a phone',
    );
    expect(invalidCreate, isNull);
    expect(await repository.getActiveStudents(), isEmpty);

    final id = await repository.addStudent(makeStudent());
    final existing = (await repository.getStudentById(id))!;
    expect(
      await cubit.updateStudent(existing.copyWith(grade: 'arbitrary')),
      isFalse,
    );
    expect(
      await cubit.updateStudent(existing.copyWith(guardianPhone: '123')),
      isFalse,
    );
    expect(await cubit.updateStudent(existing.copyWith(age: 31)), isFalse);
    expect(
      (await repository.getStudentById(id))!.guardianPhone,
      '+201112345678',
    );
    await cubit.close();
  });

  test(
    'legacy full name remains unchanged and participates in duplicate review',
    () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final legacyId = await db.db.insert('students', {
        'name': 'أحمد محمد حسن',
        'grade': 'Grade 7',
        'created_at': now,
        'updated_at': now,
      });
      expect(
        await repository.findPotentialDuplicates(
          firstName: 'أحمد',
          fatherName: 'محمد',
          familyName: 'حسن',
          grade: 'Grade 7',
        ),
        hasLength(1),
      );
      final legacy = (await repository.getStudentById(legacyId))!;
      expect(
        await repository.updateStudent(legacy.copyWith(notes: 'updated')),
        1,
      );
      final updated = (await repository.getStudentById(legacyId))!;
      expect(updated.name, 'أحمد محمد حسن');
      expect(updated.firstName, isNull);
      expect(updated.notes, 'updated');
    },
  );

  test(
    'legacy duplicate matching collapses whitespace but preserves Arabic spelling',
    () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.db.insert('students', {
        'name': '  أحمد   محمد حسن ',
        'grade': 'primary_1',
        'created_at': now,
        'updated_at': now,
      });
      expect(
        await repository.findPotentialDuplicates(
          firstName: 'أحمد',
          fatherName: 'محمد',
          familyName: 'حسن',
          grade: 'primary_1',
        ),
        hasLength(1),
      );
      expect(
        await repository.findPotentialDuplicates(
          firstName: 'احمد',
          fatherName: 'محمد',
          familyName: 'حسن',
          grade: 'primary_1',
        ),
        isEmpty,
      );
    },
  );

  test(
    'permanent deletion compacts remaining duplicate display numbering',
    () async {
      final ids = <int>[];
      for (var i = 0; i < 3; i++) {
        ids.add(await repository.addStudent(makeStudent()));
      }
      expect(
        (await repository.getActiveStudents()).map((s) => s.duplicateIndex),
        [1, 2, 3],
      );
      await repository.deleteStudent(ids[1]);
      expect(
        (await repository.getActiveStudents()).map((s) => s.duplicateIndex),
        [1, 2],
      );
    },
  );

  test(
    'deleting a student removes enrollments and attendance but keeps other data',
    () async {
      final studentId = await repository.addStudent(makeStudent());
      final otherStudentId = await repository.addStudent(
        makeStudent(name: 'Sara Ali Ahmed', firstName: 'Sara'),
      );
      final now = DateTime.now().millisecondsSinceEpoch;
      final groupId = await db.db.insert('groups', {
        'name': 'Shared group',
        'target_grade': 'primary_1',
        'created_at': now,
        'updated_at': now,
      });
      await db.db.insert('group_students', {
        'group_id': groupId,
        'student_id': studentId,
        'enrolled_at': now,
      });
      await db.db.insert('group_students', {
        'group_id': groupId,
        'student_id': otherStudentId,
        'enrolled_at': now,
      });
      final lessonId = await db.db.insert('lessons', {
        'group_id': groupId,
        'scheduled_date': now,
      });
      await db.db.insert('attendance_records', {
        'lesson_id': lessonId,
        'student_id': studentId,
        'status': 'present',
        'recorded_at': now,
      });
      await db.db.insert('attendance_records', {
        'lesson_id': lessonId,
        'student_id': otherStudentId,
        'status': 'absent',
        'recorded_at': now,
      });

      expect(await repository.deleteStudent(studentId), 1);
      expect(await repository.getStudentById(studentId), isNull);
      expect(await repository.getStudentById(otherStudentId), isNotNull);
      expect(
        await db.db.query(
          'group_students',
          where: 'student_id = ?',
          whereArgs: [studentId],
        ),
        isEmpty,
      );
      expect(
        (await db.db.query('group_students')).single['student_id'],
        otherStudentId,
      );
      expect(
        (await db.db.query('attendance_records')).single['student_id'],
        otherStudentId,
      );
      expect(await db.db.query('groups'), hasLength(1));
      expect(await db.db.query('lessons'), hasLength(1));
    },
  );

  test(
    'failed student deletion rolls back enrollment and attendance removal',
    () async {
      final studentId = await repository.addStudent(makeStudent());
      final now = DateTime.now().millisecondsSinceEpoch;
      final groupId = await db.db.insert('groups', {
        'name': 'Protected',
        'target_grade': 'primary_1',
        'created_at': now,
        'updated_at': now,
      });
      await db.db.insert('group_students', {
        'group_id': groupId,
        'student_id': studentId,
        'enrolled_at': now,
      });
      final lessonId = await db.db.insert('lessons', {
        'group_id': groupId,
        'scheduled_date': now,
      });
      await db.db.insert('attendance_records', {
        'lesson_id': lessonId,
        'student_id': studentId,
        'status': 'present',
        'recorded_at': now,
      });
      await db.db.execute(
        '''CREATE TRIGGER block_student_delete BEFORE DELETE ON students BEGIN SELECT RAISE(ABORT, 'blocked'); END''',
      );
      await expectLater(repository.deleteStudent(studentId), throwsA(anything));
      expect(await repository.getStudentById(studentId), isNotNull);
      expect(await db.db.query('group_students'), hasLength(1));
      expect(await db.db.query('attendance_records'), hasLength(1));
    },
  );

  test(
    'changing grade moves student into the correct duplicate numbering group',
    () async {
      final firstId = await repository.addStudent(makeStudent());
      final secondId = await repository.addStudent(makeStudent());
      final second = (await repository.getStudentById(secondId))!;
      await repository.updateStudent(second.copyWith(grade: 'primary_2'));
      expect((await repository.getStudentById(firstId))!.duplicateIndex, 1);
      expect((await repository.getStudentById(secondId))!.duplicateIndex, 1);
      expect((await repository.getStudentById(secondId))!.grade, 'primary_2');
    },
  );
}

class _ControlledRepository implements StudentRepository {
  final active = Completer<List<Student>>();
  final Map<String, Completer<List<Student>>> searches = {};
  @override
  Future<int> countStudents() async => 0;
  @override
  Future<List<Student>> getActiveStudents() => active.future;
  @override
  Future<Student?> getStudentById(int id) async => null;
  @override
  Future<List<Student>> searchStudents(String query) =>
      (searches[query] = Completer<List<Student>>()).future;
  @override
  Future<int> addStudent(Student student) async => 1;
  @override
  Future<List<Student>> findByNameAndGrade(String name, String grade) async =>
      [];
  @override
  Future<List<Student>> findPotentialDuplicates({
    required String firstName,
    required String fatherName,
    required String familyName,
    required String grade,
  }) async => [];
  @override
  Future<int> updateStudent(Student student) async => 1;
  @override
  Future<int> deleteStudent(int id) async => 1;
}
