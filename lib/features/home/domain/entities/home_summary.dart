import '../../../lessons/domain/entities/lesson_record.dart';

class HomeSummary {
  final String? teacherName;
  final List<LessonRecord> todaysLessons;
  final int totalGroups;
  final int totalStudents;
  final int lessonsThisWeek;

  HomeSummary({
    required this.teacherName,
    required List<LessonRecord> todaysLessons,
    required this.totalGroups,
    required this.totalStudents,
    required this.lessonsThisWeek,
  }) : todaysLessons = List.unmodifiable(todaysLessons);
}
