import '../entities/group_schedule.dart';

abstract class ScheduleRepository {
  Future<List<GroupSchedule>> getSchedules(int groupId);
  Future<int> createSchedule(GroupSchedule schedule);
  Future<void> updateSchedule(GroupSchedule schedule);
  Future<bool> removeSchedule(int scheduleId);
}

class ScheduleConflictException implements Exception {}
