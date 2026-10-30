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
      // SQLite throws DatabaseException for constraint failures
      expect(e, isA<DatabaseException>());
    }
  });
}
