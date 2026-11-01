import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../domain/entities/lesson_record.dart';
import '../../domain/repositories/lesson_repository.dart';

class LessonLocalDataSource {
  static const int upcomingWindowDays = 30;
  final DatabaseHelper dbHelper;
  LessonLocalDataSource(this.dbHelper);

  Future<List<LessonRecord>> getLessons({int? groupId}) async {
    final rows = await dbHelper.db.rawQuery(
      '''SELECT l.*, g.name AS group_name, g.target_grade AS group_grade FROM lessons l
         INNER JOIN groups g ON g.id = l.group_id
         ${groupId == null ? '' : 'WHERE l.group_id = ?'}
         ORDER BY l.scheduled_date DESC, l.start_time DESC, l.id DESC''',
      groupId == null ? const [] : [groupId],
    );
    return rows.map(LessonRecord.fromMap).toList();
  }

  Future<List<LessonRecord>> getUpcomingLessons({
    int? groupId,
    required DateTime from,
  }) async {
    final dayStart = DateTime(
      from.year,
      from.month,
      from.day,
    ).millisecondsSinceEpoch;
    final nowTime =
        '${from.hour.toString().padLeft(2, '0')}:${from.minute.toString().padLeft(2, '0')}';
    final rows = await dbHelper.db.rawQuery(
      '''SELECT l.*, g.name AS group_name, g.target_grade AS group_grade FROM lessons l
         INNER JOIN groups g ON g.id = l.group_id
         WHERE l.is_canceled = 0
           AND l.start_time IS NOT NULL AND TRIM(l.start_time) != ''
           AND l.end_time IS NOT NULL AND TRIM(l.end_time) != ''
           AND (l.scheduled_date > ? OR
             (l.scheduled_date = ? AND l.start_time >= ?))
           ${groupId == null ? '' : 'AND l.group_id = ?'}
         ORDER BY l.scheduled_date ASC, l.start_time ASC, l.id ASC''',
      groupId == null
          ? [dayStart, dayStart, nowTime]
          : [dayStart, dayStart, nowTime, groupId],
    );
    return rows
        .where(
          (row) => _isValidTimeRange(
            row['start_time'] as String?,
            row['end_time'] as String?,
          ),
        )
        .map(LessonRecord.fromMap)
        .toList();
  }

  Future<int> generateUpcomingLessons(DateTime now) async {
    final today = DateTime(now.year, now.month, now.day);
    return dbHelper.db.transaction((txn) async {
      final schedules = await txn.query(
        'group_schedules',
        where: 'active = 1',
        orderBy: 'group_id ASC, weekday ASC, start_time ASC',
      );
      var inserted = 0;
      for (var offset = 0; offset < upcomingWindowDays; offset++) {
        final date = DateTime(today.year, today.month, today.day + offset);
        final scheduledDate = DateTime(date.year, date.month, date.day);
        final dateValue = scheduledDate.millisecondsSinceEpoch;
        for (final schedule in schedules) {
          if (schedule['weekday'] != date.weekday) continue;
          final startTime = schedule['start_time'] as String?;
          final endTime = schedule['end_time'] as String?;
          if (!_isValidTimeRange(startTime, endTime)) continue;
          await txn.insert('lessons', {
            'group_id': schedule['group_id'],
            'scheduled_date': dateValue,
            'start_time': startTime,
            'end_time': endTime,
            'is_manual': 0,
            'is_canceled': 0,
            'cancellation_reason': null,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          // sqflite may return the previous insert id when IGNORE suppresses
          // a duplicate, so use SQLite's changes() count instead.
          final changes = await txn.rawQuery('SELECT changes() AS row_count');
          if (changes.single['row_count'] == 1) inserted++;
        }
      }
      return inserted;
    });
  }

  bool _isValidTimeRange(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return false;
    final start = _minutes(startTime);
    final end = _minutes(endTime);
    return start != null && end != null && start < end;
  }

  int? _minutes(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) return null;
    return hour * 60 + minute;
  }

  Future<LessonRecord> getLesson(int lessonId) async {
    final rows = await dbHelper.db.rawQuery(
      '''SELECT l.*, g.name AS group_name, g.target_grade AS group_grade FROM lessons l
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
        'UNIQUE constraint failed: lessons.group_id, lessons.scheduled_date, lessons.start_time',
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
        'UNIQUE constraint failed: lessons.group_id, lessons.scheduled_date, lessons.start_time',
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
