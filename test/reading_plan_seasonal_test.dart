import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/services/bahire_hasab_service.dart';
import 'package:holy_bible_amharic/providers/reading_plan_session_provider.dart';
import 'package:holy_bible_amharic/data/reading_plans_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EOTC Bahire Hasab Real-Time Date & Season Math Tests', () {
    test('daysBetween correctly computes day differences within same year', () {
      // Meskerem 1 to Meskerem 10 = 9 days
      final d1 = BahireHasabService.createEthiopianDate(2019, 1, 1);
      final d2 = BahireHasabService.createEthiopianDate(2019, 1, 10);
      expect(BahireHasabService.daysBetween(d1, d2), 9);
      expect(BahireHasabService.daysBetween(d2, d1), -9);

      // Tikimt 30 to Hidar 15 = 15 days
      final tikimt30 = BahireHasabService.createEthiopianDate(2019, 2, 30);
      final hidar15 = BahireHasabService.createEthiopianDate(2019, 3, 15);
      expect(BahireHasabService.daysBetween(tikimt30, hidar15), 15);
    });

    test('daysBetween accurately handles leap years (Luke vs other years)', () {
      // 2018 (Mark) has 5 Pagume days (365 total)
      final pagume1_2018 = BahireHasabService.createEthiopianDate(2018, 13, 1);
      final meskerem1_2019 = BahireHasabService.createEthiopianDate(2019, 1, 1);
      // From Pagume 1 to Meskerem 1: Pagume 1, 2, 3, 4, 5 -> 5 days
      expect(BahireHasabService.daysBetween(pagume1_2018, meskerem1_2019), 5);

      // 2019 (Luke) is a leap year with 6 Pagume days (366 total)
      expect(BahireHasabService.isLeapYear(2019), isTrue);
      final pagume1_2019 = BahireHasabService.createEthiopianDate(2019, 13, 1);
      final meskerem1_2020 = BahireHasabService.createEthiopianDate(2020, 1, 1);
      expect(BahireHasabService.daysBetween(pagume1_2019, meskerem1_2020), 6);
    });

    test('getDayOfWeek matches canonical day numbers (1=Monday, 7=Sunday)', () {
      // Today: Oct 29, 2026 Gregorian is Tikimt 19, 2019 Ethiopian (Thursday = 4)
      final dow1 = BahireHasabService.getDayOfWeek(2019, 2, 19);
      expect(dow1, 4);

      // Meskerem 1, 2017 E.C. was Wednesday (3)
      final dow2 = BahireHasabService.getDayOfWeek(2017, 1, 1);
      expect(dow2, 3);
    });
  });

  group('EOTC Seasonal Reading Plans Real-Time Lock & Countdown Tests', () {
    test('Non-seasonal plans (81 Canon, NT, Proverbs) are always unlocked', () {
      final today = BahireHasabService.createEthiopianDate(2019, 2, 30); // Tikimt 30
      final canonicalInfo = BahireHasabService.getFastSeasonInfo('canonical_365', today);
      expect(canonicalInfo.isSeasonal, isFalse);
      expect(canonicalInfo.isUnlocked, isTrue);

      final ntInfo = BahireHasabService.getFastSeasonInfo('nt_90', today);
      expect(ntInfo.isSeasonal, isFalse);
      expect(ntInfo.isUnlocked, isTrue);
    });

    test('Fast of Assumption (Filseta) locks with countdown before Nehase 1', () {
      // On Tikimt 30, 2019 (month 2, day 30), Filseta is in Nehase (month 12, day 1)
      final today = BahireHasabService.createEthiopianDate(2019, 2, 30);
      final filsetaInfo = BahireHasabService.getFastSeasonInfo('filseta_16', today);

      expect(filsetaInfo.isSeasonal, isTrue);
      expect(filsetaInfo.isUnlocked, isFalse);
      // From Tikimt 30 (day 60) to Nehase 1 (day 331) = 271 days
      expect(filsetaInfo.daysUntilStart, 271);
      expect(filsetaInfo.getCountdownText(isEnglish: true), contains('Unlocks in 271 days • Nehase 1'));
      expect(filsetaInfo.getCountdownText(isEnglish: false), contains('ከ 271 ቀናት በኋላ ይከፈታል • ነሐሴ ፩'));
    });

    test('Fast of Assumption (Filseta) unlocks and is active during Nehase 1 to 16', () {
      // On Nehase 5, 2019 (month 12, day 5)
      final today = BahireHasabService.createEthiopianDate(2019, 12, 5);
      final filsetaInfo = BahireHasabService.getFastSeasonInfo('filseta_16', today);

      expect(filsetaInfo.isSeasonal, isTrue);
      expect(filsetaInfo.isUnlocked, isTrue);
      expect(filsetaInfo.daysUntilStart, 0);
      // From Nehase 5 to Nehase 16 inclusive = 12 days remaining
      expect(filsetaInfo.daysRemaining, 12);
    });

    test('Fast of Assumption (Filseta) locks to next year when Nehase 16 has passed', () {
      // On Pagume 1, 2019 (month 13, day 1)
      final today = BahireHasabService.createEthiopianDate(2019, 13, 1);
      final filsetaInfo = BahireHasabService.getFastSeasonInfo('filseta_16', today);

      expect(filsetaInfo.isSeasonal, isTrue);
      expect(filsetaInfo.isUnlocked, isFalse);
      expect(filsetaInfo.startDate?.year, 2020);
      expect(filsetaInfo.daysUntilStart, greaterThan(0));
    });

    test('Fast of the Prophets (Advent) locks on Tikimt 30 and counts down 15 days to Hidar 15', () {
      // Today: Tikimt 30, 2019 (month 2, day 30)
      final today = BahireHasabService.createEthiopianDate(2019, 2, 30);
      final adventInfo = BahireHasabService.getFastSeasonInfo('advent_prophets_43', today);

      expect(adventInfo.isSeasonal, isTrue);
      expect(adventInfo.isUnlocked, isFalse);
      expect(adventInfo.daysUntilStart, 15);
      expect(adventInfo.startDate?.month, 3); // Hidar
      expect(adventInfo.startDate?.day, 15);
      expect(adventInfo.getCountdownText(isEnglish: true), contains('Unlocks in 15 days • Hidar 15'));
      expect(adventInfo.getCountdownText(isEnglish: false), contains('ከ 15 ቀናት በኋላ ይከፈታል • ኅዳር ፲፭'));
    });

    test('Fast of the Prophets (Advent) unlocks and becomes active on Hidar 15', () {
      // On Hidar 15, 2019
      final today = BahireHasabService.createEthiopianDate(2019, 3, 15);
      final adventInfo = BahireHasabService.getFastSeasonInfo('advent_prophets_43', today);

      expect(adventInfo.isSeasonal, isTrue);
      expect(adventInfo.isUnlocked, isTrue);
      expect(adventInfo.daysUntilStart, 0);
      // Lasts from Hidar 15 through Tahsas 28 (16 in Hidar + 28 in Tahsas = 44 days inclusive)
      expect(adventInfo.daysRemaining, 44);
    });

    test('Great Lent (55 Days) and Passion Week lock and unlock accurately with movable Bahire Hasab', () {
      // 2017: Nineveh was Yekatit 3 -> Lent starts Yekatit 17, ends Miyazya 11 (Easter Miyazya 12)
      final preLent = BahireHasabService.createEthiopianDate(2017, 5, 20); // Tir 20
      final lentInfo = BahireHasabService.getFastSeasonInfo('great_lent_55', preLent);
      expect(lentInfo.isSeasonal, isTrue);
      expect(lentInfo.isUnlocked, isFalse);
      expect(lentInfo.daysUntilStart, greaterThan(0));

      // Mid-lent: Megabit 15, 2017
      final midLent = BahireHasabService.createEthiopianDate(2017, 7, 15);
      final midLentInfo = BahireHasabService.getFastSeasonInfo('great_lent_55', midLent);
      expect(midLentInfo.isUnlocked, isTrue);
      expect(midLentInfo.daysRemaining, greaterThan(0));
    });
  });

  group('Automatic Ethiopian New Year (Meskerem 1) Cycle Reset Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Annual reset clears EOTC curated plans when new Ethiopian year arrives', () async {
      final prefs = await SharedPreferences.getInstance();

      // Setup state for Ethiopian Year 2019 with some completed days in EOTC plans
      await prefs.setInt('eotc_liturgical_cycle_year', 2019);
      await prefs.setStringList('plan_filseta_16_completed', ['1', '2', '3']);
      await prefs.setStringList('plan_canonical_365_completed', ['1', '2', '3', '4']);
      await prefs.setStringList('plan_advent_prophets_43_completed', ['1']);
      // Non-EOTC generic plan should NOT be wiped
      await prefs.setStringList('plan_nt_90_completed', ['1', '2']);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(readingPlanSessionProvider.notifier);
      await notifier.loadAll();

      // Check that in 2019 cycle they existed
      expect(notifier.state.completedDaysByPlan['filseta_16']?.length, 3);
      expect(notifier.state.completedDaysByPlan['canonical_365']?.length, 4);
      expect(notifier.state.completedDaysByPlan['nt_90']?.length, 2);

      // Now simulate arrival of New Year: Meskerem 1, 2020 E.C.!
      final newYear2020 = BahireHasabService.createEthiopianDate(2020, 1, 1);
      final didReset = await notifier.checkAndApplyAnnualCycleReset(simulatedDate: newYear2020);

      expect(didReset, isTrue);
      // All EOTC curated plans have reset to 0
      expect(notifier.state.completedDaysByPlan['filseta_16']?.isEmpty, isTrue);
      expect(notifier.state.completedDaysByPlan['canonical_365']?.isEmpty, isTrue);
      expect(notifier.state.completedDaysByPlan['advent_prophets_43']?.isEmpty, isTrue);

      // Non-EOTC plan remained intact
      expect(notifier.state.completedDaysByPlan['nt_90']?.length, 2);

      // Liturgical cycle year persisted as 2020
      expect(prefs.getInt('eotc_liturgical_cycle_year'), 2020);

      // Calling check again in the same year does NOT reset
      final again = await notifier.checkAndApplyAnnualCycleReset(simulatedDate: newYear2020);
      expect(again, isFalse);
    });

    test('Cannot start a locked seasonal plan outside its fast season', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(readingPlanSessionProvider.notifier);
      await notifier.loadAll();

      // Today is Tikimt 30, 2019 -> Filseta is locked
      final tikimt30 = BahireHasabService.createEthiopianDate(2019, 2, 30);
      final filsetaPlan = ReadingPlansData.getPlanById('filseta_16')!;

      final started = await notifier.startReadingSession(filsetaPlan, 1, simulatedDate: tikimt30);
      expect(started, isFalse);
      expect(notifier.state.activeSessionPlan, isNull);

      // But a perpetual plan starts immediately
      final canonicalPlan = ReadingPlansData.getPlanById('canonical_365')!;
      final startedCanonical = await notifier.startReadingSession(canonicalPlan, 1, simulatedDate: tikimt30);
      expect(startedCanonical, isTrue);
      expect(notifier.state.activeSessionPlan?.id, 'canonical_365');
    });
  });
}
