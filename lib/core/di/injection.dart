// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../features/students/data/datasources/student_local_datasource.dart';
import '../../features/students/domain/repositories/student_repository.dart';
import '../../features/students/data/repositories/student_repository_impl.dart';
import '../../features/students/presentation/cubit/student_cubit.dart';
import '../../features/groups/data/datasources/group_local_datasource.dart';
import '../../features/groups/data/repositories/group_repository_impl.dart';
import '../../features/groups/domain/repositories/group_repository.dart';
import '../../features/groups/presentation/cubit/group_cubit.dart';

final GetIt getIt = GetIt.instance;

/// Call this early (e.g., from main) to register core services.
Future<void> setup() async {
  if (getIt.isRegistered<DatabaseHelper>()) {
    return;
  }

  // Register DatabaseHelper as a singleton and initialize it immediately.
  getIt.registerSingletonAsync<DatabaseHelper>(() async {
    final helper = DatabaseHelper();
    await helper.init();
    return helper;
  });

  // Register the raw Database instance, depending on DatabaseHelper.
  getIt.registerSingletonWithDependencies<Database>(
    () => getIt<DatabaseHelper>().db,
    dependsOn: [DatabaseHelper],
  );

  // Register StudentLocalDataSource
  getIt.registerFactory<StudentLocalDataSource>(
    () => StudentLocalDataSource(getIt<DatabaseHelper>()),
  );

  // Register StudentRepository implementation
  getIt.registerFactory<StudentRepository>(
    () => StudentRepositoryImpl(getIt<StudentLocalDataSource>()),
  );

  // Register StudentCubit
  getIt.registerFactory<StudentCubit>(
    () => StudentCubit(getIt<StudentRepository>()),
  );

  registerGroupDependencies(getIt);

  await getIt.allReady();
}

void registerGroupDependencies(GetIt locator) {
  locator.registerFactory<GroupLocalDataSource>(
    () => GroupLocalDataSource(locator<DatabaseHelper>()),
  );
  locator.registerFactory<GroupRepository>(
    () => GroupRepositoryImpl(locator<GroupLocalDataSource>()),
  );
  locator.registerFactory<GroupCubit>(
    () => GroupCubit(locator<GroupRepository>()),
  );
}
