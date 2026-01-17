abstract class NotificationService {
  String get name;
  Future<void> init();

  Future<void> showNotification({required String title, required String body});

  Future<void> scheduleNotification({
    required int id,
    required String title,
    String? body = "Your document is expired",
    required DateTime date,
  });

  Future<void> updateNotification({
    required int id,
    required String title,
    String? body = "Your document is expired",
    required DateTime date,
  });

  Future<void> cancelNotification(List<int> ids);

  Future<void> cancelAll();
}
