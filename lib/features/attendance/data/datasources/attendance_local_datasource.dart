import '../../../../core/database/database_helper.dart';
import '../../domain/entities/attendance_entry.dart';

class AttendanceLocalDataSource {
  final DatabaseHelper dbHelper;
  AttendanceLocalDataSource(this.dbHelper);

  Future<List<AttendanceEntry>> getLessonRoster(int lessonId) async {
    final rows = await dbHelper.db.rawQuery(
      '''
      SELECT s.*, ar.status AS attendance_status, ar.recorded_at AS attendance_recorded_at
      FROM students s
      LEFT JOIN attendance_records ar
        ON ar.student_id = s.id AND ar.lesson_id = ?
      WHERE EXISTS (
        SELECT 1 FROM lessons l
        INNER JOIN group_students gs ON gs.group_id = l.group_id
        WHERE l.id = ? AND gs.student_id = s.id AND s.archived_at IS NULL
      ) OR ar.id IS NOT NULL
      ORDER BY s.name COLLATE NOCASE ASC
    ''',
      [lessonId, lessonId],
    );
    return rows.map(AttendanceEntry.fromMap).toList();
  }

  Future<void> saveAttendance(int lessonId, Map<int, String> statuses) async {
    await dbHelper.db.transaction((txn) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final entry in statuses.entries) {
        if (!const {'present', 'absent'}.contains(entry.value)) {
          throw ArgumentError('Unsupported attendance status');
        }
        final updated = await txn.update(
          'attendance_records',
          {'status': entry.value, 'recorded_at': now},
          where: 'lesson_id = ? AND student_id = ?',
          whereArgs: [lessonId, entry.key],
        );
        if (updated == 0) {
          await txn.insert('attendance_records', {
            'lesson_id': lessonId,
            'student_id': entry.key,
            'status': entry.value,
            'recorded_at': now,
          });
        }
      }
    });
  }
}
