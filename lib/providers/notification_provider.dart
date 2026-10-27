import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class DailyNotificationState {
  final bool isEnabled;
  final int hour;
  final int minute;

  const DailyNotificationState({
    this.isEnabled = false,
    this.hour = 7,
    this.minute = 0,
  });

  DailyNotificationState copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
  }) {
    return DailyNotificationState(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  /// Formatted standard 12-hour time (e.g. "7:00 AM" or "6:30 PM")
  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  /// Formatted Amharic / Ethiopian liturgical time description
  String formatDisplayTime(bool isEnglish) {
    if (isEnglish) return formattedTime;
    final period = hour >= 12 ? 'ከሰዓት' : 'ጥዋት';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$period $displayHour:$displayMinute';
  }
}

class DailyNotificationNotifier extends StateNotifier<DailyNotificationState> {
  DailyNotificationNotifier() : super(const DailyNotificationState()) {
    _loadPreferences();
  }

  static const String _prefKeyEnabled = 'daily_verse_notif_enabled';
  static const String _prefKeyHour = 'daily_verse_notif_hour';
  static const String _prefKeyMinute = 'daily_verse_notif_minute';

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_prefKeyEnabled) ?? false;
      final hour = prefs.getInt(_prefKeyHour) ?? 7;
      final minute = prefs.getInt(_prefKeyMinute) ?? 0;

      state = DailyNotificationState(
        isEnabled: isEnabled,
        hour: hour,
        minute: minute,
      );

      if (isEnabled) {
        await NotificationService.instance.scheduleDailyVerse(
          hour: hour,
          minute: minute,
        );
      }
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }
  }

  Future<bool> toggleDailyNotification(bool enabled, {bool isEnglish = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (enabled) {
      final hasPermission = await NotificationService.instance.requestPermission();
      if (!hasPermission) {
        await prefs.setBool(_prefKeyEnabled, false);
        state = state.copyWith(isEnabled: false);
        return false;
      }
      await prefs.setBool(_prefKeyEnabled, true);
      await NotificationService.instance.scheduleDailyVerse(
        hour: state.hour,
        minute: state.minute,
        isEnglish: isEnglish,
      );
      state = state.copyWith(isEnabled: true);
      return true;
    } else {
      await prefs.setBool(_prefKeyEnabled, false);
      await NotificationService.instance.cancelDailyVerse();
      state = state.copyWith(isEnabled: false);
      return true;
    }
  }

  Future<void> updateTime(TimeOfDay time, {bool isEnglish = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyHour, time.hour);
    await prefs.setInt(_prefKeyMinute, time.minute);

    state = state.copyWith(hour: time.hour, minute: time.minute);

    if (state.isEnabled) {
      await NotificationService.instance.scheduleDailyVerse(
        hour: time.hour,
        minute: time.minute,
        isEnglish: isEnglish,
      );
    }
  }

  Future<bool> sendTestNotification({bool isEnglish = false}) async {
    return await NotificationService.instance.showDailyVerseNow(isEnglish: isEnglish);
  }
}

final dailyNotificationProvider =
    StateNotifierProvider<DailyNotificationNotifier, DailyNotificationState>((ref) {
  return DailyNotificationNotifier();
});
