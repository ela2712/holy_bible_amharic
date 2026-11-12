import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/core/utils/canonical_book_map.dart';
import 'package:holy_bible_amharic/models/reading_plan.dart';
import 'package:holy_bible_amharic/services/bahire_hasab_service.dart';
import 'package:holy_bible_amharic/services/bible_repository.dart';
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

    test('Fast of Nineveh (3 Days, Book of Jonah) locks and unlocks accurately with movable Bahire Hasab', () {
      // 2017 E.C.: Nineveh starts Yekatit 3 (Monday) and lasts Yekatit 3, 4, 5
      final preNineveh = BahireHasabService.createEthiopianDate(2017, 5, 28); // Tir 28
      final preInfo = BahireHasabService.getFastSeasonInfo('nineveh_3', preNineveh);
      expect(preInfo.isSeasonal, isTrue);
      expect(preInfo.isUnlocked, isFalse);
      // Tir 28 -> Tir 29, 30, Yekatit 1, 2, 3 = 5 days
      expect(preInfo.daysUntilStart, 5);

      // Day 1 of Nineveh: Yekatit 3, 2017
      final day1 = BahireHasabService.createEthiopianDate(2017, 6, 3);
      final day1Info = BahireHasabService.getFastSeasonInfo('nineveh_3', day1);
      expect(day1Info.isUnlocked, isTrue);
      expect(day1Info.daysRemaining, 3);

      // Day 3 (Wednesday) of Nineveh: Yekatit 5, 2017
      final day3 = BahireHasabService.createEthiopianDate(2017, 6, 5);
      final day3Info = BahireHasabService.getFastSeasonInfo('nineveh_3', day3);
      expect(day3Info.isUnlocked, isTrue);
      expect(day3Info.daysRemaining, 1);

      // Thursday after Nineveh: Yekatit 6, 2017 -> locked until 2018 Nineveh
      final afterNineveh = BahireHasabService.createEthiopianDate(2017, 6, 6);
      final afterInfo = BahireHasabService.getFastSeasonInfo('nineveh_3', afterNineveh);
      expect(afterInfo.isUnlocked, isFalse);
      expect(afterInfo.startDate?.year, 2018);

      // Plan content covers all 4 chapters of Jonah across 3 days
      final plan = ReadingPlansData.getPlanById('nineveh_3')!;
      expect(plan.totalDays, 3);
      expect(plan.passages.length, 3);
      expect(plan.passages.every((p) => p.canonicalId == 'JON'), isTrue);
      expect(plan.passages[0].startChapter, 1);
      expect(plan.passages[0].endChapter, 2);
      expect(plan.passages[1].startChapter, 3);
      expect(plan.passages[2].startChapter, 4);
    });

    test('Fast of the Apostles dynamically adapts duration & readings per Bahire Hasab year (14–49 days)', () {
      // 2019 E.C.: Nineveh Yekatit 15 -> Sene 14 to Hamle 4 = 21 days (<= 28: Acts 1-28 compressed cleanly)
      final pre2019 = BahireHasabService.createEthiopianDate(2019, 9, 1);
      final info2019 = BahireHasabService.getFastSeasonInfo('apostles_fast', pre2019);
      expect(info2019.isSeasonal, isTrue);
      expect(info2019.isUnlocked, isFalse);
      expect(info2019.startDate?.month, 10); // Sene
      expect(info2019.startDate?.day, 14);
      expect(info2019.endDate?.month, 11); // Hamle
      expect(info2019.endDate?.day, 4);

      final plan2019 = ReadingPlansData.buildApostlesFastPlan(targetDate: pre2019);
      expect(plan2019.totalDays, 21);
      expect(plan2019.passages.length, 21);
      expect(plan2019.passages.every((p) => p.canonicalId == 'ACT'), isTrue);
      expect(plan2019.passages.first.startChapter, 1);
      expect(plan2019.passages.last.endChapter, 28);
      // Verify contiguous coverage of all 28 chapters with zero gaps
      int expectedNextCh = 1;
      for (final p in plan2019.passages) {
        expect(p.startChapter, expectedNextCh);
        expectedNextCh = p.endChapter + 1;
      }
      expect(expectedNextCh, 29);

      // During 2019 Apostles Fast (e.g. Sene 14, 2019): unlocked, recommendedPlanId = apostles_fast
      final active2019 = BahireHasabService.createEthiopianDate(2019, 10, 14);
      final activeInfo = BahireHasabService.getFastSeasonInfo('apostles_fast', active2019);
      expect(activeInfo.isUnlocked, isTrue);
      expect(activeInfo.daysRemaining, 21);

      // Day after 2019 Apostles Fast ends (Hamle 5, 2019 - Feast of Peter & Paul):
      // Automatically points to 2020 E.C. (37 days: Ginbot 28 - Hamle 4)
      final feast2019 = BahireHasabService.createEthiopianDate(2019, 11, 5);
      final nextYearInfo = BahireHasabService.getFastSeasonInfo('apostles_fast', feast2019);
      expect(nextYearInfo.isUnlocked, isFalse);
      expect(nextYearInfo.startDate?.year, 2020);
      expect(nextYearInfo.startDate?.month, 9); // Ginbot
      expect(nextYearInfo.startDate?.day, 28);

      final plan2020 = ReadingPlansData.buildApostlesFastPlan(targetDate: feast2019);
      expect(plan2020.totalDays, 37);
      expect(plan2020.passages.length, 37);
      // Days 1..28 cover Acts 1..28 (1 ch/day)
      for (int i = 0; i < 28; i++) {
        expect(plan2020.passages[i].canonicalId, 'ACT');
        expect(plan2020.passages[i].startChapter, i + 1);
        expect(plan2020.passages[i].endChapter, i + 1);
      }
      // Remaining 9 days (29..37) continue in EOTC General Epistles order: 1PE (5), 2PE (3), 1JN (1)
      expect(plan2020.passages[28].canonicalId, '1PE');
      expect(plan2020.passages[28].startChapter, 1);
      expect(plan2020.passages[32].canonicalId, '1PE');
      expect(plan2020.passages[32].startChapter, 5);
      expect(plan2020.passages[33].canonicalId, '2PE');
      expect(plan2020.passages[33].startChapter, 1);
      expect(plan2020.passages[35].canonicalId, '2PE');
      expect(plan2020.passages[35].startChapter, 3);
      expect(plan2020.passages[36].canonicalId, '1JN');
      expect(plan2020.passages[36].startChapter, 1);

      // 2021 E.C.: Ginbot 20 - Hamle 4 = 45 days (28 Acts + 5 1PE + 3 2PE + 5 1JN + 1 2JN + 1 3JN + 2 JAS)
      final pre2021 = BahireHasabService.createEthiopianDate(2021, 9, 1);
      final plan2021 = ReadingPlansData.buildApostlesFastPlan(targetDate: pre2021);
      expect(plan2021.totalDays, 45);
      expect(plan2021.passages.length, 45);
      expect(plan2021.passages.last.canonicalId, 'JAS');
      expect(plan2021.passages.last.startChapter, 2);
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
      await prefs.setStringList('plan_apostles_fast_completed', ['1', '35']);
      await prefs.setStringList('plan_apostles_fast_day_35_chapters', ['1']);
      // Non-EOTC generic plan should NOT be wiped
      await prefs.setStringList('plan_nt_90_completed', ['1', '2']);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(readingPlanSessionProvider.notifier);
      await notifier.loadAll();

      // Check that in 2019 cycle they existed
      expect(notifier.state.completedDaysByPlan['filseta_16']?.length, 3);
      expect(notifier.state.completedDaysByPlan['canonical_365']?.length, 4);
      expect(notifier.state.completedDaysByPlan['apostles_fast']?.length, 2);
      expect(notifier.state.completedDaysByPlan['nt_90']?.length, 2);

      // Now simulate arrival of New Year: Meskerem 1, 2020 E.C.!
      final newYear2020 = BahireHasabService.createEthiopianDate(2020, 1, 1);
      final didReset = await notifier.checkAndApplyAnnualCycleReset(simulatedDate: newYear2020);

      expect(didReset, isTrue);
      // All EOTC curated plans have reset to 0 (including stale high-numbered day keys from dynamic plans)
      expect(notifier.state.completedDaysByPlan['filseta_16']?.isEmpty, isTrue);
      expect(notifier.state.completedDaysByPlan['canonical_365']?.isEmpty, isTrue);
      expect(notifier.state.completedDaysByPlan['advent_prophets_43']?.isEmpty, isTrue);
      expect(notifier.state.completedDaysByPlan['apostles_fast']?.isEmpty, isTrue);
      expect(prefs.getStringList('plan_apostles_fast_day_35_chapters'), isNull);

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

    test('Fasting plans are ordered chronologically along the EOTC liturgical timeline', () {
      final fastingPlanIds = ReadingPlansData.allPlans
          .where((p) => p.category == 'ጾምና በዓላት' || p.categoryEn == 'Fasts & Feasts')
          .map((p) => p.id)
          .toList();

      expect(fastingPlanIds, [
        'advent_prophets_43', // Hidar 15 - Tahsas 28
        'nineveh_3',          // 3 Days (Mon-Wed, 2 weeks before Great Lent)
        'great_lent_55',      // Yekatit/Megabit - Miyazya
        'passion_week',       // Hosanna - Easter
        'apostles_fast',      // Monday after Pentecost - Hamle 4 (dynamic 14-49 days)
        'filseta_16',         // Nehase 1 - 16 (last in liturgical year)
      ]);
    });

    test('All fasting plan readings match their season and resolve real scripture across translations', () async {
      final repo = BibleRepository.instance;
      await repo.ensureInitialized();

      // Include both default current year and a long 45-day Apostles Fast year (2021 E.C.)
      final plansToVerify = <ReadingPlan>[
        for (final planId in BahireHasabService.seasonalPlanIds) ReadingPlansData.getPlanById(planId)!,
        ReadingPlansData.buildApostlesFastPlan(
          targetDate: BahireHasabService.createEthiopianDate(2021, 9, 1),
        ),
      ];

      for (final translationId in [1, 2, 3, 4]) {
        final books = await repo.getBooks(translationId: translationId);

        for (final plan in plansToVerify) {
          expect(plan.passages.length, plan.totalDays, reason: '${plan.id} passage count mismatch');

          for (int i = 0; i < plan.passages.length; i++) {
            final p = plan.passages[i];
            expect(p.day, i + 1, reason: '${plan.id} day numbering mismatch');
            expect(p.canonicalId.isNotEmpty, isTrue, reason: '${plan.id} day ${p.day} missing canonicalId');
            expect(p.startChapter, greaterThanOrEqualTo(1));
            expect(p.endChapter, greaterThanOrEqualTo(p.startChapter));

            final resolved = CanonicalBookMap.resolveBook(
              books: books,
              currentTranslationId: translationId,
              traditionalBookNumber: p.bookNumber,
              canonicalId: p.canonicalId,
              bookName: p.bookName,
            );
            expect(resolved, isNotNull, reason: 'Failed to resolve ${p.canonicalId} in translation $translationId (${plan.id} day ${p.day})');

            for (int ch = p.startChapter; ch <= p.endChapter; ch++) {
              final verses = await repo.getVerses(bookId: resolved!.id, chapter: ch);
              expect(verses.isNotEmpty, isTrue, reason: 'Empty chapter $ch in ${p.canonicalId} for translation $translationId (${plan.id} day ${p.day})');
            }
          }
        }
      }

      // Verify specific liturgical landmarks per season
      final advent = ReadingPlansData.getPlanById('advent_prophets_43')!;
      expect(advent.passages.first.canonicalId, 'GEN');
      expect(advent.passages[14].canonicalId, 'ISA');
      expect(advent.passages[14].startChapter, 7); // Emmanuel virgin birth prophecy
      expect(advent.passages[36].canonicalId, 'MIC');
      expect(advent.passages[36].startChapter, 5); // Bethlehem prophecy
      expect(advent.passages.last.canonicalId, 'LUK');
      expect(advent.passages.last.startChapter, 2); // Nativity of Christ

      final lent = ReadingPlansData.getPlanById('great_lent_55')!;
      expect(lent.passages[6].canonicalId, 'JHN');
      expect(lent.passages[6].startChapter, 3); // Sunday 1: Zewerede
      expect(lent.passages[20].canonicalId, 'JHN');
      expect(lent.passages[20].startChapter, 2); // Sunday 3: Mikurab (Cleansing temple)
      expect(lent.passages[27].canonicalId, 'JHN');
      expect(lent.passages[27].startChapter, 5); // Sunday 4: Metsague (Bethesda)
      expect(lent.passages[34].canonicalId, 'MAT');
      expect(lent.passages[34].startChapter, 24); // Sunday 5: Debre Zeyt
      expect(lent.passages[41].canonicalId, 'MAT');
      expect(lent.passages[41].startChapter, 25); // Sunday 6: Gebre Her
      expect(lent.passages[47].canonicalId, 'JHN');
      expect(lent.passages[47].startChapter, 11); // Lazarus Saturday (Day 48)
      expect(lent.passages[48].canonicalId, 'MAT');
      expect(lent.passages[48].startChapter, 21); // Palm Sunday / Hosanna (Day 49)
      expect(lent.passages[53].canonicalId, 'MAT');
      expect(lent.passages[53].startChapter, 27); // Good Friday (Day 54)
      expect(lent.passages.last.canonicalId, 'PSA');
      expect(lent.passages.last.startChapter, 16); // Holy Saturday (Day 55)

      final passion = ReadingPlansData.getPlanById('passion_week')!;
      expect(passion.passages.first.canonicalId, 'MAT');
      expect(passion.passages.first.startChapter, 21); // Hosanna
      expect(passion.passages.last.canonicalId, 'JHN');
      expect(passion.passages.last.startChapter, 20); // Resurrection

      final filseta = ReadingPlansData.getPlanById('filseta_16')!;
      expect(filseta.passages.first.canonicalId, 'LUK');
      expect(filseta.passages.first.startChapter, 1); // Annunciation & Magnificat
      expect(filseta.passages[9].canonicalId, 'EZK');
      expect(filseta.passages[9].startChapter, 44); // Closed East Gate
      expect(filseta.passages[14].canonicalId, 'REV');
      expect(filseta.passages[14].startChapter, 12); // Woman clothed with the sun
      expect(filseta.passages.last.canonicalId, 'PSA');
      expect(filseta.passages.last.startChapter, 150); // Filseta concluding praise
    });
  });
}
