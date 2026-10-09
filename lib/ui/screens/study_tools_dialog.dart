import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/verse.dart';
import '../../models/commentary.dart';
import '../../data/patristic_commentaries.dart';
import '../../services/bible_repository.dart';
import '../widgets/built_in_geez_keyboard.dart';
import 'verse_card_maker_screen.dart';

class StudyToolsSheet extends StatefulWidget {
  final Verse verse;
  final String bookName;
  final int bookNumber;
  final BibleRepository repository;
  final VoidCallback onVerseUpdated;
  final int initialTabIndex;

  const StudyToolsSheet({
    super.key,
    required this.verse,
    required this.bookName,
    required this.bookNumber,
    required this.repository,
    required this.onVerseUpdated,
    this.initialTabIndex = 0,
  });

  static void show(
    BuildContext context, {
    required Verse verse,
    required String bookName,
    required int bookNumber,
    required BibleRepository repository,
    required VoidCallback onVerseUpdated,
    int initialTabIndex = 0,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StudyToolsSheet(
        verse: verse,
        bookName: bookName,
        bookNumber: bookNumber,
        repository: repository,
        onVerseUpdated: onVerseUpdated,
        initialTabIndex: initialTabIndex,
      ),
    );
  }

  @override
  State<StudyToolsSheet> createState() => _StudyToolsSheetState();
}

