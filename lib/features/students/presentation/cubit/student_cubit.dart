// lib/features/students/presentation/cubit/student_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/student_state.dart';
import '../../domain/repositories/student_repository.dart';


class StudentCubit extends Cubit<StudentState> {
  final StudentRepository repository;

  StudentCubit(this.repository) : super(StudentLoading()) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      final students = await repository.getActiveStudents();
      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError(e.toString()));
    }
  }
}
