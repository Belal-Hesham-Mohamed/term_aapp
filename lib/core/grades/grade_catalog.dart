class GradeCatalog {
  static const ids = [
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

  static bool contains(String id) => ids.contains(id);
}
