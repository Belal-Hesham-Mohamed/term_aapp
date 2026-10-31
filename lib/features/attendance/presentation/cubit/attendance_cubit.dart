import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/attendance_repository.dart';
import '../state/attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository repository;
  bool _saving = false;

  AttendanceCubit(this.repository) : super(AttendanceLoading());

  Future<void> loadAttendance(int lessonId) async {
    try {
      emit(AttendanceLoaded(await repository.getLessonRoster(lessonId)));
    } catch (error) {
      if (!isClosed) emit(AttendanceFailure(error.toString()));
    }
  }

  void setStatus(int studentId, String? status) {
    final current = state;
    if (current is! AttendanceLoaded) return;
    final updated = current.entries
        .map(
          (entry) =>
              entry.student.id == studentId ? entry.withStatus(status) : entry,
        )
        .toList();
    emit(AttendanceLoaded(updated));
  }

  Future<bool> saveAttendance(int lessonId) async {
    if (_saving) return false;
    final current = state;
    if (current is! AttendanceLoaded) return false;
    _saving = true;
    try {
      final values = <int, String>{
        for (final entry in current.entries)
          if (entry.status != null) entry.student.id: entry.status!,
      };
      await repository.saveAttendance(lessonId, values);
      await loadAttendance(lessonId);
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(AttendanceLoaded(current.entries, saveError: error.toString()));
      }
      return false;
    } finally {
      _saving = false;
    }
  }
}
