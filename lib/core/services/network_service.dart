import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus { online, weak, offline, backOnline }

class NetworkService {
  static final NetworkService instance = NetworkService._internal();
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  NetworkStatus _lastStatus = NetworkStatus.online;

  Stream<NetworkStatus> watchStatus() async* {
    _lastStatus = await checkStatus();
    yield _lastStatus;

    await for (final _ in _connectivity.onConnectivityChanged) {
      final currentStatus = await checkStatus();

      if (_lastStatus == NetworkStatus.offline &&
          currentStatus == NetworkStatus.online) {
        yield NetworkStatus.backOnline;
      } else {
        yield currentStatus;
      }

      _lastStatus = currentStatus;
    }
  }

  Future<NetworkStatus> checkStatus() async {
    final results = await _connectivity.checkConnectivity();

    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return NetworkStatus.online;
      }
      return NetworkStatus.weak;
    } on SocketException catch (_) {
      return NetworkStatus.offline;
    } catch (_) {
      return NetworkStatus.weak;
    }
  }
}

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  return NetworkService.instance.watchStatus();
});
