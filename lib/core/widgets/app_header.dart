import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import 'term_logo.dart';

/// Shared TERM brand row.
///
/// Physical arrangement is preserved across locales:
/// LEFT: logo + TERM text + Arabic subtitle.
/// RIGHT: notification button.
///
/// This widget does not own safe-area handling; the page shell should
/// provide any needed top inset.
class AppBrandHeader extends StatelessWidget {
  final String? subtitle;
  final VoidCallback? onNotificationTap;

  const AppBrandHeader({super.key, this.subtitle, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotificationTap,
            icon: Icon(Icons.notifications_outlined, color: AppColors.surface),
          ),
        ],
      ),
    );
  }
}

/// Shared page title row.
class AppPageHeader extends StatelessWidget {
  final String title;
  final IconData titleIcon;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          Icon(titleIcon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class AppHeaderContainer extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final String? subtitle;
  final VoidCallback? onNotificationTap;

  const AppHeaderContainer({
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
        padding: EdgeInsets.only(top: topPadding + 10, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBrandHeader(
              subtitle: subtitle,
              onNotificationTap: onNotificationTap,
            ),
            const SizedBox(height: 16),
            AppPageHeader(title: title, titleIcon: titleIcon),
          ],
        ),
      ),
    );
  }
}
