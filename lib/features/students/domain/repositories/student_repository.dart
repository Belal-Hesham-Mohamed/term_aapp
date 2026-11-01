// lib/features/students/domain/repositories/student_repository.dart

import '../entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getActiveStudents();
  Future<int> countStudents();
  Future<Student?> getStudentById(int id);
  Future<List<Student>> searchStudents(String query);
  Future<int> addStudent(Student student);
  Future<List<Student>> findByNameAndGrade(String name, String grade);
  Future<List<Student>> findPotentialDuplicates({
    required String firstName,
    required String fatherName,
    required String familyName,
    required String grade,
  });
  Future<int> updateStudent(Student student);
  Future<int> deleteStudent(int id);
}
