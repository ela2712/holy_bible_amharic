import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/annotation.dart';
import '../../providers/bible_state.dart';

class AnnotationsScreen extends ConsumerStatefulWidget {
  const AnnotationsScreen({super.key});

  @override
  ConsumerState<AnnotationsScreen> createState() => _AnnotationsScreenState();
}

class _AnnotationsScreenState extends ConsumerState<AnnotationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BookmarkItem> _bookmarks = [];
  List<HighlightItem> _highlights = [];
  List<NoteItem> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repo = ref.read(bibleRepositoryProvider);
    final b = await repo.getBookmarks();
    final h = await repo.getHighlights();
    final n = await repo.getNotes();

    setState(() {
      _bookmarks = b;
      _highlights = h;
      _notes = n;
      _isLoading = false;
    });
  }

  void _navigateToVerse(int bookId, int chapter) async {
    final bibleState = ref.read(bibleStateProvider);
    final targetBook = bibleState.books.firstWhere(
      (b) => b.id == bookId,
      orElse: () => bibleState.books.first,
    );
    await ref.read(bibleStateProvider.notifier).selectBook(targetBook, chapter: chapter);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የእኔ ማስታወሻዎች (My Annotations)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'ዕልባቶች (${_bookmarks.length})'),
            Tab(text: 'ቀለሞች (${_highlights.length})'),
            Tab(text: 'ማስታወሻ (${_notes.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookmarksTab(),
                _buildHighlightsTab(),
                _buildNotesTab(),
              ],
            ),
    );
  }

  Widget _buildBookmarksTab() {
    if (_bookmarks.isEmpty) {
      return const Center(child: Text('ምንም ዕልባቶች የሉም (No bookmarks saved)'));
    }
    return ListView.separated(
      itemCount: _bookmarks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final b = _bookmarks[index];
        return ListTile(
          leading: const Icon(Icons.bookmark, color: Colors.amber),
          title: Text(
            '${b.bookName} ${b.chapter}:${b.verse}',
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            b.verseText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansEthiopic(fontSize: 13),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateToVerse(b.bookId, b.chapter),
        );
      },
    );
  }

  Widget _buildHighlightsTab() {
    if (_highlights.isEmpty) {
      return const Center(child: Text('ምንም ቀለም የተቀቡ ጥቅሶች የሉም (No highlights)'));
    }
    return ListView.separated(
      itemCount: _highlights.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final h = _highlights[index];
        final color = Color(int.parse(h.colorHex.replaceFirst('#', '0xFF')));
        return ListTile(
          leading: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26),
            ),
          ),
          title: Text(
            '${h.bookName} ${h.chapter}:${h.verse}',
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            h.verseText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansEthiopic(fontSize: 13),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateToVerse(h.bookId, h.chapter),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    if (_notes.isEmpty) {
      return const Center(child: Text('ምንም ማስታወሻዎች የሉም (No notes saved)'));
    }
    return ListView.separated(
      itemCount: _notes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final n = _notes[index];
        return ListTile(
          leading: const Icon(Icons.note_alt_outlined),
          title: Text(
            '${n.bookName} ${n.chapter}:${n.verse}',
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ማስታወሻ: ${n.noteText}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent),
              ),
              const SizedBox(height: 2),
              Text(
                n.verseText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSansEthiopic(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateToVerse(n.bookId, n.chapter),
        );
      },
    );
  }
}
