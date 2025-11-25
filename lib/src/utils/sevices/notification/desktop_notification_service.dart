import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initDesktop() async {
    debugPrint("|Desktop| notification service initialion");
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    debugPrint("|Desktop| notification sheduled at $date with id: $id");
  }

  Future<void> cancelNotification(int id) async {
    debugPrint("|Desktop| notification canceled, id: $id");
  }

  Future<void> cancelAll() async {
    debugPrint("|Desktop| all notifications canceled");
  }
}
