import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:term/core/database/database_helper.dart';
import 'package:term/core/database/migrations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'version 1 student migration preserves records and historical relations',
    () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, _) async {
          await db.execute(
            '''CREATE TABLE students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, grade TEXT NOT NULL, phone TEXT, age INTEGER, guardian_phone TEXT, notes TEXT, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, archived_at INTEGER)''',
          );
          await db.execute(Migrations.createGroups);
          await db.execute(Migrations.createGroupStudents);
          await db.execute(Migrations.createGroupSchedules);
          await db.execute(Migrations.createLessons);
          await db.execute(Migrations.createAttendanceRecords);
          await db.insert('students', {
            'id': 41,
            'name': 'Legacy Arabic Full Name',
            'grade': 'Grade 7',
            'phone': '01012345678',
            'age': 12,
            'guardian_phone': '01112345678',
            'notes': 'keep',
            'created_at': 1,
            'updated_at': 2,
          });
          await db.insert('groups', {
            'id': 5,
            'name': 'Group',
            'target_grade': 'Grade 7',
            'created_at': 1,
            'updated_at': 1,
          });
          await db.insert('group_students', {
            'group_id': 5,
            'student_id': 41,
            'enrolled_at': 1,
          });
          await db.insert('group_schedules', {
            'id': 6,
            'group_id': 5,
            'weekday': 1,
          });
          await db.insert('lessons', {
            'id': 7,
            'group_id': 5,
            'scheduled_date': 1,
          });
          await db.insert('attendance_records', {
            'lesson_id': 7,
            'student_id': 41,
            'status': 'present',
            'recorded_at': 2,
          });
        },
      );
      await DatabaseHelper.migrate(db, 1, 2);
      final student = (await db.query('students')).single;
      expect(student['id'], 41);
      expect(student['name'], 'Legacy Arabic Full Name');
      expect(student['first_name'], isNull);
      expect(student['phone'], '01012345678');
      expect((await db.query('group_students')).single['student_id'], 41);
      expect((await db.query('group_schedules')).single['id'], 6);
      expect((await db.query('lessons')).single['id'], 7);
      expect((await db.query('attendance_records')).single['student_id'], 41);
      await db.close();
    },
  );

  test(
    'version 1 partially migrated student schema skips existing columns',
    () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, _) async {
          await db.execute(
            '''CREATE TABLE students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, grade TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, first_name TEXT)''',
          );
          await db.insert('students', {
            'name': 'Existing student',
            'grade': 'primary_1',
            'created_at': 1,
            'updated_at': 1,
            'first_name': 'Existing',
          });
        },
      );
      await DatabaseHelper.migrate(db, 1, 2);
      final columns = (await db.rawQuery(
        'PRAGMA table_info(students)',
      )).map((row) => row['name']).toSet();
      expect(
        columns,
        containsAll([
          'first_name',
          'father_name',
          'family_name',
          'duplicate_index',
        ]),
      );
      final student = (await db.query('students')).single;
      expect(student['name'], 'Existing student');
      expect(student['first_name'], 'Existing');
      expect(student['duplicate_index'], 1);
      await db.close();
    },
  );
}
