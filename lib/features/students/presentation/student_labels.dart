import '../../../l10n/app_localizations.dart';

String localizedGrade(AppLocalizations l10n, String grade) => switch (grade) {
  'primary_1' => l10n.gradePrimary1,
  'primary_2' => l10n.gradePrimary2,
  'primary_3' => l10n.gradePrimary3,
  'primary_4' => l10n.gradePrimary4,
  'primary_5' => l10n.gradePrimary5,
  'primary_6' => l10n.gradePrimary6,
  'preparatory_1' => l10n.gradePreparatory1,
  'preparatory_2' => l10n.gradePreparatory2,
  'preparatory_3' => l10n.gradePreparatory3,
  'secondary_1' => l10n.gradeSecondary1,
  'secondary_2' => l10n.gradeSecondary2,
  'secondary_3' => l10n.gradeSecondary3,
  _ => grade,
};
