import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/ftue_welcome_sheet.dart';
import '../widgets/modern_bible_icons.dart';
import 'home_reader_screen.dart';
import 'home_dashboard_screen.dart';
import 'reading_plans_screen.dart';
import 'search_screen.dart';
import 'annotations_screen.dart';
import 'settings_screen.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0; // 0: ንባብ (Bible), 1: መነሻ (Home), 2: ዕቅዶች (Plans), 3: ማህደር (Saved)
  bool _isReaderChromeVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFtueWelcome();
    });
  }

  Future<void> _checkFtueWelcome() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShown = prefs.getBool(FtueWelcomeSheet.prefsKey) ?? false;
      if (!hasShown && mounted) {
        FtueWelcomeSheet.show(context);
      }
    } catch (_) {
      // Graceful fallback in constrained test/headless environments
    }
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
        _isReaderChromeVisible = true;
      });
    }
  }

  void _openSearch(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          onNavigateToReader: (tab) {
            Navigator.of(context).pop();
            _onTabSelected(0);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final isEnglish = ref.watch(isEnglishUiProvider);

    final screens = [
      HomeReaderScreen(
        onChromeVisibilityChanged: (visible) {
          if (_currentIndex == 0 && _isReaderChromeVisible != visible) {
            setState(() => _isReaderChromeVisible = visible);
          }
        },
        onNavigateTab: _onTabSelected,
        onOpenSearch: () => _openSearch(context),
      ),
      HomeDashboardScreen(onNavigateTab: _onTabSelected),
      ReadingPlansScreen(onNavigateToReader: _onTabSelected),
      AnnotationsScreen(onNavigateToReader: _onTabSelected),
      const SettingsScreen(),
    ];

    final showBottomBar = _currentIndex != 0 || _isReaderChromeVisible;

    // Active pill capsule color
    final activePillColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : themeConfig.accentColor.withValues(alpha: 0.12);

    final activeColor = isDark ? Colors.white : themeConfig.accentColor;
    final inactiveColor = isDark
        ? const Color(0xFF8E95A3)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: Stack(
        children: [
          // 1. Screen Body
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // 2. Floating Search Button for Tabs 1, 2, 3
          if (_currentIndex != 0 && _currentIndex != 4)
            Positioned(
              bottom: 80,
              right: 18,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1.0,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2128) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E333D)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: ModernSearchIcon(
                      size: 20,
                      color: themeConfig.textColor,
                    ),
                    onPressed: () => _openSearch(context),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        offset: showBottomBar ? Offset.zero : const Offset(0, 1.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: showBottomBar ? 1.0 : 0.0,
          child: Container(
            decoration: BoxDecoration(
              color: themeConfig.surfaceColor.withValues(alpha: 0.98),
              border: Border(
                top: BorderSide(
                  color: themeConfig.cardBorderColor.withValues(alpha: 0.6),
                  width: 0.8,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 58,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Tab 0: ንባብ (Bible)
                    _buildNavItem(
                      index: 0,
                      label: isEnglish ? 'Bible' : 'ንባብ',
                      isEnglish: isEnglish,
                      activePillColor: activePillColor,
                      iconBuilder: (isActive) => ModernBibleIcon(
                        size: 21,
                        color: isActive ? activeColor : inactiveColor,
                        isFilled: isActive,
                      ),
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),

                    // Tab 1: መነሻ (Home / Library)
                    _buildNavItem(
                      index: 1,
                      label: isEnglish ? 'Home' : 'መነሻ',
                      isEnglish: isEnglish,
                      activePillColor: activePillColor,
                      iconBuilder: (isActive) => ModernLibraryIcon(
                        size: 21,
                        color: isActive ? activeColor : inactiveColor,
                        isFilled: isActive,
                      ),
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),

                    // Tab 2: ዕቅዶች (Lectionary / Plans)
                    _buildNavItem(
                      index: 2,
                      label: isEnglish ? 'Plans' : 'ዕቅዶች',
                      isEnglish: isEnglish,
                      activePillColor: activePillColor,
                      iconBuilder: (isActive) => ModernLectionaryIcon(
                        size: 21,
                        color: isActive ? activeColor : inactiveColor,
                        isFilled: isActive,
                      ),
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),

                    // Tab 3: ማህደር (Highlights / Saved)
                    _buildNavItem(
                      index: 3,
                      label: isEnglish ? 'Saved' : 'ማህደር',
                      isEnglish: isEnglish,
                      activePillColor: activePillColor,
                      iconBuilder: (isActive) => ModernHighlightsIcon(
                        size: 21,
                        color: isActive ? activeColor : inactiveColor,
                        isFilled: isActive,
                      ),
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),

                    // Tab 4: ቅንብሮች (Settings)
                    _buildNavItem(
                      index: 4,
                      label: isEnglish ? 'Settings' : 'ቅንብሮች',
                      isEnglish: isEnglish,
                      activePillColor: activePillColor,
                      iconBuilder: (isActive) => ModernSettingsIcon(
                        size: 21,
                        color: isActive ? activeColor : inactiveColor,
                        isFilled: isActive,
                      ),
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required bool isEnglish,
    required Color activePillColor,
    required Widget Function(bool isActive) iconBuilder,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabSelected(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? activePillColor : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: iconBuilder(isSelected),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: isEnglish
                  ? GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
                      letterSpacing: 0.15,
                    )
                  : GoogleFonts.notoSansEthiopic(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
                      letterSpacing: 0.15,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
