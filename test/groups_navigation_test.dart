import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:term/core/di/injection.dart';
import 'package:term/core/navigation/main_navigation.dart';
import 'package:term/features/groups/domain/entities/study_group.dart';
import 'package:term/features/groups/domain/repositories/group_repository.dart';
import 'package:term/features/groups/presentation/cubit/group_cubit.dart';
import 'package:term/features/students/domain/entities/student.dart';
import 'package:term/l10n/app_localizations.dart';

void main() {
  final locator = getIt;

  tearDown(() async => locator.reset());

  testWidgets('Groups bottom navigation destination opens the Groups page', (
    tester,
  ) async {
    locator.registerFactory<GroupCubit>(
      () => GroupCubit(_EmptyGroupRepository()),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainNavigation(),
      ),
    );
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    expect(find.text('No groups yet.'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

class _EmptyGroupRepository implements GroupRepository {
  @override
  Future<List<StudyGroup>> getGroups() async => [];
  @override
  Future<List<StudyGroup>> searchGroups(String query) async => [];
  @override
  Future<StudyGroup> getGroup(int groupId) => throw UnimplementedError();
  @override
  Future<List<Student>> getEnrolledStudents(int groupId) async => [];
  @override
  Future<List<Student>> getAvailableStudents(int groupId) async => [];
  @override
  Future<int> createGroup(StudyGroup group) async => 1;
  @override
  Future<void> updateGroup(StudyGroup group) async {}
  @override
  Future<void> addStudents(int groupId, List<int> studentIds) async {}
  @override
  Future<bool> removeStudent(int groupId, int studentId) async => true;
}
