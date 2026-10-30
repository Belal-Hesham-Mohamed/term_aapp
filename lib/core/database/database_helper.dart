// lib/core/database/database_helper.dart
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'migrations.dart';

class DatabaseHelper {
  static const String _dbName = 'term.db';
  static const int _dbVersion = 1;

  Database? _db;
  Database get db => _db!;

  /// Open (or create) the database file in the app's documents directory.
  Future<void> init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// For unit tests – open an in‑memory database with the same schema.
  Future<void> initInMemory() async {
    // Use ffi implementation for desktop test environments.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _db = await openDatabase(
      inMemoryDatabasePath,
      version: _dbVersion,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute(Migrations.createStudents);
    await db.execute(Migrations.createGroups);
    await db.execute(Migrations.createGroupStudents);
    await db.execute(Migrations.createGroupSchedules);
    await db.execute(Migrations.createLessons);
    await db.execute(Migrations.createAttendanceRecords);
    await db.execute(Migrations.createAppSettings);
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will be added here.
  }
}
