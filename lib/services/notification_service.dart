import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1;
  static const String _hourKey = 'notification_hour';
  static const String _minuteKey = 'notification_minute';
  static const String _enabledKey = 'notification_enabled';

  static const int _eodReminderId = 2;
  static const String _eodHourKey = 'eod_notification_hour';
  static const String _eodMinuteKey = 'eod_notification_minute';
  static const String _eodEnabledKey = 'eod_notification_enabled';

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await _plugin.cancel(_dailyReminderId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Task Tracker',
      "Check your tasks for today — let's get things done!",
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily morning task reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);
    await prefs.setBool(_enabledKey, true);
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
  }

  Future<void> scheduleEndOfDayReminder(int hour, int minute) async {
    await _plugin.cancel(_eodReminderId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _eodReminderId,
      'Task Tracker',
      'Have you completed all your tasks today? Complete your end of day routine!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'eod_reminder',
          'End of Day Reminder',
          channelDescription: 'Daily end of day task reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_eodHourKey, hour);
    await prefs.setInt(_eodMinuteKey, minute);
    await prefs.setBool(_eodEnabledKey, true);
  }

  Future<void> cancelEndOfDayReminder() async {
    await _plugin.cancel(_eodReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eodEnabledKey, false);
  }

  Future<({bool enabled, int hour, int minute, bool eodEnabled, int eodHour, int eodMinute})> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      enabled: prefs.getBool(_enabledKey) ?? false,
      hour: prefs.getInt(_hourKey) ?? 8,
      minute: prefs.getInt(_minuteKey) ?? 0,
      eodEnabled: prefs.getBool(_eodEnabledKey) ?? false,
      eodHour: prefs.getInt(_eodHourKey) ?? 20,
      eodMinute: prefs.getInt(_eodMinuteKey) ?? 0,
    );
  }
}
