import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/group_schedule.dart';
import '../cubit/schedule_cubit.dart';
import '../state/schedule_state.dart';

class ScheduleFormPage extends StatefulWidget {
  final int groupId;
  final GroupSchedule? schedule;
  const ScheduleFormPage({super.key, required this.groupId, this.schedule});

  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final ScheduleCubit _cubit;
  late int _weekday;
  TimeOfDay? _start;
  TimeOfDay? _end;
  late bool _active;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ScheduleCubit>();
    final schedule = widget.schedule;
    _weekday = schedule?.weekday ?? DateTime.monday;
    _start = _parse(schedule?.startTime);
    _end = _parse(schedule?.endTime);
    _active = schedule?.active ?? true;
  }

  TimeOfDay? _parse(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _timeValue(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

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
    if (_start == null || _end == null) {
      setState(() => _error = l10n.scheduleTimesRequired);
      return;
    }
    if (_start!.hour * 60 + _start!.minute >= _end!.hour * 60 + _end!.minute) {
      setState(() => _error = l10n.invalidTimeRange);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final success = await _cubit.saveSchedule(
      existing: widget.schedule,
      groupId: widget.groupId,
      weekday: _weekday,
      startTime: _timeValue(_start!),
      endTime: _timeValue(_end!),
      active: _active,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (!success) {
        _error =
            _cubit.state is ScheduleFailure &&
                (_cubit.state as ScheduleFailure).message == 'conflict'
            ? l10n.scheduleConflict
            : l10n.scheduleSaveFailed;
      }
    });
    if (success) Navigator.pop(context, true);
  }

  String _weekdayName(AppLocalizations l10n, int value) => switch (value) {
    1 => l10n.monday,
    2 => l10n.tuesday,
    3 => l10n.wednesday,
    4 => l10n.thursday,
    5 => l10n.friday,
    6 => l10n.saturday,
    _ => l10n.sunday,
  };

  @override
  void dispose() {
    _cubit.close();
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
            widget.schedule == null
                ? l10n.addWeeklySchedule
                : l10n.editWeeklySchedule,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(l10n.recurringWeeklyDescription),
                  ),
                ),
                DropdownButtonFormField<int>(
                  initialValue: _weekday,
                  decoration: InputDecoration(labelText: l10n.weekday),
                  items: List.generate(
                    7,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(_weekdayName(l10n, index + 1)),
                    ),
                  ),
                  onChanged: (value) =>
                      setState(() => _weekday = value ?? _weekday),
                ),
                const SizedBox(height: 12),
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
                  title: Text(l10n.scheduleActive),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
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
