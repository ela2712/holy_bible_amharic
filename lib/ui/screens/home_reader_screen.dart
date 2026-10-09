import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geez_numbers.dart';
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
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookSelectorScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleText,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeConfig.textColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: themeConfig.accentColor),
              ],
            ),
          ),
        ),
        actions: [
          // Audio Narration Trigger
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
          // More Menu
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
          // Translation badge row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: themeConfig.surfaceColor.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bibleState.currentTranslation?.name ?? '1954 Haile Selassie',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: themeConfig.secondaryTextColor,
                  ),
                ),
                Text(
                  'ምዕራፍ $chapterLabel / ${currentBook?.totalChapters ?? 1}',
                  style: TextStyle(
                    fontSize: 12,
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
                              // Chapter navigation footer
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
                                  const SizedBox(height: 16),
                                  Text(heading.title, style: themeConfig.getHeadingStyle()),
                                  const SizedBox(height: 8),
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
        highlightBg = Color(int.parse(verse.highlightColor!.replaceFirst('#', '0xFF'))).withOpacity(0.5);
      } catch (_) {}
    }

    final verseNumberLabel = themeConfig.useGeezNumerals
        ? GeezNumbers.toGeez(verse.verse)
        : '${verse.verse}';

    return InkWell(
      borderRadius: BorderRadius.circular(6),
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
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: highlightBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: RichText(
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
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(Icons.bookmark, size: 14, color: themeConfig.accentColor),
                  ),
                ),
              if (verse.note != null && verse.note!.isNotEmpty)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(Icons.note_alt, size: 14, color: Colors.blueAccent),
                  ),
                ),
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
            onPressed: () {
              ref.read(bibleStateProvider.notifier).prevChapter();
              _scrollToTop();
            },
            icon: const Icon(Icons.chevron_left),
            label: const Text('ቀዳሚ ምዕራፍ (Prev)'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(bibleStateProvider.notifier).nextChapter();
              _scrollToTop();
            },
            icon: const Icon(Icons.chevron_right),
            label: const Text('ቀጣይ ምዕራፍ (Next)'),
          ),
        ],
      ),
    );
  }
}
