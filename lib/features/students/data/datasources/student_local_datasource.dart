// lib/features/students/data/datasources/student_local_datasource.dart

import '../../../../../core/database/database_helper.dart';
import '../../domain/entities/student.dart';
import '../../domain/student_rules.dart';

class StudentLocalDataSource {
  final DatabaseHelper dbHelper;

  StudentLocalDataSource(this.dbHelper);

  Future<List<Student>> getActiveStudents() async {
    final List<Map<String, dynamic>> rows = await dbHelper.db.query(
      'students',
      where: 'archived_at IS NULL',
      orderBy: 'name COLLATE NOCASE ASC, duplicate_index ASC, id ASC',
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
      where:
          "archived_at IS NULL AND (name LIKE ? OR (name || CASE WHEN duplicate_index > 1 THEN ' (' || duplicate_index || ')' ELSE '' END) LIKE ? OR phone LIKE ? OR first_name LIKE ? OR father_name LIKE ? OR family_name LIKE ?)",
      whereArgs: ['%$q%', '%$q%', '%$q%', '%$q%', '%$q%', '%$q%'],
      orderBy: 'name COLLATE NOCASE ASC, duplicate_index ASC, id ASC',
    );
    return rows.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> addStudent(Student student) async {
    return dbHelper.db.transaction((txn) async {
      final duplicates =
          student.firstName == null ||
              student.fatherName == null ||
              student.familyName == null
          ? <Map<String, Object?>>[]
          : await txn.query(
              'students',
              columns: ['duplicate_index'],
              where:
                  'archived_at IS NULL AND first_name = ? COLLATE NOCASE AND father_name = ? COLLATE NOCASE AND family_name = ? COLLATE NOCASE AND grade = ? COLLATE NOCASE',
              whereArgs: [
                student.firstName,
                student.fatherName,
                student.familyName,
                student.grade,
              ],
            );
      final index =
          duplicates.fold<int>(
            1,
            (max, row) => (row['duplicate_index'] as int? ?? 1) > max
                ? row['duplicate_index'] as int
                : max,
          ) +
          (duplicates.isEmpty ? 0 : 1);
      final map = student.toMap()
        ..remove('id')
        ..['duplicate_index'] = index;
      return txn.insert('students', map);
    });
  }

  Future<List<Student>> findByNameAndGrade(String name, String grade) async {
    final rows = await dbHelper.db.query(
      'students',
      where:
          'archived_at IS NULL AND name = ? COLLATE NOCASE AND grade = ? COLLATE NOCASE',
      whereArgs: [name.trim(), grade.trim()],
      orderBy: 'id ASC',
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<List<Student>> findPotentialDuplicates({
    required String firstName,
    required String fatherName,
    required String familyName,
    required String grade,
  }) async {
    final rows = await dbHelper.db.query(
      'students',
      where:
          'archived_at IS NULL AND first_name = ? COLLATE NOCASE AND father_name = ? COLLATE NOCASE AND family_name = ? COLLATE NOCASE AND grade = ? COLLATE NOCASE',
      whereArgs: [
        StudentRules.normalizeNamePart(firstName),
        StudentRules.normalizeNamePart(fatherName),
        StudentRules.normalizeNamePart(familyName),
        grade,
      ],
      orderBy: 'duplicate_index ASC',
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<int> updateStudent(Student student) async {
    return dbHelper.db.transaction((txn) async {
      final updated = student.copyWith(
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      final map = updated.toMap();
      final currentRows = await txn.query(
        'students',
        columns: [
          'first_name',
          'father_name',
          'family_name',
          'grade',
          'duplicate_index',
        ],
        where: 'id = ?',
        whereArgs: [student.id],
        limit: 1,
      );
      if (currentRows.isEmpty) return 0;
      final current = currentRows.first;
      final conflicts = await txn.query(
        'students',
        columns: ['duplicate_index'],
        where:
            'id != ? AND archived_at IS NULL AND first_name = ? COLLATE NOCASE AND father_name = ? COLLATE NOCASE AND family_name = ? COLLATE NOCASE AND grade = ? COLLATE NOCASE',
        whereArgs: [
          student.id,
          student.firstName,
          student.fatherName,
          student.familyName,
          student.grade,
        ],
      );
      final identityUnchanged =
          current['first_name'] == student.firstName &&
          current['father_name'] == student.fatherName &&
          current['family_name'] == student.familyName &&
          current['grade'] == student.grade;
      if (identityUnchanged) {
        map['duplicate_index'] = current['duplicate_index'] as int? ?? 1;
      } else if (conflicts.isNotEmpty) {
        map['duplicate_index'] =
            conflicts.fold<int>(
              1,
              (max, row) => (row['duplicate_index'] as int? ?? 1) > max
                  ? row['duplicate_index'] as int
                  : max,
            ) +
            1;
      } else {
        map['duplicate_index'] = 1;
      }
      return txn.update(
        'students',
        map,
        where: 'id = ?',
        whereArgs: [student.id],
      );
    });
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
