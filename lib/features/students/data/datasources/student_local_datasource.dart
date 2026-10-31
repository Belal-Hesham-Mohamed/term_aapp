// lib/features/students/data/datasources/student_local_datasource.dart

import '../../../../../core/database/database_helper.dart';
import '../../domain/entities/student.dart';
import '../../domain/student_rules.dart';
import 'package:sqflite/sqflite.dart';

class StudentLocalDataSource {
  final DatabaseHelper dbHelper;

  StudentLocalDataSource(this.dbHelper);

  Future<List<Student>> getActiveStudents() async {
    final List<Map<String, dynamic>> rows = await dbHelper.db.query(
      'students',
      where: 'archived_at IS NULL',
      orderBy: 'name COLLATE NOCASE ASC, duplicate_index ASC, id ASC',
    );
    return rows.map((e) => Student.fromMap(e)).toList();
  }

  Future<Student?> getStudentById(int id) async {
    final rows = await dbHelper.db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Student.fromMap(rows.single);
  }

  Future<List<Student>> searchStudents(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      return getActiveStudents();
    }
    final List<Map<String, dynamic>> rows = await dbHelper.db.query(
      'students',
      where:
          "archived_at IS NULL AND (name LIKE ? OR (name || CASE WHEN duplicate_index > 1 THEN ' (' || duplicate_index || ')' ELSE '' END) LIKE ? OR phone LIKE ? OR first_name LIKE ? OR father_name LIKE ? OR family_name LIKE ?)",
      whereArgs: ['%$q%', '%$q%', '%$q%', '%$q%', '%$q%', '%$q%'],
      orderBy: 'name COLLATE NOCASE ASC, duplicate_index ASC, id ASC',
    );
    return rows.map((e) => Student.fromMap(e)).toList();
  }

  Future<int> addStudent(Student student) async {
    return dbHelper.db.transaction((txn) async {
      final parts = StudentRules.normalizeNameParts(
        firstName: student.firstName ?? '',
        fatherName: student.fatherName ?? '',
        familyName: student.familyName ?? '',
      );
      StudentRules.validateNameParts(parts);
      if (!StudentRules.isSupportedGrade(student.grade)) {
        throw const FormatException('invalid_grade');
      }
      final phone = StudentRules.normalizePhone(student.phone ?? '');
      final guardian = StudentRules.normalizePhone(student.guardianPhone ?? '');
      final age = StudentRules.validateAge(student.age);
      final name = parts.join(' ');
      final duplicates = await _findDuplicateRows(
        txn,
        firstName: parts[0],
        fatherName: parts[1],
        familyName: parts[2],
        grade: student.grade,
        fullName: name,
      );
      final index =
          duplicates.fold<int>(
            1,
            (max, row) => (row['duplicate_index'] as int? ?? 1) > max
                ? row['duplicate_index'] as int
                : max,
          ) +
          (duplicates.isEmpty ? 0 : 1);
      final map = student.toMap()
        ..remove('id')
        ..['name'] = name
        ..['first_name'] = parts[0]
        ..['father_name'] = parts[1]
        ..['family_name'] = parts[2]
        ..['phone'] = phone.isEmpty ? null : phone
        ..['guardian_phone'] = guardian.isEmpty ? null : guardian
        ..['age'] = age
        ..['notes'] = _cleanNotes(student.notes)
        ..['duplicate_index'] = index;
      final id = await txn.insert('students', map);
      await _reindexDuplicateGroup(
        txn,
        firstName: parts[0],
        fatherName: parts[1],
        familyName: parts[2],
        grade: student.grade,
      );
      return id;
    });
  }

  Future<List<Student>> findByNameAndGrade(String name, String grade) async {
    final rows = await dbHelper.db.query(
      'students',
      where:
          'archived_at IS NULL AND name = ? COLLATE NOCASE AND grade = ? COLLATE NOCASE',
      whereArgs: [name.trim(), grade.trim()],
      orderBy: 'id ASC',
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<List<Student>> findPotentialDuplicates({
    required String firstName,
    required String fatherName,
    required String familyName,
    required String grade,
  }) async {
    final parts = StudentRules.normalizeNameParts(
      firstName: firstName,
      fatherName: fatherName,
      familyName: familyName,
    );
    StudentRules.validateNameParts(parts);
    final name = parts.join(' ');
    final rows = await _findDuplicateRows(
      dbHelper.db,
      firstName: parts[0],
      fatherName: parts[1],
      familyName: parts[2],
      grade: grade,
      fullName: name,
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<List<Map<String, Object?>>> _findDuplicateRows(
    DatabaseExecutor executor, {
    required String firstName,
    required String fatherName,
    required String familyName,
    required String grade,
    required String fullName,
    int? excludingId,
  }) async {
    final rows = await executor.query(
      'students',
      where: 'archived_at IS NULL AND grade = ? COLLATE NOCASE',
      whereArgs: [grade],
      orderBy: 'created_at ASC, id ASC',
    );
    final targetParts = [firstName, fatherName, familyName]
        .map((part) => StudentRules.normalizeNamePart(part).toLowerCase())
        .toList();
    final targetFullName = StudentRules.normalizeName(fullName);
    return rows.where((row) {
      if (row['id'] == excludingId) return false;
      final parts = [
        row['first_name'] as String?,
        row['father_name'] as String?,
        row['family_name'] as String?,
      ];
      if (parts.every((part) => part != null)) {
        return List.generate(
          3,
          (i) => StudentRules.normalizeNamePart(parts[i]!).toLowerCase(),
        ).asMap().entries.every(
          (entry) => entry.value == targetParts[entry.key],
        );
      }
      return parts.every((part) => part == null) &&
          StudentRules.normalizeName(row['name'] as String) == targetFullName;
    }).toList();
  }

  Future<int> updateStudent(Student student) async {
    return dbHelper.db.transaction((txn) async {
      final currentRows = await txn.query(
        'students',
        where: 'id = ?',
        whereArgs: [student.id],
        limit: 1,
      );
      if (currentRows.isEmpty) return 0;
      final current = currentRows.first;
      final oldFirst = current['first_name'] as String?;
      final oldFather = current['father_name'] as String?;
      final oldFamily = current['family_name'] as String?;
      final legacyName =
          oldFirst == null && oldFather == null && oldFamily == null;
      final parts = StudentRules.normalizeNameParts(
        firstName: student.firstName ?? '',
        fatherName: student.fatherName ?? '',
        familyName: student.familyName ?? '',
      );
      final noParts = parts.every((part) => part.isEmpty);
      if (!noParts) StudentRules.validateNameParts(parts);
      if (noParts && !legacyName) {
        throw const FormatException('required_name_part');
      }
      final preserveLegacyName = legacyName && noParts;
      final grade = student.grade.trim();
      if (grade.isEmpty ||
          (grade != current['grade'] &&
              !StudentRules.isSupportedGrade(grade))) {
        throw const FormatException('invalid_grade');
      }
      final phone = StudentRules.normalizePhone(student.phone ?? '');
      final guardian = StudentRules.normalizePhone(student.guardianPhone ?? '');
      final age = StudentRules.validateAge(student.age);
      final name = preserveLegacyName
          ? current['name'] as String
          : parts.join(' ');
      final map = student.toMap()
        ..['name'] = name
        ..['grade'] = grade
        ..['first_name'] = preserveLegacyName ? null : parts[0]
        ..['father_name'] = preserveLegacyName ? null : parts[1]
        ..['family_name'] = preserveLegacyName ? null : parts[2]
        ..['phone'] = phone.isEmpty ? null : phone
        ..['guardian_phone'] = guardian.isEmpty ? null : guardian
        ..['age'] = age
        ..['notes'] = _cleanNotes(student.notes)
        ..['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      final changed = await txn.update(
        'students',
        map,
        where: 'id = ?',
        whereArgs: [student.id],
      );
      if (changed == 0) return 0;
      if (!legacyName) {
        await _reindexDuplicateGroup(
          txn,
          firstName: oldFirst!,
          fatherName: oldFather!,
          familyName: oldFamily!,
          grade: current['grade'] as String,
        );
      } else if (!preserveLegacyName) {
        await _reindexLegacyDuplicateGroup(
          txn,
          name: current['name'] as String,
          grade: current['grade'] as String,
        );
      }
      if (!preserveLegacyName) {
        await _reindexDuplicateGroup(
          txn,
          firstName: parts[0],
          fatherName: parts[1],
          familyName: parts[2],
          grade: grade,
        );
      }
      return changed;
    });
  }

  Future<int> archiveStudent(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return dbHelper.db.transaction((txn) async {
      final rows = await txn.query(
        'students',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return 0;
      final student = rows.single;
      final changed = await txn.update(
        'students',
        {'archived_at': now, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [id],
      );
      final first = student['first_name'] as String?;
      final father = student['father_name'] as String?;
      final family = student['family_name'] as String?;
      if (changed > 0 && first != null && father != null && family != null) {
        await _reindexDuplicateGroup(
          txn,
          firstName: first,
          fatherName: father,
          familyName: family,
          grade: student['grade'] as String,
        );
      } else if (changed > 0 &&
          first == null &&
          father == null &&
          family == null) {
        await _reindexLegacyDuplicateGroup(
          txn,
          name: student['name'] as String,
          grade: student['grade'] as String,
        );
      }
      return changed;
    });
  }

  Future<void> _reindexDuplicateGroup(
    DatabaseExecutor executor, {
    required String firstName,
    required String fatherName,
    required String familyName,
    required String grade,
  }) async {
    final fullName = '$firstName $fatherName $familyName';
    final rows = await executor.query(
      'students',
      where: 'archived_at IS NULL AND grade = ? COLLATE NOCASE',
      whereArgs: [grade],
    );
    final targetParts = [firstName, fatherName, familyName]
        .map((part) => StudentRules.normalizeNamePart(part).toLowerCase())
        .toList();
    final targetFullName = StudentRules.normalizeName(fullName);
    final matches = rows.where((row) {
      final parts = [
        row['first_name'] as String?,
        row['father_name'] as String?,
        row['family_name'] as String?,
      ];
      if (parts.every((part) => part != null)) {
        for (var i = 0; i < 3; i++) {
          if (StudentRules.normalizeNamePart(parts[i]!).toLowerCase() !=
              targetParts[i]) {
            return false;
          }
        }
        return true;
      }
      return parts.every((part) => part == null) &&
          StudentRules.normalizeName(row['name'] as String) == targetFullName;
    }).toList()..sort(_compareDuplicateRows);
    for (var i = 0; i < matches.length; i++) {
      await executor.update(
        'students',
        {'duplicate_index': i + 1},
        where: 'id = ?',
        whereArgs: [matches[i]['id']],
      );
    }
  }

  Future<void> _reindexLegacyDuplicateGroup(
    DatabaseExecutor executor, {
    required String name,
    required String grade,
  }) async {
    final rows = await executor.query(
      'students',
      where: 'archived_at IS NULL AND grade = ? COLLATE NOCASE',
      whereArgs: [grade],
    );
    final target = StudentRules.normalizeName(name);
    final matches = rows.where((row) {
      final parts = [
        row['first_name'] as String?,
        row['father_name'] as String?,
        row['family_name'] as String?,
      ];
      final candidate = parts.every((part) => part == null)
          ? row['name'] as String
          : parts.every((part) => part != null)
          ? parts.join(' ')
          : '';
      return StudentRules.normalizeName(candidate) == target;
    }).toList()..sort(_compareDuplicateRows);
    for (var i = 0; i < matches.length; i++) {
      await executor.update(
        'students',
        {'duplicate_index': i + 1},
        where: 'id = ?',
        whereArgs: [matches[i]['id']],
      );
    }
  }

  int _compareDuplicateRows(Map<String, Object?> a, Map<String, Object?> b) {
    final createdAt = (a['created_at'] as int).compareTo(
      b['created_at'] as int,
    );
    return createdAt != 0
        ? createdAt
        : (a['id'] as int).compareTo(b['id'] as int);
  }

  String? _cleanNotes(String? notes) {
    final trimmed = notes?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
