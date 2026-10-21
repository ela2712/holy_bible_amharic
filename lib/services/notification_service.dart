import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'bible_repository.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();
  factory NotificationService() => instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static const int dailyVerseNotificationId = 8101;
  static const String channelId = 'daily_verse_channel';

  /// Initializes the local notification plugin and timezone data safely.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService initialization skipped or failed: $e');
    }
  }

  /// Requests notification permission on Android 13+ (TIRAMISU) and iOS.
  Future<bool> requestPermission() async {
    try {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }

  /// Calculates the next occurrence of [hour] and [minute] in local time.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Builds notification details with expandable BigTextStyle for scripture verses.
  NotificationDetails _buildNotificationDetails({
    required String title,
    required String body,
    required bool isEnglish,
  }) {
    final subText = isEnglish ? 'Holy Bible 81' : 'መጽሐፍ ቅዱስ 81';
    final channelName = isEnglish ? 'Daily Verse' : 'ዕለታዊ ጥቅስ';
    final channelDescription = isEnglish
        ? 'Daily Holy Scripture Verse Reminder'
        : 'ዕለታዊ የመጽሐፍ ቅዱስ ቃል ማስታወሻ';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: subText,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );
  }

  /// Schedules a recurring daily verse push notification at [hour]:[minute].
  /// References the sacred 81 Orthodox Canon daily verse.
  Future<void> scheduleDailyVerse({
    required int hour,
    required int minute,
    bool isEnglish = false,
  }) async {
    try {
      await initialize();

      // Ensure 81 Canon daily verse data is loaded
      final verseData = await BibleRepository.instance.getDailyVerse(2);
      final reference = verseData != null
          ? '${verseData['book_name']} ${verseData['chapter']}:${verseData['verse']}'
          : (isEnglish ? 'John 1:1' : 'የዮሐንስ ወንጌል 1:1');
      final verseText = verseData != null
          ? verseData['text'] as String
          : (isEnglish
              ? 'In the beginning was the Word, and the Word was with God, and the Word was God.'
              : 'በመጀመሪያ ቃል ነበረ፥ ቃልም በእግዚአብሔር ዘንድ ነበረ፥ ቃልም እግዚአብሔር ነበረ።');

      final title = isEnglish
          ? 'Daily Scripture • $reference'
          : 'ዕለታዊ ቃል • $reference';
      final body = verseText;

      final details = _buildNotificationDetails(
        title: title,
        body: body,
        isEnglish: isEnglish,
      );

      final scheduledDate = _nextInstanceOfTime(hour, minute);

      // Cancel previous schedule before setting new
      await cancelDailyVerse();

      await _notificationsPlugin.zonedSchedule(
        id: dailyVerseNotificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Daily verse scheduled for $scheduledDate (ID: $dailyVerseNotificationId)');
    } catch (e) {
      debugPrint('Failed to schedule daily verse notification: $e');
    }
  }

  /// Cancels the scheduled daily verse notification.
  Future<void> cancelDailyVerse() async {
    try {
      await _notificationsPlugin.cancel(id: dailyVerseNotificationId);
      debugPrint('Cancelled daily verse notification schedule');
    } catch (e) {
      debugPrint('Failed to cancel daily verse notification: $e');
    }
  }

  /// Shows an immediate test/preview notification with today's 81 Canon verse.
  Future<void> showDailyVerseNow({bool isEnglish = false}) async {
    try {
      await initialize();
      final verseData = await BibleRepository.instance.getDailyVerse(2);
      final reference = verseData != null
          ? '${verseData['book_name']} ${verseData['chapter']}:${verseData['verse']}'
          : (isEnglish ? 'John 1:1' : 'የዮሐንስ ወንጌል 1:1');
      final verseText = verseData != null
          ? verseData['text'] as String
          : (isEnglish
              ? 'In the beginning was the Word, and the Word was with God, and the Word was God.'
              : 'በመጀመሪያ ቃል ነበረ፥ ቃልም በእግዚአብሔር ዘንድ ነበረ፥ ቃልም እግዚአብሔር ነበረ።');

      final title = isEnglish
          ? 'Daily Scripture • $reference'
          : 'ዕለታዊ ቃል • $reference';
      final details = _buildNotificationDetails(
        title: title,
        body: verseText,
        isEnglish: isEnglish,
      );

      await _notificationsPlugin.show(
        id: dailyVerseNotificationId + 1,
        title: title,
        body: verseText,
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Failed to show test notification: $e');
    }
  }
}
