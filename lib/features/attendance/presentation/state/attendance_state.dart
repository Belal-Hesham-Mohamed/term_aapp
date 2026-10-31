import '../../domain/entities/attendance_entry.dart';

abstract class AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceEntry> entries;
  final String? saveError;
  AttendanceLoaded(this.entries, {this.saveError});
  int get presentCount =>
      entries.where((entry) => entry.status == 'present').length;
  int get absentCount =>
      entries.where((entry) => entry.status == 'absent').length;
  int get unmarkedCount =>
      entries.where((entry) => entry.status == null).length;
}

class AttendanceFailure extends AttendanceState {
  final String message;
  AttendanceFailure(this.message);
}
