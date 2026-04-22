import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/enum/constants.dart';
import '../../../../booking/data/models/appointment_model.dart';

class PatientAppointmentsRemoteService {
  final _db = FirebaseFirestore.instance;

  Future<List<AppointmentModel>> getForPatient(String patientId) async {
    final snap = await _db
        .collection(Constants.appointments.name)
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) => AppointmentModel.fromJson(d.data())).toList();
  }

  Future<void> cancel(String appointmentId) async {
    await _db
        .collection(Constants.appointments.name)
        .doc(appointmentId)
        .update({
      'status': 'cancelled',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
