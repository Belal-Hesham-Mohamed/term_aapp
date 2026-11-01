import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/study_group.dart';
import '../../domain/entities/group_setup_outcome.dart';
import '../cubit/group_cubit.dart';
import '../state/group_state.dart';
import 'group_details_page.dart';
import 'group_form_page.dart';
import '../../../students/presentation/student_labels.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<GroupCubit>()..loadGroups(),
    child: const _GroupsView(),
  );
}

class _GroupsView extends StatefulWidget {
  const _GroupsView();

  @override
  State<_GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<_GroupsView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({StudyGroup? group}) async {
    final saved = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (_) => GroupFormPage(group: group)),
    );
    if (!mounted) return;
    context.read<GroupCubit>().loadGroups();
    if (saved is GroupSetupOutcome && saved.openGroupDetails && mounted) {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => GroupDetailsPage(groupId: saved.groupId),
        ),
      );
      if (mounted) context.read<GroupCubit>().loadGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AppHeaderContainer(
              title: l10n.groups,
              titleIcon: Icons.group_work,
              onNotificationTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.groupSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _query = value.trim());
                context.read<GroupCubit>().searchGroups(value);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<GroupCubit, GroupState>(
              builder: (context, state) {
                if (state is GroupLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GroupFailure) {
                  return Center(
                    child: Text('${l10n.error}: ${l10n.groupLoadFailed}'),
                  );
                }
                if (state is! GroupListLoaded) return const SizedBox.shrink();
                if (state.groups.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty ? l10n.noGroups : l10n.noGroupsFound,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.groups.length,
                  itemBuilder: (context, index) {
                    final group = state.groups[index];
                    return ListTile(
                      title: Text(group.name),
                      subtitle: Text(
                        '${l10n.targetGrade}: ${localizedGrade(l10n, group.targetGrade)} | ${l10n.activeStudents}: ${group.activeStudentCount}${group.setupCompleted ? '' : ' | ${l10n.groupSetupIncomplete}'}',
                      ),
                      onTap: () async {
                        final deleted = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupDetailsPage(groupId: group.id),
                          ),
                        );
                        if (context.mounted) {
                          context.read<GroupCubit>().loadGroups();
                          if (deleted == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.groupDeleted)),
                            );
                          }
                        }
                      },
                      trailing: IconButton(
                        tooltip: l10n.editGroup,
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openForm(group: group),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
