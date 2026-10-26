import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ReaderThemeMode {
  light,
  sepia,
  dark,
}

class ReaderThemeConfig {
  final ReaderThemeMode mode;
  final double fontSize;
  final double lineSpacing;
  final bool useGeezNumerals;
  final String fontFamily; // 'Sans' or 'Serif'
  final bool isParagraphMode;

  const ReaderThemeConfig({
    this.mode = ReaderThemeMode.light,
    this.fontSize = 19.0,
    this.lineSpacing = 1.75,
    this.useGeezNumerals = false,
    this.fontFamily = 'Serif',
    this.isParagraphMode = false,
  });

  double get lineHeight => lineSpacing;

  ThemeData toThemeData() => AppTheme.buildTheme(this);

  ReaderThemeConfig copyWith({
    ReaderThemeMode? mode,
    double? fontSize,
    double? lineSpacing,
    double? lineHeight,
    bool? useGeezNumerals,
    String? fontFamily,
    bool? isParagraphMode,
  }) {
    return ReaderThemeConfig(
      mode: mode ?? this.mode,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? lineHeight ?? this.lineSpacing,
      useGeezNumerals: useGeezNumerals ?? this.useGeezNumerals,
      fontFamily: fontFamily ?? this.fontFamily,
      isParagraphMode: isParagraphMode ?? this.isParagraphMode,
    );
  }

  /// Minimalist Editorial Canvas
  Color get backgroundColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFFFAF9F6); // Warm Ivory Alabaster
      case ReaderThemeMode.sepia:
        return const Color(0xFFF4EFE6); // Archival Parchment
      case ReaderThemeMode.dark:
        return const Color(0xFF0E1014); // True Obsidian Charcoal
    }
  }

  /// Elevated Card & Sheet Surface
  Color get surfaceColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFFFFFFFF);
      case ReaderThemeMode.sepia:
        return const Color(0xFFEFE8DC);
      case ReaderThemeMode.dark:
        return const Color(0xFF171A21);
    }
  }

  /// Subtle Hairline Border
  Color get cardBorderColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFFE6E4DD);
      case ReaderThemeMode.sepia:
        return const Color(0xFFDFD5C4);
      case ReaderThemeMode.dark:
        return const Color(0xFF262A34);
    }
  }

  /// Primary Ink Color
  Color get textColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF18181B); // Crisp Charcoal Ink
      case ReaderThemeMode.sepia:
        return const Color(0xFF26221E); // Deep Espresso Ink
      case ReaderThemeMode.dark:
        return const Color(0xFFF3F4F6); // Soft Warm White
    }
  }

  /// Muted Secondary Ink
  Color get secondaryTextColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF64646A);
      case ReaderThemeMode.sepia:
        return const Color(0xFF6E6256);
      case ReaderThemeMode.dark:
        return const Color(0xFF9CA3AF);
    }
  }

  /// Primary Brand & Commentary Accent (Emerald Green Theme)
  Color get accentColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF047857); // Deep Emerald Forest Green
      case ReaderThemeMode.sepia:
        return const Color(0xFF065F46); // Archival Dark Emerald
      case ReaderThemeMode.dark:
        return const Color(0xFF10B981); // Luminous Mint Emerald
    }
  }

  /// Secondary Accent (Liturgical Jade / Teal)
  Color get goldAccent {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF0D9488); // Liturgical Teal-Jade
      case ReaderThemeMode.sepia:
        return const Color(0xFF0F766E); // Deep Archival Teal
      case ReaderThemeMode.dark:
        return const Color(0xFF34D399); // Luminous Jade
    }
  }
}

class AppTheme {
  static ThemeData buildTheme(ReaderThemeConfig config) {
    final isDark = config.mode == ReaderThemeMode.dark;
    final baseTheme = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);

    TextTheme textTheme;
    switch (config.fontFamily) {
      case 'Abyssinica':
        textTheme = baseTheme.textTheme.apply(
          fontFamily: 'AbyssinicaSIL',
          fontFamilyFallback: const ['Abyssinica SIL', 'Nyala', 'Noto Serif Ethiopic'],
        );
        break;
      case 'Sans':
        textTheme = baseTheme.textTheme.apply(
          fontFamily: 'NotoSansEthiopic',
          fontFamilyFallback: const ['Noto Sans Ethiopic', 'Nyala', 'sans-serif'],
        );
        break;
      case 'PowerGeez':
        textTheme = baseTheme.textTheme.apply(
          fontFamily: 'Power Ge\'ez Unicode',
          fontFamilyFallback: const [
            'PowerGeez',
            'Power Ge\'ez',
            'Nyala',
            'WashRa',
            'NotoSerifEthiopic',
            'AbyssinicaSIL',
          ],
        );
        break;
      case 'Serif':
      default:
        textTheme = baseTheme.textTheme.apply(
          fontFamily: 'NotoSerifEthiopic',
          fontFamilyFallback: const ['Noto Serif Ethiopic', 'Nyala', 'serif'],
        );
        break;
    }

    return baseTheme.copyWith(
      scaffoldBackgroundColor: config.backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: config.accentColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        surface: config.surfaceColor,
        primary: config.accentColor,
        secondary: config.goldAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: config.backgroundColor,
        foregroundColor: config.textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansEthiopic(
          color: config.textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: config.surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: config.cardBorderColor, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: config.cardBorderColor,
        thickness: 1,
      ),
      textTheme: textTheme.apply(
        bodyColor: config.textColor,
        displayColor: config.textColor,
      ),
    );
  }
}
