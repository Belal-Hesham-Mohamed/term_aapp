import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/group_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../state/schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository repository;
  ScheduleCubit(this.repository) : super(ScheduleLoading());

  Future<void> loadSchedules(int groupId) async {
    try {
      emit(ScheduleLoaded(await repository.getSchedules(groupId)));
    } catch (error) {
      if (!isClosed) emit(ScheduleFailure(error.toString()));
    }
  }

  Future<bool> saveSchedule({
    GroupSchedule? existing,
    required int groupId,
    required int weekday,
    required String startTime,
    required String endTime,
    required bool active,
  }) async {
    final start = _minutes(startTime);
    final end = _minutes(endTime);
    if (weekday < 1 ||
        weekday > 7 ||
        start == null ||
        end == null ||
        start >= end) {
      emit(ScheduleFailure('invalidTime'));
      return false;
    }
    try {
      final schedule = GroupSchedule(
        id: existing?.id ?? 0,
        groupId: groupId,
        weekday: weekday,
        startTime: startTime,
        endTime: endTime,
        active: active,
      );
      if (existing == null) {
        await repository.createSchedule(schedule);
      } else {
        await repository.updateSchedule(schedule);
      }
      await loadSchedules(groupId);
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          ScheduleFailure(
            error is ScheduleConflictException ? 'conflict' : error.toString(),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> removeSchedule(int scheduleId, int groupId) async {
    try {
      await repository.removeSchedule(scheduleId);
      await loadSchedules(groupId);
      return true;
    } catch (error) {
      if (!isClosed) emit(ScheduleFailure(error.toString()));
      return false;
    }
  }

  int? _minutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }
}
