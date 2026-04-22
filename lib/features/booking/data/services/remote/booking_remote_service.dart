import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/enum/constants.dart';
import '../../models/appointment_model.dart';

class BookingRemoteService {
  final _db = FirebaseFirestore.instance;

  Future<void> submitBooking(AppointmentModel appointment) async {
    await _db
        .collection(Constants.appointments.name)
        .doc(appointment.id)
        .set(appointment.toJson());
  }

  Future<int> getNextAppointmentNumber(String doctorId, String date) async {
    final snap = await _db
        .collection(Constants.appointments.name)
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
        .count()
        .get();
    return (snap.count ?? 0) + 1;
  }
}
