import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/annotation.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';

class AnnotationsScreen extends ConsumerStatefulWidget {
  final Function(int tabIndex)? onNavigateToReader;

  const AnnotationsScreen({
    super.key,
    this.onNavigateToReader,
  });

  @override
  ConsumerState<AnnotationsScreen> createState() => _AnnotationsScreenState();
}

class _AnnotationsScreenState extends ConsumerState<AnnotationsScreen> {
  int _selectedSection = 0; // 0: Bookmarks, 1: Highlights, 2: Notes
  List<BookmarkItem> _bookmarks = [];
  List<HighlightItem> _highlights = [];
  List<NoteItem> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repo = ref.read(bibleRepositoryProvider);
    final b = await repo.getBookmarks();
    final h = await repo.getHighlights();
    final n = await repo.getNotes();

    if (mounted) {
      setState(() {
        _bookmarks = b;
        _highlights = h;
        _notes = n;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToVerse(int bookId, int chapter, [int? verse]) async {
    final bibleState = ref.read(bibleStateProvider);
    if (bibleState.books.isEmpty) return;
    final targetBook = bibleState.books.firstWhere(
      (b) => b.id == bookId,
      orElse: () => bibleState.books.first,
    );
    await ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: chapter);
    if (verse != null) {
      ref.read(bibleStateProvider.notifier).setTargetVerse(verse);
    }
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (widget.onNavigateToReader != null) {
      widget.onNavigateToReader!(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final isEnglish = ref.watch(isEnglishUiProvider);

    // Automatically refresh when verses change in the reader
    ref.listen(bibleStateProvider.select((s) => s.verses), (_, _) {
      _loadData();
    });

    return Scaffold(
      backgroundColor: themeConfig.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Modern Editorial Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEnglish ? 'Saved Vault' : 'የእኔ ማህደር',
                    style: isEnglish
                        ? GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: themeConfig.textColor,
                          )
                        : GoogleFonts.notoSansEthiopic(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: themeConfig.textColor,
                          ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.refresh_rounded, color: themeConfig.secondaryTextColor, size: 20),
                        tooltip: isEnglish ? 'Refresh' : 'አድስ',
                        onPressed: _loadData,
                      ),
                      if (Navigator.canPop(context))
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: themeConfig.textColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Segmented Pill Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: themeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: themeConfig.cardBorderColor),
                ),
                child: Row(
                  children: [
                    _buildSegmentPill(
                      index: 0,
                      icon: Icons.bookmark_rounded,
                      label: isEnglish ? 'Bookmarks' : 'ዕልባቶች',
                      count: _bookmarks.length,
                      themeConfig: themeConfig,
                      isEnglish: isEnglish,
                    ),
                    _buildSegmentPill(
                      index: 1,
                      icon: Icons.palette_rounded,
                      label: isEnglish ? 'Highlights' : 'ቀለሞች',
                      count: _highlights.length,
                      themeConfig: themeConfig,
                      isEnglish: isEnglish,
                    ),
                    _buildSegmentPill(
                      index: 2,
                      icon: Icons.edit_note_rounded,
                      label: isEnglish ? 'Notes' : 'ማስታወሻዎች',
                      count: _notes.length,
                      themeConfig: themeConfig,
                      isEnglish: isEnglish,
                    ),
                  ],
                ),
              ),
            ),

