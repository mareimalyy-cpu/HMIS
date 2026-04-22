import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/enum/constants.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../booking/data/models/appointment_model.dart';

class AdminRemoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllPatients() async {
    final snapshot = await _firestore
        .collection(Constants.users.name)
        .where('role', isEqualTo: 'patient')
        .get();
    return snapshot.docs.map((d) => UserModel.fromJson(d.data())).toList();
  }

  Future<List<UserModel>> getAllDoctors() async {
    final snapshot = await _firestore
        .collection(Constants.users.name)
        .where('role', isEqualTo: 'doctor')
        .where('doctorStatus', isEqualTo: 'approved')
        .get();
    return snapshot.docs.map((d) => UserModel.fromJson(d.data())).toList();
  }

  Future<List<UserModel>> getPendingDoctors() async {
    final snapshot = await _firestore
        .collection(Constants.users.name)
        .where('role', isEqualTo: 'doctor')
        .where('doctorStatus', isEqualTo: 'pending')
        .get();
    return snapshot.docs.map((d) => UserModel.fromJson(d.data())).toList();
  }

  Future<void> approveDoctor(String doctorId, String adminId) async {
    await _firestore.collection(Constants.users.name).doc(doctorId).update({
      'doctorStatus': DoctorStatus.approved.value,
      'approvedBy': adminId,
      'approvedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    });
  }

  Future<void> rejectDoctor(String doctorId, String adminId) async {
    await _firestore.collection(Constants.users.name).doc(doctorId).update({
      'doctorStatus': DoctorStatus.rejected.value,
      'approvedBy': adminId,
      'approvedAt': DateTime.now().toIso8601String(),
      'isActive': false,
    });
  }

  Future<List<AppointmentModel>> getAllAppointments() async {
    final snapshot = await _firestore
        .collection(Constants.appointments.name)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((d) => AppointmentModel.fromJson(d.data()))
        .toList();
  }

  Future<List<AppointmentModel>> getPatientAppointments(
      String patientId) async {
    final snapshot = await _firestore
        .collection(Constants.appointments.name)
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((d) => AppointmentModel.fromJson(d.data()))
        .toList();
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore
        .collection(Constants.appointments.name)
        .doc(appointmentId)
        .delete();
  }

  Future<void> deleteDoctor(String doctorId) async {
    await _firestore
        .collection(Constants.users.name)
        .doc(doctorId)
        .delete();
  }

  Future<void> updateDoctor(UserModel doctor) async {
    await _firestore
        .collection(Constants.users.name)
        .doc(doctor.id)
        .update(doctor.toJson());
  }
}
