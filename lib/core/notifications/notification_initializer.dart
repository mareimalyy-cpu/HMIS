import 'local_notifications_service.dart';
import 'remote_notifications_service.dart';

class NotificationInitializer {
  static final NotificationInitializer instance = NotificationInitializer._();
  NotificationInitializer._();
  late LocalNotificationsService _localNotificationsService;
  late FirebaseMessagingService _remoteNotificationsService;

  Future<void> init() async {
    _localNotificationsService = LocalNotificationsService.instance;
    _remoteNotificationsService = FirebaseMessagingService.instance;
    await _localNotificationsService.init();
    await _remoteNotificationsService.init();
  }
}
