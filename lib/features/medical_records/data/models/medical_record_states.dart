import 'lab_test_model.dart';
import 'medical_record_model.dart';
import 'prescription_model.dart';

class MedicalRecordStates {

  const MedicalRecordStates({
    this.records = const [],
    this.prescriptions = const [],
    this.labTests = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory MedicalRecordStates.initial() => const MedicalRecordStates();
  final List<MedicalRecordModel> records;
  final List<PrescriptionModel> prescriptions;
  final List<LabTestModel> labTests;
  final bool isLoading;
  final String? errorMessage;

  MedicalRecordStates copyWith({
    List<MedicalRecordModel>? records,
    List<PrescriptionModel>? prescriptions,
    List<LabTestModel>? labTests,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MedicalRecordStates(
      records: records ?? this.records,
      prescriptions: prescriptions ?? this.prescriptions,
      labTests: labTests ?? this.labTests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
