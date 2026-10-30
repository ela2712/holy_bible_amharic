import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/core/utils/canonical_book_map.dart';
import 'package:holy_bible_amharic/core/utils/geez_numbers.dart';
import 'package:holy_bible_amharic/services/bahire_hasab_service.dart';
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

    test('Authentic Synaxarium commemorates daily EOTC saints', () {
      // Meskerem 1 (Nativity of Mary / Elijah)
      final meskerem1 = BahireHasabService.getDailySynaxarium(
        const EthiopianDate(year: 2017, month: 1, day: 1, dayOfWeek: 3),
      );
      expect(meskerem1.title, contains('ልደታ ለማርያም'));
      expect(meskerem1.passage, isNotEmpty);

      // Tikimt 27 (Medhane Alem / Savior of the World)
      final tikimt27 = BahireHasabService.getDailySynaxarium(
        const EthiopianDate(year: 2017, month: 2, day: 27, dayOfWeek: 4),
      );
      expect(tikimt27.title, contains('መድኃኔ ዓለም'));

      // Hidar 21 (Saint Mary / Theotokos)
      final hidar21 = BahireHasabService.getDailySynaxarium(
        const EthiopianDate(year: 2017, month: 3, day: 21, dayOfWeek: 5),
      );
      expect(hidar21.title, contains('እመቤታችን'));

      // Pagume 3 (Archangel Raphael)
      final pagume3 = BahireHasabService.getDailySynaxarium(
        const EthiopianDate(year: 2017, month: 13, day: 3, dayOfWeek: 6),
      );
      expect(pagume3.title, contains('ቅዱስ ሩፋኤል'));
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
