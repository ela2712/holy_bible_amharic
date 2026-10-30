import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../models/cross_reference.dart';
import '../../models/verse.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import '../../services/bible_repository.dart';
import '../widgets/built_in_geez_keyboard.dart';
import 'verse_card_maker_screen.dart';
import 'parallel_reader_screen.dart';

class StudyToolsSheet extends ConsumerStatefulWidget {
  final Verse verse;
  final String bookName;
  final int bookNumber;
  final BibleRepository repository;
  final VoidCallback onVerseUpdated;
  final VoidCallback? onDismissed;
  final Function(int targetBookNum, int targetCh, int targetVerse)? onJumpToReference;
  final int initialTabIndex;

  const StudyToolsSheet({
    super.key,
    required this.verse,
    required this.bookName,
    required this.bookNumber,
    required this.repository,
    required this.onVerseUpdated,
    this.onDismissed,
    this.onJumpToReference,
    this.initialTabIndex = 0,
  });

  static Future<void> show(
    BuildContext context, {
    required Verse verse,
    required String bookName,
    required int bookNumber,
    required BibleRepository repository,
    required VoidCallback onVerseUpdated,
    VoidCallback? onDismissed,
    Function(int targetBookNum, int targetCh, int targetVerse)? onJumpToReference,
    int initialTabIndex = 0,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StudyToolsSheet(
        verse: verse,
        bookName: bookName,
        bookNumber: bookNumber,
        repository: repository,
        onVerseUpdated: onVerseUpdated,
        onDismissed: onDismissed,
        onJumpToReference: onJumpToReference,
        initialTabIndex: initialTabIndex,
      ),
    );
    onDismissed?.call();
  }

  @override
  ConsumerState<StudyToolsSheet> createState() => _StudyToolsSheetState();
}

class _StudyToolsSheetState extends ConsumerState<StudyToolsSheet> {
  late bool _isBookmarked;
  String? _currentHighlight;
  bool _showNoteEditor = false;
  bool _showCustomKeyboard = false;
  late TextEditingController _noteController;
  int _selectedToolTab = 0; // 0: Parallel Translations, 1: Cross References, 2: Ge'ez Heritage

