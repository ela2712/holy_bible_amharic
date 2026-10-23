import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/providers/app_language_provider.dart';
import 'package:holy_bible_amharic/ui/widgets/ftue_welcome_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FTUE Reverent Welcome Sheet Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Renders properly in Amharic with sacred Ethiopian 81 Canon identity', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(appLanguageProvider.notifier).setLanguageMode(AppLanguageMode.amharic);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: FtueWelcomeSheet(),
            ),
          ),
        ),
      );

      // Verify sacred Orthodox headers
      expect(find.text('እንኳን ደህና መጡ'), findsOneWidget);
      expect(find.text('የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 መጻሕፍት ቀኖና'), findsOneWidget);

      // Verify the 4 feature cards
      expect(find.text('81 ሙሉ ቀኖና'), findsOneWidget);
      expect(find.text('የፊደላት አንድነት ፍለጋ'), findsOneWidget);
      expect(find.text('የንባብ ምልክቶችና ማስታወሻ'), findsOneWidget);
      expect(find.text('ኦፍላይንና ከማስታወቂያ የጸዳ'), findsOneWidget);

      // Verify reverent CTA button
      expect(find.text('ወደ ንባብ ግባ'), findsOneWidget);
    });

    testWidgets('Renders properly in English when English UI is selected', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(appLanguageProvider.notifier).setLanguageMode(AppLanguageMode.english);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: FtueWelcomeSheet(),
            ),
          ),
        ),
      );

      // Verify English sacred headers
      expect(find.text('Welcome to Holy Bible'), findsOneWidget);
      expect(find.text('Ethiopian Orthodox Tewahedo 81 Books Canon'), findsOneWidget);

      // Verify the 4 feature cards
      expect(find.text('81 Orthodox Canon'), findsOneWidget);
      expect(find.text('Smart Homophone Search'), findsOneWidget);
      expect(find.text('Intuitive Reading & Study'), findsOneWidget);
      expect(find.text('100% Offline & Ad-Free'), findsOneWidget);

      // Verify reverent CTA button
      expect(find.text('Start Reading'), findsOneWidget);
    });

    testWidgets('Tapping Start Reading marks ftue_welcome_shown_v1 as true in SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FtueWelcomeSheet(),
            ),
          ),
        ),
      );

      final startButton = find.text('ወደ ንባብ ግባ');
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(FtueWelcomeSheet.prefsKey), true);
    });
  });
}
