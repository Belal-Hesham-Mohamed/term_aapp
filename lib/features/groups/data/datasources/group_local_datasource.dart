import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../students/domain/entities/student.dart';
import '../../domain/entities/study_group.dart';
import '../../domain/repositories/group_repository.dart';

class GroupLocalDataSource {
  final DatabaseHelper dbHelper;

  GroupLocalDataSource(this.dbHelper);

  Future<List<StudyGroup>> getGroups([String query = '']) async {
    final trimmed = query.trim();
    final rows = await dbHelper.db.rawQuery(
      '''
      SELECT g.*, COUNT(DISTINCT CASE WHEN s.archived_at IS NULL THEN s.id END)
        AS active_student_count
      FROM groups g
      LEFT JOIN group_students gs ON gs.group_id = g.id
      LEFT JOIN students s ON s.id = gs.student_id
      WHERE (? = '' OR g.name LIKE ? OR g.target_grade LIKE ?)
      GROUP BY g.id
      ORDER BY g.name COLLATE NOCASE ASC
    ''',
      [trimmed, '%$trimmed%', '%$trimmed%'],
    );
    return rows.map(StudyGroup.fromMap).toList();
  }

  Future<StudyGroup> getGroup(int groupId) async {
    final rows = await dbHelper.db.rawQuery(
      '''
      SELECT g.*, COUNT(DISTINCT CASE WHEN s.archived_at IS NULL THEN s.id END)
        AS active_student_count
      FROM groups g
      LEFT JOIN group_students gs ON gs.group_id = g.id
      LEFT JOIN students s ON s.id = gs.student_id
      WHERE g.id = ? GROUP BY g.id
    ''',
      [groupId],
    );
    if (rows.isEmpty) throw StateError('Group no longer exists');
    return StudyGroup.fromMap(rows.first);
  }

  Future<List<Student>> getEnrolledStudents(int groupId) async {
    final rows = await dbHelper.db.rawQuery(
      '''
      SELECT s.* FROM students s
      INNER JOIN group_students gs ON gs.student_id = s.id
      WHERE gs.group_id = ? AND s.archived_at IS NULL
      ORDER BY s.name COLLATE NOCASE ASC
    ''',
      [groupId],
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<List<Student>> getAvailableStudents(int groupId) async {
    final rows = await dbHelper.db.rawQuery(
      '''
      SELECT s.* FROM students s
      WHERE s.archived_at IS NULL
        AND NOT EXISTS (
          SELECT 1 FROM group_students gs
          WHERE gs.group_id = ? AND gs.student_id = s.id
        )
      ORDER BY s.name COLLATE NOCASE ASC
    ''',
      [groupId],
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<int> createGroup(StudyGroup group) async {
    try {
      return await dbHelper.db.insert('groups', {
        'name': group.name.trim(),
        'target_grade': group.targetGrade.trim(),
        'notes': _cleanNotes(group.notes),
        'created_at': group.createdAt,
        'updated_at': group.updatedAt,
      });
    } on DatabaseException catch (error) {
      if (error.toString().contains('UNIQUE constraint failed: groups.name')) {
        throw DuplicateGroupNameException();
      }
      rethrow;
    }
  }

  Future<void> updateGroup(StudyGroup group) async {
    try {
      final changed = await dbHelper.db.update(
        'groups',
        {
          'name': group.name.trim(),
          'target_grade': group.targetGrade.trim(),
          'notes': _cleanNotes(group.notes),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [group.id],
      );
      if (changed == 0) throw StateError('Group no longer exists');
    } on DatabaseException catch (error) {
      if (error.toString().contains('UNIQUE constraint failed: groups.name')) {
        throw DuplicateGroupNameException();
      }
      rethrow;
    }
  }

  Future<void> addStudents(int groupId, List<int> studentIds) async {
    await dbHelper.db.transaction((txn) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final studentId in studentIds.toSet()) {
        final activeStudent = await txn.query(
          'students',
          columns: ['id'],
          where: 'id = ? AND archived_at IS NULL',
          whereArgs: [studentId],
          limit: 1,
        );
        if (activeStudent.isEmpty) continue;
        await txn.insert('group_students', {
          'group_id': groupId,
          'student_id': studentId,
          'enrolled_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  Future<bool> removeStudent(int groupId, int studentId) async =>
      await dbHelper.db.delete(
        'group_students',
        where: 'group_id = ? AND student_id = ?',
        whereArgs: [groupId, studentId],
      ) >
      0;

  String? _cleanNotes(String? notes) {
    final trimmed = notes?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
