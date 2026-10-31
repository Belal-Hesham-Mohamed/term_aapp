import '../../domain/entities/lesson_record.dart';

abstract class LessonState {}

class LessonLoading extends LessonState {}

class LessonListLoaded extends LessonState {
  final List<LessonRecord> lessons;
  LessonListLoaded(this.lessons);
}

class LessonDetailsLoaded extends LessonState {
  final LessonRecord lesson;
  LessonDetailsLoaded(this.lesson);
}

class LessonFailure extends LessonState {
  final String message;
  LessonFailure(this.message);
}
