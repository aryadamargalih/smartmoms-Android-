import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

/// Wrapper untuk flutter_local_notifications.
/// Semua notifikasi di sini murni lokal di device, TIDAK butuh backend/server.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'smartmoms_health_channel',
    'Notifikasi SmartMoms',
    channelDescription: 'Pengingat & alert kesehatan SmartMoms',
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  /// Notifikasi langsung — dipakai untuk alert BPM / tekanan darah abnormal.
  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: _androidDetails),
    );
  }

  /// Notifikasi berulang tiap hari di jam tertentu — untuk reminder aktivitas/vitamin.
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time),
      const NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// ID unik tiap jenis notifikasi (biar bisa di-cancel/replace masing-masing).
class NotifIds {
  static const int activityReminder = 1001;
  static const int vitaminReminder = 1002;
  static const int bpmAlert = 2001;
  static const int bpAlert = 2002;
}

/// Key SharedPreferences — dipakai bareng oleh NotificationScreen & HealthProvider.
class NotifPrefsKeys {
  static const all = 'notif_all';
  static const bpmAlert = 'notif_bpm_alert';
  static const bpAlert = 'notif_bp_alert';
  static const activityReminder = 'notif_activity_reminder';
  static const activityTime = 'notif_activity_time'; // format "HH:mm"
  static const vitaminReminder = 'notif_vitamin_reminder';
  static const vitaminTime = 'notif_vitamin_time';
  static const checkupReminder = 'notif_checkup_reminder';
  static const lastBpmAlertAt = 'notif_last_bpm_alert_at';
  static const lastBpAlertAt = 'notif_last_bp_alert_at';
}
