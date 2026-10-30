import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/canonical_book_map.dart';
import '../../core/utils/geez_numbers.dart';
import '../../models/book.dart';
import '../../models/verse.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import '../../providers/reading_plan_session_provider.dart';
import 'book_selector_screen.dart';
import 'search_screen.dart';
import 'study_tools_dialog.dart';
import '../../services/bahire_hasab_service.dart';
import '../widgets/ethiopian_cross_painter.dart';

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
  bool _isPinching = false;
  final Map<int, Offset> _pointerPositions = {};
  double _initialPinchDistance = 0.0;
  double _pinchBaseFontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    _checkAutoTrackReadingPlan();
  }

  void _checkAutoTrackReadingPlan() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // Auto-track chapter as read if reached within 140px of bottom or scrolled past 80%
    final bool isNearBottom = pos.maxScrollExtent <= 0 ||
        pos.pixels >= (pos.maxScrollExtent - 140) ||
        (pos.maxScrollExtent > 0 && (pos.pixels / pos.maxScrollExtent) >= 0.80);

    if (isNearBottom) {
      _markActivePlanChapterReadIfApplicable();
    }
  }

  void _markActivePlanChapterReadIfApplicable() {
    final planSession = ref.read(readingPlanSessionProvider);
    final plan = planSession.activeSessionPlan;
    final passage = planSession.activePassage;
    if (plan == null || passage == null) return;

    final bibleState = ref.read(bibleStateProvider);
    final currentBook = bibleState.currentBook;
    final currentChapter = bibleState.currentChapter;
    if (currentBook == null) return;

    final currentTransId = bibleState.currentTranslation?.id ?? 2;
    final currentCanonId = CanonicalBookMap.getCanonicalId(currentTransId, currentBook.bookNumber);
    final passageCanonId = passage.canonicalId.isNotEmpty
        ? passage.canonicalId
        : (currentTransId == 2
            ? CanonicalBookMap.getCanonicalId(2, passage.bookNumber)
            : CanonicalBookMap.getCanonicalId(1, passage.bookNumber));

    if (passageCanonId.isNotEmpty && passageCanonId == currentCanonId) {
      if (currentChapter >= passage.startChapter && currentChapter <= passage.endChapter) {
        final totalChapters = (passage.endChapter - passage.startChapter + 1).clamp(1, 150);
        final isAlreadyRead = planSession.isChapterCompleted(plan.id, passage.day, currentChapter);
        if (!isAlreadyRead) {
          ref.read(readingPlanSessionProvider.notifier).markChapterCompleted(
                planId: plan.id,
                day: passage.day,
                chapter: currentChapter,
                totalChaptersInDay: totalChapters,
              );
        }
        return;
      }
    }

    // Read-ahead check: If current active day is already completed, did the reader move into the next day's chapters?
    // Note: Capped strictly at plan.totalDays so it never counts past the end of the plan.
    final currentDay = planSession.activeSessionDay ?? 1;
    if (planSession.isDayCompleted(plan.id, currentDay) && currentDay < plan.totalDays) {
      final nextDay = currentDay + 1;
      final nextPassage = plan.passages[(nextDay - 1).clamp(0, plan.passages.length - 1)];
      final nextCanonId = nextPassage.canonicalId.isNotEmpty
          ? nextPassage.canonicalId
          : (currentTransId == 2
              ? CanonicalBookMap.getCanonicalId(2, nextPassage.bookNumber)
              : CanonicalBookMap.getCanonicalId(1, nextPassage.bookNumber));

      if (nextCanonId.isNotEmpty && nextCanonId == currentCanonId) {
        if (currentChapter >= nextPassage.startChapter && currentChapter <= nextPassage.endChapter) {
          // Seamlessly auto-advance active session day and record the chapter!
          ref.read(readingPlanSessionProvider.notifier).startReadingSession(plan, nextDay);
          final totalChapters = (nextPassage.endChapter - nextPassage.startChapter + 1).clamp(1, 150);
          ref.read(readingPlanSessionProvider.notifier).markChapterCompleted(
                planId: plan.id,
                day: nextDay,
                chapter: currentChapter,
                totalChaptersInDay: totalChapters,
              );
        }
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

  TextStyle _getScriptureTextStyle(
    ReaderThemeConfig themeConfig, {
    double? fontSize,
    double? height,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final size = fontSize ?? themeConfig.fontSize;
    final lineHeight = height ?? themeConfig.lineHeight;
    final textColor = color ?? themeConfig.textColor;
    final weight = fontWeight ?? FontWeight.normal;

    switch (themeConfig.fontFamily) {
      case 'Abyssinica':
        return TextStyle(
          fontFamily: 'AbyssinicaSIL',
          fontFamilyFallback: const ['Abyssinica SIL', 'Nyala', 'Noto Serif Ethiopic', 'Noto Serif', 'Roboto', 'serif'],
          fontSize: size,
          height: lineHeight,
          fontWeight: weight,
          color: textColor,
        );
      case 'Sans':
        return TextStyle(
          fontFamily: 'NotoSansEthiopic',
          fontFamilyFallback: const ['Noto Sans Ethiopic', 'Nyala', 'sans-serif', 'Roboto'],
          fontSize: size,
          height: lineHeight,
          fontWeight: weight,
          color: textColor,
        );
      case 'PowerGeez':
        return TextStyle(
          fontFamily: 'Power Ge\'ez Unicode',
          fontFamilyFallback: const [
            'PowerGeez',
            'Power Ge\'ez',
            'Nyala',
            'WashRa',
            'NotoSerifEthiopic',
            'AbyssinicaSIL',
            'Noto Serif',
            'Roboto',
            'serif',
          ],
          fontSize: size,
          height: lineHeight,
          fontWeight: weight,
          color: textColor,
        );
      case 'Serif':
      default:
        return TextStyle(
          fontFamily: 'NotoSerifEthiopic',
          fontFamilyFallback: const ['Noto Serif Ethiopic', 'Nyala', 'Noto Serif', 'Roboto', 'serif'],
          fontSize: size,
          height: lineHeight,
          fontWeight: weight,
          color: textColor,
        );
    }
  }

  static final RegExp _rubricPatternAmharic = RegExp(
    r'(እግዚአብሔር|ኢየሱስ\s+ክርስቶስ|ኢየሱስ|ክርስቶስ|መንፈስ\s+ቅዱስ|አማኑኤል|ፈጣሪ)',
  );

  static final RegExp _rubricPatternEnglish = RegExp(
    r'\b(God|Jesus\s+Christ|Jesus|Christ|Holy\s+Spirit|Lord\s+God|Lord|Almighty)\b',
    caseSensitive: false,
  );

  List<InlineSpan> _buildRubricatedSpans({
    required String text,
    required TextStyle baseStyle,
    required TextStyle rubricStyle,
    required bool isEnglish,
  }) {
    final pattern = isEnglish ? _rubricPatternEnglish : _rubricPatternAmharic;
    final matches = pattern.allMatches(text).toList();
    if (matches.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    final spans = <InlineSpan>[];
    int current = 0;

    for (final m in matches) {
      if (m.start > current) {
        spans.add(TextSpan(
          text: text.substring(current, m.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(m.start, m.end),
        style: rubricStyle,
      ));
      current = m.end;
    }

    if (current < text.length) {
      spans.add(TextSpan(
        text: text.substring(current),
        style: baseStyle,
      ));
    }

    return spans;
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
      onJumpToReference: (targetBookNum, targetCh, targetVerse) async {
        if (!mounted) return;
        await ref.read(bibleStateProvider.notifier).jumpToVerseLocation(
          bookNumber: targetBookNum,
          chapter: targetCh,
          verse: targetVerse,
        );
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

    ref.listen<int?>(bibleStateProvider.select((s) => s.targetVerse), (previous, targetVerse) {
      if (targetVerse != null) {
        _restoreChrome();
        _scrollToApproximateVerse(targetVerse, bibleState.verses.length);
        Future.microtask(() {
          ref.read(bibleStateProvider.notifier).clearTargetVerse();
        });
      }
    });

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
                      ? _buildEmptyState(context, bibleState, themeConfig)
                      : GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragEnd: (details) {
                            if (_isPinching || _pointerPositions.length > 1) return;
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
                          child: Listener(
                            behavior: HitTestBehavior.translucent,
                            onPointerDown: (event) {
                              _pointerPositions[event.pointer] = event.position;
                              if (_pointerPositions.length == 2) {
                                final points = _pointerPositions.values.toList();
                                _initialPinchDistance = (points[0] - points[1]).distance;
                                _pinchBaseFontSize = themeConfig.fontSize;
                                if (_initialPinchDistance > 10.0) {
                                  setState(() => _isPinching = true);
                                }
                              }
                            },
                            onPointerMove: (event) {
                              _pointerPositions[event.pointer] = event.position;
                              if (_pointerPositions.length >= 2 && _initialPinchDistance > 10.0) {
                                final points = _pointerPositions.values.toList();
                                final currentDist = (points[0] - points[1]).distance;
                                if (currentDist > 10.0) {
                                  if (!_isPinching) {
                                    setState(() => _isPinching = true);
                                  }
                                  final scaleRatio = currentDist / _initialPinchDistance;
                                  final newSize = (_pinchBaseFontSize * scaleRatio).clamp(14.0, 32.0);
                                  if ((newSize - themeConfig.fontSize).abs() >= 0.5) {
                                    ref.read(themeConfigProvider.notifier).setFontSize(newSize);
                                  }
                                }
                              }
                            },
                            onPointerUp: (event) {
                              _pointerPositions.remove(event.pointer);
                              if (_pointerPositions.length < 2 && _isPinching) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _isPinching = false;
                                  _initialPinchDistance = 0.0;
                                });
                              }
                            },
                            onPointerCancel: (event) {
                              _pointerPositions.remove(event.pointer);
                              if (_pointerPositions.length < 2 && _isPinching) {
                                setState(() {
                                  _isPinching = false;
                                  _initialPinchDistance = 0.0;
                                });
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
                                  planSession.activeSessionPlan != null ? 140 : 80,
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


            // 4. Pinch Zoom Font Indicator Pill
            if (_isPinching)
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2128) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: themeConfig.accentColor.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.format_size_rounded,
                          size: 16,
                          color: themeConfig.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${themeConfig.fontSize.toInt()} pt',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationDropdown(
    BuildContext context,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final current = bibleState.currentTranslation;
    final currentId = current?.id ?? 2;
    final isEnglish = ref.watch(isEnglishUiProvider);
    String shortTitle = isEnglish ? '81 Canon' : '81 ቀኖና';
    if (currentId == 4) {
      shortTitle = isEnglish ? 'Ge\'ez 81' : 'ግዕዝ 81';
    } else if (currentId == 1) {
      shortTitle = '1954';
    } else if (currentId == 3) {
      shortTitle = 'KJV';
    } else if (current?.shortName != null && current!.shortName.isNotEmpty) {
      shortTitle = current.shortName;
    }

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showTranslationPickerBottomSheet(context, bibleState, themeConfig, isDark, isEnglish);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
        decoration: BoxDecoration(
          color: themeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: themeConfig.cardBorderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 15, color: themeConfig.accentColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                shortTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.textColor,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, size: 18, color: themeConfig.secondaryTextColor),
          ],
        ),
      ),
    );
  }

  void _showTranslationPickerBottomSheet(
    BuildContext context,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
    bool isEnglish,
  ) {
    final currentId = bibleState.currentTranslation?.id ?? 2;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: themeConfig.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: themeConfig.cardBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                children: [
                  OrthodoxCrossIcon(
                    style: EthiopianCrossStyle.lalibela,
                    size: 16,
                    color: themeConfig.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEnglish ? 'Select Canon / Translation' : 'የመጽሐፍ ቅዱስ ቀኖና / ትርጉም ይምረጡ',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: themeConfig.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Translations list
              ...bibleState.translations.map((t) {
                final isSelected = t.id == currentId;
                String displayTitle = t.name;
                String displaySubtitle = '';
                if (t.id == 2) {
                  displayTitle = isEnglish ? '81 Orthodox Canon' : '81 ቀኖና (ሰማንያ ወአሐዱ)';
                  displaySubtitle = isEnglish ? 'Ethiopian Orthodox Amharic' : 'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ አማርኛ';
                } else if (t.id == 4) {
                  displayTitle = isEnglish ? 'Ancient Ge\'ez 81 Canon' : 'የቀደምት ግዕዝ 81 ቀኖና';
                  displaySubtitle = isEnglish ? 'Classical Ge\'ez Manuscript Heritage' : 'ጥንታዊ የብራና ቅርስ በግዕዝ ቋንቋ';
                } else if (t.id == 1) {
                  displayTitle = isEnglish ? '1954 Haile Selassie' : '1954 ቀዳማዊ ኃይለ ሥላሴ';
                  displaySubtitle = isEnglish ? 'Traditional Amharic (66 Books)' : 'የቀዳማዊ ኃይለ ሥላሴ ፷፮ መጻሕፍት';
                } else if (t.id == 3) {
                  displayTitle = 'King James Version (KJV)';
                  displaySubtitle = 'Authorized Version • English';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    color: isSelected
                        ? themeConfig.accentColor.withValues(alpha: isDark ? 0.16 : 0.08)
                        : themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(ctx);
                        ref.read(bibleStateProvider.notifier).selectTranslation(t);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? themeConfig.accentColor
                                : themeConfig.cardBorderColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? themeConfig.accentColor.withValues(alpha: 0.18)
                                    : themeConfig.surfaceColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                size: 18,
                                color: isSelected ? themeConfig.accentColor : themeConfig.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          displayTitle,
                                          style: GoogleFonts.notoSansEthiopic(
                                            fontSize: 13.5,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                            color: isSelected ? themeConfig.accentColor : themeConfig.textColor,
                                          ),
                                        ),
                                      ),
                                      if (t.id == 2) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: themeConfig.accentColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isEnglish ? 'Primary' : 'ዋና ቀኖና',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: themeConfig.accentColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (displaySubtitle.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      displaySubtitle,
                                      style: GoogleFonts.notoSansEthiopic(
                                        fontSize: 11.5,
                                        color: themeConfig.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }


  Widget _buildActivePlanFloatingBar(
    BuildContext context,
    ReadingPlanSessionState planSession,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final isEnglish = ref.watch(isEnglishUiProvider);
    final plan = planSession.activeSessionPlan!;
    final passage = planSession.activePassage!;
    final isDone = planSession.isDayCompleted(plan.id, passage.day);

    final currentTransId = bibleState.currentTranslation?.id ?? 2;
    final currentBook = bibleState.currentBook;
    final currentChapter = bibleState.currentChapter;

    final passageCanonId = passage.canonicalId.isNotEmpty
        ? passage.canonicalId
        : CanonicalBookMap.getCanonicalId(1, passage.bookNumber);
    final currentCanonId = currentBook != null
        ? CanonicalBookMap.getCanonicalId(currentTransId, currentBook.bookNumber)
        : '';
    final bool isSameBook = passageCanonId.isNotEmpty && passageCanonId == currentCanonId;

    final bool isInChapterRange = isSameBook &&
        currentChapter >= passage.startChapter &&
        currentChapter <= passage.endChapter;

    final totalChaptersInDay = (passage.endChapter - passage.startChapter + 1).clamp(1, 150);
    final readChapters = planSession.getReadChapters(plan.id, passage.day);
    final int readCount = readChapters.length;
    final bool isCurrentChapterRead = readChapters.contains(currentChapter);
    final bool isAtFinalChapter = isSameBook && currentChapter == passage.endChapter;

    // Header label
    final String headerLabel;
    if (!isInChapterRange) {
      headerLabel = isEnglish
          ? '${plan.getDisplayTitle(true)} • Day ${passage.day}/${plan.totalDays}'
          : '${plan.getDisplayTitle(false)} • ቀን ${passage.day}/${plan.totalDays}';
    } else if (totalChaptersInDay > 1) {
      headerLabel = isEnglish
          ? 'Day ${passage.day} • Ch $currentChapter ($readCount/$totalChaptersInDay read${isCurrentChapterRead ? " ✓" : ""})'
          : 'ቀን ${passage.day} • ምዕራፍ $currentChapter ($readCount/$totalChaptersInDay ተነቧል${isCurrentChapterRead ? " ✓" : ""})';
    } else {
      headerLabel = isEnglish
          ? 'Day ${passage.day} of ${plan.totalDays}${isDone ? " • Completed ✓" : ""}'
          : 'ቀን ${passage.day} ከ ${plan.totalDays}${isDone ? " • ተጠናቋል ✓" : ""}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: themeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (isInChapterRange && isDone)
              ? const Color(0xFF10B981).withValues(alpha: 0.6)
              : themeConfig.goldAccent.withValues(alpha: 0.5),
          width: 1.5,
        ),
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
              color: ((isInChapterRange && isDone)
                      ? const Color(0xFF10B981)
                      : (isInChapterRange ? themeConfig.goldAccent : themeConfig.accentColor))
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : (isInChapterRange ? Icons.menu_book_rounded : Icons.explore_outlined),
              size: 18,
              color: (isInChapterRange && isDone)
                  ? const Color(0xFF10B981)
                  : (isInChapterRange ? themeConfig.goldAccent : themeConfig.accentColor),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: (isInChapterRange && isDone)
                        ? const Color(0xFF10B981)
                        : (isInChapterRange ? themeConfig.goldAccent : themeConfig.accentColor),
                  ),
                ),
                Text(
                  passage.getPassageReference(isEnglish),
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

          // Action Button depending on user location
          if (!isInChapterRange)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeConfig.accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final targetBook = CanonicalBookMap.resolveBook(
                  books: bibleState.books,
                  currentTranslationId: currentTransId,
                  traditionalBookNumber: passage.bookNumber,
                  canonicalId: passage.canonicalId.isNotEmpty ? passage.canonicalId : null,
                  bookName: passage.bookName,
                );
                // Jump to first unread chapter of this day
                int targetChapter = passage.startChapter;
                for (int ch = passage.startChapter; ch <= passage.endChapter; ch++) {
                  if (!readChapters.contains(ch)) {
                    targetChapter = ch;
                    break;
                  }
                }
                if (targetBook != null) {
                  await ref.read(bibleStateProvider.notifier).selectBook(
                        targetBook,
                        chapter: targetChapter,
                      );
                  _scrollToApproximateVerse(1, 30);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEnglish
                            ? 'Navigated to ${passage.getPassageReference(true)}'
                            : 'ወደ ${passage.getPassageReference(false)} ተጉዟል',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(
                isEnglish ? 'Resume Plan' : 'ወደ ዕቅዱ ሂድ',
                style: GoogleFonts.notoSansEthiopic(fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
            )
          else if (!isAtFinalChapter && currentChapter < passage.endChapter)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentChapterRead ? const Color(0xFF10B981) : themeConfig.goldAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                // Mark current chapter completed and move to next chapter
                await ref.read(readingPlanSessionProvider.notifier).markChapterCompleted(
                      planId: plan.id,
                      day: passage.day,
                      chapter: currentChapter,
                      totalChaptersInDay: totalChaptersInDay,
                    );
                ref.read(bibleStateProvider.notifier).selectChapter(currentChapter + 1);
                _scrollToApproximateVerse(1, 30);
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(
                isEnglish ? 'Next (Ch ${currentChapter + 1}) →' : 'ቀጣይ (ምዕ ${currentChapter + 1}) →',
                style: GoogleFonts.notoSansEthiopic(fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? const Color(0xFF10B981) : themeConfig.goldAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                // Ensure current chapter is marked read
                await ref.read(readingPlanSessionProvider.notifier).markChapterCompleted(
                      planId: plan.id,
                      day: passage.day,
                      chapter: currentChapter,
                      totalChaptersInDay: totalChaptersInDay,
                    );
                final nextPassage = await ref
                    .read(readingPlanSessionProvider.notifier)
                    .completeActiveDayAndGetNext();
                if (!context.mounted) return;
                if (nextPassage != null) {
                  final targetBook = CanonicalBookMap.resolveBook(
                    books: bibleState.books,
                    currentTranslationId: currentTransId,
                    traditionalBookNumber: nextPassage.bookNumber,
                    canonicalId: nextPassage.canonicalId.isNotEmpty ? nextPassage.canonicalId : null,
                    bookName: nextPassage.bookName,
                  );
                  if (targetBook != null) {
                    await ref.read(bibleStateProvider.notifier).selectBook(
                          targetBook,
                          chapter: nextPassage.startChapter,
                        );
                    _scrollToApproximateVerse(1, 30);
                  }
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEnglish
                            ? 'Day ${passage.day} completed! Moved to Day ${nextPassage.day}.'
                            : 'ቀን ${passage.day} ተጠናቋል! ወደ ቀን ${nextPassage.day} ተሸጋግሯል።',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEnglish
                            ? 'Congratulations! You have completed the reading plan!'
                            : 'እንኳን ደስ አለዎት! የንባብ ዕቅዱን አጠናቀዋል!',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: Icon(
                isDone ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                size: 16,
              ),
              label: Text(
                isDone
                    ? (isEnglish ? 'Day Completed ✓' : 'ቀኑ ተጠናቋል ✓')
                    : (isEnglish ? 'Complete Day' : 'ቀኑን አጠናቅቅ'),
                style: GoogleFonts.notoSansEthiopic(fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
            ),

          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 18, color: themeConfig.secondaryTextColor),
            tooltip: isEnglish ? 'Close Plan Bar' : 'ዕቅድ ዝጋ',
            onPressed: () {
              ref.read(readingPlanSessionProvider.notifier).clearActiveSession();
            },
          ),
        ],
      ),
    );
  }

  String _getCompactBookName(Book? book, String fullName) {
    if (fullName.isEmpty) return 'መጽሐፍ';
    String name = fullName;
    name = name.replaceAll('የማቴዎስ ወንጌል', 'ማቴዎስ');
    name = name.replaceAll('የማርቆስ ወንጌል', 'ማርቆስ');
    name = name.replaceAll('የሉቃስ ወንጌል', 'ሉቃስ');
    name = name.replaceAll('የዮሐንስ ወንጌል', 'ዮሐንስ');
    name = name.replaceAll('የሐዋርያት ሥራ', 'ሐዋርያት');
    name = name.replaceAll('የዮሐንስ ራእይ', 'ራእይ');
    name = name.replaceAll('መዝሙረ ዳዊት', 'መዝሙር');
    name = name.replaceAll('ኦሪት ', '');
    name = name.replaceAll('መጽሐፈ ', '');
    name = name.replaceAll('ትንቢተ ', '');
    name = name.replaceAll('ወደ ', '');
    name = name.replaceAll(' ሰዎች', '');
    name = name.replaceAll(' መልእክት', '');
    name = name.replaceAll('የቀዳማዊ ', '1 ');
    name = name.replaceAll('የካልዕ ', '2 ');
    name = name.replaceAll('ቀዳማዊ ', '1 ');
    name = name.replaceAll('ካልዕ ', '2 ');
    name = name.replaceAll('ሣልስ ', '3 ');
    name = name.replaceAll('1ኛ ', '1 ');
    name = name.replaceAll('2ኛ ', '2 ');
    name = name.replaceAll('3ኛ ', '3 ');
    name = name.trim();
    if (name.startsWith('የ') && name.endsWith(' ወንጌል')) {
      name = name.substring(1, name.length - 6).trim();
    }
    return name.isNotEmpty ? name : fullName;
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
    final isEnglish = ref.watch(isEnglishUiProvider);
    final compactBookName = isEnglish && bookNameEn.isNotEmpty
        ? bookNameEn
        : _getCompactBookName(bibleState.currentBook, bookName);
    final displayChapterTitle = isEnglish ? 'Chapter $chapterStr' : 'ምዕራፍ $chapterStr';
    final displayBookTitle = isEnglish && bookNameEn.isNotEmpty ? bookNameEn : bookName;

    final liturgical = BahireHasabService.getCurrentLiturgicalStatus(DateTime.now());
    final ethDate = liturgical['ethDate'] as EthiopianDate;
    final evangelist = isEnglish ? (liturgical['evangelistEn'] as String) : (liturgical['evangelist'] as String);
    final isFastDay = liturgical['isFastDay'] as bool? ?? false;
    final fastSuffix = isFastDay ? (isEnglish ? ' • Fasting Day' : ' • የጾም ቀን') : '';
    final liturgicalText = isEnglish
        ? '❖ ${ethDate.format(includeDayName: true, isEnglish: true)} • $evangelist$fastSuffix ❖'
        : '❖ ${themeConfig.useGeezNumerals ? ethDate.toGeezString() : ethDate.format(includeDayName: true)} • $evangelist$fastSuffix ❖';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Living Liturgical Sub-Header Pill
        Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: themeConfig.goldAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeConfig.goldAccent.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Text(
              liturgicalText,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: themeConfig.goldAccent,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        // 2. Clean Navigation Controls
        Row(
          children: [
            // A. Primary Scripture Selector Capsule (Book & Chapter)
            Expanded(
              flex: 5,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  BookSelectorScreen.show(
                    context,
                    initialStep: 0,
                    onVerseSelected: (vNum) {
                      _scrollToApproximateVerse(vNum, bibleState.verses.length);
                    },
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: themeConfig.cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_stories_outlined, size: 15, color: themeConfig.accentColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$compactBookName • $displayChapterTitle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down_rounded, size: 18, color: themeConfig.secondaryTextColor),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // B. Canon / Translation Dropdown Capsule (Same style as Book Navigator)
            Expanded(
              flex: 4,
              child: _buildTranslationDropdown(context, bibleState, themeConfig, isDark),
            ),
            const SizedBox(width: 4),

            // C. Search Action Icon (Replaces Parallel)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.search_rounded, size: 21, color: themeConfig.accentColor),
              tooltip: isEnglish ? 'Search Scripture' : 'ጥቅስ ፈልግ',
              onPressed: () {
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
            ),

            // D. 1-Tap Theme Mode Toggle (Replaces Settings)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                themeConfig.mode == ReaderThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : themeConfig.mode == ReaderThemeMode.sepia
                        ? Icons.auto_stories_outlined
                        : Icons.light_mode_rounded,
                size: 20,
                color: themeConfig.accentColor,
              ),
              tooltip: isEnglish ? 'Toggle Theme' : 'ገጽታ ቀይር',
              onPressed: () {
                HapticFeedback.lightImpact();
                final notifier = ref.read(themeConfigProvider.notifier);
                if (themeConfig.mode == ReaderThemeMode.light) {
                  notifier.setMode(ReaderThemeMode.sepia);
                } else if (themeConfig.mode == ReaderThemeMode.sepia) {
                  notifier.setMode(ReaderThemeMode.dark);
                } else {
                  notifier.setMode(ReaderThemeMode.light);
                }
              },
            ),
          ],
        ),

        // 3. Authentic Manuscript Harag (ሐረግ) Ornamental Vector Divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeConfig.goldAccent.withValues(alpha: 0.0),
                        themeConfig.goldAccent.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: OrthodoxCrossIcon(
                  style: EthiopianCrossStyle.lalibela,
                  size: 16,
                  color: themeConfig.goldAccent,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeConfig.goldAccent.withValues(alpha: 0.6),
                        themeConfig.goldAccent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. Dignified Chapter Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                BookSelectorScreen.show(
                  context,
                  initialStep: 0,
                  onVerseSelected: (vNum) {
                    _scrollToApproximateVerse(vNum, bibleState.verses.length);
                  },
                );
              },
              child: Text(
                displayBookTitle,
                style: _getScriptureTextStyle(
                  themeConfig,
                  fontSize: 18.5,
                  fontWeight: FontWeight.w900,
                  color: themeConfig.accentColor,
                  height: 1.25,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '—',
                style: TextStyle(
                  color: themeConfig.goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                BookSelectorScreen.show(
                  context,
                  initialStep: 1,
                  onVerseSelected: (vNum) {
                    _scrollToApproximateVerse(vNum, bibleState.verses.length);
                  },
                );
              },
              child: Text(
                displayChapterTitle,
                style: _getScriptureTextStyle(
                  themeConfig,
                  fontSize: 18.5,
                  fontWeight: FontWeight.w900,
                  color: themeConfig.accentColor,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
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
    final sections = <Widget>[];
    List<Verse> currentChunk = [];

    void flushChunk() {
      if (currentChunk.isEmpty) return;
      final chunkVerses = List<Verse>.from(currentChunk);
      currentChunk.clear();

      sections.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 4,
            runSpacing: 8,
            children: chunkVerses.map((verse) {
              final isSelected = _selectedVerseNumber != null &&
                  _selectedVerseNumber! >= verse.verse &&
                  _selectedVerseNumber! <= (verse.verseEnd ?? verse.verse);
              final verseNumStr = _formatVerseLabel(verse, themeConfig.useGeezNumerals);

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
                          style: themeConfig.useGeezNumerals
                              ? GoogleFonts.notoSansEthiopic(
                                  fontSize: themeConfig.fontSize * 0.70,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? themeConfig.accentColor
                                      : themeConfig.secondaryTextColor,
                                )
                              : GoogleFonts.plusJakartaSans(
                                  fontSize: themeConfig.fontSize * 0.65,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? themeConfig.accentColor
                                      : themeConfig.secondaryTextColor,
                                ),
                        ),
                        ..._buildRubricatedSpans(
                          text: verse.text,
                          baseStyle: _getScriptureTextStyle(
                            themeConfig,
                            fontSize: themeConfig.fontSize,
                            height: themeConfig.lineHeight,
                            color: themeConfig.textColor,
                          ),
                          rubricStyle: _getScriptureTextStyle(
                            themeConfig,
                            fontSize: themeConfig.fontSize,
                            height: themeConfig.lineHeight,
                            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                          ),
                          isEnglish: ref.watch(isEnglishUiProvider),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    for (final verse in bibleState.verses) {
      if (headingsByVerse.containsKey(verse.verse)) {
        flushChunk();
        for (final h in headingsByVerse[verse.verse]!) {
          sections.add(
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 10),
              child: Text(
                h.title,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: themeConfig.fontSize * 0.90,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
              ),
            ),
          );
        }
      }
      currentChunk.add(verse);
    }
    flushChunk();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
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
    final isSelected = _selectedVerseNumber != null &&
        _selectedVerseNumber! >= verse.verse &&
        _selectedVerseNumber! <= (verse.verseEnd ?? verse.verse);
    Color? customHighlight;
    if (verse.highlightColor != null && verse.highlightColor!.isNotEmpty) {
      try {
        final hex = verse.highlightColor!.replaceFirst('#', '0xFF');
        customHighlight = Color(int.parse(hex)).withValues(alpha: isDark ? 0.25 : 0.42);
      } catch (_) {}
    }

    final verseNumStr = _formatVerseLabel(verse, themeConfig.useGeezNumerals);

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
                      : themeConfig.cardBorderColor.withValues(alpha: 0.65),
                  width: isSelected ? 4.0 : 1.5,
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
                        style: themeConfig.useGeezNumerals
                            ? GoogleFonts.notoSansEthiopic(
                                fontSize: themeConfig.fontSize * 0.72,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? themeConfig.accentColor
                                    : themeConfig.secondaryTextColor,
                              )
                            : GoogleFonts.plusJakartaSans(
                                fontSize: themeConfig.fontSize * 0.68,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? themeConfig.accentColor
                                    : themeConfig.secondaryTextColor,
                              ),
                      ),
                      ..._buildRubricatedSpans(
                        text: verse.text,
                        baseStyle: _getScriptureTextStyle(
                          themeConfig,
                          fontSize: themeConfig.fontSize,
                          height: themeConfig.lineHeight,
                          color: themeConfig.textColor,
                        ),
                        rubricStyle: _getScriptureTextStyle(
                          themeConfig,
                          fontSize: themeConfig.fontSize,
                          height: themeConfig.lineHeight,
                          color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                          fontWeight: FontWeight.w700,
                        ),
                        isEnglish: ref.watch(isEnglishUiProvider),
                      ),
                    ],
                  ),
                ),

                // Inline metadata row (Bookmark / Personal Note)
                if (verse.isBookmarked || (verse.note != null && verse.note!.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
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
    final isEnglish = ref.watch(isEnglishUiProvider);

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
              isEnglish
                  ? 'Chapter ${bibleState.currentChapter - 1}'
                  : 'ምዕራፍ ${bibleState.currentChapter - 1}',
              style: isEnglish
                  ? GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)
                  : GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w700, fontSize: 13),
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
              _markActivePlanChapterReadIfApplicable();
              ref.read(bibleStateProvider.notifier).nextChapter();
              setState(() => _selectedVerseNumber = null);
              _scrollToApproximateVerse(1, 30);
            },
            icon: Text(
              isEnglish
                  ? 'Chapter ${bibleState.currentChapter + 1}'
                  : 'ምዕራፍ ${bibleState.currentChapter + 1}',
              style: isEnglish
                  ? GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)
                  : GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            label: const Icon(Icons.east_rounded, size: 16),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
  ) {
    final isEnglish = ref.watch(isEnglishUiProvider);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_outlined, size: 48, color: themeConfig.accentColor),
          const SizedBox(height: 12),
          Text(
            isEnglish ? 'Loading chapter...' : 'ምዕራፉን በመጫን ላይ...',
            style: isEnglish
                ? GoogleFonts.plusJakartaSans(fontSize: 15, color: themeConfig.textColor)
                : GoogleFonts.notoSansEthiopic(fontSize: 15, color: themeConfig.textColor),
          ),
        ],
      ),
    );
  }
}
