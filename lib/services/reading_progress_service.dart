import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class ReadingProgressState {
  final int currentStreak;
  final int longestStreak;
  final int totalChaptersRead;
  final int chaptersReadToday;
  final String? lastReadDate;
  final Set<String> readChapters;
  final Set<String> todayReadChapters;
  final Set<String> activeDates;

  const ReadingProgressState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalChaptersRead = 0,
    this.chaptersReadToday = 0,
    this.lastReadDate,
    this.readChapters = const {},
    this.todayReadChapters = const {},
    this.activeDates = const {},
  });

  bool isChapterRead(int bookNumber, int chapter) =>
      readChapters.contains('${bookNumber}_$chapter');

  bool isChapterReadToday(int bookNumber, int chapter, {String? canonicalId}) {
    final key = (canonicalId != null && canonicalId.isNotEmpty)
        ? '${canonicalId}_$chapter'
        : '${bookNumber}_$chapter';
    return todayReadChapters.contains(key);
  }

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
  static const _keyTodayChapters = 'reading_progress_today_chapters_v2';

  static final ReadingProgressService instance = ReadingProgressService._();
  ReadingProgressService._();

  static String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _buildTodayChapterKey(int bookNumber, int chapter, String? canonicalId) {
    if (canonicalId != null && canonicalId.isNotEmpty) {
      return '${canonicalId}_$chapter';
    }
    return '${bookNumber}_$chapter';
  }

  Future<ReadingProgressState> loadState({DateTime? nowOverride}) async {
    final prefs = await SharedPreferences.getInstance();
    final readList = prefs.getStringList(_keyReadChapters) ?? [];
    final activeList = prefs.getStringList(_keyActiveDates) ?? [];
    final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    final lastReadDate = prefs.getString(_keyLastReadDate);
    final storedTodayChapters = prefs.getStringList(_keyTodayChapters);

    final now = nowOverride ?? DateTime.now();
    final todayStr = _formatDate(now);
    final yesterdayStr = _formatDate(now.subtract(const Duration(days: 1)));

    int calculatedStreak = currentStreak;
    Set<String> todayChaptersSet = <String>{};

    if (lastReadDate != null && lastReadDate != todayStr) {
      if (lastReadDate != yesterdayStr) {
        calculatedStreak = 0;
      }
      if (storedTodayChapters != null && storedTodayChapters.isNotEmpty) {
        await prefs.setStringList(_keyTodayChapters, const []);
        await prefs.setInt(_keyTodayCount, 0);
      }
    } else if (lastReadDate == todayStr) {
      if (storedTodayChapters != null) {
        todayChaptersSet = storedTodayChapters.toSet();
      } else {
        // Clear any legacy inflated scroll count from before unique chapter tracking
        await prefs.setStringList(_keyTodayChapters, const []);
        await prefs.setInt(_keyTodayCount, 0);
      }
    }

    return ReadingProgressState(
      currentStreak: calculatedStreak,
      longestStreak: longestStreak,
      totalChaptersRead: readList.length,
      chaptersReadToday: todayChaptersSet.length,
      lastReadDate: lastReadDate,
      readChapters: readList.toSet(),
      todayReadChapters: todayChaptersSet,
      activeDates: activeList.toSet(),
    );
  }

  Future<ReadingProgressState> markChapterRead(
    int bookNumber,
    int chapter, {
    String? canonicalId,
    DateTime? nowOverride,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final readSet = (prefs.getStringList(_keyReadChapters) ?? []).toSet();
    final activeSet = (prefs.getStringList(_keyActiveDates) ?? []).toSet();
    int currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
    int longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    final lastReadDate = prefs.getString(_keyLastReadDate);
    final storedTodayChapters = prefs.getStringList(_keyTodayChapters) ?? [];

    final now = nowOverride ?? DateTime.now();
    final todayStr = _formatDate(now);
    final yesterdayStr = _formatDate(now.subtract(const Duration(days: 1)));

    final chapterKey = '${bookNumber}_$chapter';
    final todayChapterKey = _buildTodayChapterKey(bookNumber, chapter, canonicalId);
    final bool isSameDay = lastReadDate == todayStr;

    final Set<String> todayChapters = isSameDay ? storedTodayChapters.toSet() : <String>{};

    // Guard against redundant scroll-tick writes when chapter was already counted today
    if (isSameDay && todayChapters.contains(todayChapterKey) && readSet.contains(chapterKey)) {
      return ReadingProgressState(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        totalChaptersRead: readSet.length,
        chaptersReadToday: todayChapters.length,
        lastReadDate: todayStr,
        readChapters: readSet,
        todayReadChapters: todayChapters,
        activeDates: activeSet,
      );
    }

    readSet.add(chapterKey);
    todayChapters.add(todayChapterKey);
    activeSet.add(todayStr);

    if (lastReadDate == null) {
      currentStreak = 1;
    } else if (lastReadDate == todayStr) {
      if (currentStreak == 0) currentStreak = 1;
    } else if (lastReadDate == yesterdayStr) {
      currentStreak += 1;
    } else {
      currentStreak = 1;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    final int todayCount = todayChapters.length;

    // Keep active dates bounded to last 180 days
    if (activeSet.length > 180) {
      final sorted = activeSet.toList()..sort();
      activeSet.clear();
      activeSet.addAll(sorted.skip(sorted.length - 180));
    }

    await prefs.setStringList(_keyReadChapters, readSet.toList());
    await prefs.setStringList(_keyTodayChapters, todayChapters.toList());
    await prefs.setStringList(_keyActiveDates, activeSet.toList());
    await prefs.setInt(_keyCurrentStreak, currentStreak);
    await prefs.setInt(_keyLongestStreak, longestStreak);
    await prefs.setString(_keyLastReadDate, todayStr);
    await prefs.setInt(_keyTodayCount, todayCount);

    return ReadingProgressState(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalChaptersRead: readSet.length,
      chaptersReadToday: todayCount,
      lastReadDate: todayStr,
      readChapters: readSet,
      todayReadChapters: todayChapters,
      activeDates: activeSet,
    );
  }
}
