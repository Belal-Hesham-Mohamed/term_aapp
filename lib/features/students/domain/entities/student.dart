// lib/features/students/domain/entities/student.dart

class Student {
  final int id;
  final String name;
  final String grade;
  final String? phone;
  final int? archivedAt;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    this.phone,
    this.archivedAt,
  });

  factory Student.fromMap(Map<String, dynamic> map) => Student(
        id: map['id'] as int,
        name: map['name'] as String,
        grade: map['grade'] as String,
        phone: map['phone'] as String?,
        archivedAt: map['archived_at'] as int?,
      );
}
