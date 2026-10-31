// lib/features/students/presentation/pages/student_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/student_cubit.dart';
import '../../domain/entities/student.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';

class StudentFormPage extends StatefulWidget {
  final Student? student;
  const StudentFormPage({super.key, this.student});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _gradeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ageController;
  late final TextEditingController _guardianController;
  late final TextEditingController _notesController;
  bool _saving = false;
  String? _saveError;

  bool get isEdit => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameController = TextEditingController(text: s?.name ?? '');
    _gradeController = TextEditingController(text: s?.grade ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _ageController = TextEditingController(text: s?.age?.toString() ?? '');
    _guardianController = TextEditingController(text: s?.guardianPhone ?? '');
    _notesController = TextEditingController(text: s?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _guardianController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _saveError = null; });
    final cubit = getIt<StudentCubit>();
    bool success = false;
    if (isEdit && widget.student != null) {
      final age = int.tryParse(_ageController.text.trim());
      final updated = widget.student!.copyWith(
        name: _nameController.text.trim(),
        grade: _gradeController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        age: age,
        guardianPhone: _guardianController.text.trim().isEmpty ? null : _guardianController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      success = await cubit.updateStudent(updated);
    } else {
      final age = int.tryParse(_ageController.text.trim());
      success = await cubit.addStudent(
        name: _nameController.text.trim(),
        grade: _gradeController.text.trim(),
        phone: _phoneController.text.trim(),
        age: age,
        guardianPhone: _guardianController.text.trim(),
        notes: _notesController.text.trim(),
      );
    }
    if (mounted) {
      setState(() {
        _saving = false;
        if (!success) _saveError = l10n.saveFailed;
      });
      if (success) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.name),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _gradeController,
                  decoration: InputDecoration(labelText: l10n.grade),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: l10n.phone),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: l10n.age),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    final age = int.tryParse(text);
                    return age == null || age < 0 ? l10n.invalidAge : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _guardianController,
                  decoration: InputDecoration(labelText: l10n.guardianPhone),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: l10n.notes),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                if (_saveError != null) ...[
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(_saveError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
}
