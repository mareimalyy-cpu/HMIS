import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

import 'package:riverpod_core/core/enum/constants.dart' show Constants;


class DeviceInfoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<void> saveUserDeviceData() async {
    try {
      String? deviceName;
      String? deviceId;

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceName = androidInfo.model;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        deviceId = iosInfo.identifierForVendor;
      }
      String? token = await _fcm.getToken();
      String? aPNSToken = await _fcm.getAPNSToken();

      Map<String, dynamic> userData = {
        'deviceName': deviceName,
        'deviceId': deviceId,
        'fcmToken': token ?? aPNSToken ?? '',
        'lastUpdate': FieldValue.serverTimestamp(),
        'platform': Platform.isAndroid ? 'Android' : 'iOS',
      };

      await _db
          .collection(Constants.deviceInfo.name)
          .doc(deviceId)
          .set(userData, SetOptions(merge: true));

      log("User data saved successfully!");
    } catch (e) {
      log("Error saving user data: $e");
    }
  }

  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      log("Error retrieving device ID: $e");
    }
    return '';
  }
}
