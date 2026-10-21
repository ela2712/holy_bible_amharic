import 'package:flutter_test/flutter_test.dart';
import 'package:holy_bible_amharic/providers/notification_provider.dart';
import 'package:holy_bible_amharic/services/notification_service.dart';

void main() {
  group('DailyNotificationState & Formatting Tests', () {
    test('Default values are reverent and sensible', () {
      const state = DailyNotificationState();
      expect(state.isEnabled, isFalse);
      expect(state.hour, equals(7));
      expect(state.minute, equals(0));
      expect(state.formattedTime, equals('7:00 AM'));
      expect(state.formatDisplayTime(false), equals('ጥዋት 7:00'));
      expect(state.formatDisplayTime(true), equals('7:00 AM'));
    });

    test('Formatted 12-hour time handles AM and PM correctly', () {
      const morning = DailyNotificationState(hour: 6, minute: 30);
      expect(morning.formattedTime, equals('6:30 AM'));
      expect(morning.formatDisplayTime(false), equals('ጥዋት 6:30'));
      expect(morning.formatDisplayTime(true), equals('6:30 AM'));

      const noon = DailyNotificationState(hour: 12, minute: 0);
      expect(noon.formattedTime, equals('12:00 PM'));
      expect(noon.formatDisplayTime(false), equals('ከሰዓት 12:00'));
      expect(noon.formatDisplayTime(true), equals('12:00 PM'));

      const evening = DailyNotificationState(hour: 20, minute: 15);
      expect(evening.formattedTime, equals('8:15 PM'));
      expect(evening.formatDisplayTime(false), equals('ከሰዓት 8:15'));
      expect(evening.formatDisplayTime(true), equals('8:15 PM'));

      const midnight = DailyNotificationState(hour: 0, minute: 5);
      expect(midnight.formattedTime, equals('12:05 AM'));
    });

    test('copyWith properly updates individual fields', () {
      const initial = DailyNotificationState(isEnabled: false, hour: 7, minute: 0);

      final enabled = initial.copyWith(isEnabled: true);
      expect(enabled.isEnabled, isTrue);
      expect(enabled.hour, equals(7));
      expect(enabled.minute, equals(0));

      final changedTime = initial.copyWith(hour: 8, minute: 45);
      expect(changedTime.isEnabled, isFalse);
      expect(changedTime.hour, equals(8));
      expect(changedTime.minute, equals(45));
    });
  });

  group('NotificationService Constants & Configuration Tests', () {
    test('Service instance and notification channel constants', () {
      final service = NotificationService.instance;
      expect(service, isNotNull);
      expect(NotificationService.dailyVerseNotificationId, equals(8101));
      expect(NotificationService.channelId, equals('daily_verse_channel'));
    });
  });
}
