import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart' as ftz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    final localTz = await ftz.FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz.identifier));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      const AndroidNotificationChannel(
        'mental_mantra_reminders',
        'Mental Mantra Reminders',
        description: 'Daily wellness reminders',
        importance: Importance.high,
        playSound: true,
      ),
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap — navigate based on payload
  }

  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _local.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mental_mantra_reminders',
          'Mental Mantra Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> cancel(int id) async => _local.cancel(id);
  static Future<void> cancelAll() async => _local.cancelAll();

  static Future<void> scheduleDefaultReminders() async {
    await scheduleDailyReminder(
      id: 1,
      title: 'Time to Meditate',
      body: 'Take a few minutes to center yourself.',
      hour: 8,
      minute: 0,
    );
    await scheduleDailyReminder(
      id: 2,
      title: 'How was your day?',
      body: 'Journal your thoughts and feelings.',
      hour: 21,
      minute: 0,
    );
    await scheduleDailyReminder(
      id: 3,
      title: 'Hydration Check',
      body: 'Remember to drink water for your wellbeing.',
      hour: 14,
      minute: 0,
    );
  }
}
