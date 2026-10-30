import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/canonical_book_map.dart';
import '../../data/reading_plans_data.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import 'book_selector_screen.dart';
import 'verse_card_maker_screen.dart';
import '../widgets/modern_bible_icons.dart';
import '../widgets/ethiopian_cross_painter.dart';
import '../../services/bahire_hasab_service.dart';
import '../../core/utils/geez_numbers.dart';

class HomeDashboardScreen extends ConsumerWidget {
  final Function(int tabIndex) onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bibleState = ref.watch(bibleStateProvider);
    final themeConfig = ref.watch(themeConfigProvider);
    final repo = ref.watch(bibleRepositoryProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final isEnglish = ref.watch(isEnglishUiProvider);

    if (bibleState.isLoading) {
      return Scaffold(
        backgroundColor: themeConfig.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(bibleStateProvider.notifier).init(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // 1. Modern Editorial Header (No boxy AppBar!)
                  SliverToBoxAdapter(
                    child: _buildModernHeader(context, ref, bibleState, themeConfig, isDark, isEnglish),
                  ),

                  // 2. Main Content Padding
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. Royal EOTC Bahire Hasab Liturgical Banner
                        _buildBahireHasabCard(context, ref, themeConfig, isDark, isEnglish),
                        const SizedBox(height: 18),

                        // 2. Hero: Editorial Daily Verse Card
                        _buildDailyVerseHero(context, ref, repo, themeConfig, isEnglish),
                        const SizedBox(height: 20),

                        // 2-Column Bento Grid: Resume Reading + Active Plan
                        _buildBentoGridRow(context, ref, bibleState, themeConfig, isDark, isEnglish),
                        const SizedBox(height: 26),

                        // Modern Canon Quick-Access Strip
                        _buildCanonQuickStrip(context, ref, themeConfig, isDark, isEnglish),
                        const SizedBox(height: 28),

                        // Visual Reading Plans Carousel
                        _buildReadingPlansCarousel(context, ref, themeConfig, isDark, isEnglish),
                        const SizedBox(height: 28),

                        // Curated Thematic Collections Grid
                        _buildThematicBentoSection(context, ref, themeConfig, isDark, isEnglish),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(
    BuildContext context,
    WidgetRef ref,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
    bool isEnglish,
  ) {
    final shortTrans = _shortTransLabel(bibleState.currentTranslation?.name ?? '81 ቀኖና');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          // Brand Mark
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeConfig.accentColor, const Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: themeConfig.accentColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: ModernBibleIcon(size: 22, color: Colors.white, isFilled: true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isEnglish ? 'Holy Bible' : 'መጽሐፍ ቅዱስ',
                      style: isEnglish
                          ? GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: themeConfig.textColor,
                              letterSpacing: -0.3,
                            )
                          : GoogleFonts.notoSansEthiopic(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: themeConfig.textColor,
                              letterSpacing: -0.3,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeConfig.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isEnglish
                            ? (bibleState.currentTranslation?.id == 4
                                ? 'Ge\'ez 81'
                                : (bibleState.currentTranslation?.id == 3
                                    ? 'KJV'
                                    : (bibleState.currentTranslation?.id == 1 ? '1954 H.S.' : '81 Canon')))
                            : (bibleState.currentTranslation?.id == 4
                                ? 'ግዕዝ 81'
                                : (bibleState.currentTranslation?.id == 1
                                    ? '1954'
                                    : (bibleState.currentTranslation?.id == 3 ? 'KJV' : '81 ቀኖና'))),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: themeConfig.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isEnglish
                      ? 'Ethiopian Orthodox 81 Canon & Translations'
                      : 'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 መጻሕፍትና ትርጉሞች',
                  style: isEnglish
                      ? GoogleFonts.inter(
                          fontSize: 11,
                          color: themeConfig.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        )
                      : GoogleFonts.notoSansEthiopic(
                          fontSize: 11.5,
                          color: themeConfig.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ],
            ),
          ),

          // Translation Pill Switcher
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showTranslationModal(context, ref, bibleState, themeConfig),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: themeConfig.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeConfig.cardBorderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.translate_rounded, size: 14, color: themeConfig.accentColor),
                  const SizedBox(width: 5),
                  Text(
                    shortTrans,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: themeConfig.textColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: themeConfig.secondaryTextColor),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 1-Tap Theme Mode Button
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final notifier = ref.read(themeConfigProvider.notifier);
              if (themeConfig.mode == ReaderThemeMode.light) {
                notifier.setMode(ReaderThemeMode.sepia);
              } else if (themeConfig.mode == ReaderThemeMode.sepia) {
                notifier.setMode(ReaderThemeMode.dark);
              } else {
                notifier.setMode(ReaderThemeMode.light);
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: themeConfig.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: themeConfig.cardBorderColor),
              ),
              child: Icon(
                themeConfig.mode == ReaderThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : themeConfig.mode == ReaderThemeMode.sepia
                        ? Icons.auto_stories_outlined
                        : Icons.light_mode_rounded,
                size: 18,
                color: themeConfig.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBahireHasabCard(
    BuildContext context,
    WidgetRef ref,
    ReaderThemeConfig themeConfig,
    bool isDark,
    bool isEnglish,
  ) {
    final now = DateTime.now();
    final status = BahireHasabService.getCurrentLiturgicalStatus(now);
    final ethDate = status['ethDate'] as EthiopianDate;
    final evangelist = isEnglish ? (status['evangelistEn'] as String) : (status['evangelist'] as String);
    final isFastDay = status['isFastDay'] as bool? ?? false;
    final fastLabel = isEnglish ? (status['fastLabelEn'] as String) : (status['fastLabel'] as String);
    final daysToNext = status['daysToNextEvent'] as int? ?? 0;
    final nextTitle = isEnglish ? (status['nextEventTitleEn'] as String) : (status['nextEventTitle'] as String);
    final lectionary = status['dailyLectionary'] as Map<String, dynamic>?;
    final synaxarium = status['dailySynaxarium'] as SynaxariumEntry?;

    final dateFormatted = isEnglish
        ? ethDate.format(includeDayName: true, isEnglish: true)
        : (themeConfig.useGeezNumerals ? ethDate.toGeezString() : ethDate.format());

    final daysToNextStr = themeConfig.useGeezNumerals && !isEnglish
        ? GeezNumbers.toGeez(daysToNext)
        : '$daysToNext';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF161412), const Color(0xFF221A15)]
              : [const Color(0xFFFCF9F3), const Color(0xFFF4ECE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: themeConfig.goldAccent.withValues(alpha: isDark ? 0.35 : 0.45),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: themeConfig.goldAccent.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Orthodox Cross Icon + Liturgical Badge + Fasting Status Chip
            Row(
              children: [
                OrthodoxCrossIcon(
                  size: 20,
                  color: themeConfig.goldAccent,
                  style: EthiopianCrossStyle.lalibela,
                ),
                const SizedBox(width: 8),
                Text(
                  isEnglish ? 'LITURGICAL CALENDAR' : 'ባሕረ ሐሳብና የዕለቱ ሥርዓት',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: themeConfig.goldAccent,
                  ),
                ),
                if (isFastDay) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.45),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lens,
                          size: 9,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isEnglish ? 'Fast Day' : 'የጾም ቀን',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Date in Authentic Ge'ez Numerals
            Text(
              dateFormatted,
              style: isEnglish
                  ? GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,
                    )
                  : GoogleFonts.notoSansEthiopic(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,
                      letterSpacing: -0.2,
                    ),
            ),
            const SizedBox(height: 4),

            // Evangelist & Fast Category Subtitle
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: themeConfig.accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    evangelist,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fastLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: themeConfig.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),

            // Countdown to Next Major Feast or Fast (e.g. ጾመ ነቢያት)
            if (daysToNext > 0 && nextTitle.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: themeConfig.goldAccent.withValues(alpha: isDark ? 0.10 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: themeConfig.goldAccent.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top_rounded, size: 15, color: themeConfig.goldAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEnglish
                            ? '$daysToNextStr days until $nextTitle'
                            : 'እስከ $nextTitle መግቢያ $daysToNextStr ቀናት ቀርተዋል',
                        style: isEnglish
                            ? GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: themeConfig.textColor,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: themeConfig.textColor,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Daily Synaxarium (የዕለቱ ስንክሳር) Commemoration
            if (synaxarium != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: themeConfig.goldAccent.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeConfig.goldAccent.withValues(alpha: isDark ? 0.35 : 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeConfig.goldAccent.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: OrthodoxCrossIcon(
                        size: 16,
                        color: themeConfig.goldAccent,
                        style: EthiopianCrossStyle.gondar,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isEnglish ? 'DAILY SYNAXARIUM' : 'የዕለቱ ስንክሳር',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: themeConfig.goldAccent,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: themeConfig.goldAccent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  synaxarium.getDisplayPassage(isEnglish),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: themeConfig.goldAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            synaxarium.getDisplayTitle(isEnglish),
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: themeConfig.textColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: themeConfig.textColor,
                                  ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            synaxarium.getDisplayDescription(isEnglish),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 11.5,
                              color: themeConfig.secondaryTextColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: themeConfig.goldAccent),
                      tooltip: isEnglish ? 'Read passage' : 'ምንባብ አንብብ',
                      onPressed: () {
                        final bibleState = ref.read(bibleStateProvider);
                        final targetBook = CanonicalBookMap.resolveBook(
                          books: bibleState.books,
                          currentTranslationId: bibleState.currentTranslation?.id ?? 2,
                          traditionalBookNumber: synaxarium.bookNumber,
                          bookName: synaxarium.bookName,
                        );
                        if (targetBook != null) {
                          ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: synaxarium.chapter);
                        }
                        onNavigateTab(0);
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Appointed EOTC Daily Lectionary Reading
            if (lectionary != null) ...[
              const SizedBox(height: 16),
              Divider(height: 1, color: themeConfig.cardBorderColor),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: themeConfig.accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: themeConfig.accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnglish
                              ? (lectionary['titleEn'] as String)
                              : (lectionary['title'] as String),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: themeConfig.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEnglish
                              ? (lectionary['passageEn'] as String)
                              : (lectionary['passage'] as String),
                          style: isEnglish
                              ? GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: themeConfig.textColor,
                                )
                              : GoogleFonts.notoSansEthiopic(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: themeConfig.textColor,
                                ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isEnglish
                              ? (lectionary['descriptionEn'] as String)
                              : (lectionary['description'] as String),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 11.5,
                            color: themeConfig.secondaryTextColor,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeConfig.accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      final bookNum = lectionary['bookNumber'] as int? ?? 1;
                      final chapter = lectionary['chapter'] as int? ?? 1;
                      final bibleState = ref.read(bibleStateProvider);
                      final targetBook = CanonicalBookMap.resolveBook(
                        books: bibleState.books,
                        currentTranslationId: bibleState.currentTranslation?.id ?? 2,
                        traditionalBookNumber: bookNum,
                        canonicalId: lectionary['canonicalId'] as String?,
                        bookName: lectionary['bookName'] as String?,
                      );
                      if (targetBook != null) {
                        ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: chapter);
                      }
                      onNavigateTab(0);
                    },
                    child: Text(
                      isEnglish ? 'Read' : 'አንብብ',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyVerseHero(
    BuildContext context,
    WidgetRef ref,
    dynamic repo,
    ReaderThemeConfig themeConfig,
    bool isEnglish,
  ) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: repo.getDailyVerse(ref.watch(bibleStateProvider).currentTranslation?.id ?? 2),
      builder: (context, snapshot) {
        final verseData = snapshot.data;
        final reference = verseData != null
            ? '${verseData['book_name']} ${verseData['chapter']}:${verseData['verse']}'
            : 'የዮሐንስ ወንጌል 1:1';
        final verseText = verseData != null
            ? verseData['text'] as String
            : 'በመጀመሪያ ቃል ነበረ፥ ቃልም በእግዚአብሔር ዘንድ ነበረ፥ ቃልም እግዚአብሔር ነበረ።';

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E1B4B),
                Color(0xFF312E81),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF312E81).withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative ambient glow circle
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Pill Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                isEnglish ? 'DAILY SCRIPTURE' : 'የዕለቱ ቃል',
                                style: isEnglish
                                    ? GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      )
                                    : GoogleFonts.notoSansEthiopic(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VerseCardMakerScreen(
                                  reference: reference,
                                  verseText: verseText,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.palette_outlined, color: Color(0xFFFBBF24), size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  isEnglish ? 'Share Card' : 'ካርድ ፍጠር',
                                  style: const TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Main Verse Quote
                    Text(
                      '“$verseText”',
                      style: GoogleFonts.notoSansEthiopic(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.65,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Reference & Read Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '— $reference',
                          style: GoogleFonts.notoSansEthiopic(
                            color: const Color(0xFFFBBF24),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1E1B4B),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            if (verseData != null) {
                              final bookNumber = verseData['book_number'] as int? ?? 1;
                              final chapter = verseData['chapter'] as int? ?? 1;
                              final bibleState = ref.read(bibleStateProvider);
                              final targetBook = bibleState.books.firstWhere(
                                (b) => b.bookNumber == bookNumber,
                                orElse: () => bibleState.books.first,
                              );
                              ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: chapter);
                            }
                            onNavigateTab(0);
                          },
                          icon: const Icon(Icons.menu_book_rounded, size: 15),
                          label: Text(
                            isEnglish ? 'Read Chapter' : 'ምዕራፉን አንብብ',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBentoGridRow(
    BuildContext context,
    WidgetRef ref,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
    bool isEnglish,
  ) {
    final book = bibleState.currentBook;
    final chapter = bibleState.currentChapter;
    final totalCh = book?.totalChapters ?? 50;
    final progress = (chapter / totalCh).clamp(0.02, 1.0);

    return Row(
      children: [
        // Left Bento: Resume Reading with Circular Progress
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onNavigateTab(0),
            child: Container(
              height: 156,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: themeConfig.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: themeConfig.cardBorderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: themeConfig.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.import_contacts_rounded, color: themeConfig.accentColor, size: 20),
                      ),
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3.5,
                              backgroundColor: themeConfig.cardBorderColor,
                              valueColor: AlwaysStoppedAnimation<Color>(themeConfig.accentColor),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: themeConfig.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    isEnglish ? 'RESUME READING' : 'የቀጠለ ንባብ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: themeConfig.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book != null ? book.name : (isEnglish ? 'Genesis' : 'ኦሪት ዘፍጥረት'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEnglish ? 'Chapter $chapter of $totalCh' : 'ምዕራፍ $chapter ከ $totalCh',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: themeConfig.accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: themeConfig.accentColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Right Bento: Reading Plans Hub
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onNavigateTab(2),
            child: Container(
              height: 156,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: themeConfig.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: themeConfig.cardBorderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: themeConfig.goldAccent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.explore_rounded, color: themeConfig.goldAccent, size: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: themeConfig.goldAccent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isEnglish
                              ? '${ReadingPlansData.allPlans.length} Plans'
                              : '${ReadingPlansData.allPlans.length} ዕቅዶች',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.goldAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    isEnglish ? 'READING PLANS' : 'ሥርዓተ ንባብ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: themeConfig.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isEnglish ? 'Devotional Plans' : 'የንባብ ዕቅዶች',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEnglish ? 'Fasts, Feasts & More' : 'ጾም፣ በዓላትና ዓመታዊ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: themeConfig.goldAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: themeConfig.goldAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCanonQuickStrip(
    BuildContext context,
    WidgetRef ref,
    ReaderThemeConfig themeConfig,
    bool isDark,
    bool isEnglish,
  ) {
    final items = [
      {
        'label': 'ወንጌላት',
        'sub': 'Gospels',
        'icon': Icons.auto_awesome_rounded,
        'bookNum': 40,
        'grad': [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
      },
      {
        'label': 'መዝሙር',
        'sub': 'Psalms',
        'icon': Icons.music_note_rounded,
        'bookNum': 19,
        'grad': [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
      },
      {
        'label': 'ኦሪት',
        'sub': 'Torah',
        'icon': Icons.menu_book_rounded,
        'bookNum': 1,
        'grad': [const Color(0xFF047857), const Color(0xFF10B981)],
      },
      {
        'label': 'ጥበብ',
        'sub': 'Proverbs',
        'icon': Icons.lightbulb_rounded,
        'bookNum': 20,
        'grad': [const Color(0xFFE11D48), const Color(0xFFF43F5E)],
      },
      {
        'label': '81 ቀኖና',
        'sub': 'Orthodox',
        'icon': Icons.account_balance_rounded,
        'bookNum': 1,
        'transId': 2,
        'grad': [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
      },
      {
        'label': 'ሁሉም',
        'sub': 'All Books',
        'icon': Icons.grid_view_rounded,
        'isAll': true,
        'grad': [const Color(0xFF334155), const Color(0xFF475569)],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ፈጣን መዳረሻ', 'Sacred Canon', themeConfig, isEnglish),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final item = items[idx];
              final grad = item['grad'] as List<Color>;

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  if (item['isAll'] == true) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BookSelectorScreen()));
                  } else {
                    final bibleState = ref.read(bibleStateProvider);
                    final transId = item['transId'] as int?;
                    if (transId != null) {
                      final t = bibleState.translations.firstWhere((x) => x.id == transId);
                      await ref.read(bibleStateProvider.notifier).selectTranslation(t);
                    }
                    final bookNum = item['bookNum'] as int? ?? 1;
                    final activeTrans = ref.read(bibleStateProvider);
                    final targetBook = CanonicalBookMap.resolveBook(
                      books: activeTrans.books,
                      currentTranslationId: activeTrans.currentTranslation?.id ?? 2,
                      traditionalBookNumber: bookNum,
                    );
                    if (targetBook != null) {
                      await ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: 1);
                    }
                    onNavigateTab(0);
                  }
                },
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeConfig.cardBorderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: grad),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item['icon'] as IconData, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEnglish ? (item['sub'] as String) : (item['label'] as String),
                        style: isEnglish
                            ? GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: themeConfig.textColor,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: themeConfig.textColor,
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReadingPlansCarousel(
    BuildContext context,
    WidgetRef ref,
    ReaderThemeConfig themeConfig,
    bool isDark,
    bool isEnglish,
  ) {
    final plans = ReadingPlansData.allPlans.take(6).toList();
    final gradients = [
      [const Color(0xFF4F46E5), const Color(0xFF3730A3)],
      [const Color(0xFF0D9488), const Color(0xFF115E59)],
      [const Color(0xFF047857), const Color(0xFF065F46)],
      [const Color(0xFFE11D48), const Color(0xFF9F1239)],
      [const Color(0xFF7C3AED), const Color(0xFF5B21B6)],
      [const Color(0xFF2563EB), const Color(0xFF1E40AF)],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('የንባብ ዕቅዶች', 'Devotional Plans', themeConfig, isEnglish),
            TextButton(
              onPressed: () => onNavigateTab(2),
              child: Text(
                isEnglish
                    ? 'View all (${ReadingPlansData.allPlans.length}) →'
                    : 'ሁሉንም እይ (${ReadingPlansData.allPlans.length}) →',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: themeConfig.accentColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: plans.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, idx) {
              final plan = plans[idx];
              final grad = gradients[idx % gradients.length];

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onNavigateTab(2),
                child: Container(
                  width: 230,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: grad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: grad[0].withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              plan.getDisplayCategory(isEnglish),
                              style: isEnglish
                                  ? GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    )
                                  : GoogleFonts.notoSansEthiopic(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                            ),
                          ),
                          Text(
                            isEnglish ? '${plan.totalDays} Days' : '${plan.totalDays} ቀናት',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        plan.getDisplayTitle(isEnglish),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: isEnglish
                            ? GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.getDisplaySubtitle(isEnglish),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: isEnglish
                            ? GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 11.5,
                                height: 1.35,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThematicBentoSection(
    BuildContext context,
    WidgetRef ref,
    ReaderThemeConfig themeConfig,
    bool isDark,
    bool isEnglish,
  ) {
    final guides = [
      {
        'title': 'የተራራው ስብከት',
        'titleEn': 'Sermon on the Mount',
        'sub': 'ማቴዎስ ምዕራፍ 5–7',
        'subEn': 'Matthew Ch. 5–7',
        'bookNum': 40,
        'chapter': 5,
        'icon': Icons.wb_twilight_rounded,
        'color': const Color(0xFF4F46E5),
      },
      {
        'title': 'መጽናኛና ጥበቃ',
        'titleEn': 'Comfort & Refuge',
        'sub': 'መዝሙር 23 እና 91',
        'subEn': 'Psalm 23 & 91',
        'bookNum': 19,
        'chapter': 23,
        'icon': Icons.shield_outlined,
        'color': const Color(0xFF0D9488),
      },
      {
        'title': 'የጥበብ መጀመሪያ',
        'titleEn': 'Beginning of Wisdom',
        'sub': 'መጽሐፈ ምሳሌ ምዕራፍ 1',
        'subEn': 'Proverbs Ch. 1',
        'bookNum': 20,
        'chapter': 1,
        'icon': Icons.workspace_premium_outlined,
        'color': const Color(0xFF047857),
      },
      {
        'title': 'የፍቅር መዝሙር',
        'titleEn': 'Hymn of Love',
        'sub': '1 ቆሮንቶስ ምዕራፍ 13',
        'subEn': '1 Corinthians Ch. 13',
        'bookNum': 46,
        'chapter': 13,
        'icon': Icons.favorite_border_rounded,
        'color': const Color(0xFFE11D48),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('የተመረጡ የጥናት ክፍሎች', 'Curated Passages', themeConfig, isEnglish),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.1,
          ),
          itemCount: guides.length,
          itemBuilder: (context, idx) {
            final g = guides[idx];
            final color = g['color'] as Color;
            final titleStr = isEnglish ? (g['titleEn'] as String) : (g['title'] as String);
            final subStr = isEnglish ? (g['subEn'] as String) : (g['sub'] as String);

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                final bookNum = g['bookNum'] as int;
                final chapter = g['chapter'] as int;
                final bibleState = ref.read(bibleStateProvider);
                final targetBook = CanonicalBookMap.resolveBook(
                  books: bibleState.books,
                  currentTranslationId: bibleState.currentTranslation?.id ?? 2,
                  traditionalBookNumber: bookNum,
                  bookName: g['title'] as String?,
                );
                if (targetBook != null) {
                  await ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: chapter);
                }
                onNavigateTab(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: themeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: themeConfig.cardBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(g['icon'] as IconData, color: color, size: 19),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleStr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: themeConfig.textColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: themeConfig.textColor,
                                  ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subStr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: themeConfig.secondaryTextColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontSize: 11,
                                    color: themeConfig.secondaryTextColor,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String amharic, String english, ReaderThemeConfig themeConfig, bool isEnglish) {
    return Text(
      isEnglish ? english : amharic,
      style: isEnglish
          ? GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: themeConfig.textColor,
            )
          : GoogleFonts.notoSansEthiopic(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: themeConfig.textColor,
            ),
    );
  }

  String _shortTransLabel(String name) {
    if (name.contains('ግዕዝ') || name.contains('gez') || name.contains('Ge\'ez')) return 'ግዕዝ 81';
    if (name.contains('81')) return '81 ቀኖና';
    if (name.contains('King James') || name.contains('KJV')) return 'KJV';
    return '1954 ትርጉም';
  }

  void _showTranslationModal(
    BuildContext context,
    WidgetRef ref,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
  ) {
    final isEnglish = ref.watch(isEnglishUiProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: themeConfig.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish ? 'Select Bible Translation' : 'የመጽሐፍ ቅዱስ ትርጉም ይምረጡ',
              style: isEnglish
                  ? GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,
                    )
                  : GoogleFonts.notoSansEthiopic(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,
                    ),
            ),
            const SizedBox(height: 14),
            ...bibleState.translations.map((t) {
              final selected = t.id == bibleState.currentTranslation?.id;
              final subtitle = t.id == 2
                  ? (isEnglish ? 'Ethiopian Orthodox 81 Books Canon (Amharic)' : 'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 መጻሕፍት ቀኖና')
                  : (t.id == 4
                      ? (isEnglish ? 'Ancient Classical Ge\'ez 81 Books Canon' : 'የቀደምት ግዕዝ 81 መጻሕፍት ቀኖና (ጥንታዊ ቅርስ)')
                      : (t.id == 1
                          ? (isEnglish ? 'Emperor Haile Selassie 1954 (66 Books)' : 'የቀዳማዊ ኃይለ ሥላሴ 1954 ትርጉም (66 መጻሕፍት)')
                          : (isEnglish ? 'Authorized King James Version (English)' : 'የኪንግ ጀምስ 1611 የእንግሊዝኛ ትርጉም')));

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? themeConfig.accentColor.withValues(alpha: 0.08)
                      : themeConfig.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? themeConfig.accentColor : themeConfig.cardBorderColor,
                    width: selected ? 1.8 : 1,
                  ),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        t.name,
                        style: isEnglish
                            ? GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: themeConfig.textColor,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                color: themeConfig.textColor,
                              ),
                      ),
                      if (t.id == 4) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF854D0E).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isEnglish ? 'Ge\'ez' : 'ግዕዝ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF854D0E),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    subtitle,
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 12,
                            color: themeConfig.secondaryTextColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
                            fontSize: 12,
                            color: themeConfig.secondaryTextColor,
                          ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_circle_rounded, color: themeConfig.accentColor)
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(bibleStateProvider.notifier).selectTranslation(t);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
