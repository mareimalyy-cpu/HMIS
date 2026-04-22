import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/enum/constants.dart';
import '../../models/lab_test_model.dart';
import '../../models/medical_record_model.dart';
import '../../models/prescription_model.dart';

class MedicalRecordRemoteService {
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference _recordsRef(String patientId) => _db
      .collection(Constants.users.name)
      .doc(patientId)
      .collection(Constants.medicalRecords.name);

  CollectionReference _prescriptionsRef(
          String patientId, String recordId) =>
      _recordsRef(patientId)
          .doc(recordId)
          .collection(Constants.prescriptions.name);

  CollectionReference _labTestsRef(String patientId, String recordId) =>
      _recordsRef(patientId)
          .doc(recordId)
          .collection(Constants.labTests.name);

  Future<List<MedicalRecordModel>> getRecordsForPatient(
      String patientId) async {
    final snap = await _recordsRef(patientId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) =>
            MedicalRecordModel.fromJson(d.data()! as Map<String, dynamic>))
        .toList();
  }

  Future<MedicalRecordModel> addRecord({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String createdBy,
    required String diagnosis,
    required String symptoms,
    required String treatment,
    String? appointmentId,
  }) async {
    final id = _uuid.v4();
    final record = MedicalRecordModel(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      doctorName: doctorName,
      appointmentId: appointmentId,
      diagnosis: diagnosis,
      symptoms: symptoms,
      treatment: treatment,
      visitDate: DateTime.now().toIso8601String(),
      createdBy: createdBy,
      createdAt: DateTime.now().toIso8601String(),
    );
    await _recordsRef(patientId).doc(id).set(record.toJson());
    return record;
  }

  Future<List<PrescriptionModel>> getPrescriptions(
      String patientId, String recordId) async {
    final snap = await _prescriptionsRef(patientId, recordId).get();
    return snap.docs
        .map((d) =>
            PrescriptionModel.fromJson(d.data()! as Map<String, dynamic>))
        .toList();
  }

  Future<PrescriptionModel> addPrescription({
    required String patientId,
    required String recordId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required String duration,
    String? instructions,
  }) async {
    final id = _uuid.v4();
    final prescription = PrescriptionModel(
      id: id,
      medicationName: medicationName,
      dosage: dosage,
      frequency: frequency,
      duration: duration,
      instructions: instructions,
    );
    await _prescriptionsRef(patientId, recordId)
        .doc(id)
        .set(prescription.toJson());
    return prescription;
  }

  Future<List<LabTestModel>> getLabTests(
      String patientId, String recordId) async {
    final snap = await _labTestsRef(patientId, recordId).get();
    return snap.docs
        .map((d) =>
            LabTestModel.fromJson(d.data()! as Map<String, dynamic>))
        .toList();
  }

  Future<LabTestModel> addLabTest({
    required String patientId,
    required String recordId,
    required String testName,
    required String result,
  }) async {
    final id = _uuid.v4();
    final test = LabTestModel(
      id: id,
      testName: testName,
      result: result,
      testDate: DateTime.now().toIso8601String(),
    );
    await _labTestsRef(patientId, recordId).doc(id).set(test.toJson());
    return test;
  }
}