  static const List<Map<String, dynamic>> _highlightColors = [
    {'hex': '#FDE68A', 'color': Color(0xFFFDE68A)},
    {'hex': '#A7F3D0', 'color': Color(0xFFA7F3D0)},
    {'hex': '#BAE6FD', 'color': Color(0xFFBAE6FD)},
    {'hex': '#FECDD3', 'color': Color(0xFFFECDD3)},
    {'hex': '#DDD6FE', 'color': Color(0xFFDDD6FE)},
  ];

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.verse.isBookmarked;
    _currentHighlight = widget.verse.highlightColor;
    _noteController = TextEditingController(text: widget.verse.note ?? '');
    if (widget.verse.note != null && widget.verse.note!.isNotEmpty) {
      _showNoteEditor = true;
    }
    if (widget.initialTabIndex == 1) {
      _selectedToolTab = 1;
    } else if (widget.initialTabIndex == 2) {
      _showNoteEditor = true;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _toggleBookmark() async {
    final status = await widget.repository.toggleBookmark(
      bookId: widget.verse.bookId,
      chapter: widget.verse.chapter,
      verse: widget.verse.verse,
    );
    setState(() => _isBookmarked = status);
    widget.onVerseUpdated();
  }

  Future<void> _setHighlight(String hex) async {
    await widget.repository.setHighlight(
      bookId: widget.verse.bookId,
      chapter: widget.verse.chapter,
      verse: widget.verse.verse,
      colorHex: hex,
    );
    setState(() => _currentHighlight = hex);
    widget.onVerseUpdated();
  }

  Future<void> _removeHighlight() async {
    await widget.repository.removeHighlight(
      bookId: widget.verse.bookId,
      chapter: widget.verse.chapter,
      verse: widget.verse.verse,
    );
    setState(() => _currentHighlight = null);
    widget.onVerseUpdated();
  }

  Future<void> _saveNote(bool isEnglish) async {
    await widget.repository.saveNote(
      bookId: widget.verse.bookId,
      chapter: widget.verse.chapter,
      verse: widget.verse.verse,
      noteText: _noteController.text,
    );
    widget.onVerseUpdated();
    if (mounted) {
      setState(() => _showNoteEditor = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish ? 'Note saved' : 'ማስታወሻ ተቀምጧል'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final isEnglish = ref.watch(isEnglishUiProvider);
    final vSpan = widget.verse.isMergedRange
        ? '${widget.verse.verse}–${widget.verse.verseEnd}'
        : '${widget.verse.verse}';
    final reference = '${widget.bookName} ${widget.verse.chapter}:$vSpan';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: themeConfig.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: themeConfig.cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.16),
                blurRadius: 28,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag Handle
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: themeConfig.cardBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 2. Verse Header + Quick Action Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: themeConfig.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        reference,
                        style: isEnglish
                            ? GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: themeConfig.accentColor,
                              )
                            : GoogleFonts.notoSansEthiopic(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: themeConfig.accentColor,
                              ),
                      ),
                    ),
                    const Spacer(),
                    // Bookmark
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: _isBookmarked ? themeConfig.accentColor : themeConfig.secondaryTextColor,
                        size: 21,
                      ),
                      tooltip: isEnglish ? 'Bookmark' : 'ዕልባት',
                      onPressed: _toggleBookmark,
                    ),
                    // Note Toggle
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        _showNoteEditor ? Icons.sticky_note_2_rounded : Icons.sticky_note_2_outlined,
                        color: _showNoteEditor ? themeConfig.accentColor : themeConfig.secondaryTextColor,
                        size: 21,
                      ),
                      tooltip: isEnglish ? 'Note' : 'ማስታወሻ',
                      onPressed: () => setState(() => _showNoteEditor = !_showNoteEditor),
                    ),
                    // Copy
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.copy_rounded, size: 19, color: themeConfig.secondaryTextColor),
                      tooltip: isEnglish ? 'Copy' : 'ቅዳ',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '$reference\n«${widget.verse.text}»'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEnglish ? 'Verse copied to clipboard' : 'ጥቅሱ ተገልብጧል'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    // Share
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.ios_share_rounded, size: 19, color: themeConfig.secondaryTextColor),
                      tooltip: isEnglish ? 'Share' : 'አጋራ',
                      onPressed: () {
                        final attribution = isEnglish ? '— Holy Bible' : '— ከመጽሐፍ ቅዱስ';
                        Share.share('$reference\n«${widget.verse.text}»\n$attribution');
                      },
                    ),
                    // Verse Card Maker
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.photo_outlined, size: 20, color: themeConfig.secondaryTextColor),
                      tooltip: isEnglish ? 'Verse Card Maker' : 'የጥቅስ ምስል አዘጋጅ',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VerseCardMakerScreen(
                              reference: reference,
                              verseText: widget.verse.text,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.close_rounded, size: 21, color: themeConfig.secondaryTextColor),
                      tooltip: isEnglish ? 'Close' : 'ዝጋ',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 3. Highlight Swatch Strip + Selected Verse Quote
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: themeConfig.cardBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '«${widget.verse.text}»',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'NotoSerifEthiopic',
                          fontFamilyFallback: ['Noto Serif Ethiopic', 'Nyala', 'serif'],
                          fontSize: 14.5,
                          height: 1.55,
                        ).copyWith(color: themeConfig.textColor),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            isEnglish ? 'Highlight:' : 'ቀለም፦',
                            style: isEnglish
                                ? GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: themeConfig.secondaryTextColor,
                                  )
                                : GoogleFonts.notoSansEthiopic(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: themeConfig.secondaryTextColor,
                                  ),
                          ),
                          const SizedBox(width: 10),
                          ..._highlightColors.map((c) {
                            final isSelected = _currentHighlight == c['hex'];
                            return GestureDetector(
                              onTap: () => _setHighlight(c['hex'] as String),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: c['color'] as Color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? themeConfig.accentColor : Colors.black26,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(Icons.check, size: 13, color: themeConfig.accentColor)
                                    : null,
                              ),
                            );
                          }),
                          if (_currentHighlight != null)
                            GestureDetector(
                              onTap: _removeHighlight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isEnglish ? 'Clear' : 'አጥፋ',
                                  style: isEnglish
                                      ? GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.redAccent,
                                        )
                                      : GoogleFonts.notoSansEthiopic(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.redAccent,
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Collapsible Personal Note Editor (if toggled)
              if (_showNoteEditor)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeConfig.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: themeConfig.accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEnglish ? 'Personal Study Note' : 'የግል ማስታወሻ',
                              style: isEnglish
                                  ? GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: themeConfig.accentColor,
                                    )
                                  : GoogleFonts.notoSansEthiopic(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: themeConfig.accentColor,
                                    ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                _showCustomKeyboard ? Icons.keyboard_rounded : Icons.keyboard_alt_outlined,
                                size: 18,
                                color: themeConfig.accentColor,
                              ),
                              onPressed: () => setState(() => _showCustomKeyboard = !_showCustomKeyboard),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _noteController,
                          maxLines: 2,
                          style: isEnglish
                              ? GoogleFonts.inter(fontSize: 13.5, color: themeConfig.textColor)
                              : GoogleFonts.notoSansEthiopic(fontSize: 13.5, color: themeConfig.textColor),
                          decoration: InputDecoration(
                            hintText: isEnglish
                                ? 'Write your personal study note here...'
                                : 'ማስታወሻዎን እዚህ ይጻፉ...',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        if (_showCustomKeyboard) ...[
                          const SizedBox(height: 6),
                          BuiltInGeezKeyboard(controller: _noteController),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeConfig.accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _saveNote(isEnglish),
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: Text(
                              isEnglish ? 'Save Note' : 'ማስታወሻ አስቀምጥ',
                              style: isEnglish
                                  ? GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)
                                  : GoogleFonts.notoSansEthiopic(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 5. Tool Segmented Navigation Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    color: themeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: themeConfig.cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      _buildToolTabButton(
                        index: 0,
                        icon: Icons.compare_arrows_rounded,
                        label: isEnglish ? 'Parallel' : 'ተጓዳኝ ትርጉሞች',
                        themeConfig: themeConfig,
                        isEnglish: isEnglish,
                      ),
                      _buildToolTabButton(
                        index: 1,
                        icon: Icons.alt_route_rounded,
                        label: isEnglish ? 'Cross Refs' : 'ተዛማጅ ጥቅሶች',
                        themeConfig: themeConfig,
                        isEnglish: isEnglish,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // 6. Selected Tab Content Stream
              Expanded(
                child: _selectedToolTab == 0
                    ? _buildParallelTranslationsList(scrollController, themeConfig, isEnglish)
                    : _buildCrossReferencesList(scrollController, themeConfig, isEnglish),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolTabButton({
    required int index,
    required IconData icon,
    required String label,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    final isSelected = _selectedToolTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedToolTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? themeConfig.accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeConfig.accentColor.withValues(alpha: 0.28),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : themeConfig.secondaryTextColor,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isEnglish
                      ? GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : themeConfig.secondaryTextColor,
                        )
                      : GoogleFonts.notoSansEthiopic(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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

  Widget _buildParallelTranslationsList(
    ScrollController scrollController,
    ReaderThemeConfig themeConfig,
    bool isEnglish,
  ) {
    return FutureBuilder<Map<String, String>>(
      future: widget.repository.getParallelVerseTexts(
        bookNumber: widget.bookNumber,
        chapter: widget.verse.chapter,
        verse: widget.verse.verse,
        sourceTranslationId: ref.read(bibleStateProvider).currentTranslation?.id ?? 2,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: themeConfig.accentColor));
        }

        final parallels = snapshot.data ?? {};

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          children: [
            // Full Chapter Parallel Comparison Button
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ParallelReaderScreen(
                        initialBookNumber: widget.bookNumber,
                        initialChapter: widget.verse.chapter,
                        initialTargetVerse: widget.verse.verse,
                        initialTranslationId: ref.read(bibleStateProvider).currentTranslation?.id ?? 2,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: themeConfig.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: themeConfig.accentColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: themeConfig.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.compare_arrows_rounded, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEnglish ? 'Compare Full Chapter in Parallel' : 'ሙሉ ምዕራፍ ጎን ለጎን አነጻጽር',
                              style: isEnglish
                                  ? GoogleFonts.inter(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                      color: themeConfig.accentColor,
                                    )
                                  : GoogleFonts.notoSansEthiopic(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                      color: themeConfig.accentColor,
                                    ),
                            ),
                            Text(
                              isEnglish
                                  ? 'Compare 81 Orthodox Canon, Ancient Ge\'ez, 1954, and KJV side-by-side'
                                  : 'የ81 ቀኖና፣ የቀደምት ግዕዝ፣ የ1954 እና የKJV ትርጉሞችን ጎን ለጎን ያነጻጽሩ',
                              style: isEnglish
                                  ? GoogleFonts.inter(
                                      fontSize: 11,
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
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: themeConfig.accentColor),
                    ],
                  ),
                ),
              ),
            ),

            // 1. 81 Orthodox Canon
            _buildParallelCard(
              title: isEnglish ? '81 Orthodox Canon' : '81 ቀኖና',
              badgeColor: const Color(0xFF047857),
              text: parallels['ሰማንያ ወአሐዱ (የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 ቀኖና)'] ??
                  parallels['81 ቀኖና'] ??
                  widget.verse.text,
              isEthiopic: true,
              themeConfig: themeConfig,
              isEnglish: isEnglish,
            ),

            const SizedBox(height: 12),

            // 2. Ancient Ge'ez 81 Canon
            () {
              final textGeez = parallels['የቀደምት ግዕዝ 81 ቀኖና'] ??
                  parallels['የቀደምት ግዕዝ 81 ቀኖና (Ancient Ge\'ez Canon)'] ??
                  parallels['gez_81'] ??
                  parallels.entries
                      .firstWhere(
                        (e) => e.key.contains('ግዕዝ') || e.key.contains('gez') || e.key.contains("Ge'ez"),
                        orElse: () => const MapEntry('', ''),
                      )
                      .value;
              if (textGeez.isNotEmpty) {
                return _buildParallelCard(
                  title: isEnglish ? "Ancient Ge'ez 81 Canon" : 'የቀደምት ግዕዝ 81 ቀኖና',
                  badgeColor: const Color(0xFF854D0E),
                  text: textGeez,
                  isEthiopic: true,
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                );
              } else {
                return _buildDeuterocanonNoticeCard(
                  title: isEnglish ? "Ancient Ge'ez 81 Canon" : 'የቀደምት ግዕዝ 81 ቀኖና',
                  badgeColor: const Color(0xFF854D0E),
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                );
              }
            }(),

            const SizedBox(height: 12),

            // 3. 1954 Translation
            () {
              final text1954 = parallels['የቀዳማዊ ኃይለ ሥላሴ 1954 ትርጉም'] ??
                  parallels['1954'];
              if (text1954 != null && text1954.isNotEmpty) {
                return _buildParallelCard(
                  title: isEnglish ? '1954 Translation' : '1954 ትርጉም',
                  badgeColor: const Color(0xFFB45309),
                  text: text1954,
                  isEthiopic: true,
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                );
              } else {
                return _buildDeuterocanonNoticeCard(
                  title: isEnglish ? '1954 Translation' : '1954 ትርጉም',
                  badgeColor: const Color(0xFFB45309),
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                );
              }
            }(),

            const SizedBox(height: 12),

            // 4. KJV Translation
            () {
              final textKjv = parallels['King James Version'] ??
                  parallels['KJV'];
              if (textKjv != null && textKjv.isNotEmpty) {
                return _buildParallelCard(
                  title: 'King James Version (KJV)',
                  badgeColor: const Color(0xFF4338CA),
                  text: textKjv,
                  isEthiopic: false,
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                );
              } else {
                return _buildDeuterocanonNoticeCard(
                  title: 'King James Version (KJV)',
                  badgeColor: const Color(0xFF4338CA),
                  themeConfig: themeConfig,
                  isEnglish: isEnglish,
                );
              }
            }(),
          ],
        );
      },
    );
  }

  Widget _buildCrossReferencesList(
    ScrollController scrollController,
    ReaderThemeConfig themeConfig,
    bool isEnglish,
  ) {
    return FutureBuilder<List<CrossReferenceItem>>(
      future: widget.repository.getCrossReferencesForVerse(
        bookNumber: widget.bookNumber,
        chapter: widget.verse.chapter,
        verse: widget.verse.verse,
        translationId: ref.read(bibleStateProvider).currentTranslation?.id ?? 2,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: themeConfig.accentColor));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.alt_route_rounded, size: 44, color: themeConfig.secondaryTextColor.withValues(alpha: 0.5)),
                  const SizedBox(height: 14),
                  Text(
                    isEnglish
                        ? 'No direct cross-references found for this verse'
                        : 'ለዚህ ጥቅስ ምንም ተጨማሪ ማጣቀሻ አልተገኘም',
                    textAlign: TextAlign.center,
                    style: isEnglish
                        ? GoogleFonts.inter(fontSize: 13.5, color: themeConfig.secondaryTextColor)
                        : GoogleFonts.notoSansEthiopic(fontSize: 13.5, color: themeConfig.secondaryTextColor),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 36),
          itemCount: items.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: themeConfig.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isEnglish ? '${items.length} Cross References' : '${items.length} ተዛማጅ ጥቅሶች ተገኝተዋል',
                        style: isEnglish
                            ? GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: themeConfig.accentColor)
                            : GoogleFonts.notoSansEthiopic(fontSize: 11, fontWeight: FontWeight.w800, color: themeConfig.accentColor),
                      ),
                    ),
                  ],
                ),
              );
            }

            final item = items[index - 1];
            final isProphecy = item.connectionType.contains('ትንቢት');
            final badgeColor = isProphecy ? const Color(0xFFD97706) : themeConfig.accentColor;

            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                widget.onJumpToReference?.call(
                  item.targetBookNumber,
                  item.targetChapter,
                  item.targetVerse,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: themeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: themeConfig.cardBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                item.targetReference,
                                style: isEnglish
                                    ? GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: badgeColor)
                                    : GoogleFonts.notoSansEthiopic(fontSize: 12, fontWeight: FontWeight.w800, color: badgeColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: themeConfig.cardBorderColor.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.connectionType,
                                style: isEnglish
                                    ? GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: themeConfig.secondaryTextColor)
                                    : GoogleFonts.notoSansEthiopic(fontSize: 10, fontWeight: FontWeight.w700, color: themeConfig.secondaryTextColor),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(Icons.copy_rounded, size: 16, color: themeConfig.secondaryTextColor),
                              tooltip: isEnglish ? 'Copy' : 'ቅዳ',
                              onPressed: () {
                                final text = item.targetPreviewText.isNotEmpty
                                    ? '${item.targetReference}\n«${item.targetPreviewText}»'
                                    : item.targetReference;
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEnglish ? 'Reference copied' : 'ማጣቀሻው ተገልብጧል'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios_rounded, size: 13, color: themeConfig.accentColor),
                          ],
                        ),
                      ],
                    ),
                    if (item.targetPreviewText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '«${item.targetPreviewText}»',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'NotoSerifEthiopic',
                          fontFamilyFallback: ['Noto Serif Ethiopic', 'Nyala', 'serif'],
                          fontSize: 13.5,
                          height: 1.5,
                        ).copyWith(color: themeConfig.textColor.withValues(alpha: 0.9)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildParallelCard({
    required String title,
    required Color badgeColor,
    required String text,
    required bool isEthiopic,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.copy_rounded, size: 16, color: themeConfig.secondaryTextColor),
                tooltip: isEnglish ? 'Copy' : 'ቅዳ',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '$title:\n$text'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEnglish ? '$title verse copied' : '$title ተገልብጧል',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: isEthiopic
                ? const TextStyle(
                    fontFamily: 'NotoSerifEthiopic',
                    fontFamilyFallback: ['Noto Serif Ethiopic', 'Nyala', 'serif'],
                    fontSize: 15,
                    height: 1.65,
                  ).copyWith(color: themeConfig.textColor)
                : GoogleFonts.inter(
                    fontSize: 14.5,
                    height: 1.55,
                    color: themeConfig.textColor,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeuterocanonNoticeCard({
    required String title,
    required Color badgeColor,
    required ReaderThemeConfig themeConfig,
    required bool isEnglish,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 15, color: themeConfig.secondaryTextColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEnglish
                      ? 'Exclusively in 81 Orthodox Canon (Deuterocanonical book)'
                      : 'በ81 ቀኖና ብቻ የሚገኝ መጽሐፍ ነው',
                  style: isEnglish
                      ? GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: themeConfig.secondaryTextColor,
                        )
                      : GoogleFonts.notoSansEthiopic(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: themeConfig.secondaryTextColor,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
