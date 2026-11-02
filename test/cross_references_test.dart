import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/services/bible_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Authentic Canonical Cross-References Tests', () {
    late BibleRepository repo;

    setUpAll(() async {
      repo = BibleRepository.instance;
      await repo.ensureInitialized();
    });

    test('Genesis 1:1 cross references link to John 1:1, Hebrews 11:3, and Isaiah 45:18', () async {
      final refs = await repo.getCrossReferencesForVerse(
        bookNumber: 1,
        chapter: 1,
        verse: 1,
        translationId: 2, // 81 Canon
      );

      expect(refs, isNotEmpty);
      final refTargets = refs.map((r) => '${r.targetBookName} ${r.targetChapter}').toList();
      expect(refTargets.any((t) => t.contains('ዮሐንስ') && t.contains('1')), isTrue);
      expect(refTargets.any((t) => t.contains('ዕብራውያን') && t.contains('11')), isTrue);
      expect(refTargets.any((t) => t.contains('ኢሳይያስ') && t.contains('45')), isTrue);
      expect(refs.first.targetPreviewText, isNotEmpty);
    });

    test('Matthew 1:1 in 81 Canon (Book 55) returns authentic Messianic cross references', () async {
      final refs = await repo.getCrossReferencesForVerse(
        bookNumber: 55, // Matthew in 81 Canon
        chapter: 1,
        verse: 1,
        translationId: 2,
      );

      expect(refs, isNotEmpty);
      final refTargets = refs.map((r) => '${r.targetBookName} ${r.targetChapter}').toList();
      expect(refTargets.any((t) => t.contains('ዘፍጥረት') && t.contains('22')), isTrue);
      expect(refTargets.any((t) => t.contains('ሮሜ') && t.contains('1')), isTrue);
      expect(refTargets.any((t) => t.contains('ገላትያ') && t.contains('3')), isTrue);
      expect(refs.first.targetPreviewText, isNotEmpty);
    });

    test('Matthew 1:1 in 1954 (Book 40) returns identical authentic cross references', () async {
      final refs = await repo.getCrossReferencesForVerse(
        bookNumber: 40, // Matthew in 1954
        chapter: 1,
        verse: 1,
        translationId: 1,
      );

      expect(refs, isNotEmpty);
      final refTargets = refs.map((r) => '${r.targetBookName} ${r.targetChapter}').toList();
      expect(refTargets.any((t) => t.contains('ዘፍጥረት') && t.contains('22')), isTrue);
      expect(refTargets.any((t) => t.contains('ሮሜ') && t.contains('1')), isTrue);
    });

    test('Psalm 23:1 in 81 Canon (Book 28) returns Good Shepherd cross references', () async {
      final refs = await repo.getCrossReferencesForVerse(
        bookNumber: 28, // Psalms in 81 Canon
        chapter: 23,
        verse: 1,
        translationId: 2,
      );

      expect(refs, isNotEmpty);
      final refTargets = refs.map((r) => '${r.targetBookName} ${r.targetChapter}').toList();
      expect(refTargets.any((t) => t.contains('ዮሐንስ') && t.contains('10')), isTrue);
      expect(refTargets.any((t) => t.contains('ፊልጵስዩስ') && t.contains('4')), isTrue);
    });

    test('KJV cross references render in authentic English book names and text', () async {
      final refs = await repo.getCrossReferencesForVerse(
        bookNumber: 40, // Matthew in KJV
        chapter: 1,
        verse: 1,
        translationId: 3, // KJV
      );

      expect(refs, isNotEmpty);
      expect(refs.any((r) => r.targetBookName == 'Genesis' || r.targetBookName == 'Romans'), isTrue);
      expect(refs.first.targetPreviewText, isNotEmpty);
    });
  });
}
