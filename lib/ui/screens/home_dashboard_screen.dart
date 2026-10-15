import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/canonical_book_map.dart';
import '../../data/patristic_commentaries.dart';
import '../../data/reading_plans_data.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import 'book_selector_screen.dart';
import 'verse_card_maker_screen.dart';
import '../widgets/modern_bible_icons.dart';

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
                    child: _buildModernHeader(context, ref, bibleState, themeConfig, isDark),
                  ),

                  // 2. Main Content Padding
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Hero: Editorial Daily Verse + Patristic Glass Card
                        _buildDailyVerseHero(context, ref, repo, themeConfig),
                        const SizedBox(height: 20),

                        // 2-Column Bento Grid: Resume Reading + Active Plan
                        _buildBentoGridRow(context, ref, bibleState, themeConfig, isDark),
                        const SizedBox(height: 26),

                        // Modern Canon Quick-Access Strip
                        _buildCanonQuickStrip(context, ref, themeConfig, isDark),
                        const SizedBox(height: 28),

                        // Church Fathers & Patristic Spotlight Carousel
                        _buildPatristicSpotlight(context, ref, themeConfig, isDark),
                        const SizedBox(height: 28),

                        // Visual Reading Plans Carousel
                        _buildReadingPlansCarousel(context, ref, themeConfig, isDark),
                        const SizedBox(height: 28),

                        // Curated Thematic Collections Grid
                        _buildThematicBentoSection(context, ref, themeConfig, isDark),
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
                      'መጽሐፍ ቅዱስ',
                      style: GoogleFonts.notoSansEthiopic(
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
                        'አንድምታ',
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
                  'የቀደምት አበው ትርጓሜና የጥናት መጽሐፍ ቅዱስ',
                  style: GoogleFonts.notoSansEthiopic(
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

  Widget _buildDailyVerseHero(
    BuildContext context,
    WidgetRef ref,
    dynamic repo,
    ReaderThemeConfig themeConfig,
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

        final featuredCommentary = PatristicCommentariesData.getFeaturedCommentary();

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
                                'የዕለቱ ቃል • DAILY SCRIPTURE',
                                style: GoogleFonts.notoSansEthiopic(
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
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.palette_outlined, color: Color(0xFFFBBF24), size: 14),
                                SizedBox(width: 5),
                                Text(
                                  'ካርድ ፍጠር',
                                  style: TextStyle(
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
                          label: const Text('ምዕራፉን አንብብ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                      ],
                    ),

                    // Frosted Glass Church Father Insight Box
                    if (featuredCommentary != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF818CF8).withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'የአበው ትርጓሜ',
                                    style: TextStyle(
                                      color: Color(0xFFC7D2FE),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    featuredCommentary.authorName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.notoSansEthiopic(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              featuredCommentary.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSansEthiopic(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12.5,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    'የቀጠለ ንባብ • RESUME',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: themeConfig.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book != null ? book.name : 'ኦሪት ዘፍጥረት',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ምዕራፍ $chapter ከ $totalCh',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: themeConfig.accentColor,
                        ),
                      ),
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
                          '10 ዕቅዶች',
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
                    'ሥርዓተ ንባብ • PLANS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: themeConfig.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'የንባብ ዕቅዶች',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ጾም፣ በዓላትና ዓመታዊ',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: themeConfig.goldAccent,
                        ),
                      ),
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
        _buildSectionTitle('ፈጣን መዳረሻ', 'SACRED CANON', themeConfig),
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
                        item['label'] as String,
                        style: GoogleFonts.notoSansEthiopic(
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

  Widget _buildPatristicSpotlight(
    BuildContext context,
    WidgetRef ref,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final fathers = [
      {
        'name': 'ቅዱስ ዮሐንስ አፈወርቅ',
        'en': 'St. John Chrysostom',
        'era': '349–407 ዓ.ም.',
        'quote': '«ትሕትና የሰማያዊ ሕይወት መሠረትና የመንግሥተ ሰማያት መግቢያ ናት።»',
        'ref': 'ማቴዎስ 5:3',
        'bookNum': 40,
        'chapter': 5,
        'color': const Color(0xFF4F46E5),
      },
      {
        'name': 'ቅዱስ ባስልዮስ ዘቂሣርያ',
        'en': 'St. Basil the Great',
        'era': '330–379 ዓ.ም.',
        'quote': '«ዓለም በድንገት ያልተገኘች፣ ነገር ግን በእግዚአብሔር ጥበብ የተፈጠረች ናት።»',
        'ref': 'ዘፍጥረት 1:1',
        'bookNum': 1,
        'chapter': 1,
        'color': const Color(0xFF0D9488),
      },
      {
        'name': 'ቅዱስ ቄርሎስ ዘእስክንድርያ',
        'en': 'St. Cyril of Alexandria',
        'era': '376–444 ዓ.ም.',
        'quote': '«አማኑኤል መባሉ እውነተኛ አምላክ ከእኛ ጋር ሥጋ ለብሶ መገለጡን ይመሰክራል።»',
        'ref': 'ማቴዎስ 1:23',
        'bookNum': 40,
        'chapter': 1,
        'color': const Color(0xFF047857),
      },
      {
        'name': 'ቅዱስ ኤፍሬም ሶርያዊ',
        'en': 'St. Ephrem the Syrian',
        'era': '306–373 ዓ.ም.',
        'quote': '«መንፈስ ቅዱስ በውኃ ላይ ሰፍፎ ለዓለም አዲስ ሕይወትና ልደት ሰጠ።»',
        'ref': 'ዘፍጥረት 1:2',
        'bookNum': 1,
        'chapter': 1,
        'color': const Color(0xFF7C3AED),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('የቀደምት አበው ትርጓሜ', 'PATRISTIC COMMENTARIES', themeConfig),
        const SizedBox(height: 12),
        SizedBox(
          height: 158,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: fathers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, idx) {
              final f = fathers[idx];
              final color = f['color'] as Color;

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () async {
                  final bookNum = f['bookNum'] as int;
                  final chapter = f['chapter'] as int;
                  final bibleState = ref.read(bibleStateProvider);
                  final targetBook = CanonicalBookMap.resolveBook(
                    books: bibleState.books,
                    currentTranslationId: bibleState.currentTranslation?.id ?? 2,
                    traditionalBookNumber: bookNum,
                    bookName: f['ref'] as String?,
                  );
                  if (targetBook != null) {
                    await ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: chapter);
                  }
                  onNavigateTab(0);
                },
                child: Container(
                  width: 268,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: themeConfig.cardBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(Icons.format_quote_rounded, color: color, size: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f['name'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.notoSansEthiopic(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: themeConfig.textColor,
                                  ),
                                ),
                                Text(
                                  '${f['en']} • ${f['era']}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: themeConfig.secondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          f['quote'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 12.5,
                            height: 1.45,
                            color: themeConfig.textColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              f['ref'] as String,
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          Text(
                            'ትርጓሜውን ክፈት →',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
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
            _buildSectionTitle('የንባብ ዕቅዶች', 'DEVOTIONAL PLANS', themeConfig),
            TextButton(
              onPressed: () => onNavigateTab(2),
              child: Text(
                'ሁሉንም እይ (10) →',
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
                              plan.category,
                              style: GoogleFonts.notoSansEthiopic(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${plan.totalDays} ቀናት',
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
                        plan.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansEthiopic(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansEthiopic(
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
  ) {
    final guides = [
      {
        'title': 'የተራራው ስብከት',
        'sub': 'ማቴዎስ ምዕራፍ 5–7',
        'bookNum': 40,
        'chapter': 5,
        'icon': Icons.wb_twilight_rounded,
        'color': const Color(0xFF4F46E5),
      },
      {
        'title': 'መጽናኛና ጥበቃ',
        'sub': 'መዝሙር 23 እና 91',
        'bookNum': 19,
        'chapter': 23,
        'icon': Icons.shield_outlined,
        'color': const Color(0xFF0D9488),
      },
      {
        'title': 'የጥበብ መጀመሪያ',
        'sub': 'መጽሐፈ ምሳሌ ምዕራፍ 1',
        'bookNum': 20,
        'chapter': 1,
        'icon': Icons.workspace_premium_outlined,
        'color': const Color(0xFF047857),
      },
      {
        'title': 'የፍቅር መዝሙር',
        'sub': '1 ቆሮንቶስ ምዕራፍ 13',
        'bookNum': 46,
        'chapter': 13,
        'icon': Icons.favorite_border_rounded,
        'color': const Color(0xFFE11D48),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('የተመረጡ የጥናት ርዕሶች', 'CURATED PASSAGES', themeConfig),
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
                            g['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: themeConfig.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            g['sub'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSansEthiopic(
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

  Widget _buildSectionTitle(String amharic, String english, ReaderThemeConfig themeConfig) {
    return Row(
      children: [
        Text(
          amharic,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: themeConfig.textColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '• $english',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: themeConfig.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  String _shortTransLabel(String name) {
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
              'የመጽሐፍ ቅዱስ ትርጉም ይምረጡ',
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: themeConfig.textColor,
              ),
            ),
            const SizedBox(height: 14),
            ...bibleState.translations.map((t) {
              final selected = t.id == bibleState.currentTranslation?.id;
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
                  title: Text(
                    t.name,
                    style: GoogleFonts.notoSansEthiopic(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: themeConfig.textColor,
                    ),
                  ),
                  subtitle: Text(
                    t.id == 2
                        ? 'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 መጻሕፍት ቀኖና'
                        : (t.id == 1
                            ? 'የቀዳማዊ ኃይለ ሥላሴ 1954 ትርጉም (66 መጻሕፍት)'
                            : 'Authorized King James Version (Classic English)'),
                    style: GoogleFonts.notoSansEthiopic(
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
