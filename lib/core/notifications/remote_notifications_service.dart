import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notifications_service.dart';

/// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need access to other Firebase services in the background, likely need Firebase.initializeApp() here
  log('🌙 Background Message: ${message.messageId}');
  log('🌙 Background Data: ${message.data}');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  /// 1. Initialize FirebaseMessaging
  Future<void> init() async {
    if (_isInitialized) return;

    // 4. Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request permissions
    await requestPermissions();

    // 3. Handle Ground/Terminated/Background
    _setupMessageHandlers();

    // Check for initial message (Terminated state)
    final RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      log(
        '🚀 App launched from terminated state by notification: ${initialMessage.messageId}',
      );
      _handleMessage(initialMessage);
    }

    _isInitialized = true;
    log('✅ FirebaseMessagingService initialized');
  }

  /// 2. Request Permissions
  Future<void> requestPermissions() async {
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
      log('✅ User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('⚠️ User granted provisional permission');
    } else {
      log('❌ User declined or has not accepted permission');
    }
  }

  /// 3. Message Handlers
  void _setupMessageHandlers() {
    // FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('☀️ Foreground Message: ${message.messageId}');
      log('☀️ Message Data: ${message.data}');

      if (message.notification != null) {
        log(
          '🔔 Message also contained a notification: ${message.notification?.title}',
        );

        // 5. Integrate with LocalNotificationsService to show visual notification
        // Note: Check if platform is Android, iOS automatically handles foreground presentation options if configured
        if (Platform.isAndroid) {
          LocalNotificationsService.instance.showNotification(
            title: message.notification?.title ?? 'No Title',
            body: message.notification?.body ?? 'No Body',
            payload: jsonEncode(message.data), // Pass data as payload
          );
        } else if (Platform.isIOS) {
          // ensure foreground presentation options are set (usually done in main or via plugin config)
          _firebaseMessaging.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }
    });

    // BACKGROUND / OPENED APP
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log(
        '🚀 App opened from background state by notification: ${message.messageId}',
      );
      _handleMessage(message);
    });
  }

  /// Handle message tap logic
  void _handleMessage(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      // Navigate to specific screen based on data
      // e.g., router.push('/chat', extra: message.data['chatId']);
      log('🧭 Navigation intent from notification payload: ${message.data}');
    }
  }

  /// 6. Subscribe to Topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('✅ Subscribed to topic: $topic');
    } catch (e) {
      log('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// 6. Unsubscribe from Topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      log('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// 6. Get Token
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      log('🔑 FCM Token: $token');
      return token;
    } catch (e) {
      log('❌ Error getting FCM token: $e');
      return null;
    }
  }
}
