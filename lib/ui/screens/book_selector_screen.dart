import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/canonical_book_map.dart';
import '../../core/utils/geez_numbers.dart';
import '../../models/book.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import '../../providers/reading_progress_provider.dart';

class CanonicalSectionInfo {
  final String key;
  final String title;
  final String titleEn;
  final IconData icon;
  final Color color;

  const CanonicalSectionInfo({
    required this.key,
    required this.title,
    required this.titleEn,
    required this.icon,
    required this.color,
  });
}

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
  String _testamentFilter = 'OT'; // 'OT' or 'NT'

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
      _testamentFilter = bibleState.currentBook!.isNewTestament ? 'NT' : 'OT';
    } else {
      _currentStep = 0;
      _testamentFilter = 'OT';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentBibleState = ref.read(bibleStateProvider);
        if (currentBibleState.currentBook != null && _selectedBook == null) {
          setState(() {
            _selectedBook = currentBibleState.currentBook;
            _selectedChapter = currentBibleState.currentChapter;
            _testamentFilter = currentBibleState.currentBook!.isNewTestament ? 'NT' : 'OT';
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

  CanonicalSectionInfo _getCanonicalSection(Book book, int translationId) {
    final canon = CanonicalBookMap.getCanonicalId(translationId, book.bookNumber);

    // New Testament
    if (['MAT', 'MRK', 'LUK', 'JHN'].contains(canon)) {
      return const CanonicalSectionInfo(
        key: 'NT_GOSPELS',
        title: 'አራቱ ወንጌላት',
        titleEn: 'The Four Gospels',
        icon: Icons.auto_stories_rounded,
        color: Color(0xFF047857), // Emerald
      );
    }
    if (canon == 'ACT') {
      return const CanonicalSectionInfo(
        key: 'NT_ACTS',
        title: 'የሐዋርያት ታሪክ',
        titleEn: 'Apostolic History',
        icon: Icons.history_edu_rounded,
        color: Color(0xFF0D9488), // Teal
      );
    }
    if (['ROM', '1CO', '2CO', 'GAL', 'EPH', 'PHP', 'COL', '1TH', '2TH', '1TI', '2TI', 'TIT', 'PHM', 'HEB'].contains(canon)) {
      return const CanonicalSectionInfo(
        key: 'NT_PAUL',
        title: 'የጳውሎስ መልእክታት',
        titleEn: 'Pauline Epistles',
        icon: Icons.mark_email_read_outlined,
        color: Color(0xFF0284C7), // Sky Blue
      );
    }
    if (['1PE', '2PE', '1JN', '2JN', '3JN', 'JAS', 'JUD'].contains(canon)) {
      return const CanonicalSectionInfo(
        key: 'NT_GENERAL',
        title: 'የሐዋርያት መልእክታት',
        titleEn: 'General Epistles',
        icon: Icons.mail_outline_rounded,
        color: Color(0xFF4F46E5), // Indigo
      );
    }
    if (canon == 'REV') {
      return const CanonicalSectionInfo(
        key: 'NT_REV',
        title: 'የዮሐንስ ራእይ',
        titleEn: 'Revelation (Prophecy)',
        icon: Icons.visibility_outlined,
        color: Color(0xFF7C3AED), // Purple
      );
    }

    // Old Testament
    if (['GEN', 'EXO', 'LEV', 'NUM', 'DEU'].contains(canon)) {
      return const CanonicalSectionInfo(
        key: 'OT_LAW',
        title: 'ኦሪት (የሕግ መጻሕፍት)',
        titleEn: 'The Law (Pentateuch)',
        icon: Icons.menu_book_rounded,
        color: Color(0xFF0F766E), // Deep Teal
      );
    }
    if (['JOS', 'JDG', 'RUT', '1SA', '2SA', '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH', 'EST'].contains(canon)) {
      return const CanonicalSectionInfo(
        key: 'OT_HISTORY',
        title: 'የታሪክ መጻሕፍት',
        titleEn: 'Historical Books',
        icon: Icons.account_balance_rounded,
        color: Color(0xFF0D9488), // Teal
      );
    }
    if (['JUB', 'ENO', 'EZ3', 'EZ4', 'TOB', 'JDT', 'MQ1', 'MQ2', 'MQ3', 'BAR', 'TER', 'TBR'].contains(canon)) {
      return const CanonicalSectionInfo(
        key: 'OT_DEUTERO',
        title: 'ተጨማሪ የቀኖና 81 መጻሕፍት',
        titleEn: 'Deuterocanonical Books',
        icon: Icons.verified_outlined,
        color: Color(0xFFB45309), // Amber / Bronze
      );
    }
    if (['JOB', 'PSA', 'PRO', 'TEG', 'WIS', 'ECC', 'SNG', 'SIR'].contains(canon)) {
      return const CanonicalSectionInfo(
        key: 'OT_WISDOM',
        title: 'ጥበብና ቅኔ (መዝሙራት)',
        titleEn: 'Wisdom & Poetry (Psalms)',
        icon: Icons.psychology_alt_outlined,
        color: Color(0xFF059669), // Forest Green
      );
    }
    if (['ISA', 'JER', 'LAM', 'EZK', 'DAN', 'HOS', 'AMO', 'MIC', 'JOL', 'OBA', 'JON', 'NAH', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL'].contains(canon)) {
      return const CanonicalSectionInfo(
        key: 'OT_PROPHETS',
        title: 'ትንቢት (ነቢያት)',
        titleEn: 'Prophets',
        icon: Icons.campaign_outlined,
        color: Color(0xFF4F46E5), // Indigo
      );
    }

    return CanonicalSectionInfo(
      key: book.isNewTestament ? 'NT_OTHER' : 'OT_OTHER',
      title: book.isNewTestament ? 'ሐዲስ ኪዳን' : 'ብሉይ ኪዳን',
      titleEn: book.isNewTestament ? 'New Testament' : 'Old Testament',
      icon: Icons.book_rounded,
      color: const Color(0xFF6B7280),
    );
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
    final themeConfig = ref.watch(themeConfigProvider);
    final bibleState = ref.watch(bibleStateProvider);
    final isEnglish = ref.watch(isEnglishUiProvider);
    final isDark = themeConfig.isDark;

    final step0BookName = _selectedBook != null
        ? (isEnglish && _selectedBook!.nameEn.isNotEmpty
            ? _selectedBook!.nameEn
            : _selectedBook!.name)
        : null;

    final step0Label = step0BookName != null
        ? (isEnglish ? '1. $step0BookName' : '፩. $step0BookName')
        : (isEnglish ? '1. Book' : '፩. መጽሐፍ');

    final step1Label = isEnglish
        ? '2. Chapter $_selectedChapter'
        : '፪. ምዕራፍ $_selectedChapter';

    final step2Label = isEnglish ? '3. Verse' : '፫. ቁጥር';

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
                          isEnglish ? 'SCRIPTURE NAVIGATOR' : 'የቅዱሳት መጻሕፍት ማውጫ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                            color: themeConfig.accentColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEnglish ? 'Select Book, Chapter & Verse' : 'መጽሐፍ፣ ምዕራፍና ቁጥር መምረጫ',
                          style: isEnglish
                              ? GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: themeConfig.textColor,
                                )
                              : GoogleFonts.notoSansEthiopic(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: themeConfig.textColor,
                                ),
                        ),
                      ],
                    ),
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
                      label: step0Label,
                      isEnabled: true,
                      themeConfig: themeConfig,
                      isEnglish: isEnglish,
                    ),
                    _buildStepTab(
                      stepIndex: 1,
                      label: step1Label,
                      isEnabled: _selectedBook != null,
                      themeConfig: themeConfig,
                      isEnglish: isEnglish,
                    ),
                    _buildStepTab(
                      stepIndex: 2,
                      label: step2Label,
                      isEnabled: _selectedBook != null,
                      themeConfig: themeConfig,
                      isEnglish: isEnglish,
                    ),
                  ],
                ),
              ),
            ),

            // 3. Step Content
            Expanded(
              child: _currentStep == 0
                  ? _buildStep0BookSelection(bibleState, themeConfig, isEnglish, isDark)
                  : _currentStep == 1
                      ? _buildStep1ChapterSelection(themeConfig, bibleState, isEnglish)
                      : _buildStep2VerseSelection(themeConfig, isEnglish),
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
    required bool isEnglish,
  }) {
    final isSelected = _currentStep == stepIndex;
    return Expanded(
      child: GestureDetector(
        onTap: isEnabled ? () => setState(() => _currentStep = stepIndex) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? themeConfig.accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isEnglish
                ? GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : isEnabled
                            ? themeConfig.textColor
                            : themeConfig.secondaryTextColor.withValues(alpha: 0.4),
                  )
                : GoogleFonts.notoSansEthiopic(
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
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    bool isEnglish,
    bool isDark,
  ) {
    final allBooks = bibleState.books;
    final translationId = bibleState.currentTranslation?.id ?? 2;

    // Counts
    final otBooks = allBooks.where((b) => b.isOldTestament).toList();
    final ntBooks = allBooks.where((b) => b.isNewTestament).toList();

    // Filter by search query if any
    final isSearching = _filter.trim().isNotEmpty;
    final q = _filter.trim().toLowerCase();

    List<Book> displayedBooks;
    if (isSearching) {
      displayedBooks = allBooks.where((b) {
        return b.name.toLowerCase().contains(q) ||
            b.nameEn.toLowerCase().contains(q) ||
            b.shortName.toLowerCase().contains(q);
      }).toList();
    } else {
      displayedBooks = _testamentFilter == 'NT' ? ntBooks : otBooks;
    }

    return Column(
      children: [
        // 1. Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: themeConfig.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: themeConfig.cardBorderColor),
            ),
            child: TextField(
              controller: _searchController,
              style: isEnglish
                  ? GoogleFonts.inter(fontSize: 13.5, color: themeConfig.textColor)
                  : GoogleFonts.notoSansEthiopic(fontSize: 13.5, color: themeConfig.textColor),
              decoration: InputDecoration(
                hintText: isEnglish ? 'Search books by name or abbreviation...' : 'መጽሐፍትን በስም ወይም በአህጽሮት ይፈልጉ...',
                hintStyle: TextStyle(fontSize: 12.5, color: themeConfig.secondaryTextColor),
                prefixIcon: Icon(Icons.search_rounded, size: 19, color: themeConfig.accentColor),
                suffixIcon: _filter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filter = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _filter = val),
            ),
          ),
        ),

        // 2. Testament Segmented Toggle Tabs (Only shown when not actively searching)
        if (!isSearching)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: themeConfig.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeConfig.cardBorderColor),
              ),
              child: Row(
                children: [
                  // Old Testament Tab (Left)
                  _buildTestamentTab(
                    label: isEnglish ? 'Old Testament' : 'ብሉይ ኪዳን',
                    count: otBooks.length,
                    value: 'OT',
                    themeConfig: themeConfig,
                    isEnglish: isEnglish,
                  ),
                  const SizedBox(width: 4),
                  // New Testament Tab (Right)
                  _buildTestamentTab(
                    label: isEnglish ? 'New Testament' : 'ሐዲስ ኪዳን',
                    count: ntBooks.length,
                    value: 'NT',
                    themeConfig: themeConfig,
                    isEnglish: isEnglish,
                  ),
                ],
              ),
            ),
          ),

        // 3. Books Categorized List
        Expanded(
          child: displayedBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: themeConfig.secondaryTextColor.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        isEnglish ? 'No matching books found' : 'ምንም መጽሐፍ አልተገኘም',
                        style: isEnglish
                            ? GoogleFonts.inter(fontSize: 14, color: themeConfig.secondaryTextColor)
                            : GoogleFonts.notoSansEthiopic(fontSize: 14, color: themeConfig.secondaryTextColor),
                      ),
                    ],
                  ),
                )
              : isSearching
                  ? _buildSearchResultsList(displayedBooks, bibleState, themeConfig, translationId, isEnglish, isDark)
                  : _buildCategorizedCanonicalList(displayedBooks, bibleState, themeConfig, translationId, isEnglish, isDark),
        ),
      ],
    );
  }

  Widget _buildTestamentTab({
    required String label,
    required int count,
    required String value,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    final isSelected = _testamentFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _testamentFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? themeConfig.accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: isEnglish
                    ? GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : themeConfig.textColor,
                      )
                    : GoogleFonts.notoSansEthiopic(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : themeConfig.textColor,
                      ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : themeConfig.cardBorderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : themeConfig.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorizedCanonicalList(
    List<Book> books,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    int translationId,
    bool isEnglish,
    bool isDark,
  ) {
    // Group books by canonical section in sequential liturgical order
    final sectionsOrder = _testamentFilter == 'NT'
        ? ['NT_GOSPELS', 'NT_ACTS', 'NT_PAUL', 'NT_GENERAL', 'NT_REV']
        : ['OT_LAW', 'OT_HISTORY', 'OT_DEUTERO', 'OT_WISDOM', 'OT_PROPHETS'];

    final grouped = <String, List<Book>>{};
    for (final b in books) {
      final sec = _getCanonicalSection(b, translationId);
      grouped.putIfAbsent(sec.key, () => []).add(b);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
      children: [
        for (final secKey in sectionsOrder)
          if (grouped.containsKey(secKey) && grouped[secKey]!.isNotEmpty) ...[
            _buildSectionHeader(grouped[secKey]!.first, translationId, grouped[secKey]!.length, themeConfig, isEnglish),
            const SizedBox(height: 6),
            for (final book in grouped[secKey]!)
              _buildBookCard(book, bibleState, themeConfig, translationId, isEnglish, isDark),
            const SizedBox(height: 16),
          ],
      ],
    );
  }

  Widget _buildSearchResultsList(
    List<Book> books,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    int translationId,
    bool isEnglish,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return _buildBookCard(books[index], bibleState, themeConfig, translationId, isEnglish, isDark);
      },
    );
  }

  Widget _buildSectionHeader(
    Book sampleBook,
    int translationId,
    int count,
    ReaderThemeConfig themeConfig,
    bool isEnglish,
  ) {
    final sec = _getCanonicalSection(sampleBook, translationId);
    final title = isEnglish ? sec.titleEn : sec.title;
    final countLabel = isEnglish ? '$count Books' : '$count መጻሕፍት';

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 2, right: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: sec.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(sec.icon, size: 16, color: sec.color),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: isEnglish
                ? GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: sec.color,
                  )
                : GoogleFonts.notoSansEthiopic(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: sec.color,
                  ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: sec.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              countLabel,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: sec.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(
    Book book,
    BibleViewState bibleState,
    ReaderThemeConfig themeConfig,
    int translationId,
    bool isEnglish,
    bool isDark,
  ) {
    final isCurrent = bibleState.currentBook?.id == book.id;
    final sec = _getCanonicalSection(book, translationId);
    final catColor = sec.color;
    final displayName = isEnglish && book.nameEn.isNotEmpty ? book.nameEn : book.name;

    final progressState = ref.watch(readingProgressProvider);
    final isCompleted = progressState.isBookCompleted(book.bookNumber, book.totalChapters);
    final readCount = progressState.getChaptersReadForBook(book.bookNumber);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onBookTapped(book),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isCurrent
                  ? catColor.withValues(alpha: isDark ? 0.20 : 0.08)
                  : themeConfig.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent ? catColor : themeConfig.cardBorderColor,
                width: isCurrent ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                // Canonical Number Badge
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    themeConfig.useGeezNumerals && !isEnglish
                        ? GeezNumbers.toGeez(book.bookNumber)
                        : '${book.bookNumber}',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: catColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Book Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: isEnglish
                                  ? GoogleFonts.inter(
                                      fontSize: 14.5,
                                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                                      color: isCurrent ? catColor : themeConfig.textColor,
                                    )
                                  : GoogleFonts.notoSansEthiopic(
                                      fontSize: 14.5,
                                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                                      color: isCurrent ? catColor : themeConfig.textColor,
                                    ),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isEnglish ? 'Reading' : 'በንባብ ላይ',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF047857),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_rounded, size: 11, color: Colors.white),
                                  const SizedBox(width: 3),
                                  Text(
                                    isEnglish ? 'Read' : 'ተጠናቋል',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (readCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$readCount/${book.totalChapters}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: catColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            isEnglish ? '${book.totalChapters} Chapters' : '${book.totalChapters} ምዕራፎች',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: themeConfig.secondaryTextColor,
                            ),
                          ),
                          if (!isEnglish && book.nameEn.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${book.nameEn}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: themeConfig.secondaryTextColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isCurrent ? catColor : themeConfig.secondaryTextColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1ChapterSelection(
    ReaderThemeConfig themeConfig,
    BibleViewState bibleState,
    bool isEnglish,
  ) {
    final book = _selectedBook;
    if (book == null) return const SizedBox.shrink();
    final bookDisplayName = isEnglish && book.nameEn.isNotEmpty ? book.nameEn : book.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEnglish ? '$bookDisplayName — Select Chapter' : '$bookDisplayName — ምዕራፍ ይምረጡ',
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
              Text(
                isEnglish ? '${book.totalChapters} Chapters' : '${book.totalChapters} ምዕራፎች',
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
              final label = !isEnglish && themeConfig.useGeezNumerals ? GeezNumbers.toGeez(ch) : '$ch';

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
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isCurrent ? Colors.white : themeConfig.textColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
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

  Widget _buildStep2VerseSelection(ReaderThemeConfig themeConfig, bool isEnglish) {
    final book = _selectedBook;
    if (book == null) return const SizedBox.shrink();
    final bookDisplayName = isEnglish && book.nameEn.isNotEmpty ? book.nameEn : book.name;

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
              isEnglish
                  ? 'Open $bookDisplayName Chapter $_selectedChapter from Verse 1'
                  : '$bookDisplayName ምዕራፍ $_selectedChapterን ከመጀመሪያው ክፈት',
              style: isEnglish
                  ? GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)
                  : GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            isEnglish ? 'Or jump directly to a verse:' : 'ወይም ወደ ተለየ ቁጥር በቀጥታ ይዝለሉ፦',
            style: isEnglish
                ? GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: themeConfig.secondaryTextColor,
                  )
                : GoogleFonts.notoSansEthiopic(
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
              final label = !isEnglish && themeConfig.useGeezNumerals ? GeezNumbers.toGeez(v) : '$v';

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
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: themeConfig.textColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
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
