import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bible_state.dart';

enum AppLanguageMode {
  auto, // Matches current translation: KJV -> English, 81 & 1954 -> Amharic
  amharic, // Force Amharic UI
  english, // Force English UI
}

class AppLanguageNotifier extends StateNotifier<AppLanguageMode> {
  AppLanguageNotifier() : super(AppLanguageMode.auto) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language_mode');
    if (saved == 'amharic') {
      state = AppLanguageMode.amharic;
    } else if (saved == 'english') {
      state = AppLanguageMode.english;
    } else {
      state = AppLanguageMode.auto;
    }
  }

  Future<void> setLanguageMode(AppLanguageMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language_mode', mode.name);
  }
}

final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, AppLanguageMode>((ref) {
  return AppLanguageNotifier();
});

/// Computes whether the current UI / interface language is English.
final isEnglishUiProvider = Provider<bool>((ref) {
  final mode = ref.watch(appLanguageProvider);
  switch (mode) {
    case AppLanguageMode.amharic:
      return false;
    case AppLanguageMode.english:
      return true;
    case AppLanguageMode.auto:
      final currentTrans =
          ref.watch(bibleStateProvider.select((s) => s.currentTranslation));
      return currentTrans?.id == 3;
  }
});
