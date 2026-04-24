import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../features/notifications/data/models/notification_model.dart';
import '../../features/notifications/data/services/fcm_token_service.dart';
import '../../features/notifications/data/services/notification_firestore_service.dart';
import '../helper/deep_link_helper.dart';
import '../local_services/local_storage.dart';
import '../enum/constants.dart';
import '../services/info_service.dart';
import 'local_notifications_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  final handle = DeepLinkHelper.instance;
  if (message.data.isNotEmpty) {
    log('🧭 Open screen from notification: ${message.data}');
    if (message.data.containsKey('url')) {
      await handle.launchUrl(jsonEncode(message.data));
    } else {
      await handle.handleRouteById(pyload: jsonEncode(message.data));
    }
  }
}

class FirebaseMessagingService {
  factory FirebaseMessagingService() => instance;
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService instance =
      FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _tokenService = FcmTokenService();
  final _notifService = NotificationFirestoreService();

  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;

    _notificationsEnabled = true;
    await DeviceInfoService().saveUserDeviceData();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (_notificationsEnabled) await _requestPermissions();

    _setupMessageHandlers();

    // Save token for the currently cached user (if any).
    await _saveTokenIfLoggedIn();

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) _handleMessage(initialMessage);

    _isInitialized = true;
    log('✅ FirebaseMessagingService initialized');
  }

  // ─── Token management ─────────────────────────────────────────────────────

  Future<void> saveTokenForUser(String userId) =>
      _tokenService.saveTokenForUser(userId);

  Future<void> deleteTokenForUser(String userId) =>
      _tokenService.deleteTokenForUser(userId);

  Future<void> _saveTokenIfLoggedIn() async {
    final raw = LocalStorage.instance.get(Constants.userData.name);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      final userId = map['id'] as String?;
      if (userId != null && userId.isNotEmpty) {
        await _tokenService.saveTokenForUser(userId);
      }
    } catch (e) {
      log('FCM token save skipped: $e');
    }
  }

  // ─── Permissions ──────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('🔔 Permission status: ${settings.authorizationStatus}');
  }

  Future<void> enableNotifications() async {
    _notificationsEnabled = true;
    await _requestPermissions();
    await subscribeToTopic('all');
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<bool> disableNotifications() async {
    _notificationsEnabled = false;
    await unsubscribeFromTopic('all');
    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }
    return _notificationsEnabled;
  }

  Future<void> toogle({required bool toogle}) async {
    if (toogle) {
      await enableNotifications();
    } else {
      await disableNotifications();
    }
  }

  // ─── Message handlers ─────────────────────────────────────────────────────

  void _setupMessageHandlers() {
    // FOREGROUND — show local OS notification + persist to Firestore
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (!_notificationsEnabled) {
        log('🔕 Notifications disabled – ignoring message');
        return;
      }
      log('☀️ Foreground Message: ${message.messageId}');

      if (message.notification != null) {
        await LocalNotificationsService.instance.show(
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          payload: jsonEncode(message.data),
        );
      }

      // Persist incoming FCM message as an in-app notification.
      await _persistFcmMessage(message);
    });

    // BACKGROUND / OPENED APP
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!_notificationsEnabled) return;
      _handleMessage(message);
    });
  }

  /// Saves the FCM payload as a Firestore notification document so it appears
  /// in the in-app Notification Center.
  Future<void> _persistFcmMessage(RemoteMessage message) async {
    try {
      final data = message.data;
      final userId = data['userId'] as String?;
      if (userId == null || userId.isEmpty) return;

      final typeStr = data['type'] as String? ?? 'system';
      final priorityStr = data['priority'] as String? ?? 'normal';

      await _notifService.send(
        userId: userId,
        title: message.notification?.title ?? data['title'] as String? ?? '',
        body: message.notification?.body ?? data['body'] as String? ?? '',
        type: NotificationType.fromJson(typeStr),
        priority: NotificationPriority.fromJson(priorityStr),
        entityId: data['entityId'] as String?,
        route: data['route'] as String?,
        payload: Map<String, dynamic>.from(data),
      );
    } catch (e) {
      log('Persist FCM message error: $e');
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  Future<void> _handleMessage(RemoteMessage message) async {
    final handle = DeepLinkHelper.instance;
    if (message.data.isNotEmpty) {
      log('🧭 Open screen from notification: ${message.data}');
      if (message.data.containsKey('url')) {
        await handle.launchUrl(jsonEncode(message.data));
      } else {
        await handle.handleRouteById(pyload: jsonEncode(message.data));
      }
    }
  }

  // ─── Topics ───────────────────────────────────────────────────────────────

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('✅ Subscribed to $topic');
    } catch (e) {
      log('❌ Subscribe error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('✅ Unsubscribed from $topic');
    } catch (e) {
      log('❌ Unsubscribe error: $e');
    }
  }
}
