// lib/core/database/migrations.dart
class Migrations {
  static const String createStudents = '''
CREATE TABLE IF NOT EXISTS students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  grade TEXT NOT NULL,
  phone TEXT,
  age INTEGER,
  guardian_phone TEXT,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  archived_at INTEGER
);
''';

  static const String createGroups = '''
CREATE TABLE IF NOT EXISTS groups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  target_grade TEXT NOT NULL,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
''';

  static const String createGroupStudents = '''
CREATE TABLE IF NOT EXISTS group_students (
  group_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,
  enrolled_at INTEGER NOT NULL,
  PRIMARY KEY (group_id, student_id),
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE RESTRICT
);
''';

  static const String createGroupSchedules = '''
CREATE TABLE IF NOT EXISTS group_schedules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  group_id INTEGER NOT NULL,
  weekday INTEGER NOT NULL,
  start_time TEXT,
  end_time TEXT,
  active INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
);
''';

  static const String createLessons = '''
CREATE TABLE IF NOT EXISTS lessons (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  group_id INTEGER NOT NULL,
  scheduled_date INTEGER NOT NULL,
  start_time TEXT,
  end_time TEXT,
  is_manual INTEGER NOT NULL DEFAULT 0,
  is_canceled INTEGER NOT NULL DEFAULT 0,
  cancellation_reason TEXT,
  UNIQUE (group_id, scheduled_date, start_time),
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE
);
''';

  static const String createAttendanceRecords = '''
CREATE TABLE IF NOT EXISTS attendance_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lesson_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,
  status TEXT NOT NULL,
  recorded_at INTEGER NOT NULL,
  UNIQUE (lesson_id, student_id),
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE RESTRICT
);
''';

  static const String createAppSettings = '''
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
''';
}
