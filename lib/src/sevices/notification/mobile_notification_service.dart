import 'package:awesome_notifications/awesome_notifications.dart';
import 'notification_service.dart';
import '../observer.dart';

class MobileNotificationService implements NotificationService {
  MobileNotificationService() {
    init();
  }

  @override
  String get name => "MobileNotificationService";

  @override
  Future<void> init() async {
    try {
      await AwesomeNotifications().initialize(
        null, // иконка по умолчанию
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

      // Запрос разрешений
      await AwesomeNotifications().requestPermissionToSendNotifications();

      SessionLogger.instance.onCreate(name);
    } catch (e, s) {
      SessionLogger.instance.onError(name, e, s, message: "Init failed");
    }
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    SessionLogger.instance.log(
      name,
      "Show notification | title=$title, body=$body",
    );
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'documents_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
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

      SessionLogger.instance.log(
        name,
        "Scheduled notification id=$id title=$title date=$date",
      );
    } catch (e, s) {
      SessionLogger.instance.onError(
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

      SessionLogger.instance.log(
        name,
        "Updated notification id=$id title=$title date=$date",
      );
    } catch (e, s) {
      SessionLogger.instance.onError(
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
      SessionLogger.instance.log(name, "Canceled notifications $ids");
    } catch (e, s) {
      SessionLogger.instance.onError(
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
      SessionLogger.instance.log(name, "Canceled all notifications");
    } catch (e, s) {
      SessionLogger.instance.onError(
        name,
        e,
        s,
        message: "Failed to cancel all notifications",
      );
    }
  }
}
