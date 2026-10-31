// lib/features/students/data/repositories/student_repository_impl.dart

import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student.dart';
import '../datasources/student_local_datasource.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentLocalDataSource dataSource;

  StudentRepositoryImpl(this.dataSource);

  @override
  Future<List<Student>> getActiveStudents() => dataSource.getActiveStudents();

  @override
  Future<List<Student>> searchStudents(String query) =>
      dataSource.searchStudents(query);

  @override
  Future<int> addStudent(Student student) => dataSource.addStudent(student);

  @override
  Future<List<Student>> findByNameAndGrade(String name, String grade) =>
      dataSource.findByNameAndGrade(name, grade);

  @override
  Future<List<Student>> findPotentialDuplicates({
    required String firstName,
    required String fatherName,
    required String familyName,
    required String grade,
  }) => dataSource.findPotentialDuplicates(
    firstName: firstName,
    fatherName: fatherName,
    familyName: familyName,
    grade: grade,
  );

  @override
  Future<int> updateStudent(Student student) =>
      dataSource.updateStudent(student);

  @override
  Future<int> archiveStudent(int id) => dataSource.archiveStudent(id);
}
