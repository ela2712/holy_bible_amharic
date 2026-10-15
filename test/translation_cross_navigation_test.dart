import 'package:flutter_test/flutter_test.dart';
import 'package:holy_bible_amharic/core/utils/canonical_book_map.dart';
import 'package:holy_bible_amharic/services/bible_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Translation Configuration & 81 Canon Default Tests', () {
    test('81 Orthodox Canon is primary default translation', () async {
      final repo = BibleRepository();
      await repo.ensureInitialized();

      final translations = await repo.getTranslations();
      expect(translations.isNotEmpty, true);

      // First translation must be 81 Canon
      final firstTrans = translations.first;
      expect(firstTrans.id, 2);
      expect(firstTrans.code, 'eotc_81');
      expect(firstTrans.isDefault, true);

      // KJV must not be called protestant_66
      final kjv = translations.firstWhere((t) => t.id == 3);
      expect(kjv.canon.toLowerCase().contains('protestant'), false);
    });

    test('KJV books display authentic English names', () async {
      final repo = BibleRepository();
      await repo.ensureInitialized();

      final kjvBooks = await repo.getBooks(translationId: 3);
      expect(kjvBooks.length, 66);

      // Verify Matthew is "Matthew", Genesis is "Genesis", John is "John"
      expect(kjvBooks[0].name, 'Genesis');
      expect(kjvBooks[39].name, 'Matthew');
      expect(kjvBooks[42].name, 'John');
      expect(kjvBooks[44].name, 'Romans');
      expect(kjvBooks[65].name, 'Revelation');
    });

    test('Cross-translation mapping lands on exact same book and chapter', () async {
      final repo = BibleRepository();
      await repo.ensureInitialized();

      final books81 = await repo.getBooks(translationId: 2);
      final books1954 = await repo.getBooks(translationId: 1);
      final booksKjv = await repo.getBooks(translationId: 3);

      // 1. Matthew test (81 #55 -> 1954 #40 -> KJV #40)
      final mat81 = books81.firstWhere((b) => b.bookNumber == 55);
      final canonMat = CanonicalBookMap.getCanonicalId(2, mat81.bookNumber);
      expect(canonMat, 'MAT');

      final mat1954Num = CanonicalBookMap.getBookNumber(1, canonMat);
      expect(mat1954Num, 40);
      final mat1954 = books1954.firstWhere((b) => b.bookNumber == mat1954Num);
      expect(mat1954.name.contains('ማቴዎስ'), true);

      final matKjvNum = CanonicalBookMap.getBookNumber(3, canonMat);
      expect(matKjvNum, 40);
      final matKjv = booksKjv.firstWhere((b) => b.bookNumber == matKjvNum);
      expect(matKjv.name, 'Matthew');

      // 2. Genesis test (81 #1 -> 1954 #1 -> KJV #1)
      final genCanon = CanonicalBookMap.getCanonicalId(2, 1);
      expect(genCanon, 'GEN');
      expect(CanonicalBookMap.getBookNumber(1, genCanon), 1);
      expect(CanonicalBookMap.getBookNumber(3, genCanon), 1);

      // 3. Romans test (81 #60 -> 1954 #45 -> KJV #45)
      final romCanon = CanonicalBookMap.getCanonicalId(2, 60);
      expect(romCanon, 'ROM');
      expect(CanonicalBookMap.getBookNumber(1, romCanon), 45);
      expect(CanonicalBookMap.getBookNumber(3, romCanon), 45);

      // 4. 81-Exclusive book test (Enoch #16, Jubilees #15)
      final enochCanon = CanonicalBookMap.getCanonicalId(2, 16);
      expect(enochCanon, 'ENO');
      expect(CanonicalBookMap.getBookNumber(1, enochCanon), isNull);
      expect(CanonicalBookMap.getBookNumber(3, enochCanon), isNull);
      expect(CanonicalBookMap.is81Exclusive(16), true);
    });
  });
}
