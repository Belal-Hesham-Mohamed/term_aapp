import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/attendance_cubit.dart';
import '../state/attendance_state.dart';

class LessonAttendancePage extends StatelessWidget {
  final int lessonId;
  const LessonAttendancePage({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AttendanceCubit>()..loadAttendance(lessonId),
    child: _AttendanceView(lessonId: lessonId),
  );
}

class _AttendanceView extends StatelessWidget {
  final int lessonId;
  const _AttendanceView({required this.lessonId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.attendance)),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AttendanceFailure) {
            return Center(
              child: Text('${l10n.error}: ${l10n.attendanceLoadFailed}'),
            );
          }
          if (state is! AttendanceLoaded) return const SizedBox.shrink();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Text('${l10n.present}: ${state.presentCount}'),
                    Text('${l10n.absent}: ${state.absentCount}'),
                    Text('${l10n.notMarked}: ${state.unmarkedCount}'),
                  ],
                ),
              ),
              if (state.saveError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    l10n.attendanceSaveFailed,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: state.entries.isEmpty
                    ? Center(child: Text(l10n.noAttendanceStudents))
                    : ListView.builder(
                        itemCount: state.entries.length,
                        itemBuilder: (context, index) {
                          final entry = state.entries[index];
                          return ListTile(
                            title: Text(entry.student.name),
                            subtitle: Text(
                              '${l10n.grade}: ${entry.student.grade}',
                            ),
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                ChoiceChip(
                                  label: Text(l10n.present),
                                  selected: entry.status == 'present',
                                  onSelected: (_) => context
                                      .read<AttendanceCubit>()
                                      .setStatus(entry.student.id, 'present'),
                                ),
                                ChoiceChip(
                                  label: Text(l10n.absent),
                                  selected: entry.status == 'absent',
                                  onSelected: (_) => context
                                      .read<AttendanceCubit>()
                                      .setStatus(entry.student.id, 'absent'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final saved = await context
                            .read<AttendanceCubit>()
                            .saveAttendance(lessonId);
                        if (saved && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.attendanceSaved)),
                          );
                        }
                      },
                      child: Text(l10n.saveAttendance),
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
