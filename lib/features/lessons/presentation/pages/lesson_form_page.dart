import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../groups/domain/entities/study_group.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../domain/entities/lesson_record.dart';
import '../cubit/lesson_cubit.dart';
import '../state/lesson_state.dart';

class LessonFormPage extends StatefulWidget {
  final int? groupId;
  final LessonRecord? lesson;
  const LessonFormPage({super.key, this.groupId, this.lesson});

  @override
  State<LessonFormPage> createState() => _LessonFormPageState();
}

class _LessonFormPageState extends State<LessonFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final LessonCubit _cubit;
  late final GroupRepository _groupRepository;
  late final TextEditingController _reasonController;
  List<StudyGroup> _groups = [];
  int? _groupId;
  late DateTime _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  late bool _canceled;
  bool _loadingGroups = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LessonCubit>();
    _groupRepository = getIt<GroupRepository>();
    final lesson = widget.lesson;
    _groupId = lesson?.groupId ?? widget.groupId;
    final selected = lesson == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(lesson.scheduledDate);
    _date = DateTime(selected.year, selected.month, selected.day);
    _start = _parseTime(lesson?.startTime);
    _end = _parseTime(lesson?.endTime);
    _canceled = lesson?.isCanceled ?? false;
    _reasonController = TextEditingController(
      text: lesson?.cancellationReason ?? '',
    );
    if (_groupId == null) _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _loadingGroups = true);
    try {
      final groups = await _groupRepository.getGroups();
      if (mounted) {
        setState(() {
          _groups = groups;
          _loadingGroups = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingGroups = false;
          _error = AppLocalizations.of(context)!.lessonLoadFailed;
        });
      }
    }
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _value(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(
        () => _date = DateTime(selected.year, selected.month, selected.day),
      );
    }
  }

  Future<void> _pickTime(bool start) async {
    final selected = await showTimePicker(
      context: context,
      initialTime:
          (start ? _start : _end) ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (selected != null) {
      setState(() => start ? _start = selected : _end = selected);
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (_groupId == null || _start == null || _end == null) {
      setState(() => _error = l10n.lessonFieldsRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final success = await _cubit.saveLesson(
      existing: widget.lesson,
      groupId: _groupId!,
      scheduledDate: _date,
      startTime: _value(_start!),
      endTime: _value(_end!),
      isCanceled: _canceled,
      cancellationReason: _reasonController.text,
    );
    if (!mounted) return;
    final state = _cubit.state;
    setState(() {
      _saving = false;
      if (!success) {
        _error = state is LessonFailure && state.message == 'duplicate'
            ? l10n.duplicateLesson
            : state is LessonFailure && state.message == 'invalidFields'
            ? l10n.invalidLessonTime
            : l10n.lessonSaveFailed;
      }
    });
    if (success) Navigator.pop(context, true);
  }

  String _dateLabel(BuildContext context) => DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(_date);

  @override
  void dispose() {
    _cubit.close();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.lesson == null ? l10n.createLesson : l10n.editLesson,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (widget.groupId == null && widget.lesson == null)
                  _loadingGroups
                      ? const LinearProgressIndicator()
                      : DropdownButtonFormField<int>(
                          initialValue: _groupId,
                          decoration: InputDecoration(labelText: l10n.group),
                          items: _groups
                              .map(
                                (group) => DropdownMenuItem(
                                  value: group.id,
                                  child: Text(group.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _groupId = value),
                          validator: (value) =>
                              value == null ? l10n.required : null,
                        ),
                ListTile(
                  title: Text(l10n.lessonDate),
                  subtitle: Text(_dateLabel(context)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                ListTile(
                  title: Text(l10n.startTime),
                  subtitle: Text(_start?.format(context) ?? l10n.chooseTime),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _pickTime(true),
                ),
                ListTile(
                  title: Text(l10n.endTime),
                  subtitle: Text(_end?.format(context) ?? l10n.chooseTime),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _pickTime(false),
                ),
                SwitchListTile(
                  title: Text(l10n.lessonCanceled),
                  value: _canceled,
                  onChanged: (value) => setState(() => _canceled = value),
                ),
                if (_canceled)
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: l10n.cancellationReason,
                    ),
                    maxLines: 2,
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving || _loadingGroups ? null : _save,
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
