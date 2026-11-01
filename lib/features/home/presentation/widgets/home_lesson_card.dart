import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../../../core/theme/app_tokens.dart';
import '../../../lessons/domain/entities/lesson_record.dart';

class HomeLessonCard extends StatelessWidget {
  final LessonRecord lesson;
  final VoidCallback onTap;

  const HomeLessonCard({super.key, required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final time = _formatTimeRange(locale);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(Icons.menu_book_outlined, color: colors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.groupName, style: textTheme.titleMedium),
                    if (time.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        time,
                        style: textTheme.bodyMedium,
                        textDirection: ui.TextDirection.ltr,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.arrow_forward, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(String locale) {
    final values = [lesson.startTime, lesson.endTime]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .map((value) => _formatTime(value, locale))
        .toList();
    return values.join(' – ');
  }

  String _formatTime(String value, String locale) {
    final parts = value.split(':');
    if (parts.length != 2) return value;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return value;
    }
    return DateFormat.jm(locale).format(DateTime(2020, 1, 1, hour, minute));
  }
}
