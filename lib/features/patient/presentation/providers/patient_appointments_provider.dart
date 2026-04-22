import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/patient_appointments_states.dart';
import '../../data/services/remote/patient_appointments_remote_service.dart';

part 'generated/patient_appointments_provider.g.dart';

@Riverpod(keepAlive: true)
class PatientAppointments extends _$PatientAppointments {
  late final PatientAppointmentsRemoteService _remoteService;

  @override
  Future<PatientAppointmentsStates> build() async {
    _remoteService = PatientAppointmentsRemoteService();
    return PatientAppointmentsStates.initial();
  }

  Future<void> loadForPatient(String patientId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final appts = await _remoteService.getForPatient(patientId);
      return PatientAppointmentsStates(appointments: appts);
    });
  }

  Future<void> refresh(String patientId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final appts = await _remoteService.getForPatient(patientId);
      return PatientAppointmentsStates(appointments: appts);
    });
  }

  Future<void> cancelAppointment(String appointmentId) async {
    state = AsyncData(
        state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.cancel(appointmentId);
      final updated = state.value!.appointments.map((a) {
        if (a.id != appointmentId) return a;
        return a.copyWith(status: 'cancelled');
      }).toList();
      state = AsyncData(
          state.value!.copyWith(appointments: updated, isLoading: false));
    } catch (e) {
      log('Cancel appointment error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: 'فشل إلغاء الموعد',
      ));
    }
  }
}
