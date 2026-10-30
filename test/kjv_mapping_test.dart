import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/services/bible_repository.dart';
import 'package:holy_bible_amharic/core/utils/canonical_book_map.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Check all 81 and 66 books mapping to KJV', () async {
    final repo = BibleRepository();
    await repo.ensureInitialized();

    final books81 = await repo.getBooks(translationId: 2);
    final books1954 = await repo.getBooks(translationId: 1);
    final booksKjv = await repo.getBooks(translationId: 3);

    expect(books81.length, 81);
    expect(books1954.length, 66);
    expect(booksKjv.length, 66);

    // Now test every single book in 81 canon:
    int mappedToKjv = 0;
    int exclusiveTo81 = 0;

    for (final b in books81) {
      final canonId = CanonicalBookMap.getCanonicalId(2, b.bookNumber);
      final kjvNum = CanonicalBookMap.getBookNumber(3, canonId);
      if (kjvNum == null) {
        exclusiveTo81++;
      } else {
        mappedToKjv++;
        final kjvBook = await repo.getBookByNumber(3, kjvNum);
        expect(kjvBook, isNotNull, reason: 'Failed to find KJV book for canonId $canonId');
        if (kjvBook != null) {
          final verses = await repo.getVerses(bookId: kjvBook.id, chapter: 1);
          expect(verses.isNotEmpty, isTrue, reason: 'Empty verses in KJV book ${kjvBook.name}');
        }
      }
    }

    expect(mappedToKjv, 66);
    expect(exclusiveTo81, 15);
  });
}
