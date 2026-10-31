import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../domain/entities/group_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

class ScheduleLocalDataSource {
  final DatabaseHelper dbHelper;
  ScheduleLocalDataSource(this.dbHelper);

  Future<List<GroupSchedule>> getSchedules(int groupId) async {
    final rows = await dbHelper.db.query(
      'group_schedules',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'weekday ASC, start_time ASC',
    );
    return rows.map(GroupSchedule.fromMap).toList();
  }

  Future<int> createSchedule(GroupSchedule schedule) async {
    return dbHelper.db.transaction((txn) async {
      await _validateNoConflict(txn, schedule);
      return txn.insert('group_schedules', {
        'group_id': schedule.groupId,
        'weekday': schedule.weekday,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'active': schedule.active ? 1 : 0,
      });
    });
  }

  Future<void> updateSchedule(GroupSchedule schedule) async {
    await dbHelper.db.transaction((txn) async {
      await _validateNoConflict(txn, schedule, exceptId: schedule.id);
      final changed = await txn.update(
        'group_schedules',
        {
          'weekday': schedule.weekday,
          'start_time': schedule.startTime,
          'end_time': schedule.endTime,
          'active': schedule.active ? 1 : 0,
        },
        where: 'id = ? AND group_id = ?',
        whereArgs: [schedule.id, schedule.groupId],
      );
      if (changed == 0) throw StateError('Schedule no longer exists');
    });
  }

  Future<void> _validateNoConflict(
    DatabaseExecutor executor,
    GroupSchedule schedule, {
    int? exceptId,
  }) async {
    final start = _minutes(schedule.startTime);
    final end = _minutes(schedule.endTime);
    if (start == null || end == null || start >= end) {
      throw ArgumentError('Invalid schedule time range');
    }
    if (!schedule.active) return;
    final rows = await executor.query(
      'group_schedules',
      where: 'group_id = ? AND weekday = ? AND active = 1 AND id != ?',
      whereArgs: [schedule.groupId, schedule.weekday, exceptId ?? -1],
    );
    for (final row in rows) {
      final otherStart = _minutes(row['start_time'] as String? ?? '');
      final otherEnd = _minutes(row['end_time'] as String? ?? '');
      if (otherStart != null &&
          otherEnd != null &&
          start < otherEnd &&
          otherStart < end) {
        throw ScheduleConflictException();
      }
    }
  }

  int? _minutes(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return hour * 60 + minute;
  }

  Future<bool> removeSchedule(int scheduleId) async =>
      await dbHelper.db.delete(
        'group_schedules',
        where: 'id = ?',
        whereArgs: [scheduleId],
      ) >
      0;
}
