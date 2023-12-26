import 'dart:convert';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as time_zone;

class NotificationService {
  NotificationService._constructer();
  static final NotificationService instance =
      NotificationService._constructer();
  final FlutterLocalNotificationsPlugin localNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    await localNotificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await localNotificationPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await localNotificationPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> scheduleNotification(
    String title,
    String? description,
    DateTime? time, {
    Map<String, dynamic>? payload,
  }) async {
    var id = Random().nextInt(1000);
    if (time == null ||
        time.toLocal().isBefore(time_zone.TZDateTime.now(time_zone.local).add(
              const Duration(seconds: 2),
            ))) {
      time = null; // reset time if its in past or immediate or null
    }
    await localNotificationPlugin.zonedSchedule(
      id,
      title,
      description,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload == null ? null : jsonEncode(payload),
      time == null
          ? time_zone.TZDateTime.now(time_zone.local).add(
              const Duration(seconds: 2),
            )
          : time_zone.TZDateTime.from(
              time,
              time_zone.local,
            ),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          "notification_primary",
          "Primary Notifications Channel",
          channelDescription:
              "This is primary channel for notifications of this app",
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }
}
