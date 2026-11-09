import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holy_bible_amharic/services/bahire_hasab_service.dart';
import 'package:holy_bible_amharic/core/theme/app_theme.dart';
import 'package:holy_bible_amharic/services/bible_repository.dart';
import 'package:holy_bible_amharic/providers/search_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Version Enhancements & Regression Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      GoogleFonts.config.allowRuntimeFetching = false;
    });

    test('Season of Flowers does NOT recommend Filseta plan', () {
      // Tikimt 15, 2017 E.C. (approx Oct 25, 2024 G.C.) falls squarely in Season of Flowers (ዘመነ ጽጌ)
      final testDate = DateTime(2024, 10, 25);
      final status = BahireHasabService.getCurrentLiturgicalStatus(testDate);
      
      expect(status['seasonTitle'], 'ዘመነ ጽጌ');
      expect(status['seasonTitleEn'], 'Season of Flowers');
      // recommendedPlanId must NOT be 'filseta_16'
      expect(status['recommendedPlanId'], isNull);
    });

    test('English font options are supported in ReaderThemeConfig', () {
      const config = ReaderThemeConfig(
        fontFamily: 'NotoSerif',
        englishFontFamily: 'Cormorant',
      );
      expect(config.englishFontFamily, 'Cormorant');

      final merriweatherConfig = config.copyWith(englishFontFamily: 'Merriweather');
      expect(merriweatherConfig.englishFontFamily, 'Merriweather');

      final loraConfig = config.copyWith(englishFontFamily: 'Lora');
      expect(loraConfig.englishFontFamily, 'Lora');

      final interConfig = config.copyWith(englishFontFamily: 'Inter');
      expect(interConfig.englishFontFamily, 'Inter');
    });

    test('Search history ignores single-character keystrokes', () async {
      final repo = BibleRepository();
      final notifier = SearchNotifier(repo, 2);
      
      // Single character keystrokes should be rejected
      await notifier.saveToRecentSearches('G');
      await notifier.saveToRecentSearches(' ');
      expect(notifier.state.recentSearches.isEmpty, isTrue);

      // Full words or phrases should be saved
      await notifier.saveToRecentSearches('Good');
      expect(notifier.state.recentSearches, contains('Good'));

      await notifier.saveToRecentSearches('እግዚአብሔር');
      expect(notifier.state.recentSearches, contains('እግዚአብሔር'));
    });
  });
}
