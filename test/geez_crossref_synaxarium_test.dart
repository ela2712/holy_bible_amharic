import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/core/utils/canonical_book_map.dart';
import 'package:holy_bible_amharic/core/utils/geez_numbers.dart';
import 'package:holy_bible_amharic/services/bible_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Ge\'ez Canon, Cross References, & Synaxarium Tests', () {
    test('Canonical mapping supports Ge\'ez 81 Canon (translationId = 4)', () {
      // Genesis in Ge'ez
      final genCanonical = CanonicalBookMap.getCanonicalId(4, 1);
      expect(genCanonical, equals('GEN'));
      expect(CanonicalBookMap.getBookNumber(4, 'GEN'), equals(1));

      // Jubilees in Ge'ez (Book 15 in EOTC 81 Canon)
      final jubCanonical = CanonicalBookMap.getCanonicalId(4, 15);
      expect(jubCanonical, equals('JUB'));
      expect(CanonicalBookMap.getBookNumber(4, 'JUB'), equals(15));

      // Enoch in Ge'ez (Book 16 in EOTC 81 Canon)
      final enochCanonical = CanonicalBookMap.getCanonicalId(4, 16);
      expect(enochCanonical, equals('ENO'));
      expect(CanonicalBookMap.getBookNumber(4, 'ENO'), equals(16));

      // Revelation in Ge'ez (Book 81 in EOTC 81 Canon)
      final revCanonical = CanonicalBookMap.getCanonicalId(4, 81);
      expect(revCanonical, equals('REV'));
      expect(CanonicalBookMap.getBookNumber(4, 'REV'), equals(81));
    });

    test('Ge\'ez numerals formatting converts numbers accurately', () {
      expect(GeezNumbers.toGeez(1), equals('፩'));
      expect(GeezNumbers.toGeez(3), equals('፫'));
      expect(GeezNumbers.toGeez(16), equals('፲፮'));
      expect(GeezNumbers.toGeez(81), equals('፹፩'));
    });

    test('Meaningfully curated 365 daily spiritual verses load authentic text across translations', () async {
      final repo = BibleRepository.instance;
      await repo.ensureInitialized();

      // Test in 81 Orthodox Canon (translationId = 2)
      final v81 = await repo.getDailyVerse(2);
      expect(v81, isNotNull);
      expect(v81!['text'], isNotEmpty);
      expect(v81['theme'], isNotEmpty);
      expect(v81['book_name'], isNotEmpty);

      // Test in KJV (translationId = 3)
      final vKjv = await repo.getDailyVerse(3);
      expect(vKjv, isNotNull);
      expect(vKjv!['text'], isNotEmpty);
      expect(vKjv['theme_en'], isNotEmpty);

      // Test in Ge'ez (translationId = 4)
      final vGeez = await repo.getDailyVerse(4);
      expect(vGeez, isNotNull);
      expect(vGeez!['text'], isNotEmpty);
    });

    test('Cross-references repository returns valid cross references', () async {
      final repo = BibleRepository.instance;
      await repo.ensureInitialized();

      final refs = await repo.getCrossReferencesForVerse(
        bookNumber: 1,
        chapter: 1,
        verse: 1,
      );

      expect(refs, isNotEmpty);
      expect(refs.first.targetBookName, isNotEmpty);
      expect(refs.first.connectionType, isNotEmpty);
      expect(refs.first.targetReference, isNotEmpty);
    });
  });
}
