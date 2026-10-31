// lib/features/students/presentation/state/student_state.dart

import '../../domain/entities/student.dart';

abstract class StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<Student> students;

  StudentLoaded(this.students);
}

class StudentError extends StudentState {
  final String message;

  StudentError(this.message);
}
