// test/database_helper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:term/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  late DatabaseHelper dbHelper;
  setUp(() async {
    dbHelper = DatabaseHelper();
    await dbHelper.initInMemory();
  });

  tearDown(() async {
    await dbHelper.db.close();
  });

  test('Database opens and tables exist', () async {
    // simple query to list tables
    final result = await dbHelper.db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'");
    final tableNames = result.map((e) => e['name'] as String).toSet();
    expect(tableNames, containsAll(['students', 'groups', 'group_students',
      'group_schedules', 'lessons', 'attendance_records', 'app_settings']));
  });

  test('Deleting a group cascades to related tables', () async {
    // Setup group, student, membership, lesson, attendance
    int now = DateTime.now().millisecondsSinceEpoch;
    // Insert group
    int groupId = await dbHelper.db.insert('groups', {
      'name': 'Group A',
      'target_grade': '10',
      'created_at': now,
      'updated_at': now,
    });
    // Insert student
    int studentId = await dbHelper.db.insert('students', {
      'name': 'Alice',
      'grade': '10',
      'created_at': now,
      'updated_at': now,
    });
    // Link student to group
    await dbHelper.db.insert('group_students', {
      'group_id': groupId,
      'student_id': studentId,
      'enrolled_at': now,
    });
    // Insert lesson for group
    int lessonId = await dbHelper.db.insert('lessons', {
      'group_id': groupId,
      'scheduled_date': now,
      'is_manual': 0,
      'is_canceled': 0,
    });
    // Insert attendance record
    await dbHelper.db.insert('attendance_records', {
      'lesson_id': lessonId,
      'student_id': studentId,
      'status': 'present',
      'recorded_at': now,
    });

    // Delete group
    int deleted = await dbHelper.db.delete('groups', where: 'id = ?', whereArgs: [groupId]);
    expect(deleted, equals(1));

    // Verify cascade deletions
    final remainingGroups = await dbHelper.db.query('groups');
    final remainingGroupStudents = await dbHelper.db.query('group_students');
    final remainingLessons = await dbHelper.db.query('lessons');
    final remainingAttendance = await dbHelper.db.query('attendance_records');
    expect(remainingGroups, isEmpty);
    expect(remainingGroupStudents, isEmpty);
    expect(remainingLessons, isEmpty);
    expect(remainingAttendance, isEmpty);
  });

  test('Deleting a student is restricted when attendance exists', () async {
    int now = DateTime.now().millisecondsSinceEpoch;
    // Insert student
    int studentId = await dbHelper.db.insert('students', {
      'name': 'Bob',
      'grade': '10',
      'created_at': now,
      'updated_at': now,
    });
    // Insert group and lesson
    int groupId = await dbHelper.db.insert('groups', {
      'name': 'Group B',
      'target_grade': '10',
      'created_at': now,
      'updated_at': now,
    });
    int lessonId = await dbHelper.db.insert('lessons', {
      'group_id': groupId,
      'scheduled_date': now,
      'is_manual': 0,
      'is_canceled': 0,
    });
    // Insert attendance referencing student
    await dbHelper.db.insert('attendance_records', {
      'lesson_id': lessonId,
      'student_id': studentId,
      'status': 'present',
      'recorded_at': now,
    });
    // Attempt to delete student, should fail due to RESTRICT
    try {
      await dbHelper.db.delete('students', where: 'id = ?', whereArgs: [studentId]);
      fail('Student deletion should have been restricted');
    } catch (e) {
      expect(e, isA<DatabaseException>());
    }
  });


  test('Insert student succeeds and enforces unique id', () async {
    // Insert a student
    int now = DateTime.now().millisecondsSinceEpoch;
    int id = await dbHelper.db.insert('students', {
      'name': 'John Doe',
      'grade': '10',
      'created_at': now,
      'updated_at': now,
    });
    expect(id, isPositive);

    // Attempt duplicate insert with same primary key (should fail)
    try {
      await dbHelper.db.insert('students', {
        'id': id,
        'name': 'Jane',
        'grade': '10',
        'created_at': now,
        'updated_at': now,
      });
      fail('Duplicate primary key insertion should have thrown');
    } catch (e) {
      expect(e, isA<DatabaseException>());
    }
  });

}
