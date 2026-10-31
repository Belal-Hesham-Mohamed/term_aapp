import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/lesson_record.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../state/lesson_state.dart';

class LessonCubit extends Cubit<LessonState> {
  final LessonRepository repository;
  int _requestId = 0;
  bool _saving = false;

  LessonCubit(this.repository) : super(LessonLoading());

  Future<void> loadLessons({int? groupId}) async {
    final requestId = ++_requestId;
    try {
      final lessons = await repository.getLessons(groupId: groupId);
      if (!isClosed && requestId == _requestId) emit(LessonListLoaded(lessons));
    } catch (error) {
      if (!isClosed && requestId == _requestId) {
        emit(LessonFailure(error.toString()));
      }
    }
  }

  Future<void> loadLesson(int lessonId) async {
    emit(LessonLoading());
    try {
      final lesson = await repository.getLesson(lessonId);
      if (!isClosed) emit(LessonDetailsLoaded(lesson));
    } catch (error) {
      if (!isClosed) emit(LessonFailure(error.toString()));
    }
  }

  Future<bool> saveLesson({
    LessonRecord? existing,
    required int groupId,
    required DateTime scheduledDate,
    required String startTime,
    required String endTime,
    required bool isCanceled,
    String? cancellationReason,
  }) async {
    if (_saving) return false;
    if (groupId <= 0 ||
        !_isTime(startTime) ||
        !_isTime(endTime) ||
        _minutes(startTime)! >= _minutes(endTime)!) {
      emit(LessonFailure('invalidFields'));
      return false;
    }
    _saving = true;
    try {
      final date = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );
      final lesson = LessonRecord(
        id: existing?.id ?? 0,
        groupId: existing?.groupId ?? groupId,
        groupName: existing?.groupName ?? '',
        scheduledDate: date.millisecondsSinceEpoch,
        startTime: startTime,
        endTime: endTime,
        isManual: existing?.isManual ?? true,
        isCanceled: isCanceled,
        cancellationReason: cancellationReason,
      );
      if (existing == null) {
        await repository.createLesson(lesson);
      } else {
        await repository.updateLesson(lesson);
      }
      await loadLessons(groupId: existing?.groupId ?? groupId);
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          LessonFailure(
            error is DuplicateLessonException ? 'duplicate' : error.toString(),
          ),
        );
      }
      return false;
    } finally {
      _saving = false;
    }
  }

  bool _isTime(String value) => _minutes(value) != null;
  int? _minutes(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) return null;
    return hour * 60 + minute;
  }
}
