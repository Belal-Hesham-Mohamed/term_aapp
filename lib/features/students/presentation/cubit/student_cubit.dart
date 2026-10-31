// lib/features/students/presentation/cubit/student_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/student_state.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student.dart';

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

  Future<bool> addStudent({
    required String name,
    required String grade,
    String? phone,
    int? age,
    String? guardianPhone,
    String? notes,
  }) async {
    return await createStudent(name: name, grade: grade, phone: phone, age: age,
      guardianPhone: guardianPhone, notes: notes) != null;
  }

  Future<Student?> createStudent({
    required String name,
    required String grade,
    String? phone,
    int? age,
    String? guardianPhone,
    String? notes,
    bool numberDuplicate = false,
  }) async {
    try {
      var finalName = name.trim();
      if (numberDuplicate) {
        final duplicates = await repository.findByNameAndGrade(finalName, grade);
        if (duplicates.isNotEmpty) {
          var index = 2;
          while ((await repository.findByNameAndGrade('$finalName ($index)', grade)).isNotEmpty) { index++; }
          finalName = '$finalName ($index)';
        }
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      final student = Student(
        id: 0,
        name: finalName,
        grade: grade,
        phone: phone?.isEmpty == true ? null : phone,
        age: age,
        guardianPhone: guardianPhone?.isEmpty == true ? null : guardianPhone,
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

  Future<bool> updateStudent(Student student) async {
    try {
      final updated = student.copyWith(
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
