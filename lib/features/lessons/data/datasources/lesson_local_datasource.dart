import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../domain/entities/lesson_record.dart';
import '../../domain/repositories/lesson_repository.dart';

class LessonLocalDataSource {
  final DatabaseHelper dbHelper;
  LessonLocalDataSource(this.dbHelper);

  Future<List<LessonRecord>> getLessons({int? groupId}) async {
    final rows = await dbHelper.db.rawQuery(
      '''SELECT l.*, g.name AS group_name FROM lessons l
         INNER JOIN groups g ON g.id = l.group_id
         ${groupId == null ? '' : 'WHERE l.group_id = ?'}
         ORDER BY l.scheduled_date DESC, l.start_time DESC, l.id DESC''',
      groupId == null ? const [] : [groupId],
    );
    return rows.map(LessonRecord.fromMap).toList();
  }

  Future<LessonRecord> getLesson(int lessonId) async {
    final rows = await dbHelper.db.rawQuery(
      '''SELECT l.*, g.name AS group_name FROM lessons l
         INNER JOIN groups g ON g.id = l.group_id WHERE l.id = ?''',
      [lessonId],
    );
    if (rows.isEmpty) throw StateError('Lesson no longer exists');
    return LessonRecord.fromMap(rows.first);
  }

  Future<int> createLesson(LessonRecord lesson) async {
    try {
      return await dbHelper.db.insert('lessons', {
        'group_id': lesson.groupId,
        'scheduled_date': lesson.scheduledDate,
        'start_time': lesson.startTime,
        'end_time': lesson.endTime,
        'is_manual': lesson.isManual ? 1 : 0,
        'is_canceled': lesson.isCanceled ? 1 : 0,
        'cancellation_reason': _clean(lesson.cancellationReason),
      });
    } on DatabaseException catch (error) {
      if (error.toString().contains(
        'UNIQUE constraint failed: lessons.group_id',
      )) {
        throw DuplicateLessonException();
      }
      rethrow;
    }
  }

  Future<void> updateLesson(LessonRecord lesson) async {
    try {
      final changed = await dbHelper.db.update(
        'lessons',
        {
          'scheduled_date': lesson.scheduledDate,
          'start_time': lesson.startTime,
          'end_time': lesson.endTime,
          'is_canceled': lesson.isCanceled ? 1 : 0,
          'cancellation_reason': _clean(lesson.cancellationReason),
        },
        where: 'id = ?',
        whereArgs: [lesson.id],
      );
      if (changed == 0) throw StateError('Lesson no longer exists');
    } on DatabaseException catch (error) {
      if (error.toString().contains(
        'UNIQUE constraint failed: lessons.group_id',
      )) {
        throw DuplicateLessonException();
      }
      rethrow;
    }
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
