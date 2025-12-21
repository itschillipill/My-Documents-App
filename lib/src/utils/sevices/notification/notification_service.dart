// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz_data;

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();

//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initMobile() async {
//     debugPrint("|Mobile| notification service initialization");

//     tz_data.initializeTimeZones();

//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const initSettings = InitializationSettings(android: androidSettings);

//     await _plugin.initialize(initSettings);
//   }

//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime date,
//   }) async {
//     await _plugin.zonedSchedule(
//       id, // 🔑 ID версии документа
//       title,
//       body,
//       tz.TZDateTime.from(date, tz.local),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'documents_channel',
//           'Documents',
//           channelDescription: 'Document expiration notifications',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );

//     debugPrint("|Mobile| notification scheduled at $date with id: $id");
//   }

//   Future<void> cancelNotification(int id) async {
//     await _plugin.cancel(id);
//     debugPrint("|Mobile| notification canceled, id: $id");
//   }

//   Future<void> cancelAll() async {
//     await _plugin.cancelAll();
//     debugPrint("|Mobile| all notifications canceled");
//   }
// }
