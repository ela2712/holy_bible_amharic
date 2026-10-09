import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import 'home_dashboard_screen.dart';
import 'home_reader_screen.dart';
import 'search_screen.dart';
import 'reading_plans_screen.dart';
import 'annotations_screen.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);

    final screens = [
      HomeDashboardScreen(onNavigateTab: _onTabSelected),
      const HomeReaderScreen(),
      const SearchScreen(),
      ReadingPlansScreen(onNavigateToReader: _onTabSelected),
      const AnnotationsScreen(),
    ];

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        backgroundColor: themeConfig.surfaceColor,
        indicatorColor: themeConfig.accentColor.withValues(alpha: 0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: themeConfig.accentColor),
            label: 'መነሻ',
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: themeConfig.accentColor),
            label: 'መጽሐፍ',
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: themeConfig.accentColor),
            label: 'ፍለጋ',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today, color: themeConfig.accentColor),
            label: 'ዕቅድ',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: themeConfig.accentColor),
            label: 'የእኔ',
          ),
        ],
      ),
    );
  }
}
