import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class ReadingProgressState {
  final int currentStreak;
  final int longestStreak;
  final int totalChaptersRead;
  final int chaptersReadToday;
  final String? lastReadDate;
  final Set<String> readChapters;
  final Set<String> activeDates;

  const ReadingProgressState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalChaptersRead = 0,
    this.chaptersReadToday = 0,
    this.lastReadDate,
    this.readChapters = const {},
    this.activeDates = const {},
  });

  bool isChapterRead(int bookNumber, int chapter) =>
      readChapters.contains('${bookNumber}_$chapter');

  int getChaptersReadForBook(int bookNumber) {
    final prefix = '${bookNumber}_';
    return readChapters.where((c) => c.startsWith(prefix)).length;
  }

  double getBookProgress(int bookNumber, int totalChapters) {
    if (totalChapters <= 0) return 0.0;
    final count = getChaptersReadForBook(bookNumber);
    return (count / totalChapters).clamp(0.0, 1.0);
  }

  bool isBookCompleted(int bookNumber, int totalChapters) {
    if (totalChapters <= 0) return false;
    return getChaptersReadForBook(bookNumber) >= totalChapters;
  }

  int getCompletedBooksCount(List<Book> books) {
    return books.where((b) => isBookCompleted(b.bookNumber, b.totalChapters)).length;
  }

  bool wasActiveOn(DateTime date) {
    final dateStr = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return activeDates.contains(dateStr);
  }
}

class ReadingProgressService {
  static const _keyReadChapters = 'reading_progress_read_chapters_v1';
  static const _keyCurrentStreak = 'reading_progress_current_streak';
  static const _keyLongestStreak = 'reading_progress_longest_streak';
  static const _keyLastReadDate = 'reading_progress_last_read_date';
  static const _keyActiveDates = 'reading_progress_active_dates_v1';
  static const _keyTodayCount = 'reading_progress_today_chapters_count';

  static final ReadingProgressService instance = ReadingProgressService._();
  ReadingProgressService._();

  static String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<ReadingProgressState> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final readList = prefs.getStringList(_keyReadChapters) ?? [];
    final activeList = prefs.getStringList(_keyActiveDates) ?? [];
    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    final lastReadDate = prefs.getString(_keyLastReadDate);
    final todayCount = prefs.getInt(_keyTodayCount) ?? 0;

    final todayStr = _formatDate(DateTime.now());
    final yesterdayStr = _formatDate(DateTime.now().subtract(const Duration(days: 1)));

    // Check if streak was broken (last read date was before yesterday)
    int calculatedStreak = currentStreak;
    int calculatedTodayCount = todayCount;
    if (lastReadDate != null && lastReadDate != todayStr) {
      calculatedTodayCount = 0;
      if (lastReadDate != yesterdayStr) {
        calculatedStreak = 0;
      }
    }

    return ReadingProgressState(
      currentStreak: calculatedStreak,
      longestStreak: longestStreak,
      totalChaptersRead: readList.length,
      chaptersReadToday: calculatedTodayCount,
      lastReadDate: lastReadDate,
      readChapters: readList.toSet(),
      activeDates: activeList.toSet(),
    );
  }

  Future<ReadingProgressState> markChapterRead(int bookNumber, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final readList = (prefs.getStringList(_keyReadChapters) ?? []).toSet();
    final activeList = (prefs.getStringList(_keyActiveDates) ?? []).toSet();
    int currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    int longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    final lastReadDate = prefs.getString(_keyLastReadDate);
    int todayCount = prefs.getInt(_keyTodayCount) ?? 0;

    final now = DateTime.now();
    final todayStr = _formatDate(now);
    final yesterdayStr = _formatDate(now.subtract(const Duration(days: 1)));

    // Add chapter to read set
    final chapterKey = '${bookNumber}_$chapter';
    readList.add(chapterKey);

    // Add today to active dates
    activeList.add(todayStr);

    // Update streak logic
    if (lastReadDate == null) {
      currentStreak = 1;
      todayCount = 1;
    } else if (lastReadDate == todayStr) {
      todayCount += 1;
    } else if (lastReadDate == yesterdayStr) {
      currentStreak += 1;
      todayCount = 1;
    } else {
      // Missed one or more days
      currentStreak = 1;
      todayCount = 1;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // Keep active dates bounded to last 180 days
    if (activeList.length > 180) {
      final sorted = activeList.toList()..sort();
      activeList.clear();
      activeList.addAll(sorted.skip(sorted.length - 180));
    }

    await prefs.setStringList(_keyReadChapters, readList.toList());
    await prefs.setStringList(_keyActiveDates, activeList.toList());
    await prefs.setInt(_keyCurrentStreak, currentStreak);
    await prefs.setInt(_keyLongestStreak, longestStreak);
    await prefs.setString(_keyLastReadDate, todayStr);
    await prefs.setInt(_keyTodayCount, todayCount);

    return ReadingProgressState(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalChaptersRead: readList.length,
      chaptersReadToday: todayCount,
      lastReadDate: todayStr,
      readChapters: readList,
      activeDates: activeList,
    );
  }
}
