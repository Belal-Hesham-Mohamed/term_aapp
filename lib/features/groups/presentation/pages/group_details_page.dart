import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/group_cubit.dart';
import '../state/group_state.dart';
import 'group_form_page.dart';
import 'student_enrollment_page.dart';
import '../../../schedules/presentation/pages/group_schedules_section.dart';
import '../../../lessons/presentation/pages/group_lessons_section.dart';
import '../../../students/presentation/student_labels.dart';

class GroupDetailsPage extends StatelessWidget {
  final int groupId;
  const GroupDetailsPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<GroupCubit>()..loadDetails(groupId),
    child: _GroupDetailsView(groupId: groupId),
  );
}

class _GroupDetailsView extends StatefulWidget {
  final int groupId;
  const _GroupDetailsView({required this.groupId});

  @override
  State<_GroupDetailsView> createState() => _GroupDetailsViewState();
}

class _GroupDetailsViewState extends State<_GroupDetailsView> {
  int _scheduleRefreshKey = 0;
  bool _deleting = false;

  void _refreshUpcomingLessons() {
    setState(() => _scheduleRefreshKey++);
  }

  Future<void> _edit(BuildContext context, GroupDetailsLoaded state) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => GroupFormPage(group: state.group)),
    );
    if (saved == true && context.mounted) {
      context.read<GroupCubit>().loadDetails(widget.groupId);
    }
  }

  Future<void> _enroll(BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentEnrollmentPage(groupId: widget.groupId),
      ),
    );
    if (changed == true && context.mounted) {
      context.read<GroupCubit>().loadDetails(widget.groupId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.studentEnrolledSuccess),
        ),
      );
    }
  }

  Future<void> _deleteGroup(
    BuildContext context,
    GroupDetailsLoaded state,
  ) async {
    if (_deleting) return;
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<GroupCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteGroup),
        content: Text(l10n.deleteGroupConfirm(state.group.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteGroup),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    setState(() => _deleting = true);
    final deleted = await cubit.deleteGroup(widget.groupId);
    if (!context.mounted) return;
    if (deleted) {
      Navigator.pop(context, true);
    } else {
      setState(() => _deleting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupDeleteFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupDetails),
        actions: [
          IconButton(
            tooltip: l10n.editGroup,
            onPressed: () {
              final state = context.read<GroupCubit>().state;
              if (state is GroupDetailsLoaded) _edit(context, state);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: l10n.deleteGroup,
            onPressed: _deleting
                ? null
                : () {
                    final state = context.read<GroupCubit>().state;
                    if (state is GroupDetailsLoaded) {
                      _deleteGroup(context, state);
                    }
                  },
            icon: _deleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _enroll(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.addStudents),
      ),
      body: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          if (state is GroupDetailsLoading || state is GroupLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GroupFailure) {
            return Center(
              child: Text('${l10n.error}: ${l10n.groupLoadFailed}'),
            );
          }
          if (state is! GroupDetailsLoaded) return const SizedBox.shrink();
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  state.group.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListTile(
                title: Text(l10n.targetGrade),
                subtitle: Text(state.group.targetGrade),
              ),
              if (state.group.notes?.isNotEmpty == true)
                ListTile(
                  title: Text(l10n.notes),
                  subtitle: Text(state.group.notes!),
                ),
              ListTile(
                title: Text(l10n.activeStudents),
                subtitle: Text('${state.students.length}'),
              ),
              GroupSchedulesSection(
                groupId: widget.groupId,
                onSchedulesChanged: _refreshUpcomingLessons,
              ),
              GroupLessonsSection(
                key: ValueKey(_scheduleRefreshKey),
                groupId: widget.groupId,
              ),
              const Divider(),
              if (state.students.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.noEnrolledStudents)),
                )
              else
                ...state.students.map(
                  (student) => ListTile(
                    title: Text(student.displayName),
                    subtitle: Text(
                      '${l10n.grade}: ${localizedGrade(l10n, student.grade)}${student.phone?.isNotEmpty == true ? ' | ${student.phone}' : ''}',
                    ),
                    trailing: IconButton(
                      tooltip: l10n.removeStudent,
                      icon: const Icon(Icons.person_remove_outlined),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text(l10n.removeStudent),
                            content: Text(
                              l10n.removeStudentConfirm(student.displayName),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: Text(l10n.removeStudent),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await context.read<GroupCubit>().removeStudent(
                            widget.groupId,
                            student.id,
                          );
                        }
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
