import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/auth/models/user_model.dart';
import '../../../features/booking/models/appointment_model.dart';
import '../models/admin_states.dart';
import '../services/remote/admin_remote_service.dart';

part 'generated/admin_provider.g.dart';

@Riverpod(keepAlive: true)
class Admin extends _$Admin {
  late final AdminRemoteService _remoteService;

  @override
  Future<AdminStates> build() async {
    _remoteService = AdminRemoteService();
    return _fetchAll();
  }

  Future<AdminStates> _fetchAll() async {
    final results = await Future.wait([
      _remoteService.getAllDoctors(),
      _remoteService.getAllPatients(),
      _remoteService.getAllAppointments(),
    ]);
    return AdminStates(
      doctors: results[0] as List<UserModel>,
      patients: results[1] as List<UserModel>,
      appointments: results[2] as List<AppointmentModel>,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchAll);
    state = await AsyncValue.guard(_fetchAll);
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
    } catch (e) {
      log('Delete appointment error: $e');
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
    } catch (e) {
      log('Delete doctor error: $e');
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
    } catch (e) {
      log('Update doctor error: $e');
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: 'فشل تحديث بيانات الطبيب',
        ),
      );
    }
  }
}
