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
import '../../features/schedules/data/datasources/schedule_local_datasource.dart';
import '../../features/schedules/data/repositories/schedule_repository_impl.dart';
import '../../features/schedules/domain/repositories/schedule_repository.dart';
import '../../features/schedules/presentation/cubit/schedule_cubit.dart';
import '../../features/lessons/data/datasources/lesson_local_datasource.dart';
import '../../features/lessons/data/repositories/lesson_repository_impl.dart';
import '../../features/lessons/domain/repositories/lesson_repository.dart';
import '../../features/lessons/presentation/cubit/lesson_cubit.dart';
import '../../features/attendance/data/datasources/attendance_local_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/presentation/cubit/attendance_cubit.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';

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
  registerScheduleDependencies(getIt);
  registerLessonDependencies(getIt);
  registerAttendanceDependencies(getIt);
  registerHomeDependencies(getIt);

  await getIt.allReady();
}

void registerHomeDependencies(GetIt locator) {
  locator.registerFactory<HomeLocalDataSource>(
    () => HomeLocalDataSource(locator<DatabaseHelper>()),
  );
  locator.registerFactory<HomeRepository>(
    () => HomeRepositoryImpl(
      dataSource: locator<HomeLocalDataSource>(),
      groups: locator<GroupRepository>(),
      students: locator<StudentRepository>(),
      lessons: locator<LessonRepository>(),
    ),
  );
  locator.registerFactory<HomeCubit>(
    () => HomeCubit(locator<HomeRepository>()),
  );
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

void registerScheduleDependencies(GetIt locator) {
  locator.registerFactory<ScheduleLocalDataSource>(
    () => ScheduleLocalDataSource(locator<DatabaseHelper>()),
  );
  locator.registerFactory<ScheduleRepository>(
    () => ScheduleRepositoryImpl(locator<ScheduleLocalDataSource>()),
  );
  locator.registerFactory<ScheduleCubit>(
    () => ScheduleCubit(locator<ScheduleRepository>()),
  );
}

void registerLessonDependencies(GetIt locator) {
  locator.registerFactory<LessonLocalDataSource>(
    () => LessonLocalDataSource(locator<DatabaseHelper>()),
  );
  locator.registerFactory<LessonRepository>(
    () => LessonRepositoryImpl(locator<LessonLocalDataSource>()),
  );
  locator.registerFactory<LessonCubit>(
    () => LessonCubit(locator<LessonRepository>()),
  );
}

void registerAttendanceDependencies(GetIt locator) {
  locator.registerFactory<AttendanceLocalDataSource>(
    () => AttendanceLocalDataSource(locator<DatabaseHelper>()),
  );
  locator.registerFactory<AttendanceRepository>(
    () => AttendanceRepositoryImpl(locator<AttendanceLocalDataSource>()),
  );
  locator.registerFactory<AttendanceCubit>(
    () => AttendanceCubit(locator<AttendanceRepository>()),
  );
}
