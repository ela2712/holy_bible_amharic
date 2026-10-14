import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geez_numbers.dart';
import '../../data/patristic_commentaries.dart';
import '../../data/cross_references_data.dart';
import '../../models/commentary.dart';
import '../../models/cross_reference.dart';
import '../../models/verse.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import '../../providers/reading_plan_session_provider.dart';
import '../widgets/ethiopian_cross_painter.dart';
import '../widgets/modern_bible_icons.dart';
import 'book_selector_screen.dart';
import 'parallel_reader_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'study_tools_dialog.dart';

class HomeReaderScreen extends ConsumerStatefulWidget {
  final ValueChanged<bool>? onChromeVisibilityChanged;
  final Function(int tabIndex)? onNavigateTab;
  final VoidCallback? onOpenSearch;

  const HomeReaderScreen({
    super.key,
    this.onChromeVisibilityChanged,
    this.onNavigateTab,
    this.onOpenSearch,
  });

  @override
  ConsumerState<HomeReaderScreen> createState() => _HomeReaderScreenState();
}

class _HomeReaderScreenState extends ConsumerState<HomeReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isChromeVisible = true;
  int? _selectedVerseNumber;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _scrollController.offset > 60) {
      if (_isChromeVisible) {
        setState(() => _isChromeVisible = false);
        widget.onChromeVisibilityChanged?.call(false);
      }
    } else if (direction == ScrollDirection.forward || _scrollController.offset <= 20) {
      if (!_isChromeVisible) {
        setState(() => _isChromeVisible = true);
        widget.onChromeVisibilityChanged?.call(true);
      }
    }
  }

  void _restoreChrome() {
    if (!_isChromeVisible) {
      setState(() => _isChromeVisible = true);
      widget.onChromeVisibilityChanged?.call(true);
    }
  }

  void _scrollToApproximateVerse(int verseNumber, int totalVerses) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _selectedVerseNumber = verseNumber);
      if (!_scrollController.hasClients || totalVerses <= 1) return;
      if (verseNumber <= 2) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
        return;
      }
      final maxScroll = _scrollController.position.maxScrollExtent;
      final ratio = ((verseNumber - 1) / totalVerses).clamp(0.0, 1.0);
      _scrollController.animateTo(
        maxScroll * ratio,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String _formatNumber(int number, bool useGeez) {
    return useGeez ? GeezNumbers.toGeez(number) : '$number';
  }

  String _formatVerseLabel(Verse verse, bool useGeez) {
    if (verse.isMergedRange) {
      final start = useGeez ? GeezNumbers.toGeez(verse.verse) : '${verse.verse}';
      final end = useGeez ? GeezNumbers.toGeez(verse.verseEnd!) : '${verse.verseEnd}';
      return '$start–$end';
    }
    return _formatNumber(verse.verse, useGeez);
  }

  void _openVerseStudySheet(
    BuildContext context,
    Verse verse,
    BibleViewState bibleState, {
    int initialTabIndex = 0,
  }) {
    setState(() => _selectedVerseNumber = verse.verse);
    _restoreChrome();

    StudyToolsSheet.show(
      context,
      verse: verse,
      bookName: bibleState.currentBook?.name ?? '',
      bookNumber: bibleState.currentBook?.bookNumber ?? 1,
      repository: ref.read(bibleRepositoryProvider),
      onVerseUpdated: () {
        ref.read(bibleStateProvider.notifier).refreshVerses();
      },
      onDismissed: () {
        if (mounted) {
          setState(() => _selectedVerseNumber = null);
        }
      },
      onJumpToReference: (targetBookNum, targetCh, targetVerse) {
        if (mounted) {
          _scrollToApproximateVerse(targetVerse, 35);
        }
      },
      initialTabIndex: initialTabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bibleState = ref.watch(bibleStateProvider);
    final themeConfig = ref.watch(themeConfigProvider);
    final planSession = ref.watch(readingPlanSessionProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;

    final currentBook = bibleState.currentBook;
    final currentChapter = bibleState.currentChapter;
    final chapterStr = _formatNumber(currentChapter, themeConfig.useGeezNumerals);

    final headingsByVerse = <int, List<SectionHeading>>{};
    for (final h in bibleState.headings) {
      headingsByVerse.putIfAbsent(h.verse, () => []).add(h);
    }

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 1. Main Continuous Scripture Canvas
            Positioned.fill(
              child: bibleState.isLoading
                  ? Center(child: CircularProgressIndicator(color: themeConfig.accentColor))
                  : bibleState.verses.isEmpty
                      ? _buildEmptyState(context, themeConfig)
                      : GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity != null) {
                              if (details.primaryVelocity! < -300) {
                                ref.read(bibleStateProvider.notifier).nextChapter();
                                setState(() => _selectedVerseNumber = null);
                              } else if (details.primaryVelocity! > 300) {
                                ref.read(bibleStateProvider.notifier).prevChapter();
                                setState(() => _selectedVerseNumber = null);
                              }
                            }
                          },
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 740),
                              child: ListView(
                                controller: _scrollController,
                                padding: EdgeInsets.fromLTRB(
                                  22,
                                  18,
                                  22,
                                  planSession.activeSessionPlan != null ? 180 : 140,
                                ),
                                children: [
                                  // Editorial Chapter Header
                                  _buildEditorialChapterHeader(
                                    context,
                                    currentBook?.name ?? 'መጽሐፍ ቅዱስ',
                                    currentBook?.nameEn ?? '',
                                    currentBook?.bookNumber ?? 1,
                                    currentChapter,
                                    chapterStr,
                                    bibleState,
                                    themeConfig,
                                    isDark,
                                  ),
                                  const SizedBox(height: 18),

                                  // Continuous Paragraph Mode vs Minimalist Verse Flow
                                  if (themeConfig.isParagraphMode)
                                    _buildParagraphModeFlow(
                                      context,
                                      bibleState,
                                      headingsByVerse,
                                      themeConfig,
                                      isDark,
                                    )
                                  else
                                    ...bibleState.verses.map((verse) {
                                      final verseHeadings = headingsByVerse[verse.verse] ?? [];
                                      return _buildScriptureVerseRow(
                                        context,
                                        verse,
                                        verseHeadings,
                                        bibleState,
                                        themeConfig,
                                        isDark,
                                      );
                                    }),

                                  const SizedBox(height: 36),

                                  // Clean Prev / Next Chapter Footer
                                  _buildChapterNavigationFooter(bibleState, themeConfig),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),

            // 2. Active Reading Plan In-Reader Floating Bar (if user is reading a plan)
            if (planSession.activeSessionPlan != null && planSession.activePassage != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                bottom: _isChromeVisible ? 134 : 20,
                left: 16,
                right: 16,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: _buildActivePlanFloatingBar(
                      context,
                      planSession,
                      bibleState,
                      themeConfig,
                      isDark,
                    ),
                  ),
                ),
              ),

            // 3. Auto-Hiding Floating Bottom Interaction Bar (Catena-Style)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              bottom: _isChromeVisible ? 76 : -90,
              left: 16,
              right: 16,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _buildFloatingBottomInteractionBar(
                    context,
                    currentBook?.name ?? 'መጽሐፍ ምረጥ',
                    chapterStr,
                    bibleState,
                    themeConfig,
                    isDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBottomInteractionBar(
    BuildContext context,
    String bookName,
    String chapterStr,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. Dual Capsule Chapter Switcher Pill [ ‹  Book Chapter  › ]
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: themeConfig.surfaceColor.withValues(alpha: isDark ? 0.90 : 0.94),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: themeConfig.cardBorderColor.withValues(alpha: 0.9),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Prev Chapter Chevron
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(bibleStateProvider.notifier).prevChapter();
                        setState(() => _selectedVerseNumber = null);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        alignment: Alignment.center,
                        child: Icon(
                          CupertinoIcons.chevron_left,
                          size: 16,
                          color: themeConfig.secondaryTextColor,
                        ),
                      ),
                    ),
                  ),

                  // Center: Book & Chapter Name (Tap opens BookSelector)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        BookSelectorScreen.show(
                          context,
                          onVerseSelected: (vNum) {
                            _scrollToApproximateVerse(vNum, bibleState.verses.length);
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$bookName $chapterStr',
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: themeConfig.textColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              CupertinoIcons.chevron_down,
                              size: 12,
                              color: themeConfig.accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Next Chapter Chevron
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(bibleStateProvider.notifier).nextChapter();
                        setState(() => _selectedVerseNumber = null);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        alignment: Alignment.center,
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: themeConfig.secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // 2. Floating Search Squircle Button [ 🔍 ] (Matching Catena Screenshot 1)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: themeConfig.surfaceColor.withValues(alpha: isDark ? 0.90 : 0.94),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeConfig.cardBorderColor.withValues(alpha: 0.9),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.onOpenSearch != null) {
                      widget.onOpenSearch!();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchScreen(
                            onNavigateToReader: (_) => Navigator.pop(context),
                          ),
                        ),
                      );
                    }
                  },
                  child: Center(
                    child: ModernSearchIcon(
                      size: 20,
                      color: themeConfig.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openReaderSettingsModal(
    BuildContext context,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final currentTheme = ref.watch(themeConfigProvider);
            final currentBible = ref.watch(bibleStateProvider);
            final currentIsDark = currentTheme.mode == ReaderThemeMode.dark;

            return Container(
              decoration: BoxDecoration(
                color: currentTheme.surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: currentIsDark ? 0.5 : 0.15),
                    blurRadius: 28,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: currentTheme.cardBorderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header Row
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.slider_horizontal_3,
                            size: 20,
                            color: currentTheme.accentColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'የንባብ ገጽታና ቅንብሮች',
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: currentTheme.textColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(Icons.close_rounded, color: currentTheme.secondaryTextColor),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 1, color: currentTheme.cardBorderColor),
                      const SizedBox(height: 18),

                      // 1. Translations (1954, 81, KJV)
                      Text(
                        'ትርጉም (TRANSLATION)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: currentTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildTranslationOptionChip(
                            label: '1954 ቀዳማዊ ኃ.ሥ.',
                            subLabel: '66 መጻሕፍት',
                            isSelected: currentBible.currentTranslation?.id == 1,
                            onTap: () {
                              final t = currentBible.translations.firstWhere((x) => x.id == 1, orElse: () => currentBible.translations.first);
                              ref.read(bibleStateProvider.notifier).selectTranslation(t);
                            },
                            theme: currentTheme,
                          ),
                          const SizedBox(width: 8),
                          _buildTranslationOptionChip(
                            label: '81 ቀኖና',
                            subLabel: 'ኦርቶዶክሳዊ',
                            isSelected: currentBible.currentTranslation?.id == 2,
                            onTap: () {
                              final t = currentBible.translations.firstWhere((x) => x.id == 2, orElse: () => currentBible.translations.first);
                              ref.read(bibleStateProvider.notifier).selectTranslation(t);
                            },
                            theme: currentTheme,
                          ),
                          const SizedBox(width: 8),
                          _buildTranslationOptionChip(
                            label: 'KJV',
                            subLabel: 'English',
                            isSelected: currentBible.currentTranslation?.id == 3,
                            onTap: () {
                              final t = currentBible.translations.firstWhere((x) => x.id == 3, orElse: () => currentBible.translations.first);
                              ref.read(bibleStateProvider.notifier).selectTranslation(t);
                            },
                            theme: currentTheme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // 2. Reading Theme Presets (Light, Sepia, Dark)
                      Text(
                        'ገጽታ (THEME PRESETS)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: currentTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildThemeModeCard(
                            label: 'ብርሃን',
                            subLabel: 'Light',
                            mode: ReaderThemeMode.light,
                            bgColor: const Color(0xFFFAF9F6),
                            cardColor: Colors.white,
                            textColor: const Color(0xFF18181B),
                            isSelected: currentTheme.mode == ReaderThemeMode.light,
                            onTap: () => ref.read(themeConfigProvider.notifier).setThemeMode(ReaderThemeMode.light),
                            theme: currentTheme,
                          ),
                          const SizedBox(width: 10),
                          _buildThemeModeCard(
                            label: 'ወረቀት',
                            subLabel: 'Sepia',
                            mode: ReaderThemeMode.sepia,
                            bgColor: const Color(0xFFF4EFE6),
                            cardColor: const Color(0xFFEFE8DC),
                            textColor: const Color(0xFF26221E),
                            isSelected: currentTheme.mode == ReaderThemeMode.sepia,
                            onTap: () => ref.read(themeConfigProvider.notifier).setThemeMode(ReaderThemeMode.sepia),
                            theme: currentTheme,
                          ),
                          const SizedBox(width: 10),
                          _buildThemeModeCard(
                            label: 'ጨለማ',
                            subLabel: 'Dark',
                            mode: ReaderThemeMode.dark,
                            bgColor: const Color(0xFF0E1014),
                            cardColor: const Color(0xFF171A21),
                            textColor: const Color(0xFFF3F4F6),
                            isSelected: currentTheme.mode == ReaderThemeMode.dark,
                            onTap: () => ref.read(themeConfigProvider.notifier).setThemeMode(ReaderThemeMode.dark),
                            theme: currentTheme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // 3. Layout and Numerals Toggles
                      Text(
                        'አቀራረብ (LAYOUT & NUMERALS)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: currentTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: currentTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: currentTheme.cardBorderColor),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              dense: true,
                              activeThumbColor: currentTheme.accentColor,
                              title: Text(
                                'በአንቀጽ ንባብ (Continuous Paragraph Mode)',
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: currentTheme.textColor,
                                ),
                              ),
                              value: currentTheme.isParagraphMode,
                              onChanged: (val) {
                                ref.read(themeConfigProvider.notifier).toggleParagraphMode(val);
                              },
                            ),
                            Divider(height: 1, color: currentTheme.cardBorderColor),
                            SwitchListTile(
                              dense: true,
                              activeThumbColor: currentTheme.accentColor,
                              title: Text(
                                'የግዕዝ ቁጥሮች (Ge\'ez Numerals ፩፣ ፪፣ ፫)',
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: currentTheme.textColor,
                                ),
                              ),
                              value: currentTheme.useGeezNumerals,
                              onChanged: (_) {
                                ref.read(themeConfigProvider.notifier).toggleGeezNumerals();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Font Size Adjustment
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'የፊደል መጠን (FONT SIZE)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: currentTheme.secondaryTextColor,
                            ),
                          ),
                          Text(
                            '${currentTheme.fontSize.toInt()} pt',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: currentTheme.accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.text_decrease_rounded),
                            color: currentTheme.secondaryTextColor,
                            onPressed: () {
                              ref.read(themeConfigProvider.notifier).setFontSize(currentTheme.fontSize - 1);
                            },
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: currentTheme.accentColor,
                                thumbColor: currentTheme.accentColor,
                                overlayColor: currentTheme.accentColor.withValues(alpha: 0.15),
                                inactiveTrackColor: currentTheme.cardBorderColor,
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: currentTheme.fontSize.clamp(14.0, 32.0),
                                min: 14.0,
                                max: 32.0,
                                onChanged: (val) {
                                  ref.read(themeConfigProvider.notifier).setFontSize(val);
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.text_increase_rounded),
                            color: currentTheme.secondaryTextColor,
                            onPressed: () {
                              ref.read(themeConfigProvider.notifier).setFontSize(currentTheme.fontSize + 1);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 5. Quick Shortcuts (Parallel Study & Settings)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: currentTheme.cardBorderColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ParallelReaderScreen()),
                                );
                              },
                              icon: Icon(Icons.compare_arrows_rounded, size: 18, color: currentTheme.accentColor),
                              label: Text(
                                'ማነፃፀሪያ (Parallel)',
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: currentTheme.textColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: currentTheme.cardBorderColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                );
                              },
                              icon: Icon(CupertinoIcons.gear_alt, size: 18, color: currentTheme.secondaryTextColor),
                              label: Text(
                                'ሙሉ ቅንብሮች',
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: currentTheme.textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTranslationOptionChip({
    required String label,
    required String subLabel,
    required bool isSelected,
    required VoidCallback onTap,
    required ReaderThemeConfig theme,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.accentColor.withValues(alpha: 0.12)
                : theme.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? theme.accentColor : theme.cardBorderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? theme.accentColor : theme.textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? theme.accentColor : theme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModeCard({
    required String label,
    required String subLabel,
    required ReaderThemeMode mode,
    required Color bgColor,
    required Color cardColor,
    required Color textColor,
    required bool isSelected,
    required VoidCallback onTap,
    required ReaderThemeConfig theme,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? theme.accentColor : theme.cardBorderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.accentColor : textColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded, size: 14, color: theme.accentColor)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                subLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivePlanFloatingBar(
    BuildContext context,
    ReadingPlanSessionState planSession,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final plan = planSession.activeSessionPlan!;
    final passage = planSession.activePassage!;
    final isDone = planSession.isDayCompleted(plan.id, passage.day);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: themeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: themeConfig.goldAccent.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.1),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeConfig.goldAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.flag_rounded, size: 18, color: themeConfig.goldAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${plan.title} • ቀን ${passage.day}/${plan.totalDays}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: themeConfig.goldAccent,
                  ),
                ),
                Text(
                  passage.passageReference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: themeConfig.textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? const Color(0xFF10B981) : themeConfig.goldAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final nextPassage = await ref
                  .read(readingPlanSessionProvider.notifier)
                  .completeActiveDayAndGetNext();
              if (!context.mounted) return;
              if (nextPassage != null) {
                final targetBook = bibleState.books.firstWhere(
                  (b) => b.bookNumber == nextPassage.bookNumber,
                  orElse: () => bibleState.books.first,
                );
                await ref.read(bibleStateProvider.notifier).selectBook(
                      targetBook,
                      chapter: nextPassage.startChapter,
                    );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ቀን ${passage.day} ተጠናቋል! ወደ ቀን ${nextPassage.day} ተሸጋግሯል።'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('እንኳን ደስ አለዎት! የንባብ ዕቅዱን አጠናቀዋል!')),
                );
              }
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
            label: Text(
              'ቀኑን አጠናቅቅ',
              style: GoogleFonts.notoSansEthiopic(fontSize: 11.5, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 18, color: themeConfig.secondaryTextColor),
            tooltip: 'ዕቅድ ዝጋ',
            onPressed: () {
              ref.read(readingPlanSessionProvider.notifier).clearActiveSession();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialChapterHeader(
    BuildContext context,
    String bookName,
    String bookNameEn,
    int bookNumber,
    int chapter,
    String chapterStr,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final chapterCommentaries =
        PatristicCommentariesData.getCommentariesForChapter(bookNumber, chapter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              bookNumber <= 39
                  ? 'ብሉይ ኪዳን'
                  : (bookNumber <= 66 ? 'ሐዲስ ኪዳን' : 'ቀኖና 81'),
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: themeConfig.accentColor,
              ),
            ),
            if (bookNameEn.isNotEmpty) ...[
              Text(
                ' • ${bookNameEn.toUpperCase()}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: themeConfig.secondaryTextColor,
                ),
              ),
            ],
            const Spacer(),
            // Sleek Gear Settings Button (Catena-style top action)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                CupertinoIcons.gear_alt,
                size: 20,
                color: themeConfig.secondaryTextColor,
              ),
              tooltip: 'የንባብ ገጽታና ቅንብሮች (Settings)',
              onPressed: () => _openReaderSettingsModal(context, bibleState, themeConfig, isDark),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                bookName,
                style: GoogleFonts.notoSerifEthiopic(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: themeConfig.textColor,
                  height: 1.2,
                ),
              ),
            ),
            Text(
              'ምዕራፍ $chapterStr',
              style: GoogleFonts.notoSerifEthiopic(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: themeConfig.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: themeConfig.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, size: 13, color: themeConfig.accentColor),
                  const SizedBox(width: 5),
                  Text(
                    chapterCommentaries.isNotEmpty
                        ? '${chapterCommentaries.length} ቀጥተኛ የአበው ትርጓሜ • ማንኛውንም ጥቅስ ይጫኑ'
                        : 'ለአንድምታ፣ ለአበው ትርጓሜና ለተዛማጅ ጥቅሶች ማንኛውንም ጥቅስ ይጫኑ',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: themeConfig.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Divider(height: 1, color: themeConfig.cardBorderColor),
      ],
    );
  }

  Widget _buildParagraphModeFlow(
    BuildContext context,
    BibleViewState bibleState,
    Map<int, List<SectionHeading>> headingsByVerse,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final baseFont = themeConfig.fontFamily == 'Serif'
        ? GoogleFonts.notoSerifEthiopic
        : GoogleFonts.notoSansEthiopic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headingsByVerse.containsKey(1))
          ...headingsByVerse[1]!.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                h.title,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: themeConfig.fontSize * 0.9,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
              ),
            ),
          ),
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: bibleState.verses.map((verse) {
            final isSelected = _selectedVerseNumber == verse.verse;
            final verseNumStr = _formatVerseLabel(verse, themeConfig.useGeezNumerals);
            final directCommentaries = <Commentary>[];
            final endV = verse.verseEnd ?? verse.verse;
            for (int v = verse.verse; v <= endV; v++) {
              directCommentaries.addAll(
                PatristicCommentariesData.getCommentariesForVerse(
                  bibleState.currentBook?.bookNumber ?? 1,
                  verse.chapter,
                  v,
                ),
              );
            }

            Color? bgHighlight;
            if (isSelected) {
              bgHighlight = themeConfig.accentColor.withValues(alpha: 0.14);
            } else if (verse.highlightColor != null && verse.highlightColor!.isNotEmpty) {
              try {
                final hex = verse.highlightColor!.replaceFirst('#', '0xFF');
                bgHighlight = Color(int.parse(hex)).withValues(alpha: isDark ? 0.25 : 0.45);
              } catch (_) {}
            }

            return GestureDetector(
              onTap: () => _openVerseStudySheet(context, verse, bibleState),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: bgHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$verseNumStr ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: themeConfig.fontSize * 0.65,
                          fontWeight: FontWeight.w800,
                          color: directCommentaries.isNotEmpty
                              ? themeConfig.accentColor
                              : themeConfig.secondaryTextColor,
                        ),
                      ),
                      TextSpan(
                        text: verse.text,
                        style: baseFont(
                          fontSize: themeConfig.fontSize,
                          height: themeConfig.lineHeight,
                          color: themeConfig.textColor,
                        ),
                      ),
                      if (directCommentaries.isNotEmpty)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: OrthodoxCrossIcon(
                              size: 11,
                              color: themeConfig.accentColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Minimalist continuous scripture verse flow with Left-Margin Accent Bars
  Widget _buildScriptureVerseRow(
    BuildContext context,
    Verse verse,
    List<SectionHeading> headings,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final isSelected = _selectedVerseNumber == verse.verse;
    final bookNumber = bibleState.currentBook?.bookNumber ?? 1;
    final directCommentaries = <Commentary>[];
    final crossRefs = <CrossReferenceItem>[];
    final endV = verse.verseEnd ?? verse.verse;
    for (int v = verse.verse; v <= endV; v++) {
      directCommentaries.addAll(
        PatristicCommentariesData.getCommentariesForVerse(
          bookNumber,
          verse.chapter,
          v,
        ),
      );
      crossRefs.addAll(
        CrossReferencesData.getCrossReferencesForVerse(
          bookNumber,
          verse.chapter,
          v,
        ),
      );
    }
    final hasDirectCommentary = directCommentaries.isNotEmpty;

    Color? customHighlight;
    if (verse.highlightColor != null && verse.highlightColor!.isNotEmpty) {
      try {
        final hex = verse.highlightColor!.replaceFirst('#', '0xFF');
        customHighlight = Color(int.parse(hex)).withValues(alpha: isDark ? 0.25 : 0.42);
      } catch (_) {}
    }

    final verseNumStr = _formatVerseLabel(verse, themeConfig.useGeezNumerals);
    final baseFont = themeConfig.fontFamily == 'Serif'
        ? GoogleFonts.notoSerifEthiopic
        : GoogleFonts.notoSansEthiopic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final h in headings)
          Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
            child: Text(
              h.title,
              style: GoogleFonts.notoSansEthiopic(
                fontSize: themeConfig.fontSize * 0.88,
                fontWeight: FontWeight.w800,
                color: themeConfig.accentColor,
              ),
            ),
          ),

        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openVerseStudySheet(context, verse, bibleState),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? themeConfig.accentColor.withValues(alpha: isDark ? 0.18 : 0.08)
                  : customHighlight ?? Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: isSelected
                      ? themeConfig.accentColor
                      : hasDirectCommentary
                          ? themeConfig.accentColor.withValues(alpha: 0.75)
                          : themeConfig.cardBorderColor.withValues(alpha: 0.65),
                  width: isSelected
                      ? 4.0
                      : hasDirectCommentary
                          ? 3.2
                          : 1.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$verseNumStr  ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: themeConfig.fontSize * 0.68,
                          fontWeight: FontWeight.w800,
                          color: hasDirectCommentary
                              ? themeConfig.accentColor
                              : themeConfig.secondaryTextColor,
                        ),
                      ),
                      TextSpan(
                        text: verse.text,
                        style: baseFont(
                          fontSize: themeConfig.fontSize,
                          height: themeConfig.lineHeight,
                          color: themeConfig.textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtle inline metadata row (Commentary count / Bookmark / Personal Note)
                if (hasDirectCommentary ||
                    verse.isBookmarked ||
                    (verse.note != null && verse.note!.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (hasDirectCommentary)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: themeConfig.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OrthodoxCrossIcon(
                                  size: 11,
                                  color: themeConfig.accentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${directCommentaries.length} የአበው ትርጓሜ • ${crossRefs.length} ማጣቀሻ',
                                  style: GoogleFonts.notoSansEthiopic(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: themeConfig.accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (verse.isBookmarked)
                          Icon(Icons.bookmark_rounded, size: 14, color: themeConfig.accentColor),
                        if (verse.note != null && verse.note!.isNotEmpty)
                          Text(
                            '📝 ${verse.note}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: themeConfig.goldAccent,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterNavigationFooter(
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
  ) {
    final canPrev = bibleState.currentChapter > 1;
    final canNext = bibleState.currentBook != null &&
        bibleState.currentChapter < bibleState.currentBook!.totalChapters;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (canPrev)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: themeConfig.textColor,
              side: BorderSide(color: themeConfig.cardBorderColor),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              ref.read(bibleStateProvider.notifier).prevChapter();
              setState(() => _selectedVerseNumber = null);
              _scrollToApproximateVerse(1, 30);
            },
            icon: const Icon(Icons.west_rounded, size: 16),
            label: Text(
              'ምዕራፍ ${bibleState.currentChapter - 1}',
              style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          )
        else
          const SizedBox.shrink(),

        if (canNext)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeConfig.textColor,
              foregroundColor: themeConfig.backgroundColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              ref.read(bibleStateProvider.notifier).nextChapter();
              setState(() => _selectedVerseNumber = null);
              _scrollToApproximateVerse(1, 30);
            },
            icon: Text(
              'ምዕራፍ ${bibleState.currentChapter + 1}',
              style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            label: const Icon(Icons.east_rounded, size: 16),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ReaderThemeConfig themeConfig) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_outlined, size: 48, color: themeConfig.accentColor),
          const SizedBox(height: 12),
          Text(
            'ምዕራፉን በመጫን ላይ...',
            style: GoogleFonts.notoSansEthiopic(fontSize: 15, color: themeConfig.textColor),
          ),
        ],
      ),
    );
  }
}
