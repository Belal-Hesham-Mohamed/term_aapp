// lib/features/students/presentation/pages/student_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/student_cubit.dart';
import '../state/student_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import 'student_form_page.dart';
import '../student_labels.dart';
import '../../domain/student_rules.dart';
import '../../../../core/widgets/app_header.dart';

class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider<StudentCubit>(
      create: (_) => getIt<StudentCubit>(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  AppBrandHeader(onNotificationTap: () {}),
                  AppPageHeader(
                    title: l10n.students,
                    titleIcon: Icons.people_outline,
                  ),
                ],
              ),
            ),
            Expanded(child: const _StudentListBody()),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentFormPage()),
              );
              if (result == true && context.mounted) {
                context.read<StudentCubit>().loadStudents();
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class _StudentListBody extends StatefulWidget {
  const _StudentListBody();

  @override
  State<_StudentListBody> createState() => _StudentListBodyState();
}

class _StudentListBodyState extends State<_StudentListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedGrade;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _query = value);
              context.read<StudentCubit>().searchStudents(value);
            },
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _gradeChip(l10n.allGrades, null, l10n),
              ...StudentRules.gradeIds.map(
                (grade) => _gradeChip(localizedGrade(l10n, grade), grade, l10n),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<StudentCubit, StudentState>(
            builder: (context, state) {
              if (state is StudentLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is StudentLoaded) {
                final students = state.students;
                if (students.isEmpty) {
                  return Center(
                    child: Text(
                      _query.isEmpty ? l10n.noStudents : l10n.noResults,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      title: Text(student.displayName),
                      subtitle: Text(
                        '${l10n.grade}: ${localizedGrade(l10n, student.grade)}${student.phone != null && student.phone!.isNotEmpty ? ' • ${student.phone}' : ''}',
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentFormPage(student: student),
                          ),
                        );
                        if (result == true && context.mounted) {
                          context.read<StudentCubit>().loadStudents();
                        }
                      },
                      trailing: IconButton(
                        tooltip: l10n.deleteStudent,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.deleteStudent),
                              content: Text(
                                l10n.deleteStudentConfirm(student.displayName),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            final deleted = await context
                                .read<StudentCubit>()
                                .deleteStudent(student.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    deleted
                                        ? l10n.studentDeleted
                                        : l10n.studentDeleteFailed,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              } else if (state is StudentError) {
                return Center(child: Text('${l10n.error}: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _gradeChip(String label, String? grade, AppLocalizations l10n) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: _selectedGrade == grade,
          onSelected: (_) {
            setState(() => _selectedGrade = grade);
            context.read<StudentCubit>().selectGrade(grade);
          },
        ),
      );
}
