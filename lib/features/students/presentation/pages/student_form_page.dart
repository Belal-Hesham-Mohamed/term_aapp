import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../domain/entities/student.dart';
import '../../domain/student_rules.dart';
import '../student_labels.dart';
import '../cubit/student_cubit.dart';

class StudentFormPage extends StatefulWidget {
  final Student? student;
  final int? enrollInGroupId;
  const StudentFormPage({super.key, this.student, this.enrollInGroupId});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class StudentCreationResult {
  final bool created;
  final bool enrolled;
  final int? studentId;
  const StudentCreationResult({
    required this.created,
    required this.enrolled,
    this.studentId,
  });
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _first;
  late final TextEditingController _father;
  late final TextEditingController _family;
  late final TextEditingController _phone;
  late final TextEditingController _age;
  late final TextEditingController _guardian;
  late final TextEditingController _notes;
  late String _grade;
  bool _saving = false;
  String? _saveError;

  bool get isEdit => widget.student != null;
  bool get isLegacyNameEdit {
    final student = widget.student;
    return student != null &&
        student.firstName == null &&
        student.fatherName == null &&
        student.familyName == null;
  }

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _first = TextEditingController(text: student?.firstName ?? '');
    _father = TextEditingController(text: student?.fatherName ?? '');
    _family = TextEditingController(text: student?.familyName ?? '');
    _grade = student?.grade ?? StudentRules.gradeIds.first;
    _phone = TextEditingController(text: student?.phone ?? '');
    _age = TextEditingController(text: student?.age?.toString() ?? '');
    _guardian = TextEditingController(text: student?.guardianPhone ?? '');
    _notes = TextEditingController(text: student?.notes ?? '');
  }

