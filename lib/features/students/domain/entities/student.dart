// lib/features/students/domain/entities/student.dart

const _notProvided = Object();

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
  final String? firstName;
  final String? fatherName;
  final String? familyName;
  final int duplicateIndex;

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
    this.firstName,
    this.fatherName,
    this.familyName,
    this.duplicateIndex = 1,
  });

  String get fullName => [firstName, fatherName, familyName]
      .whereType<String>()
      .where((part) => part.trim().isNotEmpty)
      .map((part) => part.trim())
      .join(' ');
  String get displayName => duplicateIndex > 1
      ? '${fullName.isNotEmpty ? fullName : name} ($duplicateIndex)'
      : (fullName.isNotEmpty ? fullName : name);

  Student copyWith({
    int? id,
    String? name,
    String? grade,
    Object? phone = _notProvided,
    Object? age = _notProvided,
    Object? guardianPhone = _notProvided,
    Object? notes = _notProvided,
    Object? archivedAt = _notProvided,
    int? createdAt,
    int? updatedAt,
    Object? firstName = _notProvided,
    Object? fatherName = _notProvided,
    Object? familyName = _notProvided,
    int? duplicateIndex,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      phone: identical(phone, _notProvided) ? this.phone : phone as String?,
      age: identical(age, _notProvided) ? this.age : age as int?,
      guardianPhone: identical(guardianPhone, _notProvided)
          ? this.guardianPhone
          : guardianPhone as String?,
      notes: identical(notes, _notProvided) ? this.notes : notes as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: identical(archivedAt, _notProvided)
          ? this.archivedAt
          : archivedAt as int?,
      firstName: identical(firstName, _notProvided)
          ? this.firstName
          : firstName as String?,
      fatherName: identical(fatherName, _notProvided)
          ? this.fatherName
          : fatherName as String?,
      familyName: identical(familyName, _notProvided)
          ? this.familyName
          : familyName as String?,
      duplicateIndex: duplicateIndex ?? this.duplicateIndex,
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
    firstName: map['first_name'] as String?,
    fatherName: map['father_name'] as String?,
    familyName: map['family_name'] as String?,
    duplicateIndex: map['duplicate_index'] as int? ?? 1,
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
      'first_name': firstName,
      'father_name': fatherName,
      'family_name': familyName,
      'duplicate_index': duplicateIndex,
    };
  }
}
