import '../observer.dart';
import 'notification_service.dart';

class DesktopNotificationService implements NotificationService {
  DesktopNotificationService() {
    init();
  }
  @override
  String get name => "DesktopNotificationService";

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
