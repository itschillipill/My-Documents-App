import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initMobile() async {
    debugPrint("|Mobile| notification service initialion");
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    debugPrint("|Mobile| notification sheduled at $date with id: $id");
  }

  Future<void> cancelNotification(int id) async {
    debugPrint("|Mobile| notification canceled, id: $id");
  }

  Future<void> cancelAll() async {
    debugPrint("|Mobile| all notifications canceled");
  }
}
