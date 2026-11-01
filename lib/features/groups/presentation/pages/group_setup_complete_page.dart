import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../schedules/presentation/cubit/schedule_cubit.dart';
import '../../../schedules/presentation/state/schedule_state.dart';
import '../../../students/presentation/student_labels.dart';
import '../../domain/entities/group_setup_outcome.dart';
import '../cubit/group_cubit.dart';
import '../state/group_state.dart';

class GroupSetupCompletePage extends StatelessWidget {
  final int groupId;
  const GroupSetupCompletePage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => getIt<GroupCubit>()..loadDetails(groupId)),
      BlocProvider(
        create: (_) => getIt<ScheduleCubit>()..loadSchedules(groupId),
      ),
    ],
    child: _GroupSetupCompleteContent(groupId: groupId),
  );
}

class _GroupSetupCompleteContent extends StatelessWidget {
  final int groupId;
  const _GroupSetupCompleteContent({required this.groupId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupSetupComplete)),
      body: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, groupState) =>
            BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, scheduleState) {
                if (groupState is GroupFailure ||
                    scheduleState is ScheduleFailure) {
                  return Center(
                    child: Text('${l10n.error}: ${l10n.groupLoadFailed}'),
                  );
                }
                if (groupState is! GroupDetailsLoaded ||
                    scheduleState is! ScheduleLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      groupState.group.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    ListTile(
                      title: Text(l10n.targetGrade),
                      subtitle: Text(
                        localizedGrade(l10n, groupState.group.targetGrade),
                      ),
                    ),
                    ListTile(
                      title: Text(l10n.configuredSchedules),
                      subtitle: Text('${scheduleState.schedules.length}'),
                    ),
                    ListTile(
                      title: Text(l10n.enrolledStudentCount),
                      subtitle: Text('${groupState.students.length}'),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.pop(
                        context,
                        GroupSetupOutcome(
                          groupId: groupId,
                          completed: true,
                          openGroupDetails: true,
                        ),
                      ),
                      child: Text(l10n.openGroupDetails),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(
                        context,
                        GroupSetupOutcome(groupId: groupId, completed: true),
                      ),
                      child: Text(l10n.done),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}
