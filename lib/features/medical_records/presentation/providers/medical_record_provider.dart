import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/medical_record_states.dart';
import '../../data/services/remote/medical_record_remote_service.dart';

part 'generated/medical_record_provider.g.dart';

@Riverpod(keepAlive: true)
class MedicalRecord extends _$MedicalRecord {
  late final MedicalRecordRemoteService _remoteService;

  @override
  Future<MedicalRecordStates> build() async {
    _remoteService = MedicalRecordRemoteService();
    return MedicalRecordStates.initial();
  }

  Future<void> loadRecordsForPatient(String patientId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final records = await _remoteService.getRecordsForPatient(patientId);
      return MedicalRecordStates(records: records);
    });
  }

  Future<void> addRecord({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String createdBy,
    required String diagnosis,
    required String symptoms,
    required String treatment,
    String? appointmentId,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final record = await _remoteService.addRecord(
        patientId: patientId,
        doctorId: doctorId,
        doctorName: doctorName,
        createdBy: createdBy,
        diagnosis: diagnosis,
        symptoms: symptoms,
        treatment: treatment,
        appointmentId: appointmentId,
      );
      state = AsyncData(state.value!.copyWith(
        records: [record, ...state.value!.records],
        isLoading: false,
      ));
    } catch (e) {
      log('Add record error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: 'فشل إضافة السجل الطبي',
      ));
    }
  }

  Future<void> loadPrescriptions(
      String patientId, String recordId) async {
    try {
      final prescriptions =
          await _remoteService.getPrescriptions(patientId, recordId);
      state = AsyncData(
          state.value!.copyWith(prescriptions: prescriptions));
    } catch (e) {
      log('Load prescriptions error: $e');
    }
  }

  Future<void> addPrescription({
    required String patientId,
    required String recordId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required String duration,
    String? instructions,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final p = await _remoteService.addPrescription(
        patientId: patientId,
        recordId: recordId,
        medicationName: medicationName,
        dosage: dosage,
        frequency: frequency,
        duration: duration,
        instructions: instructions,
      );
      state = AsyncData(state.value!.copyWith(
        prescriptions: [...state.value!.prescriptions, p],
        isLoading: false,
      ));
    } catch (e) {
      log('Add prescription error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: 'فشل إضافة الوصفة الطبية',
      ));
    }
  }

  Future<void> addLabTest({
    required String patientId,
    required String recordId,
    required String testName,
    required String result,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final test = await _remoteService.addLabTest(
        patientId: patientId,
        recordId: recordId,
        testName: testName,
        result: result,
      );
      state = AsyncData(state.value!.copyWith(
        labTests: [...state.value!.labTests, test],
        isLoading: false,
      ));
    } catch (e) {
      log('Add lab test error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: 'فشل إضافة التحليل',
      ));
    }
  }
}
