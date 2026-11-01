import '../../../../core/database/database_helper.dart';

class HomeLocalDataSource {
  static const teacherNameKey = 'teacher_name';

  final DatabaseHelper dbHelper;
  HomeLocalDataSource(this.dbHelper);

  Future<String?> getTeacherName() async {
    final rows = await dbHelper.db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [teacherNameKey],
      limit: 1,
    );
    final name = rows.isEmpty
        ? null
        : (rows.single['value'] as String?)?.trim();
    return name == null || name.isEmpty ? null : name;
  }
}
