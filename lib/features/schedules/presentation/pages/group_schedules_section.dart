import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/schedule_cubit.dart';
import '../state/schedule_state.dart';
import 'group_schedules_page.dart';

class GroupSchedulesSection extends StatelessWidget {
  final int groupId;
  const GroupSchedulesSection({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ScheduleCubit>()..loadSchedules(groupId),
    child: _SchedulePreview(groupId: groupId),
  );
}

class _SchedulePreview extends StatelessWidget {
  final int groupId;
  const _SchedulePreview({required this.groupId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(l10n.groupSchedules),
              trailing: TextButton(
                onPressed: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupSchedulesPage(groupId: groupId),
                    ),
                  );
                  if (context.mounted) {
                    context.read<ScheduleCubit>().loadSchedules(groupId);
                  }
                },
                child: Text(l10n.manage),
              ),
            ),
            if (state is ScheduleLoading)
              const LinearProgressIndicator()
            else if (state is ScheduleFailure)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(l10n.scheduleLoadFailed),
              )
            else if (state is ScheduleLoaded && state.schedules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(l10n.noSchedules),
              )
            else if (state is ScheduleLoaded)
              ...state.schedules.map(
                (schedule) => ListTile(
                  dense: true,
                  title: Text(
                    '${_weekday(l10n, schedule.weekday)} | ${schedule.startTime}–${schedule.endTime}',
                  ),
                  subtitle: Text(
                    schedule.active
                        ? l10n.scheduleActive
                        : l10n.scheduleInactive,
                  ),
                ),
              ),
          ],
        );
      },
    );
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
}
