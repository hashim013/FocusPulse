import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      // FIX 1: getLocalTimezone returns an object in some versions.
      final dynamic timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(
        tz.getLocation(
          timeZoneInfo is String ? timeZoneInfo : timeZoneInfo.name,
        ),
      );
    } catch (e) {
      debugPrint('Timezone initialization error: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(settings: initializationSettings);

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  /// Toggle the generic daily study reminder on/off
  static Future<void> toggleDailyReminder(
    bool enable, [
    TimeOfDay? time,
  ]) async {
    if (enable && time != null) {
      // FIX 3: Use native Dart local time for calculation to bypass any flutter_timezone failures.
      // This mathematically guarantees the hour/minute perfectly aligns with the device's actual clock.
      final localNow = DateTime.now();
      DateTime scheduledDateTime = DateTime(
        localNow.year,
        localNow.month,
        localNow.day,
        time.hour,
        time.minute,
      );

      if (scheduledDateTime.isBefore(localNow)) {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      }

      // Convert this exact, correct moment into tz.local (even if tz.local defaulted to UTC)
      final scheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Study Reminder 📚',
        body: 'Time to log your focus session today!',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Daily Reminder',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // repeats daily
      );
    } else {
      await _notificationsPlugin.cancel(id: 0);
    }
  }
}
