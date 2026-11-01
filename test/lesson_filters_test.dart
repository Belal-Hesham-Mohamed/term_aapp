import 'package:flutter_test/flutter_test.dart';
import 'package:term/features/lessons/domain/entities/lesson_filter.dart';
import 'package:term/features/lessons/domain/entities/lesson_record.dart';

void main() {
  final now = DateTime(2026, 3, 4, 10, 0); // Wednesday
  LessonRecord lesson(
    int id,
    DateTime date,
    String? start,
    String? end, {
    bool canceled = false,
  }) => LessonRecord(
    id: id,
    groupId: id,
    groupName: 'Group $id',
    scheduledDate: date.millisecondsSinceEpoch,
    startTime: start,
    endTime: end,
    isManual: true,
    isCanceled: canceled,
    cancellationReason: null,
  );

  test('today compares local calendar dates and sorts by start time', () {
    final later = lesson(2, DateTime(2026, 3, 4, 23, 30), '17:00', '18:00');
    final earlier = lesson(1, DateTime(2026, 3, 4), '09:00', '10:00');
    final yesterday = lesson(3, DateTime(2026, 3, 3, 23, 59), '12:00', '13:00');
    final result = LessonFilterRules.apply(
      [later, earlier, yesterday],
      filter: LessonFilter.today,
      now: now,
    );
    expect(result.map((item) => item.id), [1, 2]);
  });

  test('this week is Saturday through the following Friday', () {
    final result = LessonFilterRules.apply(
      [
        lesson(1, DateTime(2026, 2, 27), '10:00', '11:00'), // Friday before
        lesson(2, DateTime(2026, 2, 28), '10:00', '11:00'), // Saturday start
        lesson(3, DateTime(2026, 3, 6), '10:00', '11:00'), // Friday end
        lesson(4, DateTime(2026, 3, 7), '10:00', '11:00'), // next Saturday
      ],
      filter: LessonFilter.thisWeek,
      now: now,
    );
    expect(result.map((item) => item.id), [2, 3]);
  });

  test(
    'schedule excludes canceled, past, and invalid lessons and deduplicates',
    () {
      final upcoming = lesson(1, DateTime(2026, 3, 4), '11:00', '12:00');
      final result = LessonFilterRules.apply(
        [
          upcoming,
          upcoming,
          lesson(2, DateTime(2026, 3, 4), '09:00', '10:00'),
          lesson(3, DateTime(2026, 3, 5), '11:00', '12:00', canceled: true),
          lesson(4, DateTime(2026, 3, 5), null, '12:00'),
          lesson(5, DateTime(2026, 3, 5), '12:00', '11:00'),
        ],
        filter: LessonFilter.schedule,
        now: now,
      );
      expect(result.map((item) => item.id), [1]);
    },
  );
}
