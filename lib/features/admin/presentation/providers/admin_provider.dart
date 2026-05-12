import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/data/models/user_model.dart';
import '../../../booking/data/models/appointment_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/data/services/notification_firestore_service.dart';
import '../../data/models/admin_states.dart';
import '../../data/services/remote/admin_remote_service.dart';

part 'generated/admin_provider.g.dart';

@Riverpod(keepAlive: true)
class Admin extends _$Admin {
  late final AdminRemoteService _remoteService;
  late final NotificationFirestoreService _notifService;

  @override
  Future<AdminStates> build() async {
    _remoteService = AdminRemoteService();
    _notifService = NotificationFirestoreService();
    try {
      return await _fetchAll();
    } catch (e, st) {
      log('🛑 Admin build error: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<AdminStates> _fetchAll() async {
    try {
      final results = await Future.wait([
        _remoteService.getAllDoctors().catchError((e, st) {
          log('🛑 getAllDoctors error: $e', error: e, stackTrace: st);
          throw e;
        }),
        _remoteService.getPendingDoctors().catchError((e, st) {
          log('🛑 getPendingDoctors error: $e', error: e, stackTrace: st);
          throw e;
        }),
        _remoteService.getAllPatients().catchError((e, st) {
          log('🛑 getAllPatients error: $e', error: e, stackTrace: st);
          throw e;
        }),
        _remoteService.getAllAppointments().catchError((e, st) {
          log('🛑 getAllAppointments error: $e', error: e, stackTrace: st);
          throw e;
        }),
      ]);
      log('✅ Admin _fetchAll loaded: '
          '${(results[0] as List).length} doctors, '
          '${(results[1] as List).length} pending, '
          '${(results[2] as List).length} patients, '
          '${(results[3] as List).length} appointments');
      return AdminStates(
        doctors: results[0] as List<UserModel>,
        pendingDoctors: results[1] as List<UserModel>,
        patients: results[2] as List<UserModel>,
        appointments: results[3] as List<AppointmentModel>,
      );
    } catch (e, st) {
      log('🛑 Admin _fetchAll error: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    log('🔄 Admin refresh triggered');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchAll);
    if (state.hasError) {
      log('🛑 Admin refresh failed: ${state.error}',
          error: state.error, stackTrace: state.stackTrace);
    }
  }

  Future<void> approveDoctor(String doctorId, String adminId) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.approveDoctor(doctorId, adminId);
      unawaited(_notifService.send(
        userId: doctorId,
        title: 'تمت الموافقة على طلبك 🎉',
        body: 'أهلاً بك! يمكنك الآن تسجيل الدخول والبدء في استخدام التطبيق.',
        type: NotificationType.approval,
        priority: NotificationPriority.high,
        route: '/doctor-home',
      ));
      final pending = state.value!.pendingDoctors;
      final approved = pending.firstWhere((d) => d.id == doctorId);
      final updatedApproved = approved.copyWith(
        doctorStatus: DoctorStatus.approved,
        approvedBy: adminId,
        approvedAt: DateTime.now().toIso8601String(),
        isActive: true,
      );
      state = AsyncData(state.value!.copyWith(
        pendingDoctors: pending.where((d) => d.id != doctorId).toList(),
        doctors: [...state.value!.doctors, updatedApproved],
        isLoading: false,
      ));
    } catch (e, st) {
      log('🛑 Approve doctor error (id=$doctorId): $e',
          error: e, stackTrace: st);
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: 'فشل الموافقة على الطبيب',
      ));
    }
  }

  Future<void> rejectDoctor(String doctorId, String adminId) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.rejectDoctor(doctorId, adminId);
      unawaited(_notifService.send(
        userId: doctorId,
        title: 'تم رفض طلبك',
        body: 'نأسف، لم تتم الموافقة على طلبك. تواصل مع الإدارة للمزيد من المعلومات.',
        type: NotificationType.approval,
        priority: NotificationPriority.high,
      ));
      state = AsyncData(state.value!.copyWith(
        pendingDoctors: state.value!.pendingDoctors
            .where((d) => d.id != doctorId)
            .toList(),
        isLoading: false,
      ));
    } catch (e, st) {
      log('🛑 Reject doctor error (id=$doctorId): $e',
          error: e, stackTrace: st);
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: 'فشل رفض الطبيب',
      ));
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.deleteAppointment(appointmentId);
      final updated = state.value!.appointments
          .where((a) => a.id != appointmentId)
          .toList();
      state = AsyncData(
        state.value!.copyWith(appointments: updated, isLoading: false),
      );
    } catch (e, st) {
      log('🛑 Delete appointment error (id=$appointmentId): $e',
          error: e, stackTrace: st);
      state = AsyncData(
        state.value!.copyWith(isLoading: false, errorMessage: 'فشل حذف الحجز'),
      );
    }
  }

  Future<void> deleteDoctor(String doctorId) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.deleteDoctor(doctorId);
      final updated = state.value!.doctors
          .where((d) => d.id != doctorId)
          .toList();
      state = AsyncData(
        state.value!.copyWith(doctors: updated, isLoading: false),
      );
    } catch (e, st) {
      log('🛑 Delete doctor error (id=$doctorId): $e',
          error: e, stackTrace: st);
      state = AsyncData(
        state.value!.copyWith(isLoading: false, errorMessage: 'فشل حذف الطبيب'),
      );
    }
  }

  Future<void> updateDoctor(UserModel doctor) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.updateDoctor(doctor);
      final updated = state.value!.doctors
          .map((d) => d.id == doctor.id ? doctor : d)
          .toList();
      state = AsyncData(
        state.value!.copyWith(doctors: updated, isLoading: false),
      );
    } catch (e, st) {
      log('🛑 Update doctor error (id=${doctor.id}): $e',
          error: e, stackTrace: st);
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: 'فشل تحديث بيانات الطبيب',
        ),
      );
    }
  }
}
