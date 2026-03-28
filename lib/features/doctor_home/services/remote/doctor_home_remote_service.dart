import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../booking/models/appointment_model.dart';

class DoctorHomeRemoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AppointmentModel>> getTodayAppointments(String doctorId) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: today)
        .orderBy('time')
        .get();
    return snapshot.docs
        .map((doc) => AppointmentModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<AppointmentModel>> getAllAppointments(String doctorId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('date', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => AppointmentModel.fromJson(doc.data()))
        .toList();
  }
}
