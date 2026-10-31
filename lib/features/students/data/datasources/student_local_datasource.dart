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
      orderBy: 'name ASC',
    );
    return rows.map((e) => Student.fromMap(e)).toList();
  }

  Future<List<Student>> searchStudents(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      return getActiveStudents();
    }
    final List<Map<String, dynamic>> rows = await dbHelper.db.query(
      'students',
      where: 'archived_at IS NULL AND (name LIKE ? OR phone LIKE ?)',
      whereArgs: ['%$q%', '%$q%'],
      orderBy: 'name ASC',
    );
    return rows.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> addStudent(Student student) async {
    final map = student.toMap();
    map.remove('id');
    return await dbHelper.db.insert('students', map);
  }

  Future<int> updateStudent(Student student) async {
    final map = student.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await dbHelper.db.update(
      'students',
      map,
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> archiveStudent(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return await dbHelper.db.update(
      'students',
      {'archived_at': now, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
