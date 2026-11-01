import 'lesson_record.dart';

enum LessonFilter { today, thisWeek, schedule }

class LessonFilterRules {
  static List<LessonRecord> apply(
    Iterable<LessonRecord> source, {
    required LessonFilter filter,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final todayEnd = today.add(const Duration(days: 1));
    // The app is used in Egypt, where the calendar week starts on Saturday.
    final weekStart = today.subtract(Duration(days: (today.weekday + 1) % 7));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final nowTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final unique = <int, LessonRecord>{
      for (final lesson in source) lesson.id: lesson,
    };
    final filtered = unique.values.where((lesson) {
      final date = DateTime.fromMillisecondsSinceEpoch(lesson.scheduledDate);
      switch (filter) {
        case LessonFilter.today:
          return !date.isBefore(today) && date.isBefore(todayEnd);
        case LessonFilter.thisWeek:
          return !date.isBefore(weekStart) && date.isBefore(weekEnd);
        case LessonFilter.schedule:
          if (lesson.isCanceled ||
              lesson.startTime == null ||
              lesson.endTime == null) {
            return false;
          }
          if (!_validTimeRange(lesson.startTime!, lesson.endTime!)) {
            return false;
          }
          final day = DateTime(date.year, date.month, date.day);
          return !day.isBefore(today) &&
              day.isBefore(today.add(const Duration(days: 30))) &&
              (day.isAfter(today) || lesson.startTime!.compareTo(nowTime) >= 0);
      }
    }).toList();
    filtered.sort((a, b) {
      final dateOrder = a.scheduledDate.compareTo(b.scheduledDate);
      if (dateOrder != 0) return dateOrder;
      final timeOrder = (a.startTime ?? '').compareTo(b.startTime ?? '');
      return timeOrder != 0 ? timeOrder : a.id.compareTo(b.id);
    });
    return filtered;
  }

  static bool _validTimeRange(String start, String end) {
    final startParts = start.split(':');
    final endParts = end.split(':');
    if (startParts.length != 2 || endParts.length != 2) return false;
    final startHour = int.tryParse(startParts[0]);
    final startMinute = int.tryParse(startParts[1]);
    final endHour = int.tryParse(endParts[0]);
    final endMinute = int.tryParse(endParts[1]);
    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null ||
        startHour > 23 ||
        endHour > 23 ||
        startMinute > 59 ||
        endMinute > 59) {
      return false;
    }
    return startHour * 60 + startMinute < endHour * 60 + endMinute;
  }
}
