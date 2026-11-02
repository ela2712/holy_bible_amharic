import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/services/bible_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Psalms & Deuterocanon Cross-Translation Alignment Tests', () {
    late BibleRepository repo;

    setUpAll(() async {
      repo = BibleRepository.instance;
      await repo.ensureInitialized();
    });

    test('Psalm 132 aligns to "Lord, remember David" across all 4 translations', () async {
      // Translation 1: Haile Selassie 1954 (Book 19 in 66-book canon)
      final a54Book = await repo.getBookByNumber(1, 19);
      expect(a54Book, isNotNull);
      final a54Verses = await repo.getVerses(bookId: a54Book!.id, chapter: 132);
      expect(a54Verses.length, equals(18));
      expect(a54Verses.first.text, contains('ዳዊት'));

      // Translation 2: Ethiopian Orthodox 81 Canon (Book 28 in 81-book canon)
      final o81Book = await repo.getBookByNumber(2, 28);
      expect(o81Book, isNotNull);
      final o81Verses = await repo.getVerses(bookId: o81Book!.id, chapter: 132);
      expect(o81Verses.length, equals(18));
      expect(o81Verses.first.text, contains('ዳዊት'));

      // Translation 3: King James Version (Book 19 in 66-book canon)
      final kjvBook = await repo.getBookByNumber(3, 19);
      expect(kjvBook, isNotNull);
      final kjvVerses = await repo.getVerses(bookId: kjvBook!.id, chapter: 132);
      expect(kjvVerses.length, equals(18));
      expect(kjvVerses.first.text, contains('David'));

      // Translation 4: Ge'ez 81 Canon (Book 28 in 81-book canon)
      final geezBook = await repo.getBookByNumber(4, 28);
      expect(geezBook, isNotNull);
      final geezVerses = await repo.getVerses(bookId: geezBook!.id, chapter: 132);
      expect(geezVerses.length, greaterThanOrEqualTo(18));
      expect(geezVerses.first.text, contains('ተዘከሮ'));
      expect(geezVerses.first.text, contains('ዳዊት'));
    });

    test('Psalm 133 aligns to "Brethren in unity / ናሁ ሠናይ" across all 4 translations', () async {
      final a54Book = await repo.getBookByNumber(1, 19);
      final a54Verses = await repo.getVerses(bookId: a54Book!.id, chapter: 133);
      expect(a54Verses.first.text, contains('ወንድሞች'));

      final o81Book = await repo.getBookByNumber(2, 28);
      final o81Verses = await repo.getVerses(bookId: o81Book!.id, chapter: 133);
      expect(o81Verses.first.text, contains('ወንድሞች'));

      final kjvBook = await repo.getBookByNumber(3, 19);
      final kjvVerses = await repo.getVerses(bookId: kjvBook!.id, chapter: 133);
      expect(kjvVerses.first.text.toLowerCase(), contains('brethren to dwell together in unity'));

      final geezBook = await repo.getBookByNumber(4, 28);
      final geezVerses = await repo.getVerses(bookId: geezBook!.id, chapter: 133);
      expect(geezVerses.first.text, contains('ናሁ፡ ሠናይ'));
    });

    test('Psalm 134 aligns to "Bless the Lord / ናሁ ይባርክዎ" across all 4 translations', () async {
      final a54Book = await repo.getBookByNumber(1, 19);
      final a54Verses = await repo.getVerses(bookId: a54Book!.id, chapter: 134);
      expect(a54Verses.first.text, contains('ባርኩ'));

      final o81Book = await repo.getBookByNumber(2, 28);
      final o81Verses = await repo.getVerses(bookId: o81Book!.id, chapter: 134);
      expect(o81Verses.first.text, contains('ባርኩ'));

      final kjvBook = await repo.getBookByNumber(3, 19);
      final kjvVerses = await repo.getVerses(bookId: kjvBook!.id, chapter: 134);
      expect(kjvVerses.first.text.toLowerCase(), contains('bless ye the lord'));

      final geezBook = await repo.getBookByNumber(4, 28);
      final geezVerses = await repo.getVerses(bookId: geezBook!.id, chapter: 134);
      expect(geezVerses.first.text, contains('ናሁ፡ ይባርክዎ'));
    });

    test('Psalm 23 aligns to "The Lord is my shepherd / ይሬዕየኒ" across all 4 translations', () async {
      final a54Book = await repo.getBookByNumber(1, 19);
      final a54Verses = await repo.getVerses(bookId: a54Book!.id, chapter: 23);
      expect(a54Verses.first.text, contains('እረኛዬ'));

      final o81Book = await repo.getBookByNumber(2, 28);
      final o81Verses = await repo.getVerses(bookId: o81Book!.id, chapter: 23);
      expect(o81Verses.first.text, contains('እረኛዬ'));

      final kjvBook = await repo.getBookByNumber(3, 19);
      final kjvVerses = await repo.getVerses(bookId: kjvBook!.id, chapter: 23);
      expect(kjvVerses.first.text, contains('The LORD is my shepherd'));

      final geezBook = await repo.getBookByNumber(4, 28);
      final geezVerses = await repo.getVerses(bookId: geezBook!.id, chapter: 23);
      expect(geezVerses.first.text, contains('ይሬዕየኒ'));
    });

    test('Psalm 51 aligns to "Have mercy on me / ተሣሀለኒ" across all 4 translations', () async {
      final a54Book = await repo.getBookByNumber(1, 19);
      final a54Verses = await repo.getVerses(bookId: a54Book!.id, chapter: 51);
      expect(a54Verses.first.text, contains('ማረኝ'));

      final o81Book = await repo.getBookByNumber(2, 28);
      final o81Verses = await repo.getVerses(bookId: o81Book!.id, chapter: 51);
      expect(o81Verses.first.text, contains('ማረኝ'));

      final kjvBook = await repo.getBookByNumber(3, 19);
      final kjvVerses = await repo.getVerses(bookId: kjvBook!.id, chapter: 51);
      expect(kjvVerses.first.text, contains('Have mercy'));

      final geezBook = await repo.getBookByNumber(4, 28);
      final geezVerses = await repo.getVerses(bookId: geezBook!.id, chapter: 51);
      expect(geezVerses.first.text, contains('ተሣሀለኒ'));
    });

    test('Psalm 22 in Orthodox 81 and Ge\'ez 81 has full 31 verses of Messianic prophecy', () async {
      final o81Book = await repo.getBookByNumber(2, 28);
      final o81Verses = await repo.getVerses(bookId: o81Book!.id, chapter: 22);
      expect(o81Verses.length, equals(31));
      expect(o81Verses.first.text, contains('አምላኬ'));
      expect(o81Verses.first.text, contains('ተውኸኝ'));

      final geezBook = await repo.getBookByNumber(4, 28);
      final geezVerses = await repo.getVerses(bookId: geezBook!.id, chapter: 22);
      expect(geezVerses.length, greaterThanOrEqualTo(31));
      expect(geezVerses.first.text, contains('አምላኪየ'));
    });

    test('Deuterocanonical books (Baruch, Teref Ermias, Tegsas) match authentic 81 Canon chapters', () async {
      // Baruch (Book 37) has 5 chapters in both O81 and Geez
      final o81Baruch = await repo.getBookByNumber(2, 37);
      expect(o81Baruch?.totalChapters, equals(5));
      final geezBaruch = await repo.getBookByNumber(4, 37);
      expect(geezBaruch?.totalChapters, equals(5));

      // Teref Ermias (Book 39) has 1 chapter in both O81 and Geez
      final o81Ter = await repo.getBookByNumber(2, 39);
      expect(o81Ter?.totalChapters, equals(1));
      final geezTer = await repo.getBookByNumber(4, 39);
      expect(geezTer?.totalChapters, equals(1));

      // Tegsas (Book 30) has 6 chapters in both O81 and Geez
      final o81Teg = await repo.getBookByNumber(2, 30);
      expect(o81Teg?.totalChapters, equals(6));
      final geezTeg = await repo.getBookByNumber(4, 30);
      expect(geezTeg?.totalChapters, equals(6));
    });
  });
}
