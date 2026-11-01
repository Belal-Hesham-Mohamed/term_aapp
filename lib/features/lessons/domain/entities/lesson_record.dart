class LessonRecord {
  final int id;
  final int groupId;
  final String groupName;
  final String groupGrade;
  final int scheduledDate;
  final String? startTime;
  final String? endTime;
  final bool isManual;
  final bool isCanceled;
  final String? cancellationReason;

  const LessonRecord({
    required this.id,
    required this.groupId,
    required this.groupName,
    this.groupGrade = '',
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.isManual,
    required this.isCanceled,
    required this.cancellationReason,
  });

  factory LessonRecord.fromMap(Map<String, Object?> map) => LessonRecord(
    id: map['id'] as int,
    groupId: map['group_id'] as int,
    groupName: map['group_name'] as String? ?? '',
    groupGrade: map['group_grade'] as String? ?? '',
    scheduledDate: map['scheduled_date'] as int,
    startTime: map['start_time'] as String?,
    endTime: map['end_time'] as String?,
    isManual: (map['is_manual'] as int? ?? 0) == 1,
    isCanceled: (map['is_canceled'] as int? ?? 0) == 1,
    cancellationReason: map['cancellation_reason'] as String?,
  );
}
