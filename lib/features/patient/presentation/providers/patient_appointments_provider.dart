import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/data/services/notification_firestore_service.dart';
import '../../data/models/patient_appointments_states.dart';
import '../../data/services/remote/patient_appointments_remote_service.dart';

part 'generated/patient_appointments_provider.g.dart';

@Riverpod(keepAlive: true)
class PatientAppointments extends _$PatientAppointments {
  late final PatientAppointmentsRemoteService _remoteService;
  final _notifService = NotificationFirestoreService();

  String _patientId = '';

  @override
  Future<PatientAppointmentsStates> build() async {
    _remoteService = PatientAppointmentsRemoteService();
    return PatientAppointmentsStates.initial();
  }

  Future<void> loadForPatient(String patientId) async {
    _patientId = patientId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final appts = await _remoteService.getForPatient(patientId);
      return PatientAppointmentsStates(appointments: appts);
    });
  }

  Future<void> refresh([String? patientId]) async {
    final id = patientId ?? _patientId;
    if (id.isEmpty) return;
    try {
      final appts = await _remoteService.getForPatient(id);
      if (ref.mounted) {
        state = AsyncData(PatientAppointmentsStates(appointments: appts));
      }
    } catch (e) {
      log('Refresh appointments error: $e');
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final appt = state.value!.appointments
          .where((a) => a.id == appointmentId)
          .firstOrNull;

      await _remoteService.cancel(appointmentId);

      // Notify the doctor that the patient cancelled
      if (appt != null) {
        unawaited(_notifService.send(
          userId: appt.doctorId,
          title: 'تم إلغاء موعد',
          body:
              'قام المريض ${appt.patientName} بإلغاء موعده يوم ${appt.date} الساعة ${appt.time}.',
          type: NotificationType.appointment,
          priority: NotificationPriority.normal,
          entityId: appointmentId,
          route: '/doctor-home',
          payload: {'appointmentId': appointmentId},
        ));
      }

      final updated = state.value!.appointments.map((a) {
        if (a.id != appointmentId) return a;
        return a.copyWith(status: 'cancelled');
      }).toList();
      state =
          AsyncData(state.value!.copyWith(appointments: updated, isLoading: false));
    } catch (e) {
      log('Cancel appointment error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: 'فشل إلغاء الموعد',
      ));
    }
  }
}
