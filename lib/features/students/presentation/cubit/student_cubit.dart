// lib/features/students/presentation/cubit/student_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/student_state.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student.dart';
import '../../domain/student_rules.dart';

class StudentCubit extends Cubit<StudentState> {
  final StudentRepository repository;
  Timer? _searchTimer;
  String _query = '';
  int _requestId = 0;

  StudentCubit(this.repository) : super(StudentLoading()) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    final requestId = ++_requestId;
    final query = _query;
    try {
      final students = query.isEmpty
          ? await repository.getActiveStudents()
          : await repository.searchStudents(query);
      if (!isClosed && requestId == _requestId) emit(StudentLoaded(students));
    } catch (e) {
      if (!isClosed && requestId == _requestId) {
        emit(StudentError(e.toString()));
      }
    }
  }

  Future<void> searchStudents(String query) async {
    _query = query.trim();
    _searchTimer?.cancel();
    final requestId = ++_requestId;
    if (_query.isEmpty) {
      await _loadForQuery(requestId, '');
      return;
    }
    final queryToSearch = _query;
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _loadForQuery(requestId, queryToSearch);
    });
  }

  Future<void> _loadForQuery(int requestId, String query) async {
    try {
      final students = query.isEmpty
          ? await repository.getActiveStudents()
          : await repository.searchStudents(query);
      if (!isClosed && requestId == _requestId) emit(StudentLoaded(students));
    } catch (e) {
      if (!isClosed && requestId == _requestId) {
        emit(StudentError(e.toString()));
      }
    }
  }

  Future<Student?> createStudent({
    required String firstName,
    required String fatherName,
    required String familyName,
    required String grade,
    String? phone,
    int? age,
    String? guardianPhone,
    String? notes,
    bool confirmedDifferentStudent = false,
  }) async {
    try {
      final first = StudentRules.normalizeNamePart(firstName);
      final father = StudentRules.normalizeNamePart(fatherName);
      final family = StudentRules.normalizeNamePart(familyName);
      if ([first, father, family].any((part) => part.isEmpty) ||
          !StudentRules.gradeIds.contains(grade)) {
        return null;
      }
      final cleanPhone = StudentRules.normalizePhone(phone ?? '');
      final cleanGuardian = StudentRules.normalizePhone(guardianPhone ?? '');
      final cleanAge = age == null
          ? null
          : StudentRules.parseAge(age.toString());
      final name = [first, father, family].join(' ');
      final duplicates = await repository.findPotentialDuplicates(
        firstName: first,
        fatherName: father,
        familyName: family,
        grade: grade,
      );
      if (duplicates.isNotEmpty && !confirmedDifferentStudent) return null;
      final now = DateTime.now().millisecondsSinceEpoch;
      final student = Student(
        id: 0,
        name: name,
        firstName: first,
        fatherName: father,
        familyName: family,
        duplicateIndex: duplicates.length + 1,
        grade: grade,
        phone: cleanPhone.isEmpty ? null : cleanPhone,
        age: cleanAge,
        guardianPhone: cleanGuardian.isEmpty ? null : cleanGuardian,
        notes: notes?.isEmpty == true ? null : notes,
        createdAt: now,
        updatedAt: now,
      );
      final id = await repository.addStudent(student);
      await loadStudents();
      return student.copyWith(id: id);
    } catch (e) {
      emit(StudentError(e.toString()));
      return null;
    }
  }

  Future<List<Student>> findPotentialDuplicates({
    required String firstName,
    required String fatherName,
    required String familyName,
    required String grade,
  }) => repository.findPotentialDuplicates(
    firstName: firstName,
    fatherName: fatherName,
    familyName: familyName,
    grade: grade,
  );

  Future<bool> updateStudent(Student student) async {
    try {
      final first = StudentRules.normalizeNamePart(student.firstName ?? '');
      final father = StudentRules.normalizeNamePart(student.fatherName ?? '');
      final family = StudentRules.normalizeNamePart(student.familyName ?? '');
      if ([first, father, family].any((part) => part.isEmpty)) return false;
      if (StudentRules.gradeIds.contains(student.grade) == false &&
          student.grade.trim().isEmpty) {
        return false;
      }
      final phone = StudentRules.normalizePhone(student.phone ?? '');
      final guardian = StudentRules.normalizePhone(student.guardianPhone ?? '');
      final age = student.age == null
          ? null
          : StudentRules.parseAge(student.age.toString());
      final updated = student.copyWith(
        name: '$first $father $family',
        firstName: first,
        fatherName: father,
        familyName: family,
        phone: phone.isEmpty ? null : phone,
        guardianPhone: guardian.isEmpty ? null : guardian,
        age: age,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await repository.updateStudent(updated);
      await loadStudents();
      return true;
    } catch (e) {
      emit(StudentError(e.toString()));
      return false;
    }
  }

  Future<bool> archiveStudent(int id) async {
    try {
      await repository.archiveStudent(id);
      await loadStudents();
      return true;
    } catch (e) {
      emit(StudentError(e.toString()));
      return false;
    }
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
