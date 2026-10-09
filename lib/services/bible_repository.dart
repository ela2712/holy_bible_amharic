import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../core/utils/geez_normalizer.dart';
import '../models/translation.dart';
import '../models/book.dart';
import '../models/verse.dart';
import '../models/annotation.dart';

class BibleRepository {
  final DatabaseHelper _dbHelper;

  BibleRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db async => await _dbHelper.database;

  /// Fetch available translations
  Future<List<Translation>> getTranslations() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps =
        await db.query('translations', orderBy: 'id ASC');
    return maps.map((m) => Translation.fromMap(m)).toList();
  }

  /// Fetch all books for a specific translation
  Future<List<Book>> getBooks({
    required int translationId,
    String? testament,
  }) async {
    final db = await _db;
    String? whereClause = 'translation_id = ?';
    List<dynamic> whereArgs = [translationId];

    if (testament != null && testament.isNotEmpty) {
      whereClause += ' AND testament = ?';
      whereArgs.add(testament.toUpperCase());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'order_index ASC',
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  /// Fetch a book by ID
  Future<Book?> getBookById(int bookId) async {
    final db = await _db;
    final maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  /// Find matching book in another translation by book number
  Future<Book?> getBookByNumber(int translationId, int bookNumber) async {
    final db = await _db;
    final maps = await db.query(
      'books',
      where: 'translation_id = ? AND book_number = ?',
      whereArgs: [translationId, bookNumber],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  /// Fetch all verses in a chapter, joined with user annotations
  Future<List<Verse>> getVerses({
    required int bookId,
    required int chapter,
  }) async {
    final db = await _db;
    final sql = '''
      SELECT 
        v.id,
        v.book_id,
        v.chapter,
        v.verse,
        v.text,
        v.text_normalized,
        h.color_hex AS highlight_color,
        CASE WHEN b.id IS NOT NULL THEN 1 ELSE 0 END AS is_bookmarked,
        n.note_text
      FROM verses v
      LEFT JOIN highlights h ON h.book_id = v.book_id AND h.chapter = v.chapter AND h.verse = v.verse
      LEFT JOIN bookmarks b ON b.book_id = v.book_id AND b.chapter = v.chapter AND b.verse = v.verse
      LEFT JOIN notes n ON n.book_id = v.book_id AND n.chapter = v.chapter AND n.verse = v.verse
      WHERE v.book_id = ? AND v.chapter = ?
      ORDER BY v.verse ASC
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, [bookId, chapter]);
    return maps.map((m) => Verse.fromMap(m)).toList();
  }

  /// Fetch section headings (subtitles/pericopes) for a chapter
  Future<List<SectionHeading>> getSectionHeadings({
    required int bookId,
    required int chapter,
  }) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'sections',
      where: 'book_id = ? AND chapter = ?',
      whereArgs: [bookId, chapter],
      orderBy: 'verse ASC',
    );
    return maps.map((m) => SectionHeading.fromMap(m)).toList();
  }

  /// Smart Search with Ge'ez Homophone Normalization and Multi-word Queries
  Future<List<Map<String, dynamic>>> searchVerses({
    required String query,
    required int translationId,
    int? bookId,
    int limit = 50,
    int offset = 0,
  }) async {
    if (query.trim().isEmpty) return [];

    final db = await _db;
    final normalizedQuery = GeezNormalizer.normalize(query);
    final terms = normalizedQuery.split(' ').where((t) => t.isNotEmpty).toList();

    if (terms.isEmpty) return [];

    // Build LIKE conditions for every word in query
    final whereConditions = <String>[];
    final whereArgs = <dynamic>[translationId];

    for (final term in terms) {
      whereConditions.add('v.text_normalized LIKE ?');
      whereArgs.add('%$term%');
    }

    String bookFilter = '';
    if (bookId != null) {
      bookFilter = 'AND b.id = ?';
      whereArgs.add(bookId);
    }

    whereArgs.add(limit);
    whereArgs.add(offset);

    final sql = '''
      SELECT 
        v.id,
        v.book_id,
        v.chapter,
        v.verse,
        v.text,
        b.name AS book_name,
        b.book_number
      FROM verses v
      JOIN books b ON b.id = v.book_id
      WHERE b.translation_id = ?
        $bookFilter
        AND (${whereConditions.join(' AND ')})
      ORDER BY b.order_index ASC, v.chapter ASC, v.verse ASC
      LIMIT ? OFFSET ?
    ''';

    return await db.rawQuery(sql, whereArgs);
  }

  /// Toggle bookmark for a verse
  Future<bool> toggleBookmark({
    required int bookId,
    required int chapter,
    required int verse,
    String translationCode = 'amh_1954',
  }) async {
    final db = await _db;
    final existing = await db.query(
      'bookmarks',
      where: 'book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookId, chapter, verse],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        'bookmarks',
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
      return false; // Removed
    } else {
      await db.insert('bookmarks', {
        'book_id': bookId,
        'chapter': chapter,
        'verse': verse,
        'translation_code': translationCode,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true; // Added
    }
  }

  /// Highlight a verse
  Future<void> setHighlight({
    required int bookId,
    required int chapter,
    required int verse,
    required String colorHex,
  }) async {
    final db = await _db;
    await db.delete(
      'highlights',
      where: 'book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookId, chapter, verse],
    );
    await db.insert('highlights', {
      'book_id': bookId,
      'chapter': chapter,
      'verse': verse,
      'color_hex': colorHex,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Remove highlight
  Future<void> removeHighlight({
    required int bookId,
    required int chapter,
    required int verse,
  }) async {
    final db = await _db;
    await db.delete(
      'highlights',
      where: 'book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookId, chapter, verse],
    );
  }

  /// Save or update verse note
  Future<void> saveNote({
    required int bookId,
    required int chapter,
    required int verse,
    required String noteText,
  }) async {
    final db = await _db;
    final trimmed = noteText.trim();
    if (trimmed.isEmpty) {
      await deleteNote(bookId: bookId, chapter: chapter, verse: verse);
      return;
    }

    final existing = await db.query(
      'notes',
      where: 'book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookId, chapter, verse],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'notes',
        {
          'note_text': trimmed,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await db.insert('notes', {
        'book_id': bookId,
        'chapter': chapter,
        'verse': verse,
        'note_text': trimmed,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Delete note
  Future<void> deleteNote({
    required int bookId,
    required int chapter,
    required int verse,
  }) async {
    final db = await _db;
    await db.delete(
      'notes',
      where: 'book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookId, chapter, verse],
    );
  }

  /// Fetch all user bookmarks
  Future<List<BookmarkItem>> getBookmarks() async {
    final db = await _db;
    final sql = '''
      SELECT 
        b.id,
        b.book_id,
        bk.name AS book_name,
        b.chapter,
        b.verse,
        v.text AS verse_text,
        b.translation_code,
        b.created_at
      FROM bookmarks b
      JOIN books bk ON bk.id = b.book_id
      JOIN verses v ON v.book_id = b.book_id AND v.chapter = b.chapter AND v.verse = b.verse
      ORDER BY b.created_at DESC
    ''';
    final maps = await db.rawQuery(sql);
    return maps.map((m) => BookmarkItem.fromMap(m)).toList();
  }

  /// Fetch all user highlights
  Future<List<HighlightItem>> getHighlights() async {
    final db = await _db;
    final sql = '''
      SELECT 
        h.id,
        h.book_id,
        bk.name AS book_name,
        h.chapter,
        h.verse,
        v.text AS verse_text,
        h.color_hex,
        h.created_at
      FROM highlights h
      JOIN books bk ON bk.id = h.book_id
      JOIN verses v ON v.book_id = h.book_id AND v.chapter = h.chapter AND v.verse = h.verse
      ORDER BY h.created_at DESC
    ''';
    final maps = await db.rawQuery(sql);
    return maps.map((m) => HighlightItem.fromMap(m)).toList();
  }

  /// Fetch all user notes
  Future<List<NoteItem>> getNotes() async {
    final db = await _db;
    final sql = '''
      SELECT 
        n.id,
        n.book_id,
        bk.name AS book_name,
        n.chapter,
        n.verse,
        v.text AS verse_text,
        n.note_text,
        n.updated_at
      FROM notes n
      JOIN books bk ON bk.id = n.book_id
      JOIN verses v ON v.book_id = n.book_id AND v.chapter = n.chapter AND v.verse = n.verse
      ORDER BY n.updated_at DESC
    ''';
    final maps = await db.rawQuery(sql);
    return maps.map((m) => NoteItem.fromMap(m)).toList();
  }

  /// Get daily inspirational verse
  Future<Map<String, dynamic>?> getDailyVerse(int translationId) async {
    final db = await _db;
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    
    // Curated beloved Psalms, Proverbs, Gospels offsets
    final offset = (dayOfYear * 7) % 1500;
    final sql = '''
      SELECT 
        v.id,
        v.book_id,
        v.chapter,
        v.verse,
        v.text,
        b.name AS book_name
      FROM verses v
      JOIN books b ON b.id = v.book_id
      WHERE b.translation_id = ?
      LIMIT 1 OFFSET ?
    ''';
    final res = await db.rawQuery(sql, [translationId, offset]);
    if (res.isEmpty) return null;
    return res.first;
  }
}
