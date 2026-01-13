import 'package:my_documents/src/utils/sevices/observer.dart';

import 'notification_service.dart';

class MobileNotificationService implements NotificationService {
  MobileNotificationService() {
    init();
  }
  @override
  String get name => "MobileNotificationService";

  @override
  Future<void> init() async {
    MyBlocObserver.instance.onCreate(name);
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelNotification(int id) {
    throw UnimplementedError();
  }

  @override
  Future<void> cancelAll() {
    throw UnimplementedError();
  }
}
