import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/canonical_book_map.dart';
import '../core/utils/geez_normalizer.dart';
import '../models/translation.dart';
import '../models/book.dart';
import '../models/verse.dart';
import '../models/annotation.dart';

class BibleRepository {
  static final BibleRepository instance = BibleRepository._init();
  BibleRepository._init();
  factory BibleRepository() => instance;

  bool _isInitialized = false;

  // In-memory data structures for fast access across all platforms (Web, Mobile, Desktop)
  final List<Translation> _translations = [
    const Translation(
      id: 2,
      code: 'eotc_81',
      name: 'ሰማንያ ወአሐዱ (የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 ቀኖና)',
      shortName: '81 ቀኖና',
      language: 'am',
      canon: 'orthodox_81',
      isDefault: true,
    ),
    const Translation(
      id: 1,
      code: 'amh_1954',
      name: 'የቀዳማዊ ኃይለ ሥላሴ 1954 ትርጉም',
      shortName: '1954',
      language: 'am',
      canon: 'traditional_1954',
      isDefault: false,
    ),
    const Translation(
      id: 3,
      code: 'en_kjv',
      name: 'King James Version',
      shortName: 'KJV',
      language: 'en',
      canon: 'standard_kjv',
      isDefault: false,
    ),
  ];

  final Map<int, List<Book>> _booksByTranslation = {};
  // Key: '${bookId}_${chapter}' -> List<Verse>
  final Map<String, List<Verse>> _versesCache = {};
  // Key: '${bookId}_${chapter}' -> List<SectionHeading>
  final Map<String, List<SectionHeading>> _headingsCache = {};

