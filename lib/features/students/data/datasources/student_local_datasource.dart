// lib/features/students/data/datasources/student_local_datasource.dart


import '../../../../../core/database/database_helper.dart';
import '../../domain/entities/student.dart';

class StudentLocalDataSource {
  final DatabaseHelper dbHelper;

  StudentLocalDataSource(this.dbHelper);

  Future<List<Student>> getActiveStudents() async {
    final List<Map<String, dynamic>> rows = await dbHelper.db.query(
      'students',
      where: 'archived_at IS NULL',
    );
    return rows.map((e) => Student.fromMap(e)).toList();
  }
}
