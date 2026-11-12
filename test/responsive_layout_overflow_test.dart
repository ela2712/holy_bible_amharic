import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/models/book.dart';
import 'package:holy_bible_amharic/models/translation.dart';
import 'package:holy_bible_amharic/providers/app_language_provider.dart';
import 'package:holy_bible_amharic/providers/bible_state.dart';
import 'package:holy_bible_amharic/services/bible_repository.dart';
import 'package:holy_bible_amharic/ui/screens/book_selector_screen.dart';
import 'package:holy_bible_amharic/ui/screens/home_dashboard_screen.dart';
import 'package:holy_bible_amharic/ui/screens/liturgical_calendar_screen.dart';
import 'package:holy_bible_amharic/ui/screens/reading_plans_screen.dart';

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

  const sampleBooks = [
    Book(
      id: 1,
      translationId: 2,
      bookNumber: 1,
      name: 'ኦሪት ዘፍጥረት',
      shortName: 'ዘፍ',
      nameEn: 'Genesis',
      testament: 'OT',
      orderIndex: 1,
      totalChapters: 50,
    ),
    Book(
      id: 13,
      translationId: 2,
      bookNumber: 13,
      name: 'መጽሐፈ ዜና መዋዕል ቀዳማዊ',
      shortName: '1 ዜና',
      nameEn: '1 Chronicles',
      testament: 'OT',
      orderIndex: 13,
      totalChapters: 29,
    ),
    Book(
      id: 24,
      translationId: 2,
      bookNumber: 24,
      name: 'መኃልየ መኃልይ ዘሰሎሞን',
      shortName: 'መኃ',
      nameEn: 'Song of Solomon',
      testament: 'OT',
      orderIndex: 24,
      totalChapters: 8,
    ),
    Book(
      id: 40,
      translationId: 2,
      bookNumber: 40,
      name: 'የማቴዎስ ወንጌል',
      shortName: 'ማቴ',
      nameEn: 'Matthew',
      testament: 'NT',
      orderIndex: 40,
      totalChapters: 28,
    ),
  ];

  Future<void> pumpAtNarrowPhone(
    WidgetTester tester,
    Widget child, {
    AppLanguageMode mode = AppLanguageMode.amharic,
  }) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer(
      overrides: [
        bibleStateProvider.overrideWith(
          (ref) => _FakeBibleStateNotifier(canon81, sampleBooks),
        ),
        bibleRepositoryProvider.overrideWithValue(_FakeBibleRepository()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appLanguageProvider.notifier).setLanguageMode(mode);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: child),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  }

  group('Narrow Viewport (360dp) Overflow Regression Tests', () {
    testWidgets('ReadingPlansScreen renders and scrolls without overflow in Amharic & English', (tester) async {
      for (final mode in [AppLanguageMode.amharic, AppLanguageMode.english]) {
        await pumpAtNarrowPhone(
          tester,
          ReadingPlansScreen(onNavigateToReader: (_) {}),
          mode: mode,
        );

        final scrollable = find.byType(Scrollable).first;
        for (int i = 0; i < 4; i++) {
          await tester.drag(scrollable, const Offset(0, -350));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('HomeDashboardScreen renders without overflow on 360dp phone', (tester) async {
      for (final mode in [AppLanguageMode.amharic, AppLanguageMode.english]) {
        await pumpAtNarrowPhone(
          tester,
          HomeDashboardScreen(onNavigateTab: (_) {}),
          mode: mode,
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('BookSelectorScreen renders long Amharic/English book names without overflow', (tester) async {
      await pumpAtNarrowPhone(
        tester,
        const Scaffold(body: BookSelectorScreen()),
        mode: AppLanguageMode.amharic,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('LiturgicalCalendarScreen renders selected day card without overflow', (tester) async {
      await pumpAtNarrowPhone(
        tester,
        const LiturgicalCalendarScreen(),
        mode: AppLanguageMode.amharic,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

class _FakeBibleStateNotifier extends StateNotifier<BibleViewState>
    implements BibleStateNotifier {
  _FakeBibleStateNotifier(Translation translation, List<Book> books)
      : super(
          BibleViewState(
            translations: [translation],
            currentTranslation: translation,
            books: books,
            currentBook: books[1], // 1 Chronicles (long Amharic title)
            currentChapter: 12,
            isLoading: false,
          ),
        );

  @override
  Future<void> init() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBibleRepository implements BibleRepository {
  @override
  Future<Map<String, dynamic>> getDailyVerse(int translationId) async {
    return {
      'book_id': 1,
      'book_name': 'መኃልየ መኃልይ ዘሰሎሞን',
      'chapter': 2,
      'verse': 1,
      'text': 'እኔ የሳሮን ጽጌረዳ የቈላም አበባ ነኝ።',
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
