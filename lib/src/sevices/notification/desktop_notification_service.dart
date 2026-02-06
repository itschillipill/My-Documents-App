import 'package:awesome_notifications/awesome_notifications.dart';
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
    try {
      await AwesomeNotifications().initialize(
        null, // иконка по умолчанию (можно указать путь к .ico на Windows)
        [
          NotificationChannel(
            channelKey: 'documents_channel',
            channelName: 'Documents',
            channelDescription: 'Notifications for documents',
            importance: NotificationImportance.High,
            channelShowBadge: true,
          ),
        ],
        debug: true,
      );

      // На десктопе обычно разрешения не нужны, но вызов можно оставить
      await AwesomeNotifications().requestPermissionToSendNotifications();

      MyClassObserver.instance.onCreate(name);
    } catch (e, s) {
      MyClassObserver.instance.onError(name, e, s, message: "Init failed");
    }
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    MyClassObserver.instance.log(
      name,
      "Show notification | title=$title, body=$body",
    );
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    String? body = "Your document is expired",
    required DateTime date,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'documents_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar.fromDate(
          date: date,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      MyClassObserver.instance.log(
        name,
        "Scheduled notification | id=$id, title=$title, date=$date",
      );
    } catch (e, s) {
      MyClassObserver.instance.onError(
        name,
        e,
        s,
        message: "Failed to schedule notification $id",
      );
    }
  }

  @override
  Future<void> updateNotification({
    required int id,
    required String title,
    String? body = "Your document is expired",
    required DateTime date,
  }) async {
    try {
      await cancelNotification([id]);
      await scheduleNotification(id: id, title: title, body: body, date: date);

      MyClassObserver.instance.log(
        name,
        "Updated notification | id=$id, title=$title, date=$date",
      );
    } catch (e, s) {
      MyClassObserver.instance.onError(
        name,
        e,
        s,
        message: "Failed to update notification $id",
      );
    }
  }

  @override
  Future<void> cancelNotification(List<int> ids) async {
    try {
      for (var id in ids) {
        await AwesomeNotifications().cancel(id);
      }

      MyClassObserver.instance.log(name, "Canceled notifications $ids");
    } catch (e, s) {
      MyClassObserver.instance.onError(
        name,
        e,
        s,
        message: "Failed to cancel notifications $ids",
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await AwesomeNotifications().cancelAll();
      MyClassObserver.instance.log(name, "Canceled all notifications");
    } catch (e, s) {
      MyClassObserver.instance.onError(
        name,
        e,
        s,
        message: "Failed to cancel all notifications",
      );
    }
  }
}
