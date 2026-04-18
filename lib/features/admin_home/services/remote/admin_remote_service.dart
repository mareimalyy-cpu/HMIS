import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enum/constants.dart';
import '../../../auth/models/user_model.dart';
import '../../../booking/models/appointment_model.dart';

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
        .get();
    return snapshot.docs.map((d) => UserModel.fromJson(d.data())).toList();
  }

  Future<List<AppointmentModel>> getAllAppointments() async {
    final snapshot = await _firestore
        .collection('appointments')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((d) => AppointmentModel.fromJson(d.data()))
        .toList();
  }

  Future<List<AppointmentModel>> getPatientAppointments(
      String patientId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((d) => AppointmentModel.fromJson(d.data()))
        .toList();
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).delete();
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
