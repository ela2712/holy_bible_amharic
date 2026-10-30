import 'package:flutter_test/flutter_test.dart';
import 'package:holy_bible_amharic/services/bible_repository.dart';
import 'package:holy_bible_amharic/core/utils/canonical_book_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test KJV verses loading across various books', () async {
    final repo = BibleRepository();
    await repo.ensureInitialized();

    // Check translations
    final translations = await repo.getTranslations();
    expect(translations.length, greaterThanOrEqualTo(3));

    // Test Genesis (81: 1, 1954: 1, KJV: 1)
    for (int tId in [1, 2, 3]) {
      final b = await repo.getBookByNumber(tId, 1);
      expect(b, isNotNull);
      if (b != null) {
        final verses = await repo.getVerses(bookId: b.id, chapter: 1);
        expect(verses.isNotEmpty, isTrue);
      }
    }

    // Test Matthew (81: 55, 1954: 40, KJV: 40)
    final canonIdMat = CanonicalBookMap.getCanonicalId(2, 55);
    expect(canonIdMat, 'MAT');
    final kjvMatNum = CanonicalBookMap.getBookNumber(3, canonIdMat);
    expect(kjvMatNum, 40);
    final kjvMat = await repo.getBookByNumber(3, kjvMatNum!);
    expect(kjvMat, isNotNull);
    final kjvMatVerses = await repo.getVerses(bookId: kjvMat!.id, chapter: 1);
    expect(kjvMatVerses.isNotEmpty, isTrue);

    // Test John (81: 58, 1954: 43, KJV: 43)
    final canonIdJhn = CanonicalBookMap.getCanonicalId(2, 58);
    final kjvJhnNum = CanonicalBookMap.getBookNumber(3, canonIdJhn);
    final kjvJhn = await repo.getBookByNumber(3, kjvJhnNum!);
    expect(kjvJhn, isNotNull);
    final kjvJhnVerses = await repo.getVerses(bookId: kjvJhn!.id, chapter: 1);
    expect(kjvJhnVerses.isNotEmpty, isTrue);

    // Test Revelation (81: 81, 1954: 66, KJV: 66)
    final canonIdRev = CanonicalBookMap.getCanonicalId(2, 81);
    final kjvRevNum = CanonicalBookMap.getBookNumber(3, canonIdRev);
    final kjvRev = await repo.getBookByNumber(3, kjvRevNum!);
    expect(kjvRev, isNotNull);
    final kjvRevVerses = await repo.getVerses(bookId: kjvRev!.id, chapter: 1);
    expect(kjvRevVerses.isNotEmpty, isTrue);
  });
}
