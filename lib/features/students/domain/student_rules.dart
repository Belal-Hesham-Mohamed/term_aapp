class StudentRules {
  static const gradeIds = [
    'primary_1',
    'primary_2',
    'primary_3',
    'primary_4',
    'primary_5',
    'primary_6',
    'preparatory_1',
    'preparatory_2',
    'preparatory_3',
    'secondary_1',
    'secondary_2',
    'secondary_3',
  ];

  static String normalizeNamePart(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String normalizePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final compact = trimmed.replaceAll(RegExp(r'[ -]'), '');
    if (RegExp(r'^01[0125]\d{8}$').hasMatch(compact)) {
      return '+20${compact.substring(1)}';
    }
    if (RegExp(r'^\+201[0125]\d{8}$').hasMatch(compact)) {
      return compact;
    }
    throw const FormatException('invalid_phone');
  }

  static int? parseAge(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final age = int.tryParse(text);
    if (age == null || age < 4 || age > 30) {
      throw const FormatException('invalid_age');
    }
    return age;
  }

  static String normalizeName(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  static bool isSupportedGrade(String grade) => gradeIds.contains(grade);

  static List<String> normalizeNameParts({
    required String firstName,
    required String fatherName,
    required String familyName,
  }) => [
    normalizeNamePart(firstName),
    normalizeNamePart(fatherName),
    normalizeNamePart(familyName),
  ];

  static void validateNameParts(Iterable<String> parts) {
    if (parts.any((part) => part.isEmpty)) {
      throw const FormatException('required_name_part');
    }
  }

  static int? validateAge(int? age) =>
      age == null ? null : parseAge(age.toString());
}