  // All verses flattened for full-text search: Map<translationId, List<Map<String, dynamic>>>
  final Map<int, List<Map<String, dynamic>>> _searchIndex = {};

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) print('Initializing BibleRepository datasets...');
      await _load1954Bible();
      await _load81CanonBible();
      await _loadKjvBible();
      _isInitialized = true;
      if (kDebugMode) print('BibleRepository initialization completed successfully!');
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error initializing Bible data: $e');
        print(stack);
      }
    }
  }

  Future<void> _load1954Bible() async {
    final jsonStr = await rootBundle.loadString('assets/data/amharic_1954.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final rawBooks = data['books'] as List<dynamic>;

    final books = <Book>[];
    final searchList = <Map<String, dynamic>>[];
    int bookIdCounter = 1;

    for (int i = 0; i < rawBooks.length; i++) {
      final b = rawBooks[i] as Map<String, dynamic>;
      final bookNum = i + 1;
      final testament = bookNum <= 39 ? 'OT' : 'NT';
      final chapters = b['chapters'] as List<dynamic>? ?? [];
      final bookId = bookIdCounter++;

      final book = Book(
        id: bookId,
        translationId: 1,
        bookNumber: bookNum,
        name: b['title'] as String? ?? 'መጽሐፍ $bookNum',
        shortName: b['abbv'] as String? ?? '',
        nameEn: '',
        testament: testament,
        orderIndex: bookNum,
        totalChapters: chapters.length,
      );
      books.add(book);

      for (int cIdx = 0; cIdx < chapters.length; cIdx++) {
        final chObj = chapters[cIdx] as Map<String, dynamic>;
        final chNum = int.tryParse(chObj['chapter']?.toString() ?? '') ?? (cIdx + 1);
        final rawVerses = chObj['verses'] as List<dynamic>? ?? [];
        final verseList = <Verse>[];

        int? pendingRangeStart;

        for (int vIdx = 0; vIdx < rawVerses.length; vIdx++) {
          final rawText = rawVerses[vIdx]?.toString().trim() ?? '';
          final vNum = vIdx + 1;

          // Placeholder slots (empty or '-' indicating merged translation with successor verse)
          if (rawText.isEmpty || rawText == '-') {
            pendingRangeStart ??= vNum;
            continue;
          }

          final startVerse = pendingRangeStart ?? vNum;
          final endVerse = (pendingRangeStart != null) ? vNum : null;
          pendingRangeStart = null;

          final normalized = GeezNormalizer.normalize(rawText);

          verseList.add(Verse(
            id: bookId * 100000 + chNum * 1000 + startVerse,
            bookId: bookId,
            chapter: chNum,
            verse: startVerse,
            verseEnd: endVerse,
            text: rawText,
            textNormalized: normalized,
          ));

          searchList.add({
            'id': bookId * 100000 + chNum * 1000 + startVerse,
            'book_id': bookId,
            'book_number': bookNum,
            'book_name': book.name,
            'testament': book.testament,
            'chapter': chNum,
            'verse': startVerse,
            'verse_end': endVerse,
            'text': rawText,
            'text_normalized': normalized,
          });
        }
        _versesCache['${bookId}_$chNum'] = verseList;
      }
    }

    _booksByTranslation[1] = books;
    _searchIndex[1] = searchList;
  }

  Future<void> _load81CanonBible() async {
    final jsonStr = await rootBundle.loadString('assets/data/orthodox_81.json');
    final rawBooks = json.decode(jsonStr) as List<dynamic>;

    final books = <Book>[];
    final searchList = <Map<String, dynamic>>[];
    int bookIdCounter = 100;

    for (int i = 0; i < rawBooks.length; i++) {
      final b = rawBooks[i] as Map<String, dynamic>;
      final bookNum = b['book_number'] as int? ?? (i + 1);
      final testament = (b['testament']?.toString().toLowerCase() == 'new') ? 'NT' : 'OT';
      final rawChapters = b['chapters'] as List<dynamic>? ?? [];
      final bookId = bookIdCounter++;

      final book = Book(
        id: bookId,
        translationId: 2,
        bookNumber: bookNum,
        name: b['book_name_am'] as String? ?? 'መጽሐፍ $bookNum',
        shortName: b['book_short_name_am'] as String? ?? '',
        nameEn: b['book_name_en'] as String? ?? '',
        testament: testament,
        orderIndex: bookNum,
        totalChapters: rawChapters.length,
      );
      books.add(book);

      for (final chObj in rawChapters) {
        final chNum = chObj['chapter'] as int? ?? 1;
        final sections = chObj['sections'] as List<dynamic>? ?? [];
        final verseList = <Verse>[];
        final headingList = <SectionHeading>[];

        for (final sec in sections) {
          final title = sec['title'] as String? ?? '';
          final secVerses = sec['verses'] as List<dynamic>? ?? [];

          if (title.isNotEmpty && secVerses.isNotEmpty) {
            final firstVerseNum = secVerses[0]['verse'] as int? ?? 1;
            headingList.add(SectionHeading(
              id: bookId * 1000 + chNum * 50 + headingList.length,
              bookId: bookId,
              chapter: chNum,
              verse: firstVerseNum,
              title: title,
            ));
          }

          for (final vObj in secVerses) {
            final vNum = vObj['verse'] as int? ?? 1;
            final vText = vObj['text']?.toString().trim() ?? '';
            if (vText.isNotEmpty) {
              final normalized = GeezNormalizer.normalize(vText);
              verseList.add(Verse(
                id: bookId * 100000 + chNum * 1000 + vNum,
                bookId: bookId,
                chapter: chNum,
                verse: vNum,
                text: vText,
                textNormalized: normalized,
              ));

              searchList.add({
                'id': bookId * 100000 + chNum * 1000 + vNum,
                'book_id': bookId,
                'book_number': bookNum,
                'book_name': book.name,
                'testament': book.testament,
                'chapter': chNum,
                'verse': vNum,
                'text': vText,
                'text_normalized': normalized,
              });
            }
          }
        }

        _versesCache['${bookId}_$chNum'] = verseList;
        if (headingList.isNotEmpty) {
          _headingsCache['${bookId}_$chNum'] = headingList;
        }
      }
    }

    _booksByTranslation[2] = books;
    _searchIndex[2] = searchList;
  }

  Future<void> _loadKjvBible() async {
    final jsonStr = await rootBundle.loadString('assets/data/kjv.json');
    final rawBooks = json.decode(jsonStr) as List<dynamic>;

    final books = <Book>[];
    final searchList = <Map<String, dynamic>>[];
    int bookIdCounter = 300;

    for (int i = 0; i < rawBooks.length; i++) {
      final b = rawBooks[i] as Map<String, dynamic>;
      final bookNum = i + 1;
      final testament = bookNum <= 39 ? 'OT' : 'NT';
      final chapters = b['chapters'] as List<dynamic>? ?? [];
      final bookId = bookIdCounter++;
      final englishName = CanonicalBookMap.kjvEnglishNames[bookNum] ?? (b['name'] as String? ?? 'Book $bookNum');

      final book = Book(
        id: bookId,
        translationId: 3,
        bookNumber: bookNum,
        name: englishName,
        shortName: b['abbrev'] as String? ?? '',
        nameEn: englishName,
        testament: testament,
        orderIndex: bookNum,
        totalChapters: chapters.length,
      );
      books.add(book);

      for (int cIdx = 0; cIdx < chapters.length; cIdx++) {
        final chNum = cIdx + 1;
        final rawVerses = chapters[cIdx] as List<dynamic>? ?? [];
        final verseList = <Verse>[];

        for (int vIdx = 0; vIdx < rawVerses.length; vIdx++) {
          final vText = rawVerses[vIdx]?.toString().trim() ?? '';
          if (vText.isNotEmpty) {
            final vNum = vIdx + 1;
            verseList.add(Verse(
              id: bookId * 100000 + chNum * 1000 + vNum,
              bookId: bookId,
              chapter: chNum,
              verse: vNum,
              text: vText,
              textNormalized: vText.toLowerCase(),
            ));

            searchList.add({
              'id': bookId * 100000 + chNum * 1000 + vNum,
              'book_id': bookId,
              'book_number': bookNum,
              'book_name': book.name,
              'testament': book.testament,
              'chapter': chNum,
              'verse': vNum,
              'text': vText,
              'text_normalized': vText.toLowerCase(),
            });
          }
        }
        _versesCache['${bookId}_$chNum'] = verseList;
      }
    }

    _booksByTranslation[3] = books;
    _searchIndex[3] = searchList;
  }

  // --- Read API ---

  Future<List<Translation>> getTranslations() async {
    await ensureInitialized();
    return _translations;
  }

  Future<List<Book>> getBooks({
    required int translationId,
    String? testament,
  }) async {
    await ensureInitialized();
    final list = _booksByTranslation[translationId] ?? [];
    if (testament == null || testament.isEmpty) return list;
    return list.where((b) => b.testament.toUpperCase() == testament.toUpperCase()).toList();
  }

  Future<Book?> getBookById(int bookId) async {
    await ensureInitialized();
    for (final books in _booksByTranslation.values) {
      for (final b in books) {
        if (b.id == bookId) return b;
      }
    }
    return null;
  }

  Future<Book?> getBookByNumber(int translationId, int bookNumber) async {
    await ensureInitialized();
    final books = _booksByTranslation[translationId] ?? [];
    for (final b in books) {
      if (b.bookNumber == bookNumber) return b;
    }
    return null;
  }

  Future<List<Verse>> getVerses({
    required int bookId,
    required int chapter,
  }) async {
    await ensureInitialized();
    final baseVerses = _versesCache['${bookId}_$chapter'] ?? [];
    if (baseVerses.isEmpty) return [];

    // Annotations from SharedPreferences
    final bookmarks = await _getStoredBookmarks();
    final highlights = await _getStoredHighlights();
    final notes = await _getStoredNotes();

    return baseVerses.map((v) {
      bool isBookmarked = false;
      String? highlightColor;
      String? note;

      final startV = v.verse;
      final endV = v.verseEnd ?? v.verse;
      for (int vn = startV; vn <= endV; vn++) {
        final key = '${v.bookId}_${v.chapter}_$vn';
        if (bookmarks.containsKey(key)) isBookmarked = true;
        if (highlights.containsKey(key)) highlightColor = highlights[key];
        if (notes.containsKey(key)) note = notes[key];
      }

      return v.copyWith(
        isBookmarked: isBookmarked,
        highlightColor: highlightColor,
        note: note,
      );
    }).toList();
  }

  Future<List<SectionHeading>> getSectionHeadings({
    required int bookId,
    required int chapter,
  }) async {
    await ensureInitialized();
    return _headingsCache['${bookId}_$chapter'] ?? [];
  }

  Future<List<Map<String, dynamic>>> searchVerses({
    required String query,
    required int translationId,
    int? bookId,
    int limit = 50,
    int offset = 0,
  }) async {
    await ensureInitialized();
    if (query.trim().isEmpty) return [];

    final normalizedQuery = GeezNormalizer.normalize(query);
    final terms = normalizedQuery.split(' ').where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty) return [];

    final indexList = _searchIndex[translationId] ?? [];
    final matches = <Map<String, dynamic>>[];

    for (final item in indexList) {
      if (bookId != null && item['book_id'] != bookId) continue;

      final normText = item['text_normalized'] as String? ?? '';
      bool allTermsMatch = true;
      for (final term in terms) {
        if (!normText.contains(term)) {
          allTermsMatch = false;
          break;
        }
      }

      if (allTermsMatch) {
        matches.add(item);
        if (matches.length >= (offset + limit)) break;
      }
    }

    if (offset >= matches.length) return [];
    return matches.sublist(offset, matches.length.clamp(0, offset + limit));
  }

  Future<Map<String, String>> getParallelVerseTexts({
    required int bookNumber,
    required int chapter,
    required int verse,
    int? sourceTranslationId,
  }) async {
    await ensureInitialized();
    final results = <String, String>{};
    final srcId = sourceTranslationId ?? 2;
    final canonId = CanonicalBookMap.getCanonicalId(srcId, bookNumber);

    for (final trans in _translations) {
      int? targetBookNum = bookNumber;
      if (canonId.isNotEmpty) {
        targetBookNum = CanonicalBookMap.getBookNumber(trans.id, canonId);
      }
      if (targetBookNum == null) continue;

      final book = await getBookByNumber(trans.id, targetBookNum);
      if (book != null) {
        final safeChapter = chapter.clamp(1, book.totalChapters);
        final verses = await getVerses(bookId: book.id, chapter: safeChapter);
        final match = verses.where((v) =>
            v.verse == verse ||
            (v.verseEnd != null && verse >= v.verse && verse <= v.verseEnd!)).firstOrNull;
        if (match != null && match.text.trim().isNotEmpty) {
          results[trans.name] = match.text;
        }
      }
    }
    return results;
  }

  // --- User Annotations (Persistent via SharedPreferences) ---

  Future<Map<String, bool>> _getStoredBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_bookmarks_map') ?? '{}';
    final map = json.decode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as bool));
  }

  Future<Map<String, String>> _getStoredHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_highlights_map') ?? '{}';
    final map = json.decode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<Map<String, String>> _getStoredNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_notes_map') ?? '{}';
    final map = json.decode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<bool> toggleBookmark({
    required int bookId,
    required int chapter,
    required int verse,
    String translationCode = 'amh_1954',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await _getStoredBookmarks();
    final key = '${bookId}_${chapter}_$verse';

    final willBookmark = !bookmarks.containsKey(key);
    if (willBookmark) {
      bookmarks[key] = true;
    } else {
      bookmarks.remove(key);
    }

    await prefs.setString('user_bookmarks_map', json.encode(bookmarks));
    return willBookmark;
  }

  Future<void> setHighlight({
    required int bookId,
    required int chapter,
    required int verse,
    required String colorHex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final highlights = await _getStoredHighlights();
    final key = '${bookId}_${chapter}_$verse';
    highlights[key] = colorHex;
    await prefs.setString('user_highlights_map', json.encode(highlights));
  }

  Future<void> removeHighlight({
    required int bookId,
    required int chapter,
    required int verse,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final highlights = await _getStoredHighlights();
    final key = '${bookId}_${chapter}_$verse';
    highlights.remove(key);
    await prefs.setString('user_highlights_map', json.encode(highlights));
  }

  Future<void> saveNote({
    required int bookId,
    required int chapter,
    required int verse,
    required String noteText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await _getStoredNotes();
    final key = '${bookId}_${chapter}_$verse';

    if (noteText.trim().isEmpty) {
      notes.remove(key);
    } else {
      notes[key] = noteText.trim();
    }
    await prefs.setString('user_notes_map', json.encode(notes));
  }

  Future<List<BookmarkItem>> getBookmarks() async {
    final bookmarks = await _getStoredBookmarks();
    final list = <BookmarkItem>[];
    int counter = 1;

    for (final entry in bookmarks.entries) {
      final parts = entry.key.split('_');
      if (parts.length == 3) {
        final bId = int.tryParse(parts[0]) ?? 0;
        final ch = int.tryParse(parts[1]) ?? 0;
        final vNum = int.tryParse(parts[2]) ?? 0;

        final book = await getBookById(bId);
        final verses = _versesCache['${bId}_$ch'] ?? [];
        final v = verses.firstWhere(
            (x) => x.verse == vNum || (x.verseEnd != null && vNum >= x.verse && vNum <= x.verseEnd!),
            orElse: () => Verse(id: 0, bookId: bId, chapter: ch, verse: vNum, text: ''));

        if (book != null) {
          list.add(BookmarkItem(
            id: counter++,
            bookId: bId,
            bookName: book.name,
            chapter: ch,
            verse: vNum,
            verseText: v.text,
            translationCode: 'amh_1954',
            createdAt: DateTime.now(),
          ));
        }
      }
    }
    return list;
  }

  Future<List<HighlightItem>> getHighlights() async {
    final highlights = await _getStoredHighlights();
    final list = <HighlightItem>[];
    int counter = 1;

    for (final entry in highlights.entries) {
      final parts = entry.key.split('_');
      if (parts.length == 3) {
        final bId = int.tryParse(parts[0]) ?? 0;
        final ch = int.tryParse(parts[1]) ?? 0;
        final vNum = int.tryParse(parts[2]) ?? 0;

        final book = await getBookById(bId);
        final verses = _versesCache['${bId}_$ch'] ?? [];
        final v = verses.firstWhere(
            (x) => x.verse == vNum || (x.verseEnd != null && vNum >= x.verse && vNum <= x.verseEnd!),
            orElse: () => Verse(id: 0, bookId: bId, chapter: ch, verse: vNum, text: ''));

        if (book != null) {
          list.add(HighlightItem(
            id: counter++,
            bookId: bId,
            bookName: book.name,
            chapter: ch,
            verse: vNum,
            verseText: v.text,
            colorHex: entry.value,
            createdAt: DateTime.now(),
          ));
        }
      }
    }
    return list;
  }

  Future<List<NoteItem>> getNotes() async {
    final notes = await _getStoredNotes();
    final list = <NoteItem>[];
    int counter = 1;

    for (final entry in notes.entries) {
      final parts = entry.key.split('_');
      if (parts.length == 3) {
        final bId = int.tryParse(parts[0]) ?? 0;
        final ch = int.tryParse(parts[1]) ?? 0;
        final vNum = int.tryParse(parts[2]) ?? 0;

        final book = await getBookById(bId);
        final verses = _versesCache['${bId}_$ch'] ?? [];
        final v = verses.firstWhere(
            (x) => x.verse == vNum || (x.verseEnd != null && vNum >= x.verse && vNum <= x.verseEnd!),
            orElse: () => Verse(id: 0, bookId: bId, chapter: ch, verse: vNum, text: ''));

        if (book != null) {
          list.add(NoteItem(
            id: counter++,
            bookId: bId,
            bookName: book.name,
            chapter: ch,
            verse: vNum,
            verseText: v.text,
            noteText: entry.value,
            updatedAt: DateTime.now(),
          ));
        }
      }
    }
    return list;
  }

  Future<Map<String, int>> restoreBackup(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    int bookmarksAdded = 0;
    int highlightsAdded = 0;
    int notesAdded = 0;

    // Restore bookmarks
    if (data['bookmarks'] is List) {
      final bookmarks = await _getStoredBookmarks();
      for (final item in data['bookmarks']) {
        if (item is Map) {
          final bId = item['book_id'];
          final ch = item['chapter'];
          final v = item['verse'];
          if (bId != null && ch != null && v != null) {
            bookmarks['${bId}_${ch}_$v'] = true;
            bookmarksAdded++;
          }
        }
      }
      await prefs.setString('user_bookmarks_map', json.encode(bookmarks));
    }

    // Restore highlights
    if (data['highlights'] is List) {
      final highlights = await _getStoredHighlights();
      for (final item in data['highlights']) {
        if (item is Map) {
          final bId = item['book_id'];
          final ch = item['chapter'];
          final v = item['verse'];
          final color = item['color_hex']?.toString() ?? '#FFD54F';
          if (bId != null && ch != null && v != null) {
            highlights['${bId}_${ch}_$v'] = color;
            highlightsAdded++;
          }
        }
      }
      await prefs.setString('user_highlights_map', json.encode(highlights));
    }

    // Restore notes
    if (data['notes'] is List) {
      final notes = await _getStoredNotes();
      for (final item in data['notes']) {
        if (item is Map) {
          final bId = item['book_id'];
          final ch = item['chapter'];
          final v = item['verse'];
          final text = item['note_text']?.toString() ?? '';
          if (bId != null && ch != null && v != null && text.trim().isNotEmpty) {
            notes['${bId}_${ch}_$v'] = text.trim();
            notesAdded++;
          }
        }
      }
      await prefs.setString('user_notes_map', json.encode(notes));
    }

    return {
      'bookmarks': bookmarksAdded,
      'highlights': highlightsAdded,
      'notes': notesAdded,
    };
  }

  Future<Map<String, dynamic>?> getDailyVerse(int translationId) async {
    await ensureInitialized();
    final list = _searchIndex[translationId] ?? [];
    if (list.isEmpty) return null;

    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final index = (dayOfYear * 13) % list.length;
    return list[index];
  }
}
