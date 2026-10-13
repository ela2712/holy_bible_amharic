import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geez_numbers.dart';
import '../../data/patristic_commentaries.dart';
import '../../data/cross_references_data.dart';
import '../../models/verse.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import '../../services/audio_player_service.dart';
import '../../providers/reading_plan_session_provider.dart';
import '../widgets/audio_player_bar.dart';
import 'book_selector_screen.dart';
import 'parallel_reader_screen.dart';
import 'settings_screen.dart';
import 'study_tools_dialog.dart';

class HomeReaderScreen extends ConsumerStatefulWidget {
  final ValueChanged<bool>? onChromeVisibilityChanged;
  final Function(int tabIndex)? onNavigateTab;

  const HomeReaderScreen({
    super.key,
    this.onChromeVisibilityChanged,
    this.onNavigateTab,
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
    final audioState = ref.watch(audioPlayerServiceProvider);
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
                                  82,
                                  22,
                                  planSession.activeSessionPlan != null ? 175 : 130,
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
                                    themeConfig,
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
                                      return _buildCatenaVerseRow(
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

            // 2. Auto-Hiding Floating Top Reader Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              top: _isChromeVisible ? 8 : -80,
              left: 16,
              right: 16,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 740),
                  child: _buildFloatingReaderBar(
                    context,
                    currentBook?.name ?? 'መጽሐፍ ምረጥ',
                    chapterStr,
                    bibleState,
                    themeConfig,
                    audioState,
                    isDark,
                  ),
                ),
              ),
            ),

            // 3. Active Reading Plan In-Reader Floating Bar (if user is reading a plan)
            if (planSession.activeSessionPlan != null && planSession.activePassage != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                bottom: _isChromeVisible ? 88 : 16,
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

            // 4. Audio Player Bar (when active)
            if (audioState.currentTrackTitle != null)
              Positioned(
                bottom: _isChromeVisible ? 88 : 16,
                left: 16,
                right: 16,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: const AudioPlayerBar(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingReaderBar(
    BuildContext context,
    String bookName,
    String chapterStr,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    AudioState audioState,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: themeConfig.surfaceColor.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: themeConfig.cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Book & Chapter Selector Pill (opens 3-step Book -> Chapter -> Verse sheet)
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  BookSelectorScreen.show(
                    context,
                    onVerseSelected: (vNum) {
                      _scrollToApproximateVerse(vNum, bibleState.verses.length);
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: themeConfig.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: themeConfig.cardBorderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 145),
                        child: Text(
                          '$bookName $chapterStr',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 17,
                        color: themeConfig.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Translation Switcher Pill
              PopupMenuButton<int>(
                tooltip: 'ትርጉም ቀይር (Switch Translation)',
                onSelected: (tId) {
                  if (bibleState.translations.isEmpty) return;
                  final target = bibleState.translations.firstWhere(
                    (t) => t.id == tId,
                    orElse: () => bibleState.translations.first,
                  );
                  ref.read(bibleStateProvider.notifier).selectTranslation(target);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 1, child: Text('1954 ቀዳማዊ ኃይለ ሥላሴ (66)')),
                  PopupMenuItem(value: 2, child: Text('ሰማንያ አሐዱ 81 ቀኖና (81)')),
                  PopupMenuItem(value: 3, child: Text('King James Version (KJV)')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeConfig.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bibleState.currentTranslation?.id == 2
                        ? '81 ቀኖና'
                        : (bibleState.currentTranslation?.id == 3 ? 'KJV' : '1954'),
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.accentColor,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Paragraph vs Verse Flow Toggle
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  themeConfig.isParagraphMode
                      ? Icons.format_align_justify_rounded
                      : Icons.view_headline_rounded,
                  size: 19,
                  color: themeConfig.isParagraphMode
                      ? themeConfig.accentColor
                      : themeConfig.secondaryTextColor,
                ),
                tooltip: themeConfig.isParagraphMode ? 'በየቁጥሩ (Verse Flow)' : 'በአንቀጽ (Paragraph)',
                onPressed: () {
                  ref.read(themeConfigProvider.notifier).toggleParagraphMode(!themeConfig.isParagraphMode);
                },
              ),

              // 1-Tap Theme Mode Cycle (Light -> Sepia -> Dark)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  themeConfig.mode == ReaderThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : themeConfig.mode == ReaderThemeMode.sepia
                          ? Icons.auto_stories_rounded
                          : Icons.light_mode_rounded,
                  size: 19,
                  color: themeConfig.secondaryTextColor,
                ),
                tooltip: 'ገጽታ ቀይር (Cycle Theme)',
                onPressed: () {
                  final next = themeConfig.mode == ReaderThemeMode.light
                      ? ReaderThemeMode.sepia
                      : themeConfig.mode == ReaderThemeMode.sepia
                          ? ReaderThemeMode.dark
                          : ReaderThemeMode.light;
                  ref.read(themeConfigProvider.notifier).setThemeMode(next);
                },
              ),

              // Audio Narration
              Builder(
                builder: (context) {
                  final book = bibleState.currentBook;
                  final isCached = book != null &&
                      ref.read(audioPlayerServiceProvider.notifier).isChapterCached(
                            book.bookNumber,
                            bibleState.currentChapter,
                          );
                  final isThisTrackPlaying = audioState.isPlaying &&
                      audioState.currentBookNumber == book?.bookNumber &&
                      audioState.currentChapter == bibleState.currentChapter;

                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isThisTrackPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.headphones_rounded,
                          size: 19,
                          color: isThisTrackPlaying
                              ? themeConfig.accentColor
                              : themeConfig.secondaryTextColor,
                        ),
                        if (isCached)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    tooltip: isCached
                        ? 'በድምፅ አዳምጥ (ከመስመር ውጭ ተቀምጧል)'
                        : 'በድምፅ አዳምጥ (Audio)',
                    onPressed: () {
                      if (book == null) return;
                      if (isThisTrackPlaying) {
                        ref.read(audioPlayerServiceProvider.notifier).togglePlayPause();
                      } else {
                        ref.read(audioPlayerServiceProvider.notifier).playChapterAudio(
                              bookNumber: book.bookNumber,
                              chapter: bibleState.currentChapter,
                              bookName: book.name,
                            );
                      }
                    },
                  );
                },
              ),

              // Parallel View
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.compare_arrows_rounded, size: 19, color: themeConfig.secondaryTextColor),
                tooltip: 'ማነፃፀሪያ (Parallel)',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ParallelReaderScreen()),
                  );
                },
              ),

              // Typography Settings
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.text_fields_rounded, size: 19, color: themeConfig.secondaryTextColor),
                tooltip: 'የፊደል ቅንብር (Typography)',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
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
    ReaderThemeConfig themeConfig,
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
            final verseNumStr = _formatNumber(verse.verse, themeConfig.useGeezNumerals);
            final directCommentaries = PatristicCommentariesData.getCommentariesForVerse(
              bibleState.currentBook?.bookNumber ?? 1,
              verse.chapter,
              verse.verse,
            );

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
                        TextSpan(
                          text: ' ✝',
                          style: TextStyle(
                            fontSize: themeConfig.fontSize * 0.65,
                            fontWeight: FontWeight.bold,
                            color: themeConfig.accentColor,
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

  /// Minimalist Catena-inspired continuous verse flow with Left-Margin Accent Bars
  Widget _buildCatenaVerseRow(
    BuildContext context,
    Verse verse,
    List<SectionHeading> headings,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final isSelected = _selectedVerseNumber == verse.verse;
    final bookNumber = bibleState.currentBook?.bookNumber ?? 1;
    final directCommentaries = PatristicCommentariesData.getCommentariesForVerse(
      bookNumber,
      verse.chapter,
      verse.verse,
    );
    final hasDirectCommentary = directCommentaries.isNotEmpty;
    final crossRefs = CrossReferencesData.getCrossReferencesForVerse(
      bookNumber,
      verse.chapter,
      verse.verse,
    );

    Color? customHighlight;
    if (verse.highlightColor != null && verse.highlightColor!.isNotEmpty) {
      try {
        final hex = verse.highlightColor!.replaceFirst('#', '0xFF');
        customHighlight = Color(int.parse(hex)).withValues(alpha: isDark ? 0.25 : 0.42);
      } catch (_) {}
    }

    final verseNumStr = _formatNumber(verse.verse, themeConfig.useGeezNumerals);
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
                            child: Text(
                              '✝ ${directCommentaries.length} የአበው ትርጓሜ • ${crossRefs.length} ማጣቀሻ',
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: themeConfig.accentColor,
                              ),
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
