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
    String name = 'Mona',
    String grade = '5',
    String? firstName,
    String? fatherName,
    String? familyName,
    String? phone = '123',
    int? age = 12,
    String? guardian = '456',
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
    expect(students.single.phone, '123');
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
        phone: '222',
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
          name: 'Mona A',
          phone: null,
          age: null,
          guardianPhone: null,
          notes: null,
        ),
      );
      final loaded = (await repository.getActiveStudents()).single;
      expect(loaded.name, 'Mona A');
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

  test('archive excludes student from active results', () async {
    final id = await repository.addStudent(makeStudent());
    await repository.archiveStudent(id);
    expect(await repository.getActiveStudents(), isEmpty);
    expect(await repository.searchStudents('Mona'), isEmpty);
  });

  test(
    'search matches name and phone; empty query returns all active students',
    () async {
      await repository.addStudent(makeStudent(name: 'Mona', phone: '555123'));
      await repository.addStudent(makeStudent(name: 'Sara', phone: '999'));
      expect((await repository.searchStudents('Mon')).single.name, 'Mona');
      expect((await repository.searchStudents('555')).single.name, 'Mona');
      expect(await repository.searchStudents(''), hasLength(2));
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
}

class _ControlledRepository implements StudentRepository {
  final active = Completer<List<Student>>();
  final Map<String, Completer<List<Student>>> searches = {};
  @override
  Future<List<Student>> getActiveStudents() => active.future;
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
  Future<int> archiveStudent(int id) async => 1;
}
