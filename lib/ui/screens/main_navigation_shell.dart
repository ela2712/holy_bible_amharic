import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import 'home_reader_screen.dart';
import 'reading_plans_screen.dart';
import 'search_screen.dart';
import 'annotations_screen.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0; // Opens directly into the Scripture Reader (Catena UX)
  bool _isReaderChromeVisible = true;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _isReaderChromeVisible = true;
    });
  }

  static const List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.auto_stories_outlined, 'activeIcon': Icons.auto_stories_rounded, 'label': 'ንባብ (Read)'},
    {'icon': Icons.explore_outlined, 'activeIcon': Icons.explore_rounded, 'label': 'ዕቅዶች (Plans)'},
    {'icon': Icons.search_rounded, 'activeIcon': Icons.search_rounded, 'label': 'ፍለጋ (Search)'},
    {'icon': Icons.bookmarks_outlined, 'activeIcon': Icons.bookmarks_rounded, 'label': 'ማህደር (Saved)'},
  ];

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;

    final screens = [
      HomeReaderScreen(
        onChromeVisibilityChanged: (visible) {
          if (_currentIndex == 0 && _isReaderChromeVisible != visible) {
            setState(() => _isReaderChromeVisible = visible);
          }
        },
        onNavigateTab: _onTabSelected,
      ),
      ReadingPlansScreen(onNavigateToReader: _onTabSelected),
      SearchScreen(onNavigateToReader: _onTabSelected),
      AnnotationsScreen(onNavigateToReader: _onTabSelected),
    ];

    final showBottomBar = _currentIndex != 0 || _isReaderChromeVisible;

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        offset: showBottomBar ? Offset.zero : const Offset(0, 1.4),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: showBottomBar ? 1.0 : 0.0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Center(
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeConfig.surfaceColor.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: themeConfig.cardBorderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(_navItems.length, (idx) {
                            final item = _navItems[idx];
                            final isSelected = _currentIndex == idx;

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _onTabSelected(idx),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSelected ? 16 : 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? themeConfig.textColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSelected
                                          ? item['activeIcon'] as IconData
                                          : item['icon'] as IconData,
                                      size: 20,
                                      color: isSelected
                                          ? themeConfig.backgroundColor
                                          : themeConfig.secondaryTextColor,
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 7),
                                      Text(
                                        (item['label'] as String).split(' ')[0],
                                        style: GoogleFonts.notoSansEthiopic(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: themeConfig.backgroundColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
