// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'notification_service.dart';
// import '../observer.dart';

// class MobileNotificationService implements NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   MobileNotificationService(this.flutterLocalNotificationsPlugin) {
//     init();
//   }

//   @override
//   String get name => "MobileNotificationService";
//   @override
//   Future<void> init() async {
//     try {
//       const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//       const iosInit = DarwinInitializationSettings();
//       const initSettings = InitializationSettings(
//         android: androidInit,
//         iOS: iosInit,
//       );
//       await flutterLocalNotificationsPlugin.initialize(initSettings);
//       MyClassObserver.instance.onCreate(name);
//     } catch (e, s) {
//       MyClassObserver.instance.onError(name, e, s, message: "Init failed");
//     }
//   }

//   @override
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     String? body = "Your document is expired",
//     required DateTime date,
//   }) async {
//     try {

//       final androidDetails = AndroidNotificationDetails(
//         'documents_channel', 
//         'Documents', 
//         channelDescription: 'Notifications for documents',
//         importance: Importance.max,
//         priority: Priority.high,
//       );

//       final iosDetails = DarwinNotificationDetails();

//       final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         id,
//         title,
//         body,
//         tz.TZDateTime.from(date, tz.local),
//         details,
//       );

//       MyClassObserver.instance.log(
//         name,
//         "Scheduled notification id=$id title=$title date=$date",
//       );
//     } catch (e, s) {
//       MyClassObserver.instance.onError(name, e, s, message: "Failed to schedule notification $id");
//     }
//   }

//   @override
//   Future<void> updateNotification({
//     required int id,
//     required String title,
//     String? body = "Your document is expired",
//     required DateTime date,
//   }) async {
//     try {

//       await cancelNotification([id]);
//       await scheduleNotification(id: id, title: title, body: body, date: date);

//       MyClassObserver.instance.log(
//         name,
//         "Updated notification id=$id title=$title date=$date",
//       );
//     } catch (e, s) {
//       MyClassObserver.instance.onError(name, e, s, message: "Failed to update notification $id");
//     }
//   }

//   @override
//   Future<void> cancelNotification(List<int> ids) async {
//     try {
//       for (var id in ids) {
//         await flutterLocalNotificationsPlugin.cancel(id);
//       }
//       MyClassObserver.instance.log(name, "Canceled notifications $ids");
//     } catch (e, s) {
//       MyClassObserver.instance.onError(name, e, s, message: "Failed to cancel notifications $ids");
//     }
//   }

//   @override
//   Future<void> cancelAll() async {
//     try {
//       await flutterLocalNotificationsPlugin.cancelAll();
//       MyClassObserver.instance.log(name, "Canceled all notifications");
//     } catch (e, s) {
//       MyClassObserver.instance.onError(name, e, s, message: "Failed to cancel all notifications");
//     }
//   }
// }

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

      MyClassObserver.instance.onCreate(name);
    } catch (e, s) {
      MyClassObserver.instance.onError(name, e, s, message: "Init failed");
    }
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
        "Scheduled notification id=$id title=$title date=$date",
      );
    } catch (e, s) {
      MyClassObserver.instance.onError(name, e, s,
          message: "Failed to schedule notification $id");
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
        "Updated notification id=$id title=$title date=$date",
      );
    } catch (e, s) {
      MyClassObserver.instance.onError(name, e, s,
          message: "Failed to update notification $id");
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
      MyClassObserver.instance.onError(name, e, s,
          message: "Failed to cancel notifications $ids");
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await AwesomeNotifications().cancelAll();
      MyClassObserver.instance.log(name, "Canceled all notifications");
    } catch (e, s) {
      MyClassObserver.instance.onError(name, e, s,
          message: "Failed to cancel all notifications");
    }
  }
}
