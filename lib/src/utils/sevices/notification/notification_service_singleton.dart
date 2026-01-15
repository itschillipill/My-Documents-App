import 'dart:io';
import 'package:my_documents/src/utils/sevices/notification/not_supported_notification_service.dart';

import 'notification_service.dart';
//import 'desktop_notification_service.dart';
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

 if (Platform.isAndroid || Platform.isIOS) { 
 _service = MobileNotificationService();
  } else {
    _service = NotSupportedNotificationService();
  }
}

}
