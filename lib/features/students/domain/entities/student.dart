// lib/features/students/domain/entities/student.dart

class Student {
  final int id;
  final String name;
  final String grade;
  final String? phone;
  final int? age;
  final String? guardianPhone;
  final String? notes;
  final int createdAt;
  final int updatedAt;
  final int? archivedAt;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    this.phone,
    this.age,
    this.guardianPhone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  Student copyWith({
    int? id,
    String? name,
    String? grade,
    String? phone,
    int? age,
    String? guardianPhone,
    String? notes,
    int? createdAt,
    int? updatedAt,
    int? archivedAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  factory Student.fromMap(Map<String, dynamic> map) => Student(
        id: map['id'] as int,
        name: map['name'] as String,
        grade: map['grade'] as String,
        phone: map['phone'] as String?,
        age: map['age'] as int?,
        guardianPhone: map['guardian_phone'] as String?,
        notes: map['notes'] as String?,
        createdAt: map['created_at'] as int,
        updatedAt: map['updated_at'] as int,
        archivedAt: map['archived_at'] as int?,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'phone': phone,
      'age': age,
      'guardian_phone': guardianPhone,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}
