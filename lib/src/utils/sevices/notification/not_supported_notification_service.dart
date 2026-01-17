import 'package:my_documents/src/utils/sevices/observer.dart';

import 'notification_service.dart';

class NotSupportedNotificationService implements NotificationService {
  NotSupportedNotificationService() {
    init();
  }
  @override
  String get name => "NotSupportedNotificationService";

  @override
  Future<void> init() async {
    MyClassObserver.instance.log(
      name,
      "Platform not supported for notifications",
    );
    // Not supported, so no initialization needed
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // Not supported, so no action
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    String? body = "Your document is expired",
    required DateTime date,
  }) async {
    // Not supported, so no action
  }

  @override
  Future<void> updateNotification({
    required int id,
    required String title,
    String? body = "Your document is expired",
    required DateTime date,
  }) async {
    // Not supported, so no action
  }

  @override
  Future<void> cancelNotification(List<int> ids) async {
    // Not supported, so no action
  }

  @override
  Future<void> cancelAll() async {
    // Not supported, so no action
  }
}
