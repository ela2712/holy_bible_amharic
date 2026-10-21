class DailyReadingPassage {
  final int day;
  final String title;
  final String titleEn;
  final int bookNumber;
  final String bookName;
  final String bookNameEn;
  final int startChapter;
  final int endChapter;
  final String description;
  final String descriptionEn;

  const DailyReadingPassage({
    required this.day,
    required this.title,
    this.titleEn = '',
    required this.bookNumber,
    required this.bookName,
    this.bookNameEn = '',
    required this.startChapter,
    required this.endChapter,
    this.description = '',
    this.descriptionEn = '',
  });

  String getPassageReference(bool isEnglish) {
    String bName = bookName;
    try {
      if (isEnglish && bookNameEn.isNotEmpty) {
        bName = bookNameEn;
      }
    } catch (_) {}

    if (startChapter == endChapter) {
      return isEnglish
          ? '$bName Chapter $startChapter'
          : '$bName ምዕራፍ $startChapter';
    }
    return isEnglish
        ? '$bName Chapters $startChapter–$endChapter'
        : '$bName ምዕራፍ $startChapter - $endChapter';
  }

  String get passageReference => getPassageReference(false);
}

class ReadingPlan {
  final String id;
  final String title;
  final String titleEn;
  final String subtitle;
  final String subtitleEn;
  final String category; // 'ዓመታዊ', 'ጾምና በዓላት', 'ሐዲስ ኪዳን', 'ጥበብና መዝሙር'
  final String categoryEn; // 'Annual', 'Fasts & Feasts', 'New Testament', 'Wisdom & Psalms'
  final int totalDays;
  final String coverIcon; // Icon descriptor
  final String badgeText;
  final String badgeTextEn;
  final List<DailyReadingPassage> passages;

  const ReadingPlan({
    required this.id,
    required this.title,
    this.titleEn = '',
    required this.subtitle,
    this.subtitleEn = '',
    required this.category,
    this.categoryEn = '',
    required this.totalDays,
    required this.coverIcon,
    required this.badgeText,
    this.badgeTextEn = '',
    required this.passages,
  });

  String getDisplayTitle(bool isEnglish) {
    try {
      if (isEnglish && titleEn.isNotEmpty) return titleEn;
    } catch (_) {}
    return title;
  }

  String getDisplaySubtitle(bool isEnglish) {
    try {
      if (isEnglish && subtitleEn.isNotEmpty) return subtitleEn;
    } catch (_) {}
    return subtitle;
  }

  String getDisplayCategory(bool isEnglish) {
    try {
      if (isEnglish && categoryEn.isNotEmpty) return categoryEn;
    } catch (_) {}
    return category;
  }

  String getDisplayBadge(bool isEnglish) {
    try {
      if (isEnglish && badgeTextEn.isNotEmpty) return badgeTextEn;
    } catch (_) {}
    return badgeText;
  }
}
