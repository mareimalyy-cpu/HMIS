import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/logger.dart';

class RemoteNotificationsService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.i('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      AppLogger.i('User granted provisional permission');
    } else {
      AppLogger.w('User declined or has not accepted permission');
    }

    // Get FCM Token
    String? token = await _firebaseMessaging.getToken();
    AppLogger.i("FCM Token: $token");

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.i('Got a message whilst in the foreground!');
      AppLogger.i('Message data: ${message.data}');

      if (message.notification != null) {
        AppLogger.i(
          'Message also contained a notification: ${message.notification}',
        );
      }
    });
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
