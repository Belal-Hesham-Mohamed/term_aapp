import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/grades/grade_catalog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/study_group.dart';
import '../../domain/entities/group_setup_outcome.dart';
import '../cubit/group_cubit.dart';
import '../../../students/presentation/student_labels.dart';
import 'group_schedule_setup_page.dart';

class GroupFormPage extends StatefulWidget {
  final StudyGroup? group;
  const GroupFormPage({super.key, this.group});

  @override
  State<GroupFormPage> createState() => _GroupFormPageState();
}

class _GroupFormPageState extends State<GroupFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final GroupCubit _cubit;
  late final TextEditingController _nameController;
  late final TextEditingController _gradeController;
  late final TextEditingController _notesController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<GroupCubit>();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
    _gradeController = TextEditingController(
      text: widget.group?.targetGrade ?? '',
    );
    _notesController = TextEditingController(text: widget.group?.notes ?? '');
  }

  @override
  void dispose() {
    _cubit.close();
    _nameController.dispose();
    _gradeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    if (widget.group == null) {
      final group = await _cubit.createGroupForSetup(
        name: _nameController.text,
        targetGrade: _gradeController.text,
        notes: _notesController.text,
      );
      if (!mounted) return;
      if (group == null) {
        setState(() {
          _saving = false;
          _error = _cubit.lastSaveWasDuplicate
              ? AppLocalizations.of(context)!.duplicateGroupName
              : _cubit.lastSaveWasInvalidGrade
              ? AppLocalizations.of(context)!.invalidGrade
              : AppLocalizations.of(context)!.groupSaveFailed;
        });
        return;
      }
      final outcome = await Navigator.push<GroupSetupOutcome>(
        context,
        MaterialPageRoute(builder: (_) => GroupScheduleSetupPage(group: group)),
      );
      if (mounted) {
        Navigator.pop(
          context,
          outcome ?? GroupSetupOutcome(groupId: group.id, completed: false),
        );
      }
      return;
    }

    final ok = await _cubit.saveGroup(
      existing: widget.group,
      name: _nameController.text,
      targetGrade: _gradeController.text,
      notes: _notesController.text,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (!ok) {
        _error = _cubit.lastSaveWasDuplicate
            ? AppLocalizations.of(context)!.duplicateGroupName
            : _cubit.lastSaveWasInvalidGrade
            ? AppLocalizations.of(context)!.invalidGrade
            : AppLocalizations.of(context)!.groupSaveFailed;
      }
    });
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.group == null ? l10n.createGroup : l10n.editGroup),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.groupName),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.required
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGrade(),
                  decoration: InputDecoration(labelText: l10n.targetGrade),
                  items: [
                    if (widget.group != null &&
                        !GradeCatalog.contains(widget.group!.targetGrade))
                      DropdownMenuItem(
                        value: widget.group!.targetGrade,
                        child: Text(
                          l10n.legacyGrade(widget.group!.targetGrade),
                        ),
                      ),
                    ...GradeCatalog.ids.map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(localizedGrade(l10n, id)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) _gradeController.text = value;
                  },
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.required
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: l10n.notes),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? l10n.saving : l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _selectedGrade() {
    final current = _gradeController.text;
    if (current.isEmpty) return null;
    return current;
  }
}
