import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/patristic_commentaries.dart';
import '../../data/reading_plans_data.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import 'book_selector_screen.dart';
import 'verse_card_maker_screen.dart';

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

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF7D1A25).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('✝', style: TextStyle(color: Color(0xFF7D1A25), fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'መጽሐፍ ቅዱስ',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Catena • ${bibleState.currentTranslation?.name ?? "1954 Haile Selassie"}',
                  style: TextStyle(
                    fontSize: 11,
                    color: themeConfig.secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'ፈልግ (Search)',
            onPressed: () => onNavigateTab(2), // Switch to Search tab
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'ቀለምና ገጽታ (Themes)',
            onPressed: () => _showThemeDialog(context, ref),
          ),
        ],
      ),
      body: bibleState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(bibleStateProvider.notifier).init(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // 1. Hero: Daily Verse + Patristic Commentary Pairing
                  _buildDailyVerseAndCatenaHero(context, ref, repo, themeConfig),
                  const SizedBox(height: 18),

                  // 2. Continue Reading Card
                  _buildContinueReadingCard(context, ref, bibleState, themeConfig),
                  const SizedBox(height: 22),

                  // 3. Early Church Fathers Showcase (Catena Spotlight)
                  _buildPatristicFathersSpotlight(context, ref, themeConfig, isDark),
                  const SizedBox(height: 22),

                  // 4. Reading Plans Showcase (10 Liturgical Plans)
                  _buildReadingPlansShowcase(context, ref, themeConfig),
                  const SizedBox(height: 22),

                  // 5. Quick Jump Categories (Pentateuch, Gospels, Psalms, 81 Canon)
                  _buildCategoryQuickJumps(context, ref, themeConfig),
                  const SizedBox(height: 24),

                  // 6. Curated Thematic Study Guides
                  _buildThematicStudyGuides(context, ref, themeConfig),
                  const SizedBox(height: 28),
                ],
              ),
            ),
    );
  }

  Widget _buildDailyVerseAndCatenaHero(
    BuildContext context,
    WidgetRef ref,
    dynamic repo,
    ReaderThemeConfig themeConfig,
  ) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: repo.getDailyVerse(ref.watch(bibleStateProvider).currentTranslation?.id ?? 1),
      builder: (context, snapshot) {
        final verseData = snapshot.data;
        final reference = verseData != null
            ? '${verseData['book_name']} ${verseData['chapter']}:${verseData['verse']}'
            : 'የዮሐንስ ወንጌል 1:1';
        final verseText = verseData != null
            ? verseData['text'] as String
            : 'በመጀመሪያ ቃል ነበረ፥ ቃልም በእግዚአብሔር ዘንድ ነበረ፥ ቃልም እግዚአብሔር ነበረ።';

        final featuredCatena = PatristicCommentariesData.getFeaturedCommentary();

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF2C1417), Color(0xFF6B1720)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.wb_sunny_outlined, color: Color(0xFFFFD54F), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'የዕለቱ ቃልና የአበው ትምህርት',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.image, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text('ካርድ', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Scripture Verse
              Text(
                '“$verseText”',
                style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white.withValues(alpha: 0.98),
                  fontSize: 16.5,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reference,
                style: GoogleFonts.notoSansEthiopic(
                  color: const Color(0xFFFFD54F),
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // Accompanying Catena Church Father Excerpt
              if (featuredCatena != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('✝ ', style: TextStyle(color: Color(0xFFFFD54F), fontSize: 12)),
                          Expanded(
                            child: Text(
                              '${featuredCatena.authorName} (${featuredCatena.sourceWork})',
                              style: const TextStyle(
                                color: Color(0xFFFFE082),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '«${featuredCatena.content}»',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansEthiopic(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F),
                      foregroundColor: const Color(0xFF2C1417),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(0, 34),
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
                      onNavigateTab(1); // Jump to Reader tab
                    },
                    child: const Text('በሙሉ ምዕራፉ አንብብ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    WidgetRef ref,
    dynamic bibleState,
    ReaderThemeConfig themeConfig,
  ) {
    final book = bibleState.currentBook;
    final chapter = bibleState.currentChapter;

    return Card(
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFFC5A059).withValues(alpha: 0.25)),
      ),
      color: themeConfig.surfaceColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onNavigateTab(1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF7D1A25).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7D1A25).withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.auto_stories, color: Color(0xFF7D1A25), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'የቀጠለ ንባብ (Resume Reading)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: themeConfig.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book != null ? '${book.name} ምዕራፍ $chapter' : 'ኦሪት ዘፍጥረት ምዕራፍ 1',
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: themeConfig.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7D1A25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('ቀጥል', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatristicFathersSpotlight(
    BuildContext context,
    WidgetRef ref,
    ReaderThemeConfig themeConfig,
    bool isDark,
  ) {
    final fathers = [
      {
        'name': 'ቅዱስ ዮሐንስ አፈወርቅ',
        'sub': 'St. John Chrysostom • 4ኛው መ.ክ.ዘ',
        'desc': 'የቁስጥንጥንያ ሊቀ ጳጳስ፣ የወንጌላትና የመልእክታት ዝነኛ ተርጓሚ',
        'bookNum': 40,
        'chapter': 5,
      },
      {
        'name': 'ቅዱስ ባስልዮስ ዘቂሣርያ',
        'sub': 'St. Basil the Great • 330–379 ዓ.ም.',
        'desc': 'የቂሣርያ ሊቀ ጳጳስ፣ የስድስቱ ዕለታት የፍጥረት ምስጢር ተንታኝ',
        'bookNum': 1,
        'chapter': 1,
      },
      {
        'name': 'ቅዱስ ቄርሎስ ዘእስክንድርያ',
        'sub': 'St. Cyril of Alexandria • 376–444 ዓ.ም.',
        'desc': 'የእስክንድርያ ፓትርያርክ፣ የተዋሕዶ ሃይማኖት አምድ',
        'bookNum': 40,
        'chapter': 1,
      },
      {
        'name': 'ቅዱስ ኤፍሬም ሶርያዊ',
        'sub': 'St. Ephrem the Syrian • 306–373 ዓ.ም.',
        'desc': 'የቤተክርስቲያን በገና፣ የመንፈሳዊ ቅኔና የትርጓሜ አባት',
        'bookNum': 1,
        'chapter': 1,
      },
      {
        'name': 'ቅዱስ ቆጵሪያኖስ ዘካርቴጅ',
        'sub': 'St. Cyprian of Carthage • 210–258 ዓ.ም.',
        'desc': 'የካርቴጅ ሰማዕትና ኤጲስ ቆጶስ፣ ስለ ጸሎተ እግዚኦ ትርጓሜ',
        'bookNum': 40,
        'chapter': 6,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('✝ ', style: TextStyle(color: Color(0xFFC5A059), fontSize: 16)),
                Text(
                  'የቀደምት አበው ማህደር (Catena Fathers)',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: themeConfig.textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fathers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final f = fathers[idx];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  final bookNum = f['bookNum'] as int;
                  final chapter = f['chapter'] as int;
                  final bibleState = ref.read(bibleStateProvider);
                  final targetBook = bibleState.books.firstWhere(
                    (b) => b.bookNumber == bookNum,
                    orElse: () => bibleState.books.first,
                  );
                  await ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: chapter);
                  onNavigateTab(1); // Jump to Reader
                },
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFF7D1A25).withValues(alpha: 0.1),
                            child: const Text('✝', style: TextStyle(color: Color(0xFF7D1A25), fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f['name'] as String,
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF7D1A25),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f['sub'] as String,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: themeConfig.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f['desc'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 11,
                          height: 1.3,
                          color: isDark ? Colors.white70 : Colors.black87,
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

  Widget _buildReadingPlansShowcase(
    BuildContext context,
    WidgetRef ref,
    ReaderThemeConfig themeConfig,
  ) {
    final topPlans = ReadingPlansData.allPlans.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'የንባብ ዕቅዶች (Reading Plans)',
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: themeConfig.textColor,
              ),
            ),
            TextButton(
              onPressed: () => onNavigateTab(3), // Jump to Plans tab
              child: const Text('ሁሉንም እይ (10 ዕቅዶች)'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topPlans.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final p = topPlans[idx];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onNavigateTab(3),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7D1A25).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p.category,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7D1A25)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansEthiopic(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansEthiopic(fontSize: 11, color: themeConfig.secondaryTextColor, height: 1.3),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.badgeText, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF8A641A))),
                          const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF7D1A25)),
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

  Widget _buildCategoryQuickJumps(
    BuildContext context,
    WidgetRef ref,
    ReaderThemeConfig themeConfig,
  ) {
    final categories = [
      {'name': 'ወንጌላት\n(Gospels)', 'icon': Icons.favorite, 'bookNum': 40, 'color': const Color(0xFF7D1A25)},
      {'name': 'መዝሙር\n(Psalms)', 'icon': Icons.music_note, 'bookNum': 19, 'color': const Color(0xFF1976D2)},
      {'name': 'ኦሪት\n(Torah)', 'icon': Icons.menu_book, 'bookNum': 1, 'color': const Color(0xFF2E7D32)},
      {'name': 'ምሳሌ\n(Proverbs)', 'icon': Icons.lightbulb, 'bookNum': 20, 'color': const Color(0xFFE65100)},
      {'name': '81 መጻሕፍት\n(Orthodox)', 'icon': Icons.church, 'bookNum': 1, 'transId': 2, 'color': const Color(0xFF6A1B9A)},
      {'name': 'መጻሕፍት ዝርዝር\n(All Books)', 'icon': Icons.grid_view, 'isAll': true, 'color': const Color(0xFF455A64)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ፈጣን መዳረሻ (Sacred Canon Access)',
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: themeConfig.textColor,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 94,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, idx) {
              final cat = categories[idx];
              final color = cat['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    if (cat['isAll'] == true) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BookSelectorScreen()));
                    } else {
                      final bibleState = ref.read(bibleStateProvider);
                      final transId = cat['transId'] as int?;
                      if (transId != null) {
                        final t = bibleState.translations.firstWhere((x) => x.id == transId);
                        await ref.read(bibleStateProvider.notifier).selectTranslation(t);
                      }
                      final bookNum = cat['bookNum'] as int? ?? 1;
                      final targetBook = ref.read(bibleStateProvider).books.firstWhere(
                            (b) => b.bookNumber == bookNum,
                            orElse: () => ref.read(bibleStateProvider).books.first,
                          );
                      await ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: 1);
                      onNavigateTab(1); // Jump to Reader
                    }
                  },
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeConfig.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat['icon'] as IconData, color: color, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          cat['name'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThematicStudyGuides(
    BuildContext context,
    WidgetRef ref,
    ReaderThemeConfig themeConfig,
  ) {
    final guides = [
      {
        'title': 'የኢየሱስ ክርስቶስ ሕይወትና ተአምራት',
        'subtitle': 'ልደቱ፣ ጥምቀቱ፣ ተራራው ስብከትና ትንሣኤው',
        'bookNum': 40,
        'chapter': 5,
        'icon': Icons.stars,
      },
      {
        'title': 'የመጽናኛና የተስፋ ቃላት',
        'subtitle': 'መዝሙረ ዳዊት 23 & 91 — እግዚአብሔር እረኛዬ ነው',
        'bookNum': 19,
        'chapter': 23,
        'icon': Icons.spa,
      },
      {
        'title': 'የጥበብና የእውቀት መመሪያዎች',
        'subtitle': 'መጽሐፈ ምሳሌ — እግዚአብሔርን መፍራት የጥበብ መጀመሪያ ነው',
        'bookNum': 20,
        'chapter': 1,
        'icon': Icons.psychology,
      },
      {
        'title': 'የፍቅርና የጸጋ ትምህርት',
        'subtitle': '1 ቆሮንቶስ 13 — ፍቅር ለዘወትር አትወድቅም',
        'bookNum': 46,
        'chapter': 13,
        'icon': Icons.volunteer_activism,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'የጥናት መመሪያዎች (Sacred Themes & Guides)',
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: themeConfig.textColor,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: guides.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final g = guides[idx];
            return Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: themeConfig.surfaceColor,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF7D1A25).withValues(alpha: 0.12),
                  child: Icon(g['icon'] as IconData, color: const Color(0xFF7D1A25), size: 20),
                ),
                title: Text(
                  g['title'] as String,
                  style: GoogleFonts.notoSansEthiopic(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  g['subtitle'] as String,
                  style: GoogleFonts.notoSansEthiopic(fontSize: 12, color: themeConfig.secondaryTextColor),
                ),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () async {
                  final bookNum = g['bookNum'] as int;
                  final chapter = g['chapter'] as int;
                  final targetBook = ref.read(bibleStateProvider).books.firstWhere(
                        (b) => b.bookNumber == bookNum,
                        orElse: () => ref.read(bibleStateProvider).books.first,
                      );
                  await ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: chapter);
                  onNavigateTab(1); // Jump to Reader
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.read(themeConfigProvider);
    final themeNotifier = ref.read(themeConfigProvider.notifier);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('የንባብ ገጽታ (Theme)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny, color: Colors.orange),
              title: const Text('ቀን (Light Parchment)'),
              trailing: themeConfig.mode == ReaderThemeMode.light ? const Icon(Icons.check) : null,
              onTap: () {
                themeNotifier.setMode(ReaderThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Color(0xFF7D1A25)),
              title: const Text('ብራና (Monastery Sepia)'),
              trailing: themeConfig.mode == ReaderThemeMode.sepia ? const Icon(Icons.check) : null,
              onTap: () {
                themeNotifier.setMode(ReaderThemeMode.sepia);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round, color: Colors.indigo),
              title: const Text('ጽልመት (Obsidian Dark)'),
              trailing: themeConfig.mode == ReaderThemeMode.dark ? const Icon(Icons.check) : null,
              onTap: () {
                themeNotifier.setMode(ReaderThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
