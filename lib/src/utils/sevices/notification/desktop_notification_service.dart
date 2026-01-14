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
    MyClassObserver.instance.onCreate(name);
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    String? body = "Your document is expired",
    required DateTime date,
  }) async{
    //if there's notification with this id, call updateNotification()
    MyClassObserver.instance.log(name, "shcheduled notification with id $id: titile $title,\n body: $body,\n date: $date");
  }

  @override
  Future<void> updateNotification({
    required int id,
    required String title,
    String? body = "Your document is expired",
    required DateTime date,
  }) async{
    //if there's no notification with such id, call scheduleNotification()
    MyClassObserver.instance.log(name, "updated notification with id $id: titile $title,\n body: $body,\n date: $date");
  }

  @override
  Future<void> cancelNotification(List<int> ids) async{
    MyClassObserver.instance.log(name, "canceled notifications with id's $ids");
  }

  @override
  Future<void> cancelAll() async{
    MyClassObserver.instance.log(name, "canceled all notifications");
  }
}
