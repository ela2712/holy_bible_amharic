import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/core/utils/canonical_book_map.dart';
import 'package:holy_bible_amharic/data/reading_plans_data.dart';
import 'package:holy_bible_amharic/providers/reading_plan_session_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Reading Plan Canonical Mapping Tests', () {
    test('Matthew canonical code matches between 66-canon (40) and Orthodox 81 (55)', () {
      final canon66 = CanonicalBookMap.getCanonicalId(1, 40);
      final canon81 = CanonicalBookMap.getCanonicalId(2, 55);
      final canonKjv = CanonicalBookMap.getCanonicalId(3, 40);

      expect(canon66, 'MAT');
      expect(canon81, 'MAT');
      expect(canonKjv, 'MAT');
      expect(canon66, equals(canon81));
    });

    test('Genesis canonical code matches between 66-canon (1) and Orthodox 81 (1)', () {
      final canon66 = CanonicalBookMap.getCanonicalId(1, 1);
      final canon81 = CanonicalBookMap.getCanonicalId(2, 1);

      expect(canon66, 'GEN');
      expect(canon81, 'GEN');
      expect(canon66, equals(canon81));
    });

    test('Revelation canonical code matches between 66-canon (66) and Orthodox 81 (81)', () {
      final canon66 = CanonicalBookMap.getCanonicalId(1, 66);
      final canon81 = CanonicalBookMap.getCanonicalId(2, 81);

      expect(canon66, 'REV');
      expect(canon81, 'REV');
      expect(canon66, equals(canon81));
    });
  });

  group('Reading Plan Session Tracking Tests', () {
    test('markChapterCompleted tracks multi-chapter progress and auto-completes day', () async {
      final notifier = ReadingPlanSessionNotifier();
      await notifier.loadAll();

      const testPlanId = 'test_gospels_30';
      const day = 1;
      const totalChapters = 3;

      // 1. Mark chapter 1
      final completedDay1 = await notifier.markChapterCompleted(
        planId: testPlanId,
        day: day,
        chapter: 1,
        totalChaptersInDay: totalChapters,
      );
      expect(completedDay1, isFalse);
      expect(notifier.state.isChapterCompleted(testPlanId, day, 1), isTrue);
      expect(notifier.state.isChapterCompleted(testPlanId, day, 2), isFalse);
      expect(notifier.state.getReadChaptersCount(testPlanId, day), 1);
      expect(notifier.state.isDayCompleted(testPlanId, day), isFalse);

      // 2. Mark chapter 2
      final completedDay2 = await notifier.markChapterCompleted(
        planId: testPlanId,
        day: day,
        chapter: 2,
        totalChaptersInDay: totalChapters,
      );
      expect(completedDay2, isFalse);
      expect(notifier.state.getReadChaptersCount(testPlanId, day), 2);
      expect(notifier.state.isDayCompleted(testPlanId, day), isFalse);

      // 3. Mark chapter 3 (All chapters read -> auto-completes day)
      final completedDay3 = await notifier.markChapterCompleted(
        planId: testPlanId,
        day: day,
        chapter: 3,
        totalChaptersInDay: totalChapters,
      );
      expect(completedDay3, isTrue);
      expect(notifier.state.getReadChaptersCount(testPlanId, day), 3);
      expect(notifier.state.isDayCompleted(testPlanId, day), isTrue);
    });

    test('startReadingSession persists active session and restores on reload', () async {
      final notifier = ReadingPlanSessionNotifier();
      await notifier.loadAll();

      final plan = ReadingPlansData.allPlans.first;
      await notifier.startReadingSession(plan, 5);

      expect(notifier.state.activeSessionPlan?.id, plan.id);
      expect(notifier.state.activeSessionDay, 5);

      // Create new notifier simulating app restart
      final newNotifier = ReadingPlanSessionNotifier();
      await newNotifier.loadAll();

      expect(newNotifier.state.activeSessionPlan?.id, plan.id);
      expect(newNotifier.state.activeSessionDay, 5);
      expect(newNotifier.state.activePassage?.day, 5);
    });

    test('completing final day stops counting, records 100% completion, and clears session', () async {
      final notifier = ReadingPlanSessionNotifier();
      await notifier.loadAll();

      final plan = ReadingPlansData.allPlans.first; // 365 days
      // Jump to last day
      await notifier.startReadingSession(plan, plan.totalDays);
      expect(notifier.state.activeSessionDay, plan.totalDays);

      // Complete last day
      final next = await notifier.completeActiveDayAndGetNext();
      // Must be null because plan is fully completed
      expect(next, isNull);
      // Active session is completed and cleared (does not count past totalDays to day 366)
      expect(notifier.state.activeSessionPlan, isNull);
      expect(notifier.state.activeSessionDay, isNull);
      expect(notifier.state.isDayCompleted(plan.id, plan.totalDays), isTrue);
    });

    test('resetPlan clears completed days, read chapters, and rewinds active session to Day 1', () async {
      final notifier = ReadingPlanSessionNotifier();
      await notifier.loadAll();

      final plan = ReadingPlansData.allPlans.first;
      await notifier.startReadingSession(plan, 12);
      await notifier.markChapterCompleted(
        planId: plan.id,
        day: 12,
        chapter: 1,
        totalChaptersInDay: 2,
      );
      await notifier.toggleDayComplete(plan.id, 1);
      await notifier.toggleDayComplete(plan.id, 2);

      expect(notifier.state.completedDaysByPlan[plan.id]?.length, 2);
      expect(notifier.state.getReadChaptersCount(plan.id, 12), 1);
      expect(notifier.state.activeSessionDay, 12);

      // Execute resetPlan
      await notifier.resetPlan(plan.id);

      expect(notifier.state.completedDaysByPlan[plan.id]?.isEmpty, isTrue);
      expect(notifier.state.getReadChaptersCount(plan.id, 12), 0);
      expect(notifier.state.activeSessionDay, 1);

      // Verify persistence after reload
      final reloadedNotifier = ReadingPlanSessionNotifier();
      await reloadedNotifier.loadAll();
      expect(reloadedNotifier.state.completedDaysByPlan[plan.id]?.isEmpty, isTrue);
      expect(reloadedNotifier.state.activeSessionDay, 1);
    });
  });
}
