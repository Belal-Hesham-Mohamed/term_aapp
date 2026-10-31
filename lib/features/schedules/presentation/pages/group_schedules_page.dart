import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/group_schedule.dart';
import '../cubit/schedule_cubit.dart';
import '../state/schedule_state.dart';
import 'schedule_form_page.dart';

class GroupSchedulesPage extends StatelessWidget {
  final int groupId;
  const GroupSchedulesPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ScheduleCubit>()..loadSchedules(groupId),
    child: _SchedulesView(groupId: groupId),
  );
}

class _SchedulesView extends StatelessWidget {
  final int groupId;
  const _SchedulesView({required this.groupId});

  Future<void> _form(BuildContext context, {GroupSchedule? schedule}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleFormPage(groupId: groupId, schedule: schedule),
      ),
    );
    if (saved == true && context.mounted) {
      context.read<ScheduleCubit>().loadSchedules(groupId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupSchedules)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _form(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ScheduleFailure) {
            return Center(
              child: Text('${l10n.error}: ${l10n.scheduleLoadFailed}'),
            );
          }
          if (state is! ScheduleLoaded) return const SizedBox.shrink();
          if (state.schedules.isEmpty) {
            return Center(child: Text(l10n.noSchedules));
          }
          return ListView.builder(
            itemCount: state.schedules.length,
            itemBuilder: (context, index) {
              final schedule = state.schedules[index];
              return ListTile(
                title: Text(
                  '${_weekday(l10n, schedule.weekday)} | ${schedule.startTime}–${schedule.endTime}',
                ),
                subtitle: Text(
                  schedule.active ? l10n.scheduleActive : l10n.scheduleInactive,
                ),
                onTap: () => _form(context, schedule: schedule),
                trailing: IconButton(
                  tooltip: l10n.removeSchedule,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l10n.removeSchedule),
                        content: Text(l10n.removeScheduleConfirm),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: Text(l10n.removeSchedule),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<ScheduleCubit>().removeSchedule(
                        schedule.id,
                        groupId,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _weekday(AppLocalizations l10n, int weekday) => switch (weekday) {
  1 => l10n.monday,
  2 => l10n.tuesday,
  3 => l10n.wednesday,
  4 => l10n.thursday,
  5 => l10n.friday,
  6 => l10n.saturday,
  _ => l10n.sunday,
};
