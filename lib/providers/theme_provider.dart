import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

final themeConfigProvider =
    StateNotifierProvider<ThemeConfigNotifier, ReaderThemeConfig>((ref) {
  return ThemeConfigNotifier();
});

class ThemeConfigNotifier extends StateNotifier<ReaderThemeConfig> {
  ThemeConfigNotifier() : super(const ReaderThemeConfig()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('reader_theme_mode') ?? 0;
    final fontSize = prefs.getDouble('reader_font_size') ?? 19.0;
    final lineSpacing = prefs.getDouble('reader_line_spacing') ?? 1.75;
    final useGeezNumerals = prefs.getBool('reader_use_geez_numerals') ?? false;

    state = ReaderThemeConfig(
      mode: ReaderThemeMode.values[modeIndex.clamp(0, 2)],
      fontSize: fontSize,
      lineSpacing: lineSpacing,
      useGeezNumerals: useGeezNumerals,
    );
  }

  Future<void> setMode(ReaderThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reader_theme_mode', mode.index);
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size.clamp(14.0, 36.0));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('reader_font_size', state.fontSize);
  }

  Future<void> setLineSpacing(double spacing) async {
    state = state.copyWith(lineSpacing: spacing.clamp(1.3, 2.5));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('reader_line_spacing', state.lineSpacing);
  }

  Future<void> toggleGeezNumerals() async {
    state = state.copyWith(useGeezNumerals: !state.useGeezNumerals);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reader_use_geez_numerals', state.useGeezNumerals);
  }

  Future<void> toggleParagraphMode(bool isParagraph) async {
    state = state.copyWith(isParagraphMode: isParagraph);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reader_is_paragraph_mode', isParagraph);
  }

  Future<void> setThemeMode(ReaderThemeMode mode) => setMode(mode);
}
