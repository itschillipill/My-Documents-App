import 'dart:io';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';
import 'desktop_notification_service.dart';
import 'mobile_notification_service.dart';

class NotificationServiceSingleton {
  NotificationServiceSingleton._();
  static final NotificationServiceSingleton instance =
      NotificationServiceSingleton._();

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

    if (kIsWeb) {
      throw UnsupportedError('Notifications not supported on Web');
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _service = DesktopNotificationService();
    } else if (Platform.isAndroid || Platform.isIOS) {
      _service = MobileNotificationService();
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }
}
