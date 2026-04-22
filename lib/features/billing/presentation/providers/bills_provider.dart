import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/bills_states.dart';
import '../../data/services/remote/bills_remote_service.dart';

part 'generated/bills_provider.g.dart';

@Riverpod(keepAlive: true)
class Bills extends _$Bills {
  late final BillsRemoteService _remoteService;

  @override
  Future<BillsStates> build() async {
    _remoteService = BillsRemoteService();
    final bills = await _remoteService.getAllBills();
    return BillsStates(bills: bills);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bills = await _remoteService.getAllBills();
      return BillsStates(bills: bills);
    });
  }

  Future<void> loadForPatient(String patientId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bills = await _remoteService.getBillsForPatient(patientId);
      return BillsStates(bills: bills);
    });
  }

  BillsStates get _current => state.value ?? BillsStates.initial();

  Future<void> createBill({
    required String patientId,
    required String patientName,
    required String appointmentId,
    required double totalAmount,
    required String createdBy,
  }) async {
    state = AsyncData(_current.copyWith(isLoading: true, clearError: true));
    try {
      final bill = await _remoteService.createBill(
        patientId: patientId,
        patientName: patientName,
        appointmentId: appointmentId,
        totalAmount: totalAmount,
        createdBy: createdBy,
      );
      state = AsyncData(_current.copyWith(
        bills: [bill, ..._current.bills],
        isLoading: false,
      ));
    } catch (e) {
      log('Create bill error: $e');
      state = AsyncData(_current.copyWith(
        isLoading: false,
        errorMessage: 'فشل إنشاء الفاتورة',
      ));
    }
  }

  Future<void> markAsPaid(String billId) async {
    state = AsyncData(_current.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.markAsPaid(billId);
      final updated = _current.bills.map((b) {
        if (b.id != billId) return b;
        return b.copyWith(
          paymentStatus: 'paid',
          updatedAt: DateTime.now().toIso8601String(),
        );
      }).toList();
      state = AsyncData(_current.copyWith(bills: updated, isLoading: false));
    } catch (e) {
      log('Mark paid error: $e');
      state = AsyncData(_current.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحديث حالة الدفع',
      ));
    }
  }

  Future<void> deleteBill(String billId) async {
    state = AsyncData(_current.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.deleteBill(billId);
      state = AsyncData(_current.copyWith(
        bills: _current.bills.where((b) => b.id != billId).toList(),
        isLoading: false,
      ));
    } catch (e) {
      log('Delete bill error: $e');
      state = AsyncData(_current.copyWith(
        isLoading: false,
        errorMessage: 'فشل حذف الفاتورة',
      ));
    }
  }
}
