import '../entities/attendance_entry.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntry>> getLessonRoster(int lessonId);
  Future<void> saveAttendance(int lessonId, Map<int, String> statuses);
}
