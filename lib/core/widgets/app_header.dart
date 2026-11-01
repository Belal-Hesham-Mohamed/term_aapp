import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import 'term_logo.dart';

/// Shared header composition for the main shell pages.
///
/// It does not paint its own background. The blue gradient and curve are
/// provided by [AppBackground] at the shell level so the header and
/// background remain one continuous composition.
class AppHeader extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final String? subtitle;
  final VoidCallback? onNotificationTap;

  const AppHeader({
    super.key,
    required this.title,
    required this.titleIcon,
    this.subtitle,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding + 10,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const TermLogo(size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TERM',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.surface.withValues(alpha: 0.9),
                              ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onNotificationTap,
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(titleIcon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
