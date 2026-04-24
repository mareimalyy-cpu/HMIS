import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenService {
  final _db = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;
  final _deviceInfo = DeviceInfoPlugin();

  CollectionReference<Map<String, dynamic>> _tokensRef(String userId) =>
      _db.collection('users').doc(userId).collection('fcmTokens');

  // ─── Token lifecycle ───────────────────────────────────────────────────────

  Future<void> saveTokenForUser(String userId) async {
    final token = await _messaging.getToken();
    if (token == null) return;

    final deviceId = await _resolveDeviceId();
    await _tokensRef(userId).doc(deviceId).set({
      'token': token,
      'deviceId': deviceId,
      'platform': Platform.operatingSystem,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    log('✅ FCM token saved for user $userId on $deviceId');

    // Watch for token rotation and update automatically.
    _messaging.onTokenRefresh.listen((newToken) async {
      await _tokensRef(userId).doc(deviceId).update({
        'token': newToken,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log('🔄 FCM token refreshed for user $userId');
    });
  }

  Future<void> deleteTokenForUser(String userId) async {
    final deviceId = await _resolveDeviceId();
    await _tokensRef(userId).doc(deviceId).delete();
    await _messaging.deleteToken();
    log('🗑️ FCM token removed for user $userId on $deviceId');
  }

  /// Returns all active FCM tokens for a user (used by server-side FCM sends).
  Future<List<String>> getTokensForUser(String userId) async {
    final snap = await _tokensRef(userId).get();
    return snap.docs
        .map((d) => d.data()['token'] as String? ?? '')
        .where((t) => t.isNotEmpty)
        .toList();
  }

  // ─── Private ───────────────────────────────────────────────────────────────

  Future<String> _resolveDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return info.id;
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.identifierForVendor ?? 'ios_unknown';
      }
    } catch (_) {}
    return 'unknown_device';
  }
}
