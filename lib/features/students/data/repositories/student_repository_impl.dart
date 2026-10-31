// lib/features/students/data/repositories/student_repository_impl.dart

import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student.dart';
import '../datasources/student_local_datasource.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentLocalDataSource dataSource;

  StudentRepositoryImpl(this.dataSource);

  @override
  Future<List<Student>> getActiveStudents() => dataSource.getActiveStudents();
}
