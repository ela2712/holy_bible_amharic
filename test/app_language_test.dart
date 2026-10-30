import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/data/reading_plans_data.dart';
import 'package:holy_bible_amharic/models/translation.dart';
import 'package:holy_bible_amharic/providers/app_language_provider.dart';
import 'package:holy_bible_amharic/providers/bible_state.dart';
import 'package:holy_bible_amharic/services/bahire_hasab_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const canon81 = Translation(
    id: 2,
    code: 'eotc_81',
    name: '81 Canon',
    shortName: '81',
    language: 'am',
    canon: 'orthodox_81',
    isDefault: true,
  );

  const kjv = Translation(
    id: 3,
    code: 'kjv',
    name: 'King James Version',
    shortName: 'KJV',
    language: 'en',
    canon: 'kjv_66',
    isDefault: false,
  );

  group('Interface Language & AppLanguageMode Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Auto mode: Amharic 81 Canon gives Amharic interface', () {
      final container = ProviderContainer(
        overrides: [
          bibleStateProvider.overrideWith((ref) => _FakeBibleStateNotifier(canon81)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appLanguageProvider), AppLanguageMode.auto);
      expect(container.read(isEnglishUiProvider), false);
    });

    test('Auto mode: KJV translation automatically gives English interface', () {
      final container = ProviderContainer(
        overrides: [
          bibleStateProvider.overrideWith((ref) => _FakeBibleStateNotifier(kjv)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appLanguageProvider), AppLanguageMode.auto);
      expect(container.read(isEnglishUiProvider), true);
    });

    test('Amharic mode forces Amharic interface even with KJV translation', () async {
      final container = ProviderContainer(
        overrides: [
          bibleStateProvider.overrideWith((ref) => _FakeBibleStateNotifier(kjv)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appLanguageProvider.notifier).setLanguageMode(AppLanguageMode.amharic);

      expect(container.read(appLanguageProvider), AppLanguageMode.amharic);
      expect(container.read(isEnglishUiProvider), false);
    });

    test('English mode forces English interface even with 81 Orthodox Canon translation', () async {
      final container = ProviderContainer(
        overrides: [
          bibleStateProvider.overrideWith((ref) => _FakeBibleStateNotifier(canon81)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(appLanguageProvider.notifier).setLanguageMode(AppLanguageMode.english);

      expect(container.read(appLanguageProvider), AppLanguageMode.english);
      expect(container.read(isEnglishUiProvider), true);
    });
  });

  group('Reading Plans Clean Language Separation Tests', () {
    test('All 15 Reading Plans have pure Amharic titles without English in brackets', () {
      expect(ReadingPlansData.allPlans.length, 15);

      for (final plan in ReadingPlansData.allPlans) {
        // Amharic title must NOT contain English bracketed suffixes
        expect(plan.title, isNot(contains('(Chronological)')));
        expect(plan.title, isNot(contains('(M\'Cheyne)')));
        expect(plan.title, isNot(contains('(Holy Passion Week)')));
        expect(plan.title, isNot(contains('(Great Lent')));
        expect(plan.title, isNot(contains('(Fast of the Prophets')));
        expect(plan.title, isNot(contains('(Fast of the Assumption)')));
        expect(plan.title, isNot(contains('(Faith & Courage)')));

        // English fields must be non-empty and cleanly defined
        expect(plan.titleEn.isNotEmpty, isTrue, reason: 'Plan ${plan.id} missing titleEn');
        expect(plan.subtitleEn.isNotEmpty, isTrue, reason: 'Plan ${plan.id} missing subtitleEn');
        expect(plan.categoryEn.isNotEmpty, isTrue, reason: 'Plan ${plan.id} missing categoryEn');
        expect(plan.badgeTextEn.isNotEmpty, isTrue, reason: 'Plan ${plan.id} missing badgeTextEn');

        // Verify helper methods return expected strings based on isEnglish
        expect(plan.getDisplayTitle(false), plan.title);
        expect(plan.getDisplayTitle(true), plan.titleEn);
        expect(plan.getDisplaySubtitle(false), plan.subtitle);
        expect(plan.getDisplaySubtitle(true), plan.subtitleEn);
        expect(plan.getDisplayCategory(false), plan.category);
        expect(plan.getDisplayCategory(true), plan.categoryEn);
        expect(plan.getDisplayBadge(false), plan.badgeText);
        expect(plan.getDisplayBadge(true), plan.badgeTextEn);
      }
    });

    test('Passage references format correctly in both Amharic and English', () {
      final plan = ReadingPlansData.getPlanById('gospels_30')!;
      final passage = plan.passages.first;

      final amharicRef = passage.getPassageReference(false);
      final englishRef = passage.getPassageReference(true);

      expect(amharicRef, contains('ምዕራፍ'));
      expect(englishRef, contains('Chapter'));
    });
  });

  group('Bahire Hasab Clean Language Separation Tests', () {
    test('Liturgical status returns pure Amharic and pure English titles without bracketed mix', () {
      final status = BahireHasabService.getCurrentLiturgicalStatus(DateTime.now());

      final seasonTitleAm = status['seasonTitle'] as String;
      final seasonTitleEn = status['seasonTitleEn'] as String;

      // Amharic season title must not contain English brackets like '(Season of Flowers)' or '(Fast of Assumption)'
      expect(seasonTitleAm, isNot(contains('(Season of Flowers)')));
      expect(seasonTitleAm, isNot(contains('(Fast of Assumption)')));
      expect(seasonTitleAm, isNot(contains('(Advent')));
      expect(seasonTitleAm, isNot(contains('(Holy Great Lent)')));

      expect(seasonTitleEn.isNotEmpty, isTrue);
    });

    test('EthiopianDate formats in both Amharic and English', () {
      const date = EthiopianDate(year: 2017, month: 2, day: 11, dayOfWeek: 3);

      final formattedAm = date.format(isEnglish: false);
      final formattedEn = date.format(isEnglish: true);

      expect(formattedAm, contains('ጥቅምት 11 ቀን 2017 ዓ.ም.'));
      expect(formattedEn, contains('Tikimt 11, 2017 E.C.'));
      expect(formattedEn, contains('Wednesday'));
    });
  });
}

class _FakeBibleStateNotifier extends StateNotifier<BibleViewState>
    implements BibleStateNotifier {
  _FakeBibleStateNotifier(Translation translation)
      : super(BibleViewState(
          currentTranslation: translation,
          isLoading: false,
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
