import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_documents/src/utils/sevices/notification/not_supported_notification_service.dart';

import 'notification_service.dart';
import 'desktop_notification_service.dart';
import 'mobile_notification_service.dart';

class NotificationServiceSingleton {
  NotificationServiceSingleton._();
  static final NotificationServiceSingleton instance =
      NotificationServiceSingleton._();

  String get name => "NotificationServiceSingleton";

  NotificationService? _service;

  NotificationService get service {
    if (_service == null) {
      throw Exception(
        'NotificationService not initialized. Call init() first.',
      );
    }
    return _service!;
  }

 Future<void> init() async {
  if (_service != null) return;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    _service = DesktopNotificationService();
  } else if (Platform.isAndroid || Platform.isIOS) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    bool granted = false;

    if (Platform.isAndroid) {
      final bool? androidGranted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      granted = androidGranted ?? false;
    } else if (Platform.isIOS) {
      final bool? iosGranted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      granted = iosGranted ?? false;
    }

    if (granted) {
      _service = MobileNotificationService(flutterLocalNotificationsPlugin);
    } else {
      _service = NotSupportedNotificationService();
    }
  } else {
    _service = NotSupportedNotificationService();
  }
}

}
