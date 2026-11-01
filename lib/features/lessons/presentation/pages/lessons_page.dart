import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/lesson_record.dart';
import '../../domain/entities/lesson_filter.dart';
import '../cubit/lesson_cubit.dart';
import '../state/lesson_state.dart';
import 'lesson_details_page.dart';
import 'lesson_form_page.dart';

class LessonsPage extends StatelessWidget {
  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<LessonCubit>()..loadLessons(),
    child: const _LessonsList(),
  );
}

class GroupLessonsPage extends StatelessWidget {
  final int groupId;
  const GroupLessonsPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<LessonCubit>()..loadLessons(groupId: groupId),
    child: _LessonsList(groupId: groupId),
  );
}

class _LessonsList extends StatefulWidget {
  final int? groupId;
  const _LessonsList({this.groupId});

  @override
  State<_LessonsList> createState() => _LessonsListState();
}

class _LessonsListState extends State<_LessonsList> {
  LessonFilter _filter = LessonFilter.schedule;

  Future<void> _create(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LessonFormPage(groupId: widget.groupId),
      ),
    );
    if (result == true && context.mounted) {
      _load(context);
    }
  }

  void _load(BuildContext context) {
    final cubit = context.read<LessonCubit>();
    if (widget.groupId == null) {
      cubit.loadLessons();
    } else {
      cubit.loadLessons(groupId: widget.groupId);
    }
  }

  List<LessonRecord> _filteredLessons(
    List<LessonRecord> lessons,
    DateTime now,
  ) {
    if (widget.groupId != null) return lessons;
    return LessonFilterRules.apply(lessons, filter: _filter, now: now);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupId == null ? l10n.lessons : l10n.groupLessons),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addExceptionalLesson,
        onPressed: () => _create(context),
        child: const Icon(Icons.add),
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
          if (state is! LessonListLoaded) return const SizedBox.shrink();
          final lessons = _filteredLessons(
            state.lessons,
            context.read<LessonCubit>().clock(),
          );
          if (widget.groupId == null) {
            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(l10n.today, LessonFilter.today),
                      _filterChip(l10n.thisWeek, LessonFilter.thisWeek),
                      _filterChip(l10n.schedule, LessonFilter.schedule),
                    ],
                  ),
                ),
                Expanded(child: _lessonList(context, lessons, l10n)),
              ],
            );
          }
          if (lessons.isEmpty) {
            return Center(child: Text(l10n.noLessons));
          }
          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) =>
                _lessonTile(context, lessons[index]),
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, LessonFilter filter) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _filter == filter,
      onSelected: (_) => setState(() => _filter = filter),
    ),
  );

  Widget _lessonList(
    BuildContext context,
    List<LessonRecord> lessons,
    AppLocalizations l10n,
  ) {
    if (lessons.isEmpty) {
      return Center(
        child: Text(
          _filter == LessonFilter.schedule
              ? l10n.noUpcomingLessons
              : l10n.noLessons,
        ),
      );
    }
    return ListView.builder(
      itemCount: lessons.length,
      itemBuilder: (context, index) => _filter == LessonFilter.schedule
          ? _upcomingLessonTile(context, lessons[index], isNearest: index == 0)
          : _lessonTile(context, lessons[index]),
    );
  }

  Widget _lessonTile(BuildContext context, LessonRecord lesson) {
    final l10n = AppLocalizations.of(context)!;
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(DateTime.fromMillisecondsSinceEpoch(lesson.scheduledDate));
    final time = [
      lesson.startTime,
      lesson.endTime,
    ].whereType<String>().where((value) => value.isNotEmpty).join('–');
    return ListTile(
      title: Text(
        widget.groupId == null ? '${lesson.groupName} | $date' : date,
      ),
      subtitle: Text(
        '$time${lesson.isCanceled ? ' | ${l10n.lessonCanceled}' : ''}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => LessonDetailsPage(lessonId: lesson.id),
          ),
        );
        if (context.mounted) {
          _load(context);
        }
      },
    );
  }

  Widget _upcomingLessonTile(
    BuildContext context,
    LessonRecord lesson, {
    required bool isNearest,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat(
      'EEEE, yMMMd',
      locale,
    ).format(DateTime.fromMillisecondsSinceEpoch(lesson.scheduledDate));
    final time = '${lesson.startTime}–${lesson.endTime}';
    return Card(
      color: isNearest ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(
          lesson.groupName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.grade}: ${lesson.groupGrade}'),
            Text(date),
            Text('${l10n.lessonTime}: $time'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => LessonDetailsPage(lessonId: lesson.id),
            ),
          );
          if (context.mounted) _load(context);
        },
      ),
    );
  }
}
