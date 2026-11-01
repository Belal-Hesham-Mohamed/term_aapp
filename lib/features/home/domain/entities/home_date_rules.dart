class HomeDateRules {
  /// Returns the local Saturday that starts the current Egyptian calendar week.
  static DateTime weekStart(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: (day.weekday + 1) % 7));
  }

  static DateTime weekEndExclusive(DateTime date) =>
      weekStart(date).add(const Duration(days: 7));
}
