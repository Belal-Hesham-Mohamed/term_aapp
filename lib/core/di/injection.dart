// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

final GetIt getIt = GetIt.instance;

/// Call this early (e.g., from main) to register core services.
Future<void> setup() async {
  // Register DatabaseHelper as a singleton and initialize it immediately.
  getIt.registerSingletonAsync<DatabaseHelper>(
    () async {
      final helper = DatabaseHelper();
      await helper.init();
      return helper;
    },
  );

  // Register the raw Database instance, depending on DatabaseHelper.
  getIt.registerSingletonWithDependencies<Database>(
    () => getIt<DatabaseHelper>().db,
    dependsOn: [DatabaseHelper],
  );

  await getIt.allReady();
}
