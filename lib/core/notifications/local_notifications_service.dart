import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  // Singleton pattern
  static final LocalNotificationsService instance =
      LocalNotificationsService._internal();
  factory LocalNotificationsService() => instance;
  LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _alarmCheckChannel = MethodChannel(
    'flutter_alarm_check',
  );

  bool _isInitialized = false;

  /// 1. Initialize FlutterLocalNotificationsPlugin with Android and iOS settings.
  /// 3. Initialize TimeZone correctly.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize TimeZone
      tz.initializeTimeZones();
      final String timeZoneName =
          await FlutterNativeTimezoneLatest.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      log('✅ Timezone initialized: $timeZoneName');

      // Android Settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS Settings - Dont request permissions immediately
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          );

      final InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 5. Handle notification taps
      await _flutterLocalNotificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          log('🔔 Notification tapped: ${response.payload}');
          _handleNotificationTap(response);
        },
      );

      _isInitialized = true;
      log('✅ LocalNotificationsService initialized');

      // 2. Request all necessary permissions
      await requestPermissions();
    } catch (e, stack) {
      log(
        '❌ Error initializing LocalNotificationsService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// 2. Request permissions: Android (POST_NOTIFICATIONS) & iOS (alert, badge, sound)
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // Android 13+ Notification Permission
      final bool? grantedArgs = await androidImplementation
          ?.requestNotificationsPermission();
      log('✅ Android notification permissions: $grantedArgs');
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// 6. Ensure Android 12+ Exact Alarms are checked using MethodChannel
  Future<bool> _canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      // Check native capability via custom channel
      final bool? canSchedule = await _alarmCheckChannel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );
      log('⏰ MethodChannel check canScheduleExactAlarms: $canSchedule');

      // If the channel returns null, it might not be implemented, proceed with caution or return false
      return canSchedule ?? false;
    } on PlatformException catch (e) {
      log('❌ PlatformException checking exact alarms: ${e.message}');
      // If method not found, assume false to trigger fallback or settings
      return false;
    } catch (e) {
      log('❌ Error checking exact alarms: $e');
      return false;
    }
  }

  /// 7. Open Android settings if Exact Alarm not permitted
  Future<void> _openExactAlarmSettings() async {
    if (Platform.isAndroid) {
      try {
        log('⚠️ Opening Exact Alarm settings...');
        final intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
      } catch (e) {
        log('❌ Error opening settings: $e');
      }
    }
  }

  NotificationDetails _getPlatformChannelSpecifics() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel_id',
        'Default Channel',
        channelDescription: 'Default channel for app notifications',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  /// 4. showNotification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        _getPlatformChannelSpecifics(),
        payload: payload,
      );
      log('📤 Notification shown: $title');
    } catch (e) {
      log('❌ Error showing notification: $e');
    }
  }

  /// 4. scheduleNotification
  /// 8. Fallback to inexact scheduling
  Future<void> scheduleNotification({
    required String title,
    required String body,
    String? payload,
    required Duration delay,
  }) async {
    try {
      AndroidScheduleMode scheduleMode =
          AndroidScheduleMode.exactAllowWhileIdle;

      // Check Exact Alarm for Android
      if (Platform.isAndroid) {
        final canExact = await _canScheduleExactAlarms();
        if (!canExact) {
          log(
            '⚠️ Exact alarms not allowed. Opening settings and falling back to inexact.',
          );
          await _openExactAlarmSettings();
          // 8. Ensure fallback
          scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        }
      }

      final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        DateTime.now().millisecond,
        title,
        body,
        scheduledDate,
        _getPlatformChannelSpecifics(),
        androidScheduleMode: scheduleMode,
        payload: payload,
      );
      log('📅 Notification scheduled for $scheduledDate (Mode: $scheduleMode)');
    } on PlatformException catch (e) {
      log('❌ PlatformException scheduling: ${e.message}');
      // 9. Handle PlatformException - Retry with inexact if failed due to exact alarm
      if (Platform.isAndroid &&
          (e.code == 'SecurityException' ||
              e.message?.contains('SecurityException') == true)) {
        log('🔄 Retrying with inexact scheduling due to SecurityException...');
        try {
          await _flutterLocalNotificationsPlugin.zonedSchedule(
            DateTime.now().millisecond,
            title,
            body,
            tz.TZDateTime.now(tz.local).add(delay),
            _getPlatformChannelSpecifics(),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

            payload: payload,
          );
          log('✅ Retry successful using inexact scheduling.');
        } catch (retryError) {
          log('❌ Retry failed: $retryError');
        }
      }
    } catch (e) {
      log('❌ Error scheduling notification: $e');
    }
  }

  /// 4. schedulePeriodicNotification
  Future<void> schedulePeriodicNotification({
    required String title,
    required String body,
    String? payload,
    required RepeatInterval interval,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.periodicallyShow(
        DateTime.now()
            .millisecond, // NOTE: ID management should ideally be better for periodic to cancel them
        title,
        body,
        interval,
        _getPlatformChannelSpecifics(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
      log('🔄 Periodic notification scheduled: $interval');
    } catch (e) {
      log('❌ Error scheduling periodic notification: $e');
    }
  }

  /// 4. repeatNotification
  Future<void> repeatNotification({
    required String title,
    required String body,
    String? payload,
    required RepeatInterval interval,
  }) async {
    // Delegating to periodic notification as functionality is identical for defined intervals
    await schedulePeriodicNotification(
      title: title,
      body: body,
      payload: payload,
      interval: interval,
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      log('🚀 Handle navigation for payload: ${response.payload}');
      // Add logic to navigate to specific screen
    }
  }
}
