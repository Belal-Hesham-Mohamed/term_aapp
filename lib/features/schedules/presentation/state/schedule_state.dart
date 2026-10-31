import '../../domain/entities/group_schedule.dart';

abstract class ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<GroupSchedule> schedules;
  ScheduleLoaded(this.schedules);
}

class ScheduleFailure extends ScheduleState {
  final String message;
  ScheduleFailure(this.message);
}
