import 'package:flutter_test/flutter_test.dart';
import 'package:term/features/students/domain/student_rules.dart';

void main() {
  test('exposes the twelve stable grades in business order', () {
    expect(StudentRules.gradeIds, [
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
    ]);
  });

  test('normalizes supported Egyptian mobile formats', () {
    for (final local in [
      '01012345678',
      '01112345678',
      '01212345678',
      '01512345678',
    ]) {
      expect(StudentRules.normalizePhone(local), '+20${local.substring(1)}');
      expect(
        StudentRules.normalizePhone('+20${local.substring(1)}'),
        '+20${local.substring(1)}',
      );
    }
    expect(StudentRules.normalizePhone(' 010 1234-5678 '), '+201012345678');
    expect(StudentRules.normalizePhone(' -  '), '');
    expect(StudentRules.normalizePhone('   '), '');
  });

  test('rejects malformed and unsupported Egyptian numbers', () {
    for (final invalid in [
      '02012345678',
      '0101234567',
      '010123456789',
      '+2001012345678',
      'abc',
      '+201612345678',
      '+20101234567-',
    ]) {
      expect(
        () => StudentRules.normalizePhone(invalid),
        throwsFormatException,
        reason: invalid,
      );
    }
  });

  test(
    'age is optional and limited to integer ages from four through thirty',
    () {
      expect(StudentRules.parseAge('  '), isNull);
      expect(StudentRules.parseAge('4'), 4);
      expect(StudentRules.parseAge('30'), 30);
      for (final invalid in ['3', '31', '-1', '12.5', 'abc']) {
        expect(
          () => StudentRules.parseAge(invalid),
          throwsFormatException,
          reason: invalid,
        );
      }
    },
  );

  test('normalizes name whitespace without Arabic character substitutions', () {
    expect(StudentRules.normalizeNamePart('  Mona   Ali '), 'Mona Ali');
    expect(StudentRules.normalizeName('  MONA   Ali '), 'mona ali');
    expect(StudentRules.normalizeNamePart('أحمد'), 'أحمد');
  });
}
