import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class HomeStatisticCard extends StatelessWidget {
  final double width;
  final String label;
  final int value;
  final IconData icon;

  const HomeStatisticCard({
    super.key,
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(icon, color: colors.primary, size: 20),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$value',
                style: textTheme.displaySmall?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(label, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
