import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geez_numbers.dart';
import '../../data/patristic_commentaries.dart';
import '../../models/verse.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import '../../services/audio_player_service.dart';
import '../widgets/audio_player_bar.dart';
import 'book_selector_screen.dart';
import 'search_screen.dart';
import 'parallel_reader_screen.dart';
import 'annotations_screen.dart';
import 'reading_plans_screen.dart';
import 'settings_screen.dart';
import 'study_tools_dialog.dart';

class HomeReaderScreen extends ConsumerStatefulWidget {
  const HomeReaderScreen({super.key});

  @override
  ConsumerState<HomeReaderScreen> createState() => _HomeReaderScreenState();
}

class _HomeReaderScreenState extends ConsumerState<HomeReaderScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bibleState = ref.watch(bibleStateProvider);
    final themeConfig = ref.watch(themeConfigProvider);
    final currentBook = bibleState.currentBook;
    final currentChapter = bibleState.currentChapter;

    final chapterLabel = themeConfig.useGeezNumerals
        ? GeezNumbers.toGeez(currentChapter)
        : '$currentChapter';

    final titleText = currentBook != null
        ? '${currentBook.name} $chapterLabel'
        : 'መጽሐፍ ቅዱስ';

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeConfig.surfaceColor,
        elevation: 0.5,
        title: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookSelectorScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: themeConfig.accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: themeConfig.accentColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleText,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: themeConfig.textColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: themeConfig.accentColor, size: 22),
              ],
            ),
          ),
        ),
        actions: [
          // Quick Translation Switcher Pill
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showTranslationPicker(context, ref),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFC5A059).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _shortTranslationName(bibleState.currentTranslation?.name ?? '1954'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7D1A25),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF7D1A25)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Audio Narration
          IconButton(
            icon: const Icon(Icons.headphones_outlined),
            tooltip: 'ድምፅ አጫውት (Listen Audio)',
            onPressed: () {
              if (currentBook != null) {
                ref.read(audioPlayerServiceProvider.notifier).playChapterAudio(
                      bookNumber: currentBook.bookNumber,
                      chapter: currentChapter,
                      bookName: currentBook.name,
                    );
              }
            },
          ),

          // Typography & Appearance (Aa)
          IconButton(
            icon: const Icon(Icons.format_size),
            tooltip: 'የጽሑፍ መጠንና ገጽታ (Typography & Theme)',
            onPressed: () => _showTypographySheet(context, ref),
          ),

          // Search
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'ፈልግ (Search)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),

          // Overflow Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              switch (val) {
                case 'parallel':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ParallelReaderScreen()));
                  break;
                case 'annotations':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnotationsScreen()));
                  break;
                case 'plans':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingPlansScreen()));
                  break;
                case 'settings':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'parallel',
                child: Row(
                  children: [
                    Icon(Icons.compare_arrows, size: 20),
                    SizedBox(width: 10),
                    Text('ማነፃፀሪያ (Parallel Bible)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'annotations',
                child: Row(
                  children: [
                    Icon(Icons.bookmarks_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('የእኔ ማስታወሻዎች (Annotations)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'plans',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('የንባብ ዕቅዶች (Reading Plans)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('ማስተካከያዎች (Settings)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Sub-header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            color: themeConfig.surfaceColor.withValues(alpha: 0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC5A059),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bibleState.currentTranslation?.name ?? '1954 Haile Selassie',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: themeConfig.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ምዕራፍ $chapterLabel / ${currentBook?.totalChapters ?? 1}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: themeConfig.accentColor,
                  ),
                ),
              ],
            ),
          ),

          // Main Reading Area
          Expanded(
            child: bibleState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : bibleState.verses.isEmpty
                    ? const Center(child: Text('ምንም ጥቅሶች አልተገኙም (No verses)'))
                    : GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity != null) {
                            if (details.primaryVelocity! < -200) {
                              ref.read(bibleStateProvider.notifier).nextChapter();
                              _scrollToTop();
                            } else if (details.primaryVelocity! > 200) {
                              ref.read(bibleStateProvider.notifier).prevChapter();
                              _scrollToTop();
                            }
                          }
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          itemCount: bibleState.verses.length + 1,
                          itemBuilder: (context, index) {
                            if (index == bibleState.verses.length) {
                              return _buildChapterNavigationFooter(ref);
                            }

                            final verse = bibleState.verses[index];
                            final heading = bibleState.headings.firstWhere(
                              (h) => h.verse == verse.verse,
                              orElse: () => const SectionHeading(id: -1, bookId: -1, chapter: -1, verse: -1, title: ''),
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (heading.title.isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Color(0xFFC5A059), width: 1)),
                                    ),
                                    child: Text(heading.title, style: themeConfig.getHeadingStyle()),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                _buildVerseRow(context, ref, verse, currentBook!, themeConfig),
                              ],
                            );
                          },
                        ),
                      ),
          ),

          // Persistent Floating Audio Player
          const AudioPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildVerseRow(
    BuildContext context,
    WidgetRef ref,
    Verse verse,
    dynamic currentBook,
    ReaderThemeConfig themeConfig,
  ) {
    Color? highlightBg;
    if (verse.highlightColor != null) {
      try {
        highlightBg = Color(int.parse(verse.highlightColor!.replaceFirst('#', '0xFF'))).withValues(alpha: 0.35);
      } catch (_) {}
    }

    final verseNumberLabel = themeConfig.useGeezNumerals
        ? GeezNumbers.toGeez(verse.verse)
        : '${verse.verse}';

    final commentaries = PatristicCommentariesData.getCommentariesForVerse(
      currentBook.bookNumber,
      verse.chapter,
      verse.verse,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: highlightBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          StudyToolsSheet.show(
            context,
            verse: verse,
            bookName: currentBook.name,
            bookNumber: currentBook.bookNumber,
            repository: ref.read(bibleRepositoryProvider),
            onVerseUpdated: () {
              ref.read(bibleStateProvider.notifier).refreshVerses();
            },
            initialTabIndex: commentaries.isNotEmpty ? 0 : 1,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$verseNumberLabel ',
                      style: themeConfig.getVerseNumberStyle(),
                    ),
                    TextSpan(
                      text: verse.text,
                      style: themeConfig.getVerseStyle(),
                    ),
                    if (verse.isBookmarked)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Icon(Icons.bookmark, size: 14, color: themeConfig.accentColor),
                        ),
                      ),
                    if (verse.note != null && verse.note!.isNotEmpty)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: Icon(Icons.note_alt, size: 14, color: Colors.blueAccent),
                        ),
                      ),
                  ],
                ),
              ),

              // Catena Church Father Commentary Badge
              if (commentaries.isNotEmpty) ...[
                const SizedBox(height: 5),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    StudyToolsSheet.show(
                      context,
                      verse: verse,
                      bookName: currentBook.name,
                      bookNumber: currentBook.bookNumber,
                      repository: ref.read(bibleRepositoryProvider),
                      onVerseUpdated: () {
                        ref.read(bibleStateProvider.notifier).refreshVerses();
                      },
                      initialTabIndex: 0, // Direct to Commentary tab
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFC5A059).withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '✝ ',
                          style: TextStyle(
                            color: Color(0xFF7D1A25),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'የአበው ትርጓሜ (${commentaries.length}) — ${commentaries.first.authorName.split('(')[0].trim()}',
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7D1A25),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 9, color: Color(0xFF7D1A25)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterNavigationFooter(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ref.read(bibleStateProvider.notifier).prevChapter();
              _scrollToTop();
            },
            icon: const Icon(Icons.chevron_left),
            label: const Text('ቀዳሚ ምዕራፍ'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ref.read(bibleStateProvider.notifier).nextChapter();
              _scrollToTop();
            },
            icon: const Icon(Icons.chevron_right),
            label: const Text('ቀጣይ ምዕራፍ'),
          ),
        ],
      ),
    );
  }

  String _shortTranslationName(String fullName) {
    if (fullName.contains('81')) return '81 ካኖን';
    if (fullName.contains('King James') || fullName.contains('KJV')) return 'KJV';
    return '1954';
  }

  void _showTranslationPicker(BuildContext context, WidgetRef ref) {
    final bibleState = ref.read(bibleStateProvider);
    final notifier = ref.read(bibleStateProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ትርጉም ምረጥ (Select Translation)',
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7D1A25),
              ),
            ),
            const SizedBox(height: 12),
            ...bibleState.translations.map((t) {
              final isSelected = t.id == bibleState.currentTranslation?.id;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF7D1A25) : Colors.black12,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? const Color(0xFF7D1A25) : Colors.black12,
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                    child: Text('${t.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(
                    t.name,
                    style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${t.canon} • ${t.language}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                  ),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF7D1A25)) : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await notifier.selectTranslation(t);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showTypographySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final themeConfig = ref.watch(themeConfigProvider);
          final notifier = ref.read(themeConfigProvider.notifier);
          final isDark = themeConfig.mode == ReaderThemeMode.dark;

          return Container(
            decoration: BoxDecoration(
              color: themeConfig.surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'የንባብ ገጽታና ፊደል (Typography & Theme)',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeConfig.accentColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Theme Mode Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildThemeOptionCard(
                        title: 'ቀን (Light)',
                        mode: ReaderThemeMode.light,
                        currentMode: themeConfig.mode,
                        bgColor: const Color(0xFFFAF8F5),
                        textColor: const Color(0xFF221A16),
                        onTap: () => notifier.setMode(ReaderThemeMode.light),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOptionCard(
                        title: 'ብራና (Sepia)',
                        mode: ReaderThemeMode.sepia,
                        currentMode: themeConfig.mode,
                        bgColor: const Color(0xFFF3EBDB),
                        textColor: const Color(0xFF382B1B),
                        onTap: () => notifier.setMode(ReaderThemeMode.sepia),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOptionCard(
                        title: 'ጽልመት (Dark)',
                        mode: ReaderThemeMode.dark,
                        currentMode: themeConfig.mode,
                        bgColor: const Color(0xFF131313),
                        textColor: const Color(0xFFE6E2DE),
                        onTap: () => notifier.setMode(ReaderThemeMode.dark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Font Size Slider
                Row(
                  children: [
                    const Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: themeConfig.fontSize,
                        min: 14,
                        max: 30,
                        divisions: 16,
                        activeColor: themeConfig.accentColor,
                        label: '${themeConfig.fontSize.toInt()}',
                        onChanged: (val) => notifier.setFontSize(val),
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),

                // Ge'ez numbers switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'የግዕዝ ቁጥሮች (፩ ፪ ፫...)',
                    style: GoogleFonts.notoSansEthiopic(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('የምዕራፍና የቁጥር አመልካቾችን በግዕዝ አሳይ', style: TextStyle(fontSize: 12)),
                  value: themeConfig.useGeezNumerals,
                  activeThumbColor: themeConfig.accentColor,
                  onChanged: (val) => notifier.toggleGeezNumerals(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required String title,
    required ReaderThemeMode mode,
    required ReaderThemeMode currentMode,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF7D1A25) : Colors.black26,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
