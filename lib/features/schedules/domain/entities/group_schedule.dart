class GroupSchedule {
  final int id;
  final int groupId;
  final int weekday;
  final String startTime;
  final String endTime;
  final bool active;

  const GroupSchedule({
    required this.id,
    required this.groupId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.active,
  });

  factory GroupSchedule.fromMap(Map<String, Object?> map) => GroupSchedule(
    id: map['id'] as int,
    groupId: map['group_id'] as int,
    weekday: map['weekday'] as int,
    startTime: map['start_time'] as String? ?? '',
    endTime: map['end_time'] as String? ?? '',
    active: (map['active'] as int? ?? 1) == 1,
  );
}
