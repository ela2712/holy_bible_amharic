import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/reading_plans_data.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import '../../providers/reading_progress_provider.dart';
import 'verse_card_maker_screen.dart';
import 'liturgical_calendar_screen.dart';
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
                        const SizedBox(height: 18),

                        // 3. Reading Journey & Streaks Card
                        _buildReadingStreaksCard(context, ref, bibleState, themeConfig, isDark, isEnglish),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      isEnglish ? 'Holy Bible' : 'መጽሐፍ ቅዱስ',
                      style: themeConfig.getAppStyle(
                        isEnglish: isEnglish,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: themeConfig.textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
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
                        style: themeConfig.getAppStyle(
                          isEnglish: isEnglish,
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
                  style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 11.5,
                          color: themeConfig.secondaryTextColor,
                          fontWeight: FontWeight.w500,),
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
                    style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: themeConfig.textColor,),
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
                Expanded(
                  child: Text(
                    isEnglish ? 'LITURGICAL CALENDAR' : 'ባሕረ ሐሳብና የዕለቱ ሥርዓት',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: themeConfig.getAppStyle(
                      isEnglish: isEnglish,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: themeConfig.goldAccent,
                    ),
                  ),
                ),
                if (isFastDay) ...[
                  const SizedBox(width: 8),
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
                          style: themeConfig.getAppStyle(
                            isEnglish: isEnglish,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFEF4444),
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
              style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 18.5,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,
                      letterSpacing: -0.2,),
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
                    style: themeConfig.getAppStyle(
                      isEnglish: isEnglish,
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
                    style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: themeConfig.secondaryTextColor,),
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
                        style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: themeConfig.textColor,),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // View Full Liturgical Calendar Button
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LiturgicalCalendarScreen()),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: themeConfig.goldAccent.withValues(alpha: isDark ? 0.14 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: themeConfig.goldAccent.withValues(alpha: isDark ? 0.35 : 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 16, color: themeConfig.goldAccent),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isEnglish ? 'View Full Liturgical Calendar' : 'ሙሉውን የአጽዋማትና በዓላት ቀን መቁጠሪያ እይ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 12.5, fontWeight: FontWeight.w800, color: themeConfig.textColor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded, size: 11, color: themeConfig.goldAccent),
                  ],
                ),
              ),
            ),
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
        final themeLabel = verseData != null
            ? (isEnglish
                ? (verseData['theme_en'] as String? ?? 'DAILY SCRIPTURE')
                : (verseData['theme'] as String? ?? 'የዕለቱ ቃል'))
            : (isEnglish ? 'DAILY SCRIPTURE' : 'የዕለቱ ቃል');

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
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const OrthodoxVectorIcon(
                                  kind: OrthodoxIconKind.bethlehemStar,
                                  color: Color(0xFFFBBF24),
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    themeLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: themeConfig.getAppStyle(
                                      isEnglish: isEnglish,
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                  style: themeConfig.getAppStyle(
                                    isEnglish: isEnglish,
                                    color: const Color(0xFFFBBF24),
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
                      style: themeConfig.getAppStyle(isEnglish: isEnglish, color: Colors.white,
                        fontSize: 18,
                        height: 1.65,
                        fontWeight: FontWeight.w600,),
                    ),
                    const SizedBox(height: 12),

                    // Reference & Read Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '— $reference',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: themeConfig.getAppStyle(
                              isEnglish: isEnglish,
                              color: const Color(0xFFFBBF24),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                          icon: const OrthodoxVectorIcon(
                            kind: OrthodoxIconKind.geezScroll,
                            size: 16,
                            color: Color(0xFF1E1B4B),
                          ),
                          label: Text(
                            isEnglish ? 'Read Chapter' : 'ምዕራፉን አንብብ',
                            style: themeConfig.getAppStyle(
                              isEnglish: isEnglish,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: const Color(0xFF1E1B4B),
                            ),
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
                        child: OrthodoxVectorIcon(
                          kind: OrthodoxIconKind.birannaCodex,
                          color: themeConfig.accentColor,
                          size: 22,
                        ),
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
                              style: themeConfig.getAppStyle(
                                isEnglish: true,
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
                    style: themeConfig.getAppStyle(
                      isEnglish: isEnglish,
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
                    style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEnglish ? 'Chapter $chapter of $totalCh' : 'ምዕራፍ $chapter ከ $totalCh',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: themeConfig.getAppStyle(
                            isEnglish: isEnglish,
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
                        child: OrthodoxVectorIcon(
                          kind: OrthodoxIconKind.orthodoxCross,
                          color: themeConfig.goldAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: themeConfig.goldAccent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isEnglish
                                ? '${ReadingPlansData.allPlans.length} Plans'
                                : '${ReadingPlansData.allPlans.length} ዕቅዶች',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: themeConfig.getAppStyle(
                              isEnglish: isEnglish,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: themeConfig.goldAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    isEnglish ? 'READING PLANS' : 'ሥርዓተ ንባብ',
                    style: themeConfig.getAppStyle(
                      isEnglish: isEnglish,
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
                    style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEnglish ? 'Fasts, Feasts & More' : 'ጾም፣ በዓላትና ዓመታዊ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: themeConfig.getAppStyle(
                            isEnglish: isEnglish,
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

  Widget _buildReadingStreaksCard(
    BuildContext context,
    WidgetRef ref,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isDark,
    bool isEnglish,
  ) {
    final progressState = ref.watch(readingProgressProvider);
    final streak = progressState.currentStreak;
    final longestStreak = progressState.longestStreak;
    final todayCount = progressState.chaptersReadToday;
    final totalRead = progressState.totalChaptersRead;
    final completedBooks = progressState.getCompletedBooksCount(bibleState.books);
    final totalBooks = bibleState.books.isNotEmpty ? bibleState.books.length : 81;

    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header: Flame + Streak Title + Longest Streak
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const OrthodoxVectorIcon(
                  kind: OrthodoxIconKind.vigilFlame,
                  color: Color(0xFFF97316),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak > 0
                          ? (isEnglish ? '$streak-Day Reading Streak!' : '$streak የቀናት ተከታታይ ንባብ!')
                          : (isEnglish ? 'Start Your Reading Streak' : 'የንባብ ተከታታይነትዎን ይጀምሩ'),
                      style: themeConfig.getAppStyle(isEnglish: isEnglish, fontWeight: FontWeight.w800, fontSize: 15, color: themeConfig.textColor),
                    ),
                    Text(
                      isEnglish
                          ? (streak > 0 ? 'Best: $longestStreak days' : 'Read any chapter today to begin')
                          : (streak > 0 ? 'ከፍተኛው: $longestStreak ቀናት' : 'ተከታታይነት ለመጀመር ዛሬ አንድ ምዕራፍ ያንብቡ'),
                      style: themeConfig.getAppStyle(
                        isEnglish: isEnglish,
                        fontSize: 11.5,
                        color: themeConfig.secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (todayCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF047857).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF047857)),
                      const SizedBox(width: 4),
                      Text(
                        isEnglish ? '$todayCount ch today' : 'ዛሬ $todayCount ምዕራፍ',
                        style: themeConfig.getAppStyle(
                          isEnglish: isEnglish,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 7-day Mini Activity Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final date = now.subtract(Duration(days: 6 - i));
              final isActive = progressState.wasActiveOn(date);
              final isToday = i == 6;
              final dayInitial = isEnglish
                  ? ['M', 'T', 'W', 'T', 'F', 'S', 'S'][(date.weekday - 1) % 7]
                  : ['ሰ', 'ማ', 'ረ', 'ሐ', 'ዓ', 'ቅ', 'እ'][(date.weekday - 1) % 7];

              return Column(
                children: [
                  Text(
                    dayInitial,
                    style: themeConfig.getAppStyle(
                      isEnglish: isEnglish,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isToday ? themeConfig.accentColor : themeConfig.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive
                          ? themeConfig.accentColor
                          : (isToday ? themeConfig.accentColor.withValues(alpha: 0.12) : themeConfig.backgroundColor),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? themeConfig.accentColor
                            : (isToday ? themeConfig.accentColor : themeConfig.cardBorderColor),
                        width: isToday || isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: isActive
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                          : Text(
                              '${date.day}',
                              style: themeConfig.getAppStyle(
                                isEnglish: true,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isToday ? themeConfig.accentColor : themeConfig.secondaryTextColor,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Bottom Stats: Completed Books & Total Chapters
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? 'BOOKS COMPLETED' : 'የተጠናቀቁ መጻሕፍት',
                      style: themeConfig.getAppStyle(
                        isEnglish: isEnglish,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: themeConfig.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedBooks / $totalBooks',
                      style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 16, fontWeight: FontWeight.w800, color: themeConfig.textColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? 'TOTAL CHAPTERS' : 'ጠቅላላ የተነበቡ ምዕራፎች',
                      style: themeConfig.getAppStyle(
                        isEnglish: isEnglish,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: themeConfig.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish ? '$totalRead Chapters' : '$totalRead ምዕራፎች',
                      style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 16, fontWeight: FontWeight.w800, color: themeConfig.accentColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
              style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,),
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
                      Flexible(
                        child: Text(
                          t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: themeConfig.getAppStyle(
                            isEnglish: isEnglish,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: themeConfig.textColor,
                          ),
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
                            style: themeConfig.getAppStyle(
                              isEnglish: isEnglish,
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
                    style: themeConfig.getAppStyle(isEnglish: isEnglish, fontSize: 12,
                            color: themeConfig.secondaryTextColor,),
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
