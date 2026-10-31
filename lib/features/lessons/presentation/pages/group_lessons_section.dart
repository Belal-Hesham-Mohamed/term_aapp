import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/lesson_cubit.dart';
import '../state/lesson_state.dart';
import 'lessons_page.dart';
import 'lesson_details_page.dart';
import 'lesson_form_page.dart';

class GroupLessonsSection extends StatelessWidget {
  final int groupId;
  const GroupLessonsSection({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<LessonCubit>()..loadUpcomingLessons(groupId: groupId),
    child: _GroupLessonPreview(groupId: groupId),
  );
}

class _GroupLessonPreview extends StatelessWidget {
  final int groupId;
  const _GroupLessonPreview({required this.groupId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<LessonCubit, LessonState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(l10n.upcomingLessons),
            trailing: Wrap(
              children: [
                IconButton(
                  tooltip: l10n.addExceptionalLesson,
                  onPressed: () async {
                    final saved = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonFormPage(groupId: groupId),
                      ),
                    );
                    if (saved == true && context.mounted) {
                      context.read<LessonCubit>().loadUpcomingLessons(
                        groupId: groupId,
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupLessonsPage(groupId: groupId),
                      ),
                    );
                    if (context.mounted) {
                      context.read<LessonCubit>().loadUpcomingLessons(
                        groupId: groupId,
                      );
                    }
                  },
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
          ),
          if (state is LessonLoading)
            const LinearProgressIndicator()
          else if (state is LessonFailure)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(l10n.lessonLoadFailed),
            )
          else if (state is LessonListLoaded && state.lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(l10n.noUpcomingLessons),
            )
          else if (state is LessonListLoaded)
            ...state.lessons
                .take(3)
                .map(
                  (lesson) => ListTile(
                    dense: true,
                    title: Text(
                      '${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(DateTime.fromMillisecondsSinceEpoch(lesson.scheduledDate))} | ${lesson.startTime ?? ''} - ${lesson.endTime ?? ''}',
                    ),
                    subtitle: Text(
                      lesson.isCanceled
                          ? l10n.lessonCanceled
                          : l10n.lessonScheduled,
                    ),
                    onTap: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LessonDetailsPage(lessonId: lesson.id),
                        ),
                      );
                      if (context.mounted) {
                        context.read<LessonCubit>().loadUpcomingLessons(
                          groupId: groupId,
                        );
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
