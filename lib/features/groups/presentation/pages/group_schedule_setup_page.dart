import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../schedules/domain/entities/group_schedule.dart';
import '../../../schedules/presentation/cubit/schedule_cubit.dart';
import '../../../schedules/presentation/pages/schedule_form_page.dart';
import '../../../schedules/presentation/state/schedule_state.dart';
import '../../domain/entities/group_setup_outcome.dart';
import '../../domain/entities/study_group.dart';
import 'student_enrollment_page.dart';

class GroupScheduleSetupPage extends StatefulWidget {
  final StudyGroup group;
  const GroupScheduleSetupPage({super.key, required this.group});

  @override
  State<GroupScheduleSetupPage> createState() => _GroupScheduleSetupPageState();
}

class _GroupScheduleSetupPageState extends State<GroupScheduleSetupPage> {
  late final ScheduleCubit _cubit;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ScheduleCubit>()..loadSchedules(widget.group.id);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _addSchedule() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleFormPage(groupId: widget.group.id),
      ),
    );
    if (saved == true && mounted) _cubit.loadSchedules(widget.group.id);
  }

  Future<void> _removeSchedule(GroupSchedule schedule) async {
    if (_removing) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeSchedule),
        content: Text(l10n.removeScheduleConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.removeSchedule),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _removing = true);
    final success = await _cubit.removeSchedule(schedule.id, widget.group.id);
    if (!mounted) return;
    setState(() => _removing = false);
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.scheduleSaveFailed)));
    }
  }

  Future<void> _continueToStudents() async {
    final state = _cubit.state;
    if (state is! ScheduleLoaded || state.schedules.isEmpty) return;
    final outcome = await Navigator.push<GroupSetupOutcome>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentEnrollmentPage(
          groupId: widget.group.id,
          targetGrade: widget.group.targetGrade,
          completeSetupOnSave: true,
        ),
      ),
    );
    if (outcome != null && mounted) Navigator.pop(context, outcome);
  }

  void _finishLater() => Navigator.pop(
    context,
    GroupSetupOutcome(groupId: widget.group.id, completed: false),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.groupScheduleSetup)),
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('${l10n.group}: ${widget.group.name}'),
                  ),
                ),
                Expanded(
                  child: state.schedules.isEmpty
                      ? Center(child: Text(l10n.groupScheduleRequired))
                      : ListView.builder(
                          itemCount: state.schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = state.schedules[index];
                            return ListTile(
                              title: Text(_weekdayName(l10n, schedule.weekday)),
                              subtitle: Text(
                                '${schedule.startTime}–${schedule.endTime}',
                              ),
                              trailing: IconButton(
                                tooltip: l10n.removeSchedule,
                                onPressed: _removing
                                    ? null
                                    : () => _removeSchedule(schedule),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _addSchedule,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addSchedule),
                        ),
                        FilledButton(
                          onPressed: state.schedules.isEmpty
                              ? null
                              : _continueToStudents,
                          child: Text(l10n.continueToStudents),
                        ),
                        TextButton(
                          onPressed: _finishLater,
                          child: Text(l10n.finishSetupLater),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _weekdayName(AppLocalizations l10n, int weekday) => switch (weekday) {
    DateTime.monday => l10n.monday,
    DateTime.tuesday => l10n.tuesday,
    DateTime.wednesday => l10n.wednesday,
    DateTime.thursday => l10n.thursday,
    DateTime.friday => l10n.friday,
    DateTime.saturday => l10n.saturday,
    _ => l10n.sunday,
  };
}
