// lib/features/students/presentation/pages/student_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/student_cubit.dart';
import '../state/student_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';

class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider<StudentCubit>(
      create: (_) => getIt<StudentCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.students),
        ),
        body: const _StudentListBody(),
      ),
    );
  }
}

class _StudentListBody extends StatelessWidget {
  const _StudentListBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<StudentCubit, StudentState>(
      builder: (context, state) {
        if (state is StudentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StudentLoaded) {
          final students = state.students;
          if (students.isEmpty) {
            return Center(
              child: Text(l10n.noStudents),
            );
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text(student.name),
                subtitle: Text('${l10n.grade}: ${student.grade}'),
                trailing: student.phone != null ? Text(student.phone!) : null,
              );
            },
          );
        } else if (state is StudentError) {
          return Center(child: Text('${l10n.error}: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
