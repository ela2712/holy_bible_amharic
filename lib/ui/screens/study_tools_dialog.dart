import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../models/verse.dart';
import '../../models/commentary.dart';
import '../../models/cross_reference.dart';
import '../../data/patristic_commentaries.dart';
import '../../data/cross_references_data.dart';
import '../../providers/bible_state.dart';
import '../../providers/theme_provider.dart';
import '../../services/bible_repository.dart';
import '../widgets/built_in_geez_keyboard.dart';
import '../widgets/ethiopian_cross_painter.dart';
import 'verse_card_maker_screen.dart';

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
  // Filter pills: 'ALL', 'ANDIMTA', 'EARLY_FATHERS', 'CROSS_REF', 'PARALLEL'
  String _selectedFilter = 'ALL';
  late bool _isBookmarked;
  String? _currentHighlight;
  bool _showNoteEditor = false;
  bool _showCustomKeyboard = false;
  late TextEditingController _noteController;

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
      _selectedFilter = 'PARALLEL';
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

  Future<void> _saveNote() async {
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
        const SnackBar(content: Text('ማስታወሻ ተቀምጧል (Note saved)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeConfigProvider);
    final isDark = themeConfig.mode == ReaderThemeMode.dark;
    final vSpan = widget.verse.isMergedRange
        ? '${widget.verse.verse}–${widget.verse.verseEnd}'
        : '${widget.verse.verse}';
    final reference = '${widget.bookName} ${widget.verse.chapter}:$vSpan';

    final allCommentaries = <Commentary>[];
    final crossReferences = <CrossReferenceItem>[];
    final endV = widget.verse.verseEnd ?? widget.verse.verse;
    for (int v = widget.verse.verse; v <= endV; v++) {
      allCommentaries.addAll(
        PatristicCommentariesData.getCommentariesOrContextualForVerse(
          widget.bookNumber,
          widget.verse.chapter,
          v,
        ),
      );
      crossReferences.addAll(
        CrossReferencesData.getCrossReferencesForVerse(
          widget.bookNumber,
          widget.verse.chapter,
          v,
        ),
      );
    }
    final andimtaCommentaries =
        allCommentaries.where(PatristicCommentariesData.isEthiopianTradition).toList();
    final earlyFatherCommentaries =
        allCommentaries.where((c) => !PatristicCommentariesData.isEthiopianTradition(c)).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
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
                        style: GoogleFonts.notoSansEthiopic(
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
                      tooltip: 'ዕልባት (Bookmark)',
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
                      tooltip: 'ማስታወሻ (Note)',
                      onPressed: () => setState(() => _showNoteEditor = !_showNoteEditor),
                    ),
                    // Copy
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.copy_rounded, size: 19, color: themeConfig.secondaryTextColor),
                      tooltip: 'ቅዳ (Copy)',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '$reference\n«${widget.verse.text}»'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ጥቅሱ ተገልብጧል (Copied)')),
                        );
                      },
                    ),
                    // Share
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.ios_share_rounded, size: 19, color: themeConfig.secondaryTextColor),
                      tooltip: 'አጋራ (Share)',
                      onPressed: () {
                        Share.share('$reference\n«${widget.verse.text}»');
                      },
                    ),
                    // Verse Card Maker
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.photo_outlined, size: 20, color: themeConfig.secondaryTextColor),
                      tooltip: 'የጥቅስ ካርድ (Verse Card)',
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
                        style: GoogleFonts.notoSerifEthiopic(
                          fontSize: 14.5,
                          height: 1.55,
                          color: themeConfig.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'ቀለም፦',
                            style: GoogleFonts.notoSansEthiopic(
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
                                  'አጥፋ',
                                  style: GoogleFonts.notoSansEthiopic(
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
                              'የግል ማስታወሻ (Personal Study Note)',
                              style: GoogleFonts.notoSansEthiopic(
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
                          style: GoogleFonts.notoSansEthiopic(fontSize: 13.5, color: themeConfig.textColor),
                          decoration: InputDecoration(
                            hintText: 'ማስታወሻዎን እዚህ ይጻፉ...',
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
                            onPressed: _saveNote,
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: Text(
                              'ማስታወሻ አስቀምጥ',
                              style: GoogleFonts.notoSansEthiopic(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 5. Tradition & Study Filter Pills
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  children: [
                    _buildFilterPill(
                      id: 'ALL',
                      label: 'ሁሉም አበው (${allCommentaries.length})',
                      icon: Icons.auto_awesome_rounded,
                      themeConfig: themeConfig,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                      id: 'ANDIMTA',
                      label: 'አንድምታ (${andimtaCommentaries.length})',
                      icon: Icons.menu_book_rounded,
                      themeConfig: themeConfig,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                      id: 'EARLY_FATHERS',
                      label: 'ቀደምት አበው (${earlyFatherCommentaries.length})',
                      icon: Icons.history_edu_rounded,
                      themeConfig: themeConfig,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                      id: 'CROSS_REF',
                      label: 'ተዛማጅ ጥቅሶች (${crossReferences.length})',
                      icon: Icons.hub_outlined,
                      themeConfig: themeConfig,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterPill(
                      id: 'PARALLEL',
                      label: 'ማነፃፀሪያ (3 ትርጉም)',
                      icon: Icons.compare_arrows_rounded,
                      themeConfig: themeConfig,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 6. Filtered Content Stream
              Expanded(
                child: _buildActiveContentView(
                  scrollController: scrollController,
                  themeConfig: themeConfig,
                  allCommentaries: allCommentaries,
                  andimtaCommentaries: andimtaCommentaries,
                  earlyFatherCommentaries: earlyFatherCommentaries,
                  crossReferences: crossReferences,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterPill({
    required String id,
    required String label,
    required IconData icon,
    required ReaderThemeConfig themeConfig,
  }) {
    final isSelected = _selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? themeConfig.accentColor : themeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? themeConfig.accentColor : themeConfig.cardBorderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : themeConfig.accentColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : themeConfig.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContentView({
    required ScrollController scrollController,
    required ReaderThemeConfig themeConfig,
    required List<Commentary> allCommentaries,
    required List<Commentary> andimtaCommentaries,
    required List<Commentary> earlyFatherCommentaries,
    required List<CrossReferenceItem> crossReferences,
  }) {
    if (_selectedFilter == 'CROSS_REF') {
      return _buildCrossReferencesList(scrollController, crossReferences, themeConfig);
    }
    if (_selectedFilter == 'PARALLEL') {
      return _buildParallelTranslationsList(scrollController, themeConfig);
    }

    final commentariesToShow = _selectedFilter == 'ANDIMTA'
        ? andimtaCommentaries
        : _selectedFilter == 'EARLY_FATHERS'
            ? earlyFatherCommentaries
            : allCommentaries;

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      itemCount: commentariesToShow.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = commentariesToShow[idx];
        final isAndimta = PatristicCommentariesData.isEthiopianTradition(item);
        final badgeColor = isAndimta ? themeConfig.goldAccent : themeConfig.accentColor;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: isAndimta
                        ? Text(
                            'አ',
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: badgeColor,
                            ),
                          )
                        : OrthodoxCrossIcon(
                            size: 18,
                            color: badgeColor,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isAndimta ? 'የኢትዮጵያ አንድምታ' : 'ቀደምት አበው',
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.authorEra,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: themeConfig.secondaryTextColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.authorName,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ምንጭ፦ ${item.sourceWork}',
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: themeConfig.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.copy_rounded, size: 17, color: themeConfig.secondaryTextColor),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: '${item.authorName} (${item.sourceWork}):\n"${item.content}"',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ትርጓሜው ተገልብጧል (Commentary copied)')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.content,
                style: GoogleFonts.notoSerifEthiopic(
                  fontSize: 15,
                  height: 1.7,
                  color: themeConfig.textColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCrossReferencesList(
    ScrollController scrollController,
    List<CrossReferenceItem> crossRefs,
    ReaderThemeConfig themeConfig,
  ) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      itemCount: crossRefs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final refItem = crossRefs[idx];
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
              // Target Reference & Connection Type Pill
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeConfig.goldAccent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link_rounded, size: 14, color: themeConfig.goldAccent),
                        const SizedBox(width: 5),
                        Text(
                          refItem.targetReference,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.goldAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      refItem.connectionType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: themeConfig.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Detailed Scholarly / Canonical Source Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: themeConfig.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: themeConfig.cardBorderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_outlined, size: 14, color: themeConfig.accentColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        refItem.sourceCitation,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: themeConfig.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Target Verse Preview Quote
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: themeConfig.goldAccent, width: 3),
                  ),
                  color: themeConfig.goldAccent.withValues(alpha: 0.05),
                ),
                child: Text(
                  '«${refItem.targetPreviewText}»',
                  style: GoogleFonts.notoSerifEthiopic(
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: themeConfig.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Detailed Exegetical Explanation
              Text(
                refItem.explanation,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 13.5,
                  height: 1.6,
                  color: themeConfig.textColor,
                ),
              ),
              const SizedBox(height: 10),

              // Action to jump directly to the cross-referenced verse
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: themeConfig.goldAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () async {
                    final bibleState = ref.read(bibleStateProvider);
                    final targetBook = bibleState.books.firstWhere(
                      (b) => b.bookNumber == refItem.targetBookNumber,
                      orElse: () => bibleState.books.first,
                    );
                    await ref.read(bibleStateProvider.notifier).selectBook(
                          targetBook,
                          chapter: refItem.targetChapter,
                        );
                    widget.onJumpToReference?.call(
                      refItem.targetBookNumber,
                      refItem.targetChapter,
                      refItem.targetVerse,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: Text(
                    'ወደ ${refItem.targetReference} ሂድ',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParallelTranslationsList(
    ScrollController scrollController,
    ReaderThemeConfig themeConfig,
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
        if (parallels.isEmpty) {
          return const Center(child: Text('ምንም ተዛማጅ ትርጉሞች አልተገኙም'));
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          children: parallels.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                          color: themeConfig.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.key,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: themeConfig.accentColor,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.copy_rounded, size: 16, color: themeConfig.secondaryTextColor),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '${entry.key}:\n${entry.value}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${entry.key} ተገልብጧል')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    entry.value,
                    style: GoogleFonts.notoSerifEthiopic(
                      fontSize: 15,
                      height: 1.65,
                      color: themeConfig.textColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
