import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../lessons/presentation/pages/lesson_details_page.dart';
import '../cubit/home_cubit.dart';
import '../state/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<HomeCubit>()..loadSummary(),
    child: const _HomeContent(),
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.home)),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeFailure) {
            return Center(child: Text('${l10n.error}: ${l10n.homeLoadFailed}'));
          }
          if (state is! HomeLoaded) return const SizedBox.shrink();
          final summary = state.summary;
          final teacher = summary.teacherName ?? l10n.teacherNameFallback;
          final dateFormat = DateFormat.yMMMd(locale);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.welcomeBack(teacher)),
              Text(l10n.homeOverviewSubtitle),
              const SizedBox(height: 20),
              Text(l10n.todaysLessons),
              if (summary.todaysLessons.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l10n.noLessonsToday),
                )
              else
                ...summary.todaysLessons.map((lesson) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    lesson.scheduledDate,
                  );
                  final time = [lesson.startTime, lesson.endTime]
                      .whereType<String>()
                      .where((value) => value.isNotEmpty)
                      .join('–');
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(lesson.groupName),
                    subtitle: Text(
                      '${dateFormat.format(date)}${time.isEmpty ? '' : ' • $time'}',
                    ),
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonDetailsPage(lessonId: lesson.id),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              Text('${l10n.totalGroups}: ${summary.totalGroups}'),
              Text('${l10n.totalStudents}: ${summary.totalStudents}'),
              Text('${l10n.lessonsThisWeek}: ${summary.lessonsThisWeek}'),
            ],
          );
        },
      ),
    );
  }
}
