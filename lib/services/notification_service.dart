import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/document_item.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Bucharest'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(
      settings: settings,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleAllDocuments(List<DocumentItem> documents) async {
    await notificationsPlugin.cancelAll();

    for (final document in documents) {
      await scheduleDocumentNotifications(document);
    }
  }

  static Future<void> scheduleDocumentNotifications(
    DocumentItem document,
  ) async {
    for (final daysBefore in document.reminderDays) {
      final scheduledDate = DateTime(
        document.expiryDate.year,
        document.expiryDate.month,
        document.expiryDate.day,
        9,
      ).subtract(Duration(days: daysBefore));

      if (scheduledDate.isBefore(DateTime.now())) {
        continue;
      }

      final id = _notificationId(document, daysBefore);

      await notificationsPlugin.zonedSchedule(
        id: id,
        title: 'ActeAlert',
        body: _buildNotificationBody(document, daysBefore),
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'document_reminders',
            'Document reminders',
            channelDescription: 'Notificări pentru documente care expiră',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static String _buildNotificationBody(DocumentItem document, int daysBefore) {
    if (daysBefore == 0) {
      return '${document.name} expiră azi.';
    }

    if (daysBefore == 1) {
      return '${document.name} expiră mâine.';
    }

    return '${document.name} expiră în $daysBefore zile.';
  }

  static int _notificationId(DocumentItem document, int daysBefore) {
    return '${document.name}_${document.category}_${document.expiryDate.toIso8601String()}_$daysBefore'
        .hashCode
        .abs();
  }

  static Future<void> showTestNotification() async {
    await notificationsPlugin.show(
      id: 999999,
      title: 'ActeAlert',
      body: 'Notificările funcționează corect.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'document_reminders',
          'Document reminders',
          channelDescription: 'Notificări pentru documente care expiră',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}