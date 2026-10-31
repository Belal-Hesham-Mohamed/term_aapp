// lib/features/students/domain/repositories/student_repository.dart

import '../entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getActiveStudents();
}
