import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../lessons/domain/entities/lesson_record.dart';
import '../../domain/entities/home_date_rules.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../state/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;
  final DateTime Function() clock;
  int _requestId = 0;

  HomeCubit(this.repository, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now,
      super(HomeInitial());

  Future<void> loadSummary() async {
    final requestId = ++_requestId;
    emit(HomeLoading());
    try {
      final now = clock();
      final weekStart = HomeDateRules.weekStart(now);
      final weekEnd = HomeDateRules.weekEndExclusive(now);
      final results = await Future.wait<Object?>([
        repository.getTeacherName(),
        repository.getLessonsForDate(now),
        repository.countGroups(),
        repository.countStudents(),
        repository.countLessonsInRange(weekStart, weekEnd),
      ]);
      if (isClosed || requestId != _requestId) return;
      emit(
        HomeLoaded(
          HomeSummary(
            teacherName: results[0] as String?,
            todaysLessons: results[1] as List<LessonRecord>,
            totalGroups: results[2] as int,
            totalStudents: results[3] as int,
            lessonsThisWeek: results[4] as int,
          ),
        ),
      );
    } catch (error) {
      if (!isClosed && requestId == _requestId) {
        emit(HomeFailure(error.toString()));
      }
    }
  }
}
