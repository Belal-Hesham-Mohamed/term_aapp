import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/grades/grade_catalog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../students/domain/entities/student.dart';
import '../../domain/entities/group_setup_outcome.dart';
import '../cubit/group_cubit.dart';
import '../state/group_state.dart';
import 'group_setup_complete_page.dart';
import '../../../students/presentation/pages/student_form_page.dart';
import '../../../students/presentation/student_labels.dart';

class StudentEnrollmentPage extends StatefulWidget {
  final int groupId;
  final String? targetGrade;
  final bool completeSetupOnSave;
  const StudentEnrollmentPage({
    super.key,
    required this.groupId,
    this.targetGrade,
    this.completeSetupOnSave = false,
  });

  @override
  State<StudentEnrollmentPage> createState() => _StudentEnrollmentPageState();
}

class _StudentEnrollmentPageState extends State<StudentEnrollmentPage> {
  late final GroupCubit _cubit;
  final Set<int> _selected = {};
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<GroupCubit>()..loadAvailableStudents(widget.groupId);
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_saving) return;
    if (_selected.isEmpty) {
      if (widget.completeSetupOnSave) await _completeSetup();
      return;
    }
    setState(() => _saving = true);
    final success = await _cubit.addStudents(
      widget.groupId,
      _selected.toList(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success && widget.completeSetupOnSave) {
      await _completeSetup();
    } else if (success) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _completeSetup() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final completed = await _cubit.completeSetup(widget.groupId);
      if (!mounted) return;
      if (!completed) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.groupSetupSaveFailed)));
        return;
      }
      final outcome = await Navigator.push<GroupSetupOutcome>(
        context,
        MaterialPageRoute(
          builder: (_) => GroupSetupCompletePage(groupId: widget.groupId),
        ),
      );
      if (mounted && outcome != null) Navigator.pop(context, outcome);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.groupSetupSaveFailed)));
      }
    }
  }

  Future<void> _addNewStudent() async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentFormPage(
          enrollInGroupId: widget.completeSetupOnSave ? null : widget.groupId,
        ),
      ),
    );
    if (widget.completeSetupOnSave && result == true && mounted) {
      await _cubit.loadAvailableStudents(widget.groupId);
      return;
    }
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
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _query = value.trim()),
                  ),
                ),
                if (_hasGradeMismatch(state.students))
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.studentGradeMismatchWarning(
                        localizedGrade(l10n, widget.targetGrade!),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
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
                  child: _filteredStudents(state.students).isEmpty
                      ? Center(child: Text(l10n.noAvailableStudents))
                      : ListView.builder(
                          itemCount: _filteredStudents(state.students).length,
                          itemBuilder: (context, index) => _studentTile(
                            _filteredStudents(state.students)[index],
                          ),
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
              onPressed: _saving ? null : _add,
              child: Text(
                _saving
                    ? l10n.saving
                    : _selected.isEmpty && widget.completeSetupOnSave
                    ? l10n.finishSetupWithoutStudents
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

  List<Student> _filteredStudents(List<Student> students) {
    final query = _query.toLowerCase();
    if (query.isEmpty) return students;
    return students.where((student) {
      final values = [
        student.displayName,
        student.name,
        student.firstName,
        student.fatherName,
        student.familyName,
        student.phone,
        student.grade,
      ];
      return values.any(
        (value) => value?.toLowerCase().contains(query) == true,
      );
    }).toList();
  }

  bool _hasGradeMismatch(List<Student> students) {
    final target = widget.targetGrade;
    if (target == null || !GradeCatalog.contains(target)) return false;
    return students.any(
      (student) =>
          _selected.contains(student.id) &&
          GradeCatalog.contains(student.grade) &&
          student.grade != target,
    );
  }
}
