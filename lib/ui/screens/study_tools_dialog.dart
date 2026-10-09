import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/verse.dart';
import '../../services/bible_repository.dart';
import '../widgets/built_in_geez_keyboard.dart';
import 'verse_card_maker_screen.dart';

class StudyToolsSheet extends StatefulWidget {
  final Verse verse;
  final String bookName;
  final int bookNumber;
  final BibleRepository repository;
  final VoidCallback onVerseUpdated;

  const StudyToolsSheet({
    super.key,
    required this.verse,
    required this.bookName,
    required this.bookNumber,
    required this.repository,
    required this.onVerseUpdated,
  });

  static void show(
    BuildContext context, {
    required Verse verse,
    required String bookName,
    required int bookNumber,
    required BibleRepository repository,
    required VoidCallback onVerseUpdated,
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
      ),
    );
  }

  @override
  State<StudyToolsSheet> createState() => _StudyToolsSheetState();
}

class _StudyToolsSheetState extends State<StudyToolsSheet> {
  late bool _isBookmarked;
  String? _currentHighlight;
  bool _isEditingNote = false;
  bool _showCustomKeyboard = false;
  late TextEditingController _noteController;

  static const List<Map<String, dynamic>> _highlightColors = [
    {'name': 'Yellow', 'hex': '#FFF59D', 'color': Color(0xFFFFF59D)},
    {'name': 'Green', 'hex': '#C8E6C9', 'color': Color(0xFFC8E6C9)},
    {'name': 'Blue', 'hex': '#BBDEFB', 'color': Color(0xFFBBDEFB)},
    {'name': 'Pink', 'hex': '#F8BBD0', 'color': Color(0xFFF8BBD0)},
    {'name': 'Orange', 'hex': '#FFE0B2', 'color': Color(0xFFFFE0B2)},
  ];

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.verse.isBookmarked;
    _currentHighlight = widget.verse.highlightColor;
    _noteController = TextEditingController(text: widget.verse.note ?? '');
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
    setState(() => _isEditingNote = false);
    widget.onVerseUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reference = '${widget.bookName} ${widget.verse.chapter}:${widget.verse.verse}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Verse Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reference,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked ? theme.colorScheme.primary : null,
                ),
                onPressed: _toggleBookmark,
                tooltip: 'Bookmark',
              ),
            ],
          ),

          // Verse Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.verse.text,
              style: GoogleFonts.notoSansEthiopic(fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 14),

          // Highlight Color Palette
          Row(
            children: [
              Text('ቀለም (Highlight): ', style: theme.textTheme.bodyMedium),
              const Spacer(),
              ..._highlightColors.map((c) {
                final isSelected = _currentHighlight == c['hex'];
                return GestureDetector(
                  onTap: () => _setHighlight(c['hex'] as String),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c['color'] as Color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.black12,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                  ),
                );
              }),
              if (_currentHighlight != null)
                IconButton(
                  icon: const Icon(Icons.format_color_reset, size: 20),
                  tooltip: 'Clear Highlight',
                  onPressed: _removeHighlight,
                ),
            ],
          ),
          const Divider(height: 24),

          // Inline Note Section
          if (_isEditingNote) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ማስታወሻ ጻፍ (Write Note):', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(
                    _showCustomKeyboard ? Icons.keyboard : Icons.keyboard_alt_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Toggle Ge\'ez Keyboard',
                  onPressed: () => setState(() => _showCustomKeyboard = !_showCustomKeyboard),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'የጥናት ማስታወሻዎን እዚህ ይጻፉ...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
            if (_showCustomKeyboard)
              BuiltInGeezKeyboard(controller: _noteController),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isEditingNote = false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveNote,
                  child: const Text('Save Note'),
                ),
              ],
            ),
          ] else ...[
            // Actions Row
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.note_add_outlined, size: 18),
                  label: Text(widget.verse.note != null ? 'ማስታወሻ አርትዕ' : 'ማስታወሻ (Note)'),
                  onPressed: () => setState(() => _isEditingNote = true),
                ),
                ActionChip(
                  avatar: const Icon(Icons.copy, size: 18),
                  label: const Text('ቅዳ (Copy)'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text: '$reference\n"${widget.verse.text}"',
                    ));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ጥቅሱ ተገልብጧል (Copied to clipboard)')),
                    );
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.share, size: 18),
                  label: const Text('አጋራ (Share)'),
                  onPressed: () {
                    Share.share('$reference\n"${widget.verse.text}"\n— ከመጽሐፍ ቅዱስ መተግበሪያ');
                    Navigator.pop(context);
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.image, size: 18),
                  label: const Text('ምስል ፍጠር (Card)'),
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
              ],
            ),
          ],
        ],
      ),
    );
  }
}
