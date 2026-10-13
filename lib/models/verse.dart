class Verse {
  final int id;
  final int bookId;
  final int chapter;
  final int verse;
  final int? verseEnd;
  final String text;
  final String? textNormalized;

  // Transient / Joined annotations
  final String? highlightColor; // hex string e.g. '#FFEB3B'
  final bool isBookmarked;
  final String? note;

  const Verse({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.verse,
    this.verseEnd,
    required this.text,
    this.textNormalized,
    this.highlightColor,
    this.isBookmarked = false,
    this.note,
  });

  bool get isMergedRange => verseEnd != null && verseEnd! > verse;

  Verse copyWith({
    int? verseEnd,
    String? highlightColor,
    bool? isBookmarked,
    String? note,
  }) {
    return Verse(
      id: id,
      bookId: bookId,
      chapter: chapter,
      verse: verse,
      verseEnd: verseEnd ?? this.verseEnd,
      text: text,
      textNormalized: textNormalized,
      highlightColor: highlightColor ?? this.highlightColor,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      note: note ?? this.note,
    );
  }

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      verseEnd: map['verse_end'] as int?,
      text: map['text'] as String,
      textNormalized: map['text_normalized'] as String?,
      highlightColor: map['highlight_color'] as String?,
      isBookmarked: (map['is_bookmarked'] as int? ?? 0) > 0,
      note: map['note_text'] as String?,
    );
  }
}

class SectionHeading {
  final int id;
  final int bookId;
  final int chapter;
  final int verse;
  final String title;

  const SectionHeading({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.title,
  });

  factory SectionHeading.fromMap(Map<String, dynamic> map) {
    return SectionHeading(
      id: map['id'] as int,
      bookId: map['book_id'] as int,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      title: map['title'] as String,
    );
  }
}
