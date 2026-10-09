class BookmarkItem {
  final int id;
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String verseText;
  final String translationCode;
  final DateTime createdAt;

  BookmarkItem({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.verseText,
    required this.translationCode,
    required this.createdAt,
  });

  factory BookmarkItem.fromMap(Map<String, dynamic> map) {
    return BookmarkItem(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      bookName: map['book_name'] as String? ?? '',
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      verseText: map['verse_text'] as String? ?? '',
      translationCode: map['translation_code'] as String? ?? 'amh_1954',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class HighlightItem {
  final int id;
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String verseText;
  final String colorHex;
  final DateTime createdAt;

  HighlightItem({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.verseText,
    required this.colorHex,
    required this.createdAt,
  });

  factory HighlightItem.fromMap(Map<String, dynamic> map) {
    return HighlightItem(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      bookName: map['book_name'] as String? ?? '',
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      verseText: map['verse_text'] as String? ?? '',
      colorHex: map['color_hex'] as String? ?? '#FFEB3B',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class NoteItem {
  final int id;
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String verseText;
  final String noteText;
  final DateTime updatedAt;

  NoteItem({
    required this.id,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.verseText,
    required this.noteText,
    required this.updatedAt,
  });

  factory NoteItem.fromMap(Map<String, dynamic> map) {
    return NoteItem(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      bookName: map['book_name'] as String? ?? '',
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      verseText: map['verse_text'] as String? ?? '',
      noteText: map['note_text'] as String? ?? '',
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
