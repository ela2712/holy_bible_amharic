class DailyReadingPassage {
  final int day;
  final String title;
  final int bookNumber;
  final String bookName;
  final int startChapter;
  final int endChapter;
  final String description;

  const DailyReadingPassage({
    required this.day,
    required this.title,
    required this.bookNumber,
    required this.bookName,
    required this.startChapter,
    required this.endChapter,
    this.description = '',
  });

  String get passageReference {
    if (startChapter == endChapter) {
      return '$bookName ምዕራፍ $startChapter';
    }
    return '$bookName ምዕራፍ $startChapter - $endChapter';
  }
}

class ReadingPlan {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'ዓመታዊ', 'ጾምና በዓላት', 'ሐዲስ ኪዳን', 'ጥበብና መዝሙር'
  final int totalDays;
  final String coverIcon; // Icon descriptor
  final String badgeText;
  final List<DailyReadingPassage> passages;

  const ReadingPlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.totalDays,
    required this.coverIcon,
    required this.badgeText,
    required this.passages,
  });
}
