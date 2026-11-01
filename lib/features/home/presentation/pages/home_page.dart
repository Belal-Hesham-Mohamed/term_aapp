import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../lessons/presentation/pages/lesson_details_page.dart';
import '../cubit/home_cubit.dart';
import '../state/home_state.dart';
import '../widgets/home_lesson_card.dart';
import '../widgets/home_statistic_card.dart';
import '../widgets/home_welcome_card.dart';
import '../../../../core/widgets/app_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<HomeCubit>()..loadSummary(),
    child: const _HomeContent(),
  );
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeFailure) {
            return _HomeError(
              onRetry: () => context.read<HomeCubit>().loadSummary(),
            );
          }
          if (state is! HomeLoaded) return const SizedBox.shrink();

          final summary = state.summary;
          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().loadSummary(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AppHeaderContainer(
                  title: l10n.home,
                  titleIcon: Icons.home_outlined,
                  subtitle: null,
                  onNotificationTap: () {},
                ),
                const SizedBox(height: AppSpacing.lg),
                HomeWelcomeCard(
                  greeting: l10n.welcomeBack(
                    summary.teacherName ?? l10n.teacherNameFallback,
                  ),
                  subtitle: l10n.homeOverviewSubtitle,
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeading(
                  title: l10n.todaysLessons,
                  icon: Icons.today_outlined,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (summary.todaysLessons.isEmpty)
                  _EmptyLessonsCard(message: l10n.noLessonsToday)
                else
                  ...summary.todaysLessons.map(
                    (lesson) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: HomeLessonCard(
                        lesson: lesson,
                        onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LessonDetailsPage(lessonId: lesson.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeading(
                  title: l10n.homeSummary,
                  icon: Icons.insights_outlined,
                ),
                const SizedBox(height: AppSpacing.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = AppSpacing.sm;
                    final columns = constraints.maxWidth >= 640 ? 3 : 2;
                    final cardWidth =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        HomeStatisticCard(
                          width: cardWidth,
                          label: l10n.totalGroups,
                          value: summary.totalGroups,
                          icon: Icons.groups_outlined,
                        ),
                        HomeStatisticCard(
                          width: cardWidth,
                          label: l10n.totalStudents,
                          value: summary.totalStudents,
                          icon: Icons.school_outlined,
                        ),
                        HomeStatisticCard(
                          width: cardWidth,
                          label: l10n.lessonsThisWeek,
                          value: summary.lessonsThisWeek,
                          icon: Icons.calendar_view_week_outlined,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeading({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    ],
  );
}

class _EmptyLessonsCard extends StatelessWidget {
  final String message;

  const _EmptyLessonsCard({required this.message});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.event_available_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    ),
  );
}

class _HomeError extends StatelessWidget {
  final VoidCallback onRetry;

  const _HomeError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 44,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.homeLoadFailed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.homeRetry),
            ),
          ],
        ),
      ),
    );
  }
}
