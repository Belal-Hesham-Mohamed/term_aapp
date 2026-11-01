// lib/core/navigation/main_navigation.dart
import 'package:flutter/material.dart';
import '../../features/students/presentation/pages/student_list_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/lessons/presentation/pages/lessons_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../core/widgets/app_background.dart';
import '../../l10n/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    StudentListPage(),
    GroupsPage(),
    LessonsPage(),
    _PlaceholderPage(titleKey: 'more'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
      BottomNavigationBarItem(
        icon: const Icon(Icons.people),
        label: l10n.students,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.group_work),
        label: l10n.groups,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.event_note),
        label: l10n.lessons,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.more_horiz),
        label: l10n.more,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: items,
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String titleKey;
  const _PlaceholderPage({required this.titleKey});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String title = '';
    switch (titleKey) {
      case 'home':
        title = l10n.home;
        break;
      case 'groups':
        title = l10n.groups;
        break;
      case 'lessons':
        title = l10n.lessons;
        break;
      case 'more':
        title = l10n.more;
        break;
      default:
        title = titleKey;
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
