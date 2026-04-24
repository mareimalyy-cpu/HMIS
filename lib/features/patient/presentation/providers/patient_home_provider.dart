import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/local_services/local_storage.dart';
import '../../../auth/data/services/local/auth_local_service.dart';
import '../../data/models/patient_home_states.dart';
import '../../data/models/specialty_model.dart';
import '../../data/services/local/patient_home_local_service.dart';
import '../../data/services/remote/patient_home_remote_service.dart';

part 'generated/patient_home_provider.g.dart';

@riverpod
class PatientHome extends _$PatientHome {
  late final PatientHomeRemoteService _remoteService;
  late final PatientHomeLocalService _localService;
  late final AuthLocalService _authLocalService;

  @override
  Future<PatientHomeStates> build() async {
    _remoteService = PatientHomeRemoteService();
    _localService = PatientHomeLocalService(LocalStorage.instance);
    _authLocalService = AuthLocalService(LocalStorage.instance);
    try {
      final localState = _loadFromLocal();
      if (localState != null) {
        unawaited(_loadFromRemoteInBackground());
        return localState;
      }
      return await _loadFromRemote();
    } catch (e) {
      return PatientHomeStates(errorMessage: e.toString());
    }
  }

  PatientHomeStates? _loadFromLocal() {
    final user = _authLocalService.getUser();
    final doctors = _localService.getDoctors();
    if (doctors != null) {
      return PatientHomeStates(
        currentUser: user,
        specialties: SpecialtyModel.defaults,
        allDoctors: doctors,
      );
    }
    return null;
  }

  Future<PatientHomeStates> _loadFromRemote() async {
    final user = _authLocalService.getUser();
    final results = await Future.wait([
      _remoteService.getAllDoctors(),
      _remoteService.getSpecialties(),
    ]);
    final doctors = results[0] as List;
    final specialties = results[1] as List;
    unawaited(_localService.saveDoctors(doctors.cast()));
    return PatientHomeStates(
      currentUser: user,
      specialties: specialties.isEmpty
          ? SpecialtyModel.defaults
          : specialties.cast<SpecialtyModel>(),
      allDoctors: doctors.cast(),
    );
  }

  Future<void> _loadFromRemoteInBackground() async {
    try {
      final remoteState = await _loadFromRemote();
      if (ref.mounted) state = AsyncData(remoteState);
    } catch (e) {
      log('Background refresh error: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadFromRemote());
  }

  void updateSearch(String query) {
    state = AsyncData(state.value!.copyWith(searchQuery: query));
  }
}
