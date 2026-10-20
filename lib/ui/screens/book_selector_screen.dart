import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/geez_numbers.dart';
import '../../models/book.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';

class BookSelectorScreen extends ConsumerStatefulWidget {
  final ValueChanged<int>? onVerseSelected;
  final int initialStep;

  const BookSelectorScreen({
    super.key,
    this.onVerseSelected,
    this.initialStep = 0,
  });

  static Future<void> show(
    BuildContext context, {
    ValueChanged<int>? onVerseSelected,
    int initialStep = 0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.90,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BookSelectorScreen(
            onVerseSelected: onVerseSelected,
            initialStep: initialStep,
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<BookSelectorScreen> createState() => _BookSelectorScreenState();
}

class _BookSelectorScreenState extends ConsumerState<BookSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';
  String _testamentFilter = 'ALL'; // 'ALL', 'OT', 'NT'
  bool _isGridView = true; // Compact abbreviation grid by default

  // 3-Step State: 0 = Book, 1 = Chapter, 2 = Verse
  int _currentStep = 0;
  Book? _selectedBook;
  int _selectedChapter = 1;
  int _verseCountForChapter = 30;
  bool _loadingVerseCount = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    final bibleState = ref.read(bibleStateProvider);
    if (bibleState.currentBook != null) {
      _selectedBook = bibleState.currentBook;
      _selectedChapter = bibleState.currentChapter;
    } else {
      _currentStep = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentBibleState = ref.read(bibleStateProvider);
        if (currentBibleState.currentBook != null && _selectedBook == null) {
          setState(() {
            _selectedBook = currentBibleState.currentBook;
            _selectedChapter = currentBibleState.currentChapter;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getCanonicalGroupStyle(Book book) {
    final n = book.bookNumber;
    if (book.isNewTestament) {
      if (n >= 40 && n <= 43) {
        return {'label': 'ወንጌላት (Gospels)', 'color': const Color(0xFF047857)};
      }
      if (n == 44) {
        return {'label': 'ታሪክ (Acts)', 'color': const Color(0xFF0D9488)};
      }
      if (n >= 45 && n <= 65) {
        return {'label': 'መልእክታት (Epistles)', 'color': const Color(0xFF0284C7)};
      }
      if (n == 66) {
        return {'label': 'ራእይ (Prophecy)', 'color': const Color(0xFF7C3AED)};
      }
      return {'label': 'ቀኖና 81 (Canon)', 'color': const Color(0xFFE11D48)};
    } else {
      if (n >= 1 && n <= 5) {
        return {'label': 'ኦሪት (Pentateuch)', 'color': const Color(0xFF0F766E)};
      }
      if (n >= 6 && n <= 17) {
        return {'label': 'ታሪክ (History)', 'color': const Color(0xFF0D9488)};
      }
      if (n >= 18 && n <= 22) {
        return {'label': 'ጥበብና መዝሙር (Wisdom)', 'color': const Color(0xFF059669)};
      }
      if (n >= 23 && n <= 39) {
        return {'label': 'ነቢያት (Prophets)', 'color': const Color(0xFF4F46E5)};
      }
      return {'label': 'ቀኖና 81 (Deuterocanon)', 'color': const Color(0xFFE11D48)};
    }
  }

  String _getBookAbbreviation(Book book) {
    if (book.shortName.trim().isNotEmpty) {
      return book.shortName.trim();
    }
    final cleaned = book.name
        .replaceAll('ኦሪት ', '')
        .replaceAll('መጽሐፈ ', '')
        .replaceAll('ትንቢተ ', '')
        .replaceAll('የ', '')
        .replaceAll('ወደ ', '')
        .trim();
    if (cleaned.length >= 2) {
      return cleaned.substring(0, 2);
    }
    return cleaned;
  }

  Future<void> _onBookTapped(Book book) async {
    setState(() {
      _selectedBook = book;
      _selectedChapter = 1;
      _currentStep = 1;
    });
  }

  Future<void> _onChapterTapped(int chapter, {bool jumpImmediately = false}) async {
    final book = _selectedBook;
    if (book == null) return;

    if (jumpImmediately) {
      await ref.read(bibleStateProvider.notifier).selectBook(book, chapter: chapter);
      widget.onVerseSelected?.call(1);
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      _selectedChapter = chapter;
      _currentStep = 2;
      _loadingVerseCount = true;
    });

    final repo = ref.read(bibleRepositoryProvider);
    final verses = await repo.getVerses(bookId: book.id, chapter: chapter);
    if (mounted) {
      int maxVerse = 0;
      for (final v in verses) {
        final end = v.verseEnd ?? v.verse;
        if (end > maxVerse) maxVerse = end;
      }
      setState(() {
        _verseCountForChapter = maxVerse > 0 ? maxVerse : (verses.isNotEmpty ? verses.length : 30);
        _loadingVerseCount = false;
      });
    }
  }

  Future<void> _onVerseTapped(int verseNum) async {
    final book = _selectedBook;
    if (book == null) return;

    await ref.read(bibleStateProvider.notifier).selectBook(book, chapter: _selectedChapter);
    widget.onVerseSelected?.call(verseNum);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bibleState = ref.watch(bibleStateProvider);
    final themeConfig = ref.watch(themeConfigProvider);

    final filteredBooks = bibleState.books.where((b) {
      if (_testamentFilter == 'OT' && !b.isOldTestament) return false;
      if (_testamentFilter == 'NT' && !b.isNewTestament) return false;
      if (_filter.isEmpty) return true;
      final q = _filter.toLowerCase();
      return b.name.toLowerCase().contains(q) ||
          b.nameEn.toLowerCase().contains(q) ||
          b.shortName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Drag Handle & Header
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeConfig.cardBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCRIPTURE NAVIGATOR',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                            color: themeConfig.accentColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'መጽሐፍ፣ ምዕራፍና ቁጥር መምረጫ',
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: themeConfig.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_currentStep == 0)
                    IconButton(
                      icon: Icon(
                        _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                        color: themeConfig.textColor,
                        size: 21,
                      ),
                      tooltip: _isGridView ? 'ዝርዝር እይታ (List View)' : 'ሰንጠረዥ እይታ (Grid View)',
                      onPressed: () => setState(() => _isGridView = !_isGridView),
                    ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: themeConfig.secondaryTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 2. 3-Step Segmented Breadcrumb Bar (Book -> Chapter -> Verse)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: themeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: themeConfig.cardBorderColor),
                ),
                child: Row(
                  children: [
                    _buildStepTab(
                      stepIndex: 0,
                      label: _selectedBook != null ? '፩. ${_selectedBook!.name}' : '፩. መጽሐፍ (Book)',
                      isEnabled: true,
                      themeConfig: themeConfig,
                    ),
                    _buildStepTab(
                      stepIndex: 1,
                      label: '፪. ምዕራፍ $_selectedChapter',
                      isEnabled: _selectedBook != null,
                      themeConfig: themeConfig,
                    ),
                    _buildStepTab(
                      stepIndex: 2,
                      label: '፫. ቁጥር (Verse)',
                      isEnabled: _selectedBook != null,
                      themeConfig: themeConfig,
                    ),
                  ],
                ),
              ),
            ),

            // 3. Step Content
            Expanded(
              child: _currentStep == 0
                  ? _buildStep0BookSelection(filteredBooks, bibleState, themeConfig)
                  : _currentStep == 1
                      ? _buildStep1ChapterSelection(themeConfig, bibleState)
                      : _buildStep2VerseSelection(themeConfig),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTab({
    required int stepIndex,
    required String label,
    required bool isEnabled,
    required ReaderThemeConfig themeConfig,
  }) {
    final isSelected = _currentStep == stepIndex;
    return Expanded(
      child: GestureDetector(
        onTap: isEnabled ? () => setState(() => _currentStep = stepIndex) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? themeConfig.accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : isEnabled
                      ? themeConfig.textColor
                      : themeConfig.secondaryTextColor.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep0BookSelection(
    List<Book> books,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
  ) {
    return Column(
      children: [
        // Search + Testament Filter Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeConfig.cardBorderColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.notoSansEthiopic(fontSize: 13.5, color: themeConfig.textColor),
                    decoration: InputDecoration(
                      hintText: 'መጽሐፍ ፈልግ (Search book)...',
                      hintStyle: TextStyle(fontSize: 12.5, color: themeConfig.secondaryTextColor),
                      prefixIcon: Icon(Icons.search_rounded, size: 18, color: themeConfig.accentColor),
                      suffixIcon: _filter.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _filter = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => setState(() => _filter = val),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildTestamentChip('ሁሉም', 'ALL', themeConfig),
              const SizedBox(width: 4),
              _buildTestamentChip('ብሉይ', 'OT', themeConfig),
              const SizedBox(width: 4),
              _buildTestamentChip('ሐዲስ', 'NT', themeConfig),
            ],
          ),
        ),

        Expanded(
          child: books.isEmpty
              ? Center(
                  child: Text(
                    'ምንም መጽሐፍ አልተገኘም',
                    style: GoogleFonts.notoSansEthiopic(color: themeConfig.secondaryTextColor),
                  ),
                )
              : _isGridView
                  ? _buildAbbreviationGrid(books, bibleState, themeConfig)
                  : _buildDetailedList(books, bibleState, themeConfig),
        ),
      ],
    );
  }

  Widget _buildTestamentChip(String label, String value, ReaderThemeConfig themeConfig) {
    final isSelected = _testamentFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _testamentFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? themeConfig.textColor : themeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? themeConfig.textColor : themeConfig.cardBorderColor,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? themeConfig.backgroundColor : themeConfig.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAbbreviationGrid(
    List<Book> books,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isCurrent = bibleState.currentBook?.id == book.id;
        final style = _getCanonicalGroupStyle(book);
        final catColor = style['color'] as Color;
        final abbr = _getBookAbbreviation(book);

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onBookTapped(book),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? catColor.withValues(alpha: 0.14)
                  : themeConfig.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent ? catColor : themeConfig.cardBorderColor,
                width: isCurrent ? 1.8 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    abbr,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: catColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book.name.replaceAll('መጽሐፈ ', '').replaceAll('ኦሪት ', '').replaceAll('ትንቢተ ', ''),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: themeConfig.textColor,
                  ),
                ),
                Text(
                  '${book.totalChapters} ምዕራፍ',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: themeConfig.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailedList(
    List<Book> books,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final book = books[index];
        final isCurrent = bibleState.currentBook?.id == book.id;
        final style = _getCanonicalGroupStyle(book);
        final catColor = style['color'] as Color;
        final catLabel = style['label'] as String;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _onBookTapped(book),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: themeConfig.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrent ? catColor : themeConfig.cardBorderColor,
                width: isCurrent ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getBookAbbreviation(book),
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: catColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: themeConfig.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              catLabel,
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: catColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${book.totalChapters} ምዕራፎች',
                            style: TextStyle(fontSize: 11.5, color: themeConfig.secondaryTextColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: themeConfig.secondaryTextColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep1ChapterSelection(
    ReaderThemeConfig themeConfig,
    BibleViewState bibleState,
  ) {
    final book = _selectedBook;
    if (book == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${book.name} — ምዕራፍ ይምረጡ',
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.textColor,
                ),
              ),
              Text(
                '${book.totalChapters} ምዕራፎች',
                style: TextStyle(fontSize: 12, color: themeConfig.secondaryTextColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemCount: book.totalChapters,
            itemBuilder: (context, index) {
              final ch = index + 1;
              final isCurrent =
                  bibleState.currentBook?.id == book.id && bibleState.currentChapter == ch;
              final label = themeConfig.useGeezNumerals ? GeezNumbers.toGeez(ch) : '$ch';

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _onChapterTapped(ch),
                onLongPress: () => _onChapterTapped(ch, jumpImmediately: true),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent ? themeConfig.accentColor : themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent ? themeConfig.accentColor : themeConfig.cardBorderColor,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isCurrent ? Colors.white : themeConfig.textColor,
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

  Widget _buildStep2VerseSelection(ReaderThemeConfig themeConfig) {
    final book = _selectedBook;
    if (book == null) return const SizedBox.shrink();

    if (_loadingVerseCount) {
      return Center(child: CircularProgressIndicator(color: themeConfig.accentColor));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick button to open chapter at Verse 1 immediately
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeConfig.accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _onVerseTapped(1),
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: Text(
              '${book.name} ምዕራፍ $_selectedChapterን ከመጀመሪያው ክፈት',
              style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            'ወይም ወደ ተለየ ቁጥር (Verse) በቀጥታ ይዝለሉ፦',
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: themeConfig.secondaryTextColor,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemCount: _verseCountForChapter,
            itemBuilder: (context, index) {
              final v = index + 1;
              final label = themeConfig.useGeezNumerals ? GeezNumbers.toGeez(v) : '$v';

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _onVerseTapped(v),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeConfig.cardBorderColor),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: themeConfig.textColor,
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
}
