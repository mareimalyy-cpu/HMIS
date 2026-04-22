import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/enum/constants.dart';
import '../../../../booking/data/models/appointment_model.dart';
import '../../models/time_slot_model.dart';

class TimeSlotRemoteService {
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ── Collection helpers ───────────────────────────────────────────────────────
  // All slot data lives under doctors/{doctorId}/timeSlots/

  CollectionReference<Map<String, dynamic>> _slotsRef(String doctorId) => _db
      .collection(Constants.doctors.name)
      .doc(doctorId)
      .collection(Constants.timeSlots.name);

  // ── Queries ──────────────────────────────────────────────────────────────────

  Future<List<TimeSlotModel>> getSlotsForDoctor(String doctorId) async {
    final snap =
        await _slotsRef(doctorId).orderBy('startTime').get();
    return snap.docs.map((d) => TimeSlotModel.fromJson(d.data())).toList();
  }

  Future<List<TimeSlotModel>> getAvailableSlotsForDoctor(
      String doctorId) async {
    final snap = await _slotsRef(doctorId)
        .where('isBooked', isEqualTo: false)
        .orderBy('startTime')
        .get();
    return snap.docs.map((d) => TimeSlotModel.fromJson(d.data())).toList();
  }

  // ── Mutations ────────────────────────────────────────────────────────────────

  Future<TimeSlotModel> createSlot({
    required String doctorId,
    required String startTime,
    required String endTime,
  }) async {
    // Overlap / duplicate check
    final existing = await getSlotsForDoctor(doctorId);
    final newStart = DateTime.parse(startTime);
    final newEnd = DateTime.parse(endTime);

    for (final s in existing) {
      final sStart = DateTime.tryParse(s.startTime);
      final sEnd = DateTime.tryParse(s.endTime);
      if (sStart == null || sEnd == null) continue;

      final overlaps = newStart.isBefore(sEnd) && newEnd.isAfter(sStart);
      if (overlaps) throw Exception('slot_overlap');
    }

    final id = _uuid.v4();
    final slot = TimeSlotModel(
      id: id,
      doctorId: doctorId,
      startTime: startTime,
      endTime: endTime,
      createdAt: DateTime.now().toIso8601String(),
    );
    await _slotsRef(doctorId).doc(id).set(slot.toJson());
    return slot;
  }

  /// Deletes the slot, cancels linked appointments, and notifies patients.
  Future<void> deleteSlot({
    required String doctorId,
    required String slotId,
  }) async {
    final slotRef = _slotsRef(doctorId).doc(slotId);

    // Guard: do not delete booked slots
    final slotSnap = await slotRef.get();
    if (!slotSnap.exists) throw Exception('slot_not_found');
    final slot = TimeSlotModel.fromJson(slotSnap.data()!);
    if (slot.isBooked) throw Exception('cannot_delete_booked_slot');

    // Find scheduled appointments linked to this slot
    final appointmentsSnap = await _db
        .collection(Constants.appointments.name)
        .where('timeSlotId', isEqualTo: slotId)
        .where('status', isEqualTo: 'scheduled')
        .get();

    final batch = _db.batch();

    for (final doc in appointmentsSnap.docs) {
      final appointment = AppointmentModel.fromJson(doc.data());

      batch.update(doc.reference, {
        'status': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // In-app notification to the patient (stays in users/ since patients are there)
      final patientId = appointment.patientUserId.isNotEmpty
          ? appointment.patientUserId
          : appointment.patientId;

      final notifRef = _db
          .collection(Constants.users.name)
          .doc(patientId)
          .collection('notifications')
          .doc(_uuid.v4());

      batch.set(notifRef, {
        'id': notifRef.id,
        'title': 'تم إلغاء موعدك',
        'body':
            'تم إلغاء موعدك مع الدكتور ${appointment.doctorName} بتاريخ ${appointment.date} الساعة ${appointment.time}.',
        'type': 'appointment_cancelled',
        'appointmentId': appointment.id,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    batch.delete(slotRef);
    await batch.commit();
  }

  /// Atomically marks the slot as booked and saves the appointment.
  /// Throws if the slot no longer exists or is already booked.
  Future<void> bookSlotWithAppointment({
    required String doctorId,
    required String slotId,
    required AppointmentModel appointment,
  }) async {
    final slotRef = _slotsRef(doctorId).doc(slotId);
    final appointmentRef =
        _db.collection(Constants.appointments.name).doc(appointment.id);

    await _db.runTransaction((tx) async {
      final slotSnap = await tx.get(slotRef);
      if (!slotSnap.exists) throw Exception('الموعد غير موجود');
      final current = TimeSlotModel.fromJson(slotSnap.data()!);
      if (current.isBooked) throw Exception('هذا الموعد محجوز بالفعل');

      tx.update(slotRef, {
        'isBooked': true,
        'appointmentId': appointment.id,
      });
      tx.set(appointmentRef, appointment.toJson());
    });
  }
}
