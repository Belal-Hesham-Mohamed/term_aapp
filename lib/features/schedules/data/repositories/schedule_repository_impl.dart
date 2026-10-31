import '../../domain/entities/group_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_local_datasource.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleLocalDataSource dataSource;
  ScheduleRepositoryImpl(this.dataSource);

  @override
  Future<List<GroupSchedule>> getSchedules(int groupId) =>
      dataSource.getSchedules(groupId);
  @override
  Future<int> createSchedule(GroupSchedule schedule) =>
      dataSource.createSchedule(schedule);
  @override
  Future<void> updateSchedule(GroupSchedule schedule) =>
      dataSource.updateSchedule(schedule);
  @override
  Future<bool> removeSchedule(int scheduleId) =>
      dataSource.removeSchedule(scheduleId);
}
