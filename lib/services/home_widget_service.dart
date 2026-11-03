import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  HomeWidgetService._();

  /// Updates the Android/iOS home screen widget with the curated verse of the day
  static Future<void> updateDailyVerseWidget({
    required String verseText,
    required String reference,
    required String theme,
  }) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await HomeWidget.saveWidgetData<String>('daily_verse_text', '“$verseText”');
        await HomeWidget.saveWidgetData<String>('daily_verse_reference', '— $reference');
        await HomeWidget.saveWidgetData<String>('daily_verse_theme', theme);
        await HomeWidget.updateWidget(
          name: 'DailyVerseWidgetProvider',
          androidName: 'DailyVerseWidgetProvider',
        );
      } catch (e) {
        debugPrint('HomeWidget update error (non-fatal): $e');
      }
    }
  }
}
