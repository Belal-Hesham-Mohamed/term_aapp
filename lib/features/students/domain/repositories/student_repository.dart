// lib/features/students/domain/repositories/student_repository.dart

import '../entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getActiveStudents();
  Future<List<Student>> searchStudents(String query);
  Future<int> addStudent(Student student);
  Future<int> updateStudent(Student student);
  Future<int> archiveStudent(int id);
}