  @override
  void dispose() {
    _first.dispose();
    _father.dispose();
    _family.dispose();
    _phone.dispose();
    _age.dispose();
    _guardian.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final cubit = getIt<StudentCubit>();
      final first = StudentRules.normalizeNamePart(_first.text);
      final father = StudentRules.normalizeNamePart(_father.text);
      final family = StudentRules.normalizeNamePart(_family.text);
      var confirmedDuplicate = false;
      if (!isEdit) {
        final matches = await cubit.findPotentialDuplicates(
          firstName: first,
          fatherName: father,
          familyName: family,
          grade: _grade,
        );
        if (matches.isNotEmpty && mounted) {
          final decision = await showDialog<Object?>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.duplicateStudentTitle),
              content: SizedBox(
                width: 420,
                child: ListView(
                  shrinkWrap: true,
                  children: matches
                      .map(
                        (student) => ListTile(
                          title: Text(student.displayName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${localizedGrade(AppLocalizations.of(context)!, student.grade)}${student.phone == null ? '' : ' • ${student.phone}'}',
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, student),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.duplicateSameStudent,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            tooltip: AppLocalizations.of(
                              context,
                            )!.reviewExistingStudent,
                            icon: const Icon(Icons.visibility),
                            onPressed: () => showDialog<void>(
                              context: dialogContext,
                              builder: (reviewContext) => AlertDialog(
                                title: Text(student.displayName),
                                content: Text(
                                  '${localizedGrade(AppLocalizations.of(context)!, student.grade)}\n${student.phone ?? ''}\n${student.notes ?? ''}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(reviewContext),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, 'different'),
                  child: Text(AppLocalizations.of(context)!.differentStudent),
                ),
              ],
            ),
          );
          if (!mounted) return;
          if (decision is Student) {
            final openExisting = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.duplicateStudentTitle,
                ),
                content: Text(
                  AppLocalizations.of(context)!.openExistingStudentPrompt,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(
                      AppLocalizations.of(context)!.openExistingStudent,
                    ),
                  ),
                ],
              ),
            );
            if (openExisting == true && mounted) {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentFormPage(student: decision),
                ),
              );
              if (mounted) {
                Navigator.pop(
                  context,
                  widget.enrollInGroupId == null
                      ? true
                      : StudentCreationResult(
                          created: false,
                          enrolled: false,
                          studentId: decision.id,
                        ),
                );
              }
              return;
            }
            if (mounted) setState(() => _saving = false);
            return;
          }
          if (decision != 'different') {
            if (mounted) setState(() => _saving = false);
            return;
          }
          confirmedDuplicate = true;
        }
      }

      final phone = StudentRules.normalizePhone(_phone.text);
      final guardian = StudentRules.normalizePhone(_guardian.text);
      final age = StudentRules.parseAge(_age.text);
      bool saved;
      if (isEdit) {
        final preserveLegacyName =
            isLegacyNameEdit &&
            [first, father, family].every((part) => part.isEmpty);
        final updated = widget.student!.copyWith(
          name: preserveLegacyName
              ? widget.student!.name
              : '$first $father $family',
          firstName: preserveLegacyName ? null : first,
          fatherName: preserveLegacyName ? null : father,
          familyName: preserveLegacyName ? null : family,
          grade: _grade,
          phone: phone.isEmpty ? null : phone,
          guardianPhone: guardian.isEmpty ? null : guardian,
          age: age,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        );
        saved = await cubit.updateStudent(updated);
        if (saved && mounted) Navigator.pop(context, true);
      } else {
        final created = await cubit.createStudent(
          firstName: first,
          fatherName: father,
          familyName: family,
          grade: _grade,
          phone: phone,
          age: age,
          guardianPhone: guardian,
          notes: _notes.text,
          confirmedDifferentStudent: confirmedDuplicate,
        );
        saved = created != null;
        if (created != null && widget.enrollInGroupId != null) {
          try {
            await getIt<GroupRepository>().addStudents(
              widget.enrollInGroupId!,
              [created.id],
            );
            if (mounted) {
              Navigator.pop(
                context,
                StudentCreationResult(
                  created: true,
                  enrolled: true,
                  studentId: created.id,
                ),
              );
            }
            return;
          } catch (_) {
            if (mounted) {
              Navigator.pop(
                context,
                StudentCreationResult(
                  created: true,
                  enrolled: false,
                  studentId: created.id,
                ),
              );
            }
            return;
          }
        }
        if (saved && mounted) {
          Navigator.pop(context, true);
        }
      }
      if (!saved && mounted) {
        setState(() {
          _saving = false;
          _saveError = AppLocalizations.of(context)!.saveFailed;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = AppLocalizations.of(context)!.saveFailed;
        });
      }
    }
  }

  String? _phoneValidator(String? value) {
    try {
      StudentRules.normalizePhone(value ?? '');
      return null;
    } on FormatException {
      return AppLocalizations.of(context)!.invalidPhone;
    }
  }

  String? _ageValidator(String? value) {
    try {
      StudentRules.parseAge(value ?? '');
      return null;
    } on FormatException {
      return AppLocalizations.of(context)!.ageOutOfRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final grades = [...StudentRules.gradeIds];
    if (!grades.contains(_grade)) grades.insert(0, _grade);
    return BlocProvider.value(
      value: getIt<StudentCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? l10n.editStudent : l10n.addStudent),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (isLegacyNameEdit)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.legacyStudentNameRetained(widget.student!.name),
                    ),
                  ),
                _nameField(_first, l10n.firstName),
                const SizedBox(height: 12),
                _nameField(_father, l10n.fatherName),
                const SizedBox(height: 12),
                _nameField(_family, l10n.familyName),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _grade,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.grade),
                  items: grades
                      .map(
                        (id) => DropdownMenuItem(
                          value: id,
                          child: Text(
                            StudentRules.gradeIds.contains(id)
                                ? localizedGrade(l10n, id)
                                : l10n.legacyGrade(id),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value != null) setState(() => _grade = value);
                        },
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.required
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: InputDecoration(labelText: l10n.phone),
                  keyboardType: TextInputType.phone,
                  validator: _phoneValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _age,
                  decoration: InputDecoration(labelText: l10n.age),
                  keyboardType: TextInputType.number,
                  validator: _ageValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _guardian,
                  decoration: InputDecoration(labelText: l10n.guardianPhone),
                  keyboardType: TextInputType.phone,
                  validator: _phoneValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  decoration: InputDecoration(labelText: l10n.notes),
                  maxLines: 3,
                ),
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _saveError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
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

  Widget _nameField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final nameParts = [_first.text, _father.text, _family.text];
          if (isLegacyNameEdit &&
              nameParts.every((part) => part.trim().isEmpty)) {
            return null;
          }
          return (value == null || value.trim().isEmpty)
              ? AppLocalizations.of(context)!.required
              : null;
        },
      );
}
