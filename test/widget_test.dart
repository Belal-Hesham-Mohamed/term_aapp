// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:term/main.dart';
import 'package:term/core/di/injection.dart';
import 'package:term/features/home/presentation/cubit/home_cubit.dart';
import 'home_test_doubles.dart';

void main() {
  tearDown(() async => getIt.reset());

  testWidgets('App starts', (WidgetTester tester) async {
    getIt.registerFactory<HomeCubit>(
      () => HomeCubit(const EmptyHomeRepository()),
    );
    await tester.pumpWidget(const TermApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home summary is readable on a narrow Arabic layout', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    getIt.registerFactory<HomeCubit>(
      () => HomeCubit(const EmptyHomeRepository()),
    );

    await tester.pumpWidget(const TermApp());
    await tester.pumpAndSettle();

    expect(find.text('ملخصك'), findsOneWidget);
    expect(find.text('دروس اليوم'), findsOneWidget);
    expect(find.text('إجمالي المجموعات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
