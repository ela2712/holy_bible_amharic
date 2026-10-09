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
  final String fontFamily;

  const ReaderThemeConfig({
    this.mode = ReaderThemeMode.light,
    this.fontSize = 19.0,
    this.lineSpacing = 1.75,
    this.useGeezNumerals = false,
    this.fontFamily = 'NotoSansEthiopic',
  });

  ReaderThemeConfig copyWith({
    ReaderThemeMode? mode,
    double? fontSize,
    double? lineSpacing,
    bool? useGeezNumerals,
    String? fontFamily,
  }) {
    return ReaderThemeConfig(
      mode: mode ?? this.mode,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      useGeezNumerals: useGeezNumerals ?? this.useGeezNumerals,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  Color get backgroundColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFFFAF8F5); // Soft ivory liturgical parchment
      case ReaderThemeMode.sepia:
        return const Color(0xFFF3EBDB); // Ancient monastery parchment
      case ReaderThemeMode.dark:
        return const Color(0xFF131313); // Obsidian night
    }
  }

  Color get surfaceColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return Colors.white;
      case ReaderThemeMode.sepia:
        return const Color(0xFFE8DECA);
      case ReaderThemeMode.dark:
        return const Color(0xFF1E1E1E);
    }
  }

  Color get textColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF221A16);
      case ReaderThemeMode.sepia:
        return const Color(0xFF382B1B);
      case ReaderThemeMode.dark:
        return const Color(0xFFE6E2DE);
    }
  }

  Color get secondaryTextColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF6E645C);
      case ReaderThemeMode.sepia:
        return const Color(0xFF6F5E48);
      case ReaderThemeMode.dark:
        return const Color(0xFFA59F98);
    }
  }

  Color get accentColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF7D1A25); // Catena Imperial Burgundy
      case ReaderThemeMode.sepia:
        return const Color(0xFF7A1C24); // Warm liturgical burgundy
      case ReaderThemeMode.dark:
        return const Color(0xFFD4AF37); // Liturgical Gold
    }
  }

  Color get goldAccent {
    return const Color(0xFFC5A059); // Byzantine / Church Gold
  }

  Color get commentaryCardColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFFF6F1E9);
      case ReaderThemeMode.sepia:
        return const Color(0xFFE2D6C0);
      case ReaderThemeMode.dark:
        return const Color(0xFF252220);
    }
  }

  TextStyle getVerseStyle() {
    return GoogleFonts.notoSansEthiopic(
      fontSize: fontSize,
      height: lineSpacing,
      color: textColor,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle getVerseNumberStyle() {
    return GoogleFonts.notoSansEthiopic(
      fontSize: fontSize * 0.75,
      fontWeight: FontWeight.w700,
      color: accentColor.withValues(alpha: 0.9),
    );
  }

  TextStyle getHeadingStyle() {
    return GoogleFonts.notoSansEthiopic(
      fontSize: fontSize * 1.05,
      fontWeight: FontWeight.w700,
      color: accentColor,
      height: 1.4,
    );
  }

  ThemeData toThemeData() {
    final isDark = mode == ReaderThemeMode.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        surface: surfaceColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0.5,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0.8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerColor: isDark ? Colors.white12 : Colors.black12,
    );
  }
}
