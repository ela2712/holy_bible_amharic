class Book {
  final int id;
  final int translationId;
  final int bookNumber;
  final String name;
  final String shortName;
  final String nameEn;
  final String testament; // 'OT' or 'NT'
  final int orderIndex;
  final int totalChapters;

  const Book({
    required this.id,
    required this.translationId,
    required this.bookNumber,
    required this.name,
    required this.shortName,
    required this.nameEn,
    required this.testament,
    required this.orderIndex,
    required this.totalChapters,
  });

  bool get isOldTestament => testament.toUpperCase() == 'OT';
  bool get isNewTestament => testament.toUpperCase() == 'NT';

  String getDisplayName(bool isEnglish) =>
      (isEnglish && nameEn.isNotEmpty) ? nameEn : name;

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      translationId: map['translation_id'] as int,
      bookNumber: map['book_number'] as int,
      name: map['name'] as String,
      shortName: map['short_name'] as String? ?? '',
      nameEn: map['name_en'] as String? ?? '',
      testament: map['testament'] as String? ?? 'OT',
      orderIndex: map['order_index'] as int? ?? 0,
      totalChapters: map['total_chapters'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'translation_id': translationId,
      'book_number': bookNumber,
      'name': name,
      'short_name': shortName,
      'name_en': nameEn,
      'testament': testament,
      'order_index': orderIndex,
      'total_chapters': totalChapters,
    };
  }
}
