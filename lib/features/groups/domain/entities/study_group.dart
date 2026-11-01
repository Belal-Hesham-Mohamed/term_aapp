class StudyGroup {
  final int id;
  final String name;
  final String targetGrade;
  final String? notes;
  final int createdAt;
  final int updatedAt;
  final int activeStudentCount;
  final bool setupCompleted;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.targetGrade,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.activeStudentCount = 0,
    this.setupCompleted = true,
  });

  factory StudyGroup.fromMap(Map<String, Object?> map) => StudyGroup(
    id: map['id'] as int,
    name: map['name'] as String,
    targetGrade: map['target_grade'] as String,
    notes: map['notes'] as String?,
    createdAt: map['created_at'] as int,
    updatedAt: map['updated_at'] as int,
    activeStudentCount: (map['active_student_count'] as int?) ?? 0,
    setupCompleted: (map['setup_completed'] as int? ?? 1) == 1,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'target_grade': targetGrade,
    'notes': notes,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'setup_completed': setupCompleted ? 1 : 0,
  };
}
