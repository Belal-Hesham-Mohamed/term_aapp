import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../students/domain/entities/student.dart';
import '../cubit/group_cubit.dart';
import '../state/group_state.dart';
import '../../../students/presentation/pages/student_form_page.dart';
import '../../../students/presentation/student_labels.dart';

class StudentEnrollmentPage extends StatefulWidget {
  final int groupId;
  const StudentEnrollmentPage({super.key, required this.groupId});

  @override
  State<StudentEnrollmentPage> createState() => _StudentEnrollmentPageState();
}

class _StudentEnrollmentPageState extends State<StudentEnrollmentPage> {
  late final GroupCubit _cubit;
  final Set<int> _selected = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<GroupCubit>()..loadAvailableStudents(widget.groupId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _add() async {
    if (_saving || _selected.isEmpty) return;
    setState(() => _saving = true);
    final success = await _cubit.addStudents(
      widget.groupId,
      _selected.toList(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) Navigator.pop(context, true);
  }

  Future<void> _addNewStudent() async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentFormPage(enrollInGroupId: widget.groupId),
      ),
    );
    if (result is StudentCreationResult && mounted) {
      await _cubit.loadAvailableStudents(widget.groupId);
      if (result.enrolled && mounted) {
        Navigator.pop(context, true);
      } else if (result.studentId != null &&
          _cubit.state is GroupAvailableStudentsLoaded &&
          (_cubit.state as GroupAvailableStudentsLoaded).students.any(
            (student) => student.id == result.studentId,
          )) {
        setState(() => _selected.add(result.studentId!));
        if (result.created && mounted) _showEnrollmentRetry(result.studentId!);
      } else if (result.created && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.studentCreatedEnrollmentFailed,
            ),
            action: result.studentId == null
                ? null
                : SnackBarAction(
                    label: AppLocalizations.of(context)!.retryEnrollment,
                    onPressed: () => _retryEnrollment(result.studentId!),
                  ),
          ),
        );
      }
    }
  }

  void _showEnrollmentRetry(int studentId) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.studentCreatedEnrollmentFailed),
        action: SnackBarAction(
          label: l10n.retryEnrollment,
          onPressed: () => _retryEnrollment(studentId),
        ),
      ),
    );
  }

  Future<void> _retryEnrollment(int studentId) async {
    if (_saving) return;
    setState(() => _saving = true);
    final success = await _cubit.addStudents(widget.groupId, [studentId]);
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.addStudents)),
        body: BlocBuilder<GroupCubit, GroupState>(
          builder: (context, state) {
            if (state is GroupFailure) {
              return Center(
                child: Text('${l10n.error}: ${l10n.groupLoadFailed}'),
              );
            }
            if (state is! GroupAvailableStudentsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton.icon(
                      onPressed: _addNewStudent,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addNewStudent),
                    ),
                  ),
                ),
                Expanded(
                  child: state.students.isEmpty
                      ? Center(child: Text(l10n.noAvailableStudents))
                      : ListView.builder(
                          itemCount: state.students.length,
                          itemBuilder: (context, index) =>
                              _studentTile(state.students[index]),
                        ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: _saving || _selected.isEmpty ? null : _add,
              child: Text(
                _saving
                    ? l10n.saving
                    : l10n.addSelectedStudents(_selected.length),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _studentTile(Student student) => CheckboxListTile(
    value: _selected.contains(student.id),
    onChanged: (checked) => setState(() {
      if (checked == true) {
        _selected.add(student.id);
      } else {
        _selected.remove(student.id);
      }
    }),
    title: Text(student.displayName),
    subtitle: Text(
      localizedGrade(AppLocalizations.of(context)!, student.grade),
    ),
  );
}
