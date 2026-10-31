import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/lesson_record.dart';
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

class _LessonsList extends StatelessWidget {
  final int? groupId;
  const _LessonsList({this.groupId});

  Future<void> _create(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => LessonFormPage(groupId: groupId)),
    );
    if (result == true && context.mounted) {
      context.read<LessonCubit>().loadLessons(groupId: groupId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(groupId == null ? l10n.lessons : l10n.groupLessons),
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
          if (state.lessons.isEmpty) return Center(child: Text(l10n.noLessons));
          return ListView.builder(
            itemCount: state.lessons.length,
            itemBuilder: (context, index) =>
                _lessonTile(context, state.lessons[index]),
          );
        },
      ),
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
      title: Text(groupId == null ? '${lesson.groupName} | $date' : date),
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
          context.read<LessonCubit>().loadLessons(groupId: groupId);
        }
      },
    );
  }
}
