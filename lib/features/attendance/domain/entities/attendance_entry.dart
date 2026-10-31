import '../../../students/domain/entities/student.dart';

class AttendanceEntry {
  final Student student;
  final String? status;
  final int? recordedAt;

  const AttendanceEntry({required this.student, this.status, this.recordedAt});

  factory AttendanceEntry.fromMap(Map<String, Object?> map) => AttendanceEntry(
    student: Student.fromMap(map),
    status: map['attendance_status'] as String?,
    recordedAt: map['attendance_recorded_at'] as int?,
  );

  AttendanceEntry withStatus(String? value) =>
      AttendanceEntry(student: student, status: value, recordedAt: recordedAt);
}
