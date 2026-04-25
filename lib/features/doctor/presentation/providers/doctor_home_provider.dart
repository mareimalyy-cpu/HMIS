import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/local_services/local_storage.dart';
import '../../../auth/data/services/local/auth_local_service.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/data/services/notification_firestore_service.dart';
import '../../data/models/doctor_home_states.dart';
import '../../data/services/local/doctor_home_local_service.dart';
import '../../data/services/remote/doctor_home_remote_service.dart';

part 'generated/doctor_home_provider.g.dart';

@riverpod
class DoctorHome extends _$DoctorHome {
  late final DoctorHomeRemoteService _remoteService;
  late final DoctorHomeLocalService _localService;
  late final AuthLocalService _authLocalService;
  final _notifService = NotificationFirestoreService();

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
      if (ref.mounted) state = AsyncData(remoteState);
    } catch (e) {
      log('Doctor home background refresh error: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _loadFromRemote());
  }

  // ─── Appointment actions ───────────────────────────────────────────────────

  Future<void> approveAppointment(String appointmentId) async {
    final current = state.value;
    if (current == null) return;
    try {
      final appt = current.allAppointments
          .where((a) => a.id == appointmentId)
          .firstOrNull;

      await _remoteService.approveAppointment(appointmentId);

      if (appt != null) {
        unawaited(_notifService.send(
          userId: appt.patientId,
          title: 'تم تأكيد موعدك ✅',
          body:
              'تم تأكيد موعدك مع د. ${appt.doctorName} يوم ${appt.date} الساعة ${appt.time}.',
          type: NotificationType.appointment,
          priority: NotificationPriority.high,
          entityId: appointmentId,
          route: '/patient-home',
          payload: {'appointmentId': appointmentId},
        ));
      }

      _updateStatus(appointmentId, 'approved');
    } catch (e) {
      log('Approve appointment error: $e');
      state = AsyncData(current.copyWith(errorMessage: 'فشل تأكيد الموعد'));
    }
  }

  Future<void> rejectAppointment(String appointmentId) async {
    final current = state.value;
    if (current == null) return;
    try {
      final appt = current.allAppointments
          .where((a) => a.id == appointmentId)
          .firstOrNull;

      await _remoteService.rejectAppointment(appointmentId);

      if (appt != null) {
        unawaited(_notifService.send(
          userId: appt.patientId,
          title: 'تم رفض موعدك',
          body:
              'نأسف، تم رفض موعدك مع د. ${appt.doctorName} يوم ${appt.date}. يمكنك الحجز في وقت آخر.',
          type: NotificationType.appointment,
          priority: NotificationPriority.high,
          entityId: appointmentId,
          route: '/patient-home',
          payload: {'appointmentId': appointmentId},
        ));
      }

      _updateStatus(appointmentId, 'rejected');
    } catch (e) {
      log('Reject appointment error: $e');
      state = AsyncData(current.copyWith(errorMessage: 'فشل رفض الموعد'));
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    final current = state.value;
    if (current == null) return;
    try {
      final appt = current.allAppointments
          .where((a) => a.id == appointmentId)
          .firstOrNull;

      await _remoteService.completeAppointment(appointmentId);

      if (appt != null) {
        unawaited(_notifService.send(
          userId: appt.patientId,
          title: 'تم إتمام موعدك ✅',
          body:
              'تم إتمام موعدك مع د. ${appt.doctorName} يوم ${appt.date}. نتمنى لك الصحة والعافية.',
          type: NotificationType.appointment,
          priority: NotificationPriority.normal,
          entityId: appointmentId,
          route: '/patient-home',
          payload: {'appointmentId': appointmentId},
        ));
      }

      _updateStatus(appointmentId, 'completed');
    } catch (e) {
      log('Complete appointment error: $e');
      state = AsyncData(current.copyWith(errorMessage: 'فشل إتمام الموعد'));
    }
  }

  Future<void> markNoShow(String appointmentId) async {
    final current = state.value;
    if (current == null) return;
    try {
      await _remoteService.markNoShow(appointmentId);
      _updateStatus(appointmentId, 'no_show');
    } catch (e) {
      log('No-show appointment error: $e');
      state = AsyncData(current.copyWith(errorMessage: 'فشل تحديث الموعد'));
    }
  }

  void _updateStatus(String appointmentId, String status) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      todayAppointments: current.todayAppointments
          .map((a) => a.id == appointmentId ? a.copyWith(status: status) : a)
          .toList(),
      allAppointments: current.allAppointments
          .map((a) => a.id == appointmentId ? a.copyWith(status: status) : a)
          .toList(),
    ));
  }
}
