import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/lesson_cubit.dart';
import '../state/lesson_state.dart';
import 'lesson_form_page.dart';
import '../../../attendance/presentation/pages/lesson_attendance_page.dart';

class LessonDetailsPage extends StatelessWidget {
  final int lessonId;
  const LessonDetailsPage({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<LessonCubit>()..loadLesson(lessonId),
    child: _LessonDetailsView(lessonId: lessonId),
  );
}

class _LessonDetailsView extends StatelessWidget {
  final int lessonId;
  const _LessonDetailsView({required this.lessonId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lessonDetails),
        actions: [
          IconButton(
            tooltip: l10n.editLesson,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final state = context.read<LessonCubit>().state;
              if (state is LessonDetailsLoaded) {
                final saved = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonFormPage(lesson: state.lesson),
                  ),
                );
                if (saved == true && context.mounted) {
                  context.read<LessonCubit>().loadLesson(lessonId);
                }
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<LessonCubit, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LessonFailure) {
            return Center(
              child: Text('${l10n.error}: ${l10n.lessonLoadFailed}'),
            );
          }
          if (state is! LessonDetailsLoaded) return const SizedBox.shrink();
          final lesson = state.lesson;
          final date = DateFormat.yMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(DateTime.fromMillisecondsSinceEpoch(lesson.scheduledDate));
          return ListView(
            children: [
              ListTile(
                title: Text(l10n.group),
                subtitle: Text(lesson.groupName),
              ),
              ListTile(title: Text(l10n.lessonDate), subtitle: Text(date)),
              ListTile(
                title: Text(l10n.lessonTime),
                subtitle: Text(
                  '${lesson.startTime ?? ''}–${lesson.endTime ?? ''}',
                ),
              ),
              ListTile(
                title: Text(l10n.lessonStatus),
                subtitle: Text(
                  lesson.isCanceled
                      ? l10n.lessonCanceled
                      : l10n.lessonScheduled,
                ),
              ),
              if (lesson.cancellationReason?.isNotEmpty == true)
                ListTile(
                  title: Text(l10n.cancellationReason),
                  subtitle: Text(lesson.cancellationReason!),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.fact_check_outlined),
                  label: Text(l10n.takeAttendance),
                  onPressed: lesson.isCanceled
                      ? null
                      : () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LessonAttendancePage(lessonId: lesson.id),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
