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
}
