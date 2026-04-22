import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/time_slot_states.dart';
import '../../data/services/remote/time_slot_remote_service.dart';

part 'generated/time_slot_provider.g.dart';

@Riverpod(keepAlive: true)
class TimeSlot extends _$TimeSlot {
  late final TimeSlotRemoteService _remoteService;

  @override
  Future<TimeSlotStates> build() async {
    _remoteService = TimeSlotRemoteService();
    return TimeSlotStates.initial();
  }

  Future<void> loadSlotsForDoctor(String doctorId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final slots = await _remoteService.getSlotsForDoctor(doctorId);
      return TimeSlotStates(slots: slots);
    });
  }

  Future<void> loadAvailableSlots(String doctorId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final slots = await _remoteService.getAvailableSlotsForDoctor(doctorId);
      return TimeSlotStates(slots: slots);
    });
  }

  Future<void> addSlot({
    required String doctorId,
    required String startTime,
    required String endTime,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final slot = await _remoteService.createSlot(
        doctorId: doctorId,
        startTime: startTime,
        endTime: endTime,
      );
      state = AsyncData(state.value!.copyWith(
        slots: [...state.value!.slots, slot],
        isLoading: false,
      ));
    } catch (e) {
      log('Add slot error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: 'فشل إضافة الموعد',
      ));
    }
  }

  Future<void> deleteSlot({
    required String doctorId,
    required String slotId,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.deleteSlot(doctorId: doctorId, slotId: slotId);
      state = AsyncData(state.value!.copyWith(
        slots: state.value!.slots.where((s) => s.id != slotId).toList(),
        isLoading: false,
      ));
    } catch (e) {
      log('Delete slot error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: 'فشل حذف الموعد',
      ));
    }
  }

  void markSlotBooked(String slotId, String appointmentId) {
    final updated = state.value!.slots.map((s) {
      if (s.id != slotId) return s;
      return s.copyWith(isBooked: true, appointmentId: appointmentId);
    }).toList();
    state = AsyncData(state.value!.copyWith(slots: updated));
  }
}
