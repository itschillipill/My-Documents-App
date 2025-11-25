abstract class NotificationService {
  Future<void> init();
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  });
  Future<void> cancelNotification(int id);
  Future<void> cancelAll();
}
