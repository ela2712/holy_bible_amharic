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
        return const Color(0xFFFAFAF7);
      case ReaderThemeMode.sepia:
        return const Color(0xFFF4ECD8);
      case ReaderThemeMode.dark:
        return const Color(0xFF121212);
    }
  }

  Color get surfaceColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return Colors.white;
      case ReaderThemeMode.sepia:
        return const Color(0xFFEADBBE);
      case ReaderThemeMode.dark:
        return const Color(0xFF1E1E1E);
    }
  }

  Color get textColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF1E1E1E);
      case ReaderThemeMode.sepia:
        return const Color(0xFF382C1E);
      case ReaderThemeMode.dark:
        return const Color(0xFFE2E2E2);
    }
  }

  Color get secondaryTextColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF666666);
      case ReaderThemeMode.sepia:
        return const Color(0xFF6B5840);
      case ReaderThemeMode.dark:
        return const Color(0xFFA0A0A0);
    }
  }

  Color get accentColor {
    switch (mode) {
      case ReaderThemeMode.light:
        return const Color(0xFF8B2500); // Deep Ethiopian crimson
      case ReaderThemeMode.sepia:
        return const Color(0xFF8B4513); // Saddle brown
      case ReaderThemeMode.dark:
        return const Color(0xFFD4AF37); // Royal gold
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
      fontWeight: FontWeight.w600,
      color: accentColor.withOpacity(0.9),
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
}