class _StudyToolsSheetState extends State<StudyToolsSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isBookmarked;
  String? _currentHighlight;
  bool _showCustomKeyboard = false;
  late TextEditingController _noteController;

  static const List<Map<String, dynamic>> _highlightColors = [
    {'name': 'ቢጫ (Yellow)', 'hex': '#FFF59D', 'color': Color(0xFFFFF59D)},
    {'name': 'አረንጓዴ (Green)', 'hex': '#C8E6C9', 'color': Color(0xFFC8E6C9)},
    {'name': 'ሰማያዊ (Blue)', 'hex': '#BBDEFB', 'color': Color(0xFFBBDEFB)},
    {'name': 'ሮዝ (Pink)', 'hex': '#F8BBD0', 'color': Color(0xFFF8BBD0)},
    {'name': 'ብርቱካን (Orange)', 'hex': '#FFE0B2', 'color': Color(0xFFFFE0B2)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
    _isBookmarked = widget.verse.isBookmarked;
    _currentHighlight = widget.verse.highlightColor;
    _noteController = TextEditingController(text: widget.verse.note ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ማስታወሻ ተቀምጧል (Note saved)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reference = '${widget.bookName} ${widget.verse.chapter}:${widget.verse.verse}';
    final commentaries = PatristicCommentariesData.getCommentariesForVerse(
      widget.bookNumber,
      widget.verse.chapter,
      widget.verse.verse,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF191716) : const Color(0xFFFAF8F5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag bar
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Verse Reference Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7D1A25).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.church_outlined, color: Color(0xFF7D1A25), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reference,
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF7D1A25),
                            ),
                          ),
                          Text(
                            commentaries.isNotEmpty
                                ? 'የቀደምት አበው ትርጓሜ (${commentaries.length})'
                                : 'የጥናትና ትርጓሜ መድረክ (Study Panel)',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? const Color(0xFF7D1A25) : null,
                      ),
                      tooltip: 'Bookmark',
                      onPressed: _toggleBookmark,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 3. Compact Verse Snippet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF24201E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFC5A059).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '«${widget.verse.text}»',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 14,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF221A16),
                    ),
                  ),
                ),
              ),

              // 4. Tab Bar (Catena / Church Fathers first!)
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: const Color(0xFF7D1A25),
                unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                indicatorColor: const Color(0xFF7D1A25),
                indicatorWeight: 3,
                labelStyle: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.notoSansEthiopic(fontSize: 13),
                tabs: [
                  Tab(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✝ ', style: TextStyle(color: Color(0xFFC5A059), fontSize: 15)),
                        Text('የአበው ትርጓሜ (${commentaries.length})'),
                      ],
                    ),
                  ),
                  const Tab(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.compare_arrows, size: 16),
                        SizedBox(width: 4),
                        Text('ማነፃፀሪያ (Parallel)'),
                      ],
                    ),
                  ),
                  const Tab(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note, size: 16),
                        SizedBox(width: 4),
                        Text('ማስታወሻና ቀለም'),
                      ],
                    ),
                  ),
                  const Tab(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_outlined, size: 16),
                        SizedBox(width: 4),
                        Text('የጥቅስ ካርድ'),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),

              // 5. Tab Content Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 0: Church Fathers Catena Commentary
                    _buildPatristicTab(context, commentaries, isDark, scrollController),

                    // Tab 1: Parallel Translations
                    _buildParallelTab(context, isDark, scrollController),

                    // Tab 2: Notes & Highlights
                    _buildNotesAndHighlightTab(context, theme, isDark, reference, scrollController),

                    // Tab 3: Verse Card Maker shortcut
                    _buildVerseCardTab(context, reference, isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatristicTab(
    BuildContext context,
    List<Commentary> commentaries,
    bool isDark,
    ScrollController scrollController,
  ) {
    if (commentaries.isEmpty) {
      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF221F1D) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.menu_book, color: Color(0xFFC5A059), size: 40),
                const SizedBox(height: 12),
                Text(
                  'የቀደምት አበውና አንድምታ ትምህርት',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7D1A25),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ለዚህ የተለየ ጥቅስ የቀጥታ ሐተታ ባይመዘገብም፣ የዚህ ምዕራፍና የመጽሐፉ አጠቃላይ ትርጓሜ በቅዱሳን አበው ትምህርት መሠረት ከቀደምት የቤተክርስቲያን ትውፊት ጋር የተስማማ ነው።',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 13.5,
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.bookmark_outline, size: 16, color: Color(0xFF7D1A25)),
                      label: const Text('አንድምታ ትርጓሜ'),
                      backgroundColor: const Color(0xFF7D1A25).withValues(alpha: 0.08),
                    ),
                    Chip(
                      avatar: const Icon(Icons.verified_outlined, size: 16, color: Color(0xFFC5A059)),
                      label: const Text('የኢትዮጵያ ኦርቶዶክስ ትውፊት'),
                      backgroundColor: const Color(0xFFC5A059).withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: commentaries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, idx) {
        final item = commentaries[idx];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF23201D) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC5A059).withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7D1A25).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
                    ),
                    child: const Center(
                      child: Text('✝', style: TextStyle(color: Color(0xFF7D1A25), fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.authorName,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7D1A25),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.authorTitle} • ${item.authorEra}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5A059).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ምንጭ፦ ${item.sourceWork}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF8A641A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'ትርጓሜውን ቅዳ (Copy)',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: '${item.authorName} (${item.sourceWork}):\n"${item.content}"\n— Catena Amharic Bible',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('የአበው ትርጓሜ ተገልብጧል (Commentary copied)')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Commentary Content
              Text(
                item.content,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 14.5,
                  height: 1.65,
                  color: isDark ? Colors.white.withValues(alpha: 0.92) : const Color(0xFF1E1714),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParallelTab(
    BuildContext context,
    bool isDark,
    ScrollController scrollController,
  ) {
    return FutureBuilder<Map<String, String>>(
      future: widget.repository.getParallelVerseTexts(
        bookNumber: widget.bookNumber,
        chapter: widget.verse.chapter,
        verse: widget.verse.verse,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final parallels = snapshot.data ?? {};
        if (parallels.isEmpty) {
          return const Center(child: Text('ምንም ተዛማጅ ትርጉሞች አልተገኙም'));
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: parallels.entries.map((entry) {
            final isKjv = entry.key.contains('King James');
            final is81 = entry.key.contains('81');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: is81
                      ? const Color(0xFF7D1A25).withValues(alpha: 0.3)
                      : isKjv
                          ? const Color(0xFFC5A059).withValues(alpha: 0.4)
                          : Colors.black12,
                ),
              ),
              color: isDark ? const Color(0xFF221F1D) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: is81
                                ? const Color(0xFF7D1A25).withValues(alpha: 0.12)
                                : const Color(0xFFC5A059).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.key,
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: is81 ? const Color(0xFF7D1A25) : const Color(0xFF8A641A),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '${entry.key}:\n${entry.value}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${entry.key} ተገልብጧል')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.value,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 14.5,
                        height: 1.6,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF221A16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildNotesAndHighlightTab(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String reference,
    ScrollController scrollController,
  ) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // Highlight Palette
        Text(
          'የጥቅስ ቀለም ምረጥ (Highlight Palette)',
          style: GoogleFonts.notoSansEthiopic(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ..._highlightColors.map((c) {
              final isSelected = _currentHighlight == c['hex'];
              return GestureDetector(
                onTap: () => _setHighlight(c['hex'] as String),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: c['color'] as Color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF7D1A25) : Colors.black12,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                ),
              );
            }),
            if (_currentHighlight != null)
              IconButton(
                icon: const Icon(Icons.format_color_reset, size: 22, color: Colors.redAccent),
                tooltip: 'ቀለም አጥፋ (Clear Highlight)',
                onPressed: _removeHighlight,
              ),
          ],
        ),
        const Divider(height: 28),

        // Note Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'የግል ማስታወሻ (Personal Study Note)',
              style: GoogleFonts.notoSansEthiopic(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(
                _showCustomKeyboard ? Icons.keyboard : Icons.keyboard_alt_outlined,
                color: const Color(0xFF7D1A25),
              ),
              tooltip: 'የግዕዝ ኪቦርድ (Ge\'ez Keyboard)',
              onPressed: () => setState(() => _showCustomKeyboard = !_showCustomKeyboard),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 4,
          style: GoogleFonts.notoSansEthiopic(fontSize: 14.5),
          decoration: InputDecoration(
            hintText: 'የመንፈሳዊ ንባብ ማስታወሻዎን እዚህ ይጻፉ...',
            filled: true,
            fillColor: isDark ? const Color(0xFF24201E) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (_showCustomKeyboard) ...[
          const SizedBox(height: 8),
          BuiltInGeezKeyboard(controller: _noteController),
        ],
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7D1A25),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _saveNote,
          icon: const Icon(Icons.save, size: 18),
          label: const Text('ማስታወሻ አስቀምጥ (Save Note)'),
        ),
        const SizedBox(height: 16),

        // Quick sharing row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: '$reference\n"${widget.verse.text}"\n— ከመጽሐፍ ቅዱስ',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ጥቅሱ ተገልብጧል (Copied)')),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('ቅዳ (Copy)'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Share.share('$reference\n"${widget.verse.text}"\n— ከመጽሐፍ ቅዱስ መተግበሪያ');
                },
                icon: const Icon(Icons.share, size: 16),
                label: const Text('አጋራ (Share)'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerseCardTab(
    BuildContext context,
    String reference,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C1810), Color(0xFF7D1A25)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.format_quote, color: Color(0xFFFFD54F), size: 36),
                  const SizedBox(height: 8),
                  Text(
                    '«${widget.verse.text}»',
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansEthiopic(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reference,
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D1A25),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
              icon: const Icon(Icons.palette),
              label: const Text('የጥቅስ ካርድ አዘጋጅ (Design Verse Card)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
