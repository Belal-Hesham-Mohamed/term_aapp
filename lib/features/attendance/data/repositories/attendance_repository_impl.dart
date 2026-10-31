import '../../domain/entities/attendance_entry.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource dataSource;
  AttendanceRepositoryImpl(this.dataSource);

  @override
  Future<List<AttendanceEntry>> getLessonRoster(int lessonId) =>
      dataSource.getLessonRoster(lessonId);
  @override
  Future<void> saveAttendance(int lessonId, Map<int, String> statuses) =>
      dataSource.saveAttendance(lessonId, statuses);
}
