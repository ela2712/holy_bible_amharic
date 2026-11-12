import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/services/reading_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReadingProgressService Daily Count & Streak Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Repeated scroll/mark calls on the same chapter do not inflate chaptersReadToday', () async {
      final service = ReadingProgressService.instance;
      final today = DateTime(2026, 11, 10, 12, 0);

      // Simulate 30 scroll events firing on Genesis Chapter 1 today
      late ReadingProgressState state;
      for (int i = 0; i < 30; i++) {
        state = await service.markChapterRead(1, 1, canonicalId: 'GEN', nowOverride: today);
      }

      expect(state.chaptersReadToday, 1);
      expect(state.totalChaptersRead, 1);
      expect(state.currentStreak, 1);
      expect(state.isChapterReadToday(1, 1, canonicalId: 'GEN'), isTrue);
    });

    test('Same chapter across translations (different bookNumber, same canonicalId) counts once today', () async {
      final service = ReadingProgressService.instance;
      final today = DateTime(2026, 11, 10, 12, 0);

      // Jonah Chapter 1 in 66-book canon (book 32) and 81-book canon (book 48)
      await service.markChapterRead(32, 1, canonicalId: 'JON', nowOverride: today);
      final state = await service.markChapterRead(48, 1, canonicalId: 'JON', nowOverride: today);

      expect(state.chaptersReadToday, 1);
      expect(state.isChapterRead(32, 1), isTrue);
      expect(state.isChapterRead(48, 1), isTrue);
    });

    test('Reading distinct chapters increments chaptersReadToday accurately and increments streak next day', () async {
      final service = ReadingProgressService.instance;
      final day1 = DateTime(2026, 11, 10, 9, 0);
      final day2 = DateTime(2026, 11, 11, 9, 0);

      await service.markChapterRead(1, 1, canonicalId: 'GEN', nowOverride: day1);
      await service.markChapterRead(1, 2, canonicalId: 'GEN', nowOverride: day1);
      final endOfDay1 = await service.markChapterRead(1, 3, canonicalId: 'GEN', nowOverride: day1);

      expect(endOfDay1.chaptersReadToday, 3);
      expect(endOfDay1.currentStreak, 1);

      // Next day before reading: today count resets to 0, streak stays 1
      final startOfDay2 = await service.loadState(nowOverride: day2);
      expect(startOfDay2.chaptersReadToday, 0);
      expect(startOfDay2.currentStreak, 1);

      // Read 1 chapter on day 2: streak becomes 2, today count becomes 1
      final afterDay2Read = await service.markChapterRead(1, 4, canonicalId: 'GEN', nowOverride: day2);
      expect(afterDay2Read.chaptersReadToday, 1);
      expect(afterDay2Read.currentStreak, 2);
      expect(afterDay2Read.longestStreak, 2);
    });

    test('Legacy inflated today count (without v2 unique chapter list) is sanitized on loadState', () async {
      SharedPreferences.setMockInitialValues({
        'reading_progress_last_read_date': '2026-11-10',
        'reading_progress_today_chapters_count': 27,
        'reading_progress_current_streak': 1,
        'reading_progress_read_chapters_v1': ['1_1'],
      });

      final state = await ReadingProgressService.instance.loadState(
        nowOverride: DateTime(2026, 11, 10, 14, 0),
      );
      expect(state.chaptersReadToday, 0);
      expect(state.currentStreak, 1);
    });
  });
}
