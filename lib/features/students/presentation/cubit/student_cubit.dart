// lib/features/students/presentation/cubit/student_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/student_state.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student.dart';

class StudentCubit extends Cubit<StudentState> {
  final StudentRepository repository;

  StudentCubit(this.repository) : super(StudentLoading()) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      emit(StudentLoading());
      final students = await repository.getActiveStudents();
      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }

  Future<void> searchStudents(String query) async {
    try {
      emit(StudentLoading());
      final students = await repository.searchStudents(query);
      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError(e.toString()));
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
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final student = Student(
        id: 0,
        name: name,
        grade: grade,
        phone: phone?.isEmpty == true ? null : phone,
        age: age,
        guardianPhone: guardianPhone?.isEmpty == true ? null : guardianPhone,
        notes: notes?.isEmpty == true ? null : notes,
        createdAt: now,
        updatedAt: now,
      );
      await repository.addStudent(student);
      await loadStudents();
      return true;
    } catch (e) {
      emit(StudentError(e.toString()));
      return false;
    }
  }

  Future<bool> updateStudent(Student student) async {
    try {
      final updated = student.copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
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
}
