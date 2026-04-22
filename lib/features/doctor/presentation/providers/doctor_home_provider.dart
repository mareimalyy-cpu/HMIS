import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/local_services/local_storage.dart';
import '../../../auth/data/services/local/auth_local_service.dart';
import '../../data/models/doctor_home_states.dart';
import '../../data/services/local/doctor_home_local_service.dart';
import '../../data/services/remote/doctor_home_remote_service.dart';

part 'generated/doctor_home_provider.g.dart';

@riverpod
class DoctorHome extends _$DoctorHome {
  late final DoctorHomeRemoteService _remoteService;
  late final DoctorHomeLocalService _localService;
  late final AuthLocalService _authLocalService;

  @override
  Future<DoctorHomeStates> build() async {
    _remoteService = DoctorHomeRemoteService();
    _localService = DoctorHomeLocalService(LocalStorage.instance);
    _authLocalService = AuthLocalService(LocalStorage.instance);
    try {
      final localState = _loadFromLocal();
      if (localState != null) {
        unawaited(_loadFromRemoteInBackground());
        return localState;
      }
      return await _loadFromRemote();
    } catch (e) {
      return DoctorHomeStates(errorMessage: e.toString());
    }
  }

  DoctorHomeStates? _loadFromLocal() {
    final doctor = _authLocalService.getUser();
    if (doctor == null) return null;
    final today = _localService.getTodayAppointments();
    final all = _localService.getAllAppointments();
    if (today != null || all != null) {
      return DoctorHomeStates(
        currentDoctor: doctor,
        todayAppointments: today ?? [],
        allAppointments: all ?? [],
      );
    }
    return DoctorHomeStates(currentDoctor: doctor);
  }

  Future<DoctorHomeStates> _loadFromRemote() async {
    final doctor = _authLocalService.getUser();
    if (doctor == null) return DoctorHomeStates.initial();

    final today = await _remoteService.getTodayAppointments(doctor.id);
    final all = await _remoteService.getAllAppointments(doctor.id);
    unawaited(_localService.saveTodayAppointments(today));
    unawaited(_localService.saveAllAppointments(all));
    return DoctorHomeStates(
      currentDoctor: doctor,
      todayAppointments: today,
      allAppointments: all,
    );
  }

  Future<void> _loadFromRemoteInBackground() async {
    try {
      final remoteState = await _loadFromRemote();
      state = AsyncData(remoteState);
    } catch (e) {
      log('Doctor home background refresh error: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadFromRemote());
  }
}