            // 3. Content Area
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: themeConfig.accentColor))
                  : _selectedSection == 0
                      ? _buildBookmarksList(themeConfig, isDark)
                      : _selectedSection == 1
                          ? _buildHighlightsList(themeConfig, isDark)
                          : _buildNotesList(themeConfig, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentPill({
    required int index,
    required IconData icon,
    required String label,
    required int count,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    final isSelected = _selectedSection == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedSection = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? themeConfig.accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : themeConfig.secondaryTextColor,
              ),
              const SizedBox(width: 6),
              Text(
                '$label ($count)',
                style: isEnglish
                    ? GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : themeConfig.textColor,
                      )
                    : GoogleFonts.notoSansEthiopic(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : themeConfig.textColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyVaultState({
    required IconData icon,
    required String title,
    required String subtitle,
    required ReaderThemeConfig themeConfig,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: themeConfig.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: themeConfig.accentColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: themeConfig.textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 13,
                height: 1.5,
                color: themeConfig.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksList(ReaderThemeConfig themeConfig, bool isDark) {
    if (_bookmarks.isEmpty) {
      return _buildEmptyVaultState(
        icon: Icons.bookmark_border_rounded,
        title: 'ምንም የተቀመጡ ዕልባቶች የሉም',
        subtitle: 'በንባብ ጊዜ ማንኛውንም ጥቅስ በመጫን ዕልባት ማድረግ ይችላሉ።',
        themeConfig: themeConfig,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: _bookmarks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = _bookmarks[index];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToVerse(b.bookId, b.chapter, b.verse),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeConfig.surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: themeConfig.cardBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          Icon(Icons.bookmark_rounded, size: 13, color: themeConfig.accentColor),
                          const SizedBox(width: 5),
                          Text(
                            '${b.bookName} ${b.chapter}:${b.verse}',
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: themeConfig.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.copy_rounded, size: 16, color: themeConfig.secondaryTextColor),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '${b.bookName} ${b.chapter}:${b.verse}\n«${b.verseText}»'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ጥቅሱ ተገልብጧል (Copied)')),
                        );
                      },
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      onPressed: () async {
                        await ref.read(bibleRepositoryProvider).toggleBookmark(
                              bookId: b.bookId,
                              chapter: b.chapter,
                              verse: b.verse,
                            );
                        await ref.read(bibleStateProvider.notifier).refreshVerses();
                        _loadData();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  b.verseText,
                  style: GoogleFonts.notoSerifEthiopic(
                    fontSize: 15,
                    height: 1.65,
                    color: themeConfig.textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighlightsList(ReaderThemeConfig themeConfig, bool isDark) {
    if (_highlights.isEmpty) {
      return _buildEmptyVaultState(
        icon: Icons.palette_outlined,
        title: 'ምንም ቀለም የተቀቡ ጥቅሶች የሉም',
        subtitle: 'በንባብ ገጽ ላይ ማንኛውንም ጥቅስ በመጫን ቀለም መቀባት ይችላሉ።',
        themeConfig: themeConfig,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: _highlights.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final h = _highlights[index];
        final swatchColor = Color(int.parse(h.colorHex.replaceFirst('#', '0xFF')));
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToVerse(h.bookId, h.chapter, h.verse),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeConfig.surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: themeConfig.cardBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: swatchColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${h.bookName} ${h.chapter}:${h.verse}',
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: themeConfig.textColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      onPressed: () async {
                        await ref.read(bibleRepositoryProvider).removeHighlight(
                              bookId: h.bookId,
                              chapter: h.chapter,
                              verse: h.verse,
                            );
                        await ref.read(bibleStateProvider.notifier).refreshVerses();
                        _loadData();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: swatchColor.withValues(alpha: isDark ? 0.22 : 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    h.verseText,
                    style: GoogleFonts.notoSerifEthiopic(
                      fontSize: 14.5,
                      height: 1.6,
                      color: themeConfig.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesList(ReaderThemeConfig themeConfig, bool isDark) {
    if (_notes.isEmpty) {
      return _buildEmptyVaultState(
        icon: Icons.sticky_note_2_outlined,
        title: 'ምንም የግል ማስታወሻዎች የሉም',
        subtitle: 'በንባብ ጊዜ ጥቅሶችን በመጫን የግል የጥናት ማስታወሻዎን መጻፍ ይችላሉ።',
        themeConfig: themeConfig,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: _notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final n = _notes[index];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToVerse(n.bookId, n.chapter, n.verse),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeConfig.surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: themeConfig.cardBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeConfig.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${n.bookName} ${n.chapter}:${n.verse}',
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: themeConfig.accentColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      onPressed: () async {
                        await ref.read(bibleRepositoryProvider).saveNote(
                              bookId: n.bookId,
                              chapter: n.chapter,
                              verse: n.verse,
                              noteText: '',
                            );
                        await ref.read(bibleStateProvider.notifier).refreshVerses();
                        _loadData();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeConfig.accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeConfig.accentColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    n.noteText,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeConfig.textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '«${n.verseText}»',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSerifEthiopic(
                    fontSize: 13,
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
}
