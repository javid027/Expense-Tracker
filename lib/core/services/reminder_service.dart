import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService._();

  static final plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await plugin.initialize(settings);
      await plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  static const exactAlarmsNotPermitted = 'exact_alarms_not_permitted';

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) {
      await init();
    }

    if (!_initialized) return;

    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // Cancel old reminder before creating new one
    await plugin.cancel(1001);

    await plugin.zonedSchedule(
      1001,
      'Finora Reminder',
      'Take a minute to review your spending today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'finora_daily',
          'Daily reminders',
          channelDescription: 'Daily finance reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyReminder() async {
    try {
      await plugin.cancel(1001);
    } catch (_) {}
  }
}

class ReminderPermissionException implements Exception {
  ReminderPermissionException(this.message);

  final String message;

  @override
  String toString() => message;
}
