import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../attachments/data/services/file_upload_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../doctor/data/models/time_slot_model.dart';
import '../../../doctor/data/services/remote/time_slot_remote_service.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/data/services/notification_firestore_service.dart';
import '../../../../core/notifications/local_notifications_service.dart';
import '../../data/models/appointment_model.dart';
import '../../../attachments/data/models/booking_attachment.dart';
import '../../data/models/booking_states.dart';
import '../../data/services/remote/booking_remote_service.dart';

part 'generated/booking_provider.g.dart';

@Riverpod(keepAlive: true)
class Booking extends _$Booking {
  late final BookingRemoteService _bookingService;
  late final TimeSlotRemoteService _slotService;
  final _uploadService = FileUploadService.instance;
  final _notifService = NotificationFirestoreService();
  final _localNotif = LocalNotificationsService.instance;

  @override
  Future<BookingStates> build() async {
    _bookingService = BookingRemoteService();
    _slotService = TimeSlotRemoteService();
    return BookingStates.initial();
  }

  // ─── Slot loading ────────────────────────────────────────────────────────────

  Future<void> loadAvailableSlots(String doctorId) async {
    final current = state.value ?? BookingStates.initial();
    state = AsyncData(
      current.copyWith(
        isSlotsLoading: true,
        clearSlotsError: true,
        clearSelectedSlot: true,
      ),
    );

    try {
      final slots = await _slotService.getAvailableSlotsForDoctor(doctorId);
      state = AsyncData(
        (state.value ?? BookingStates.initial()).copyWith(
          availableSlots: slots,
          isSlotsLoading: false,
        ),
      );
    } catch (e) {
      log('Load slots error: $e');
      state = AsyncData(
        (state.value ?? BookingStates.initial()).copyWith(
          isSlotsLoading: false,
          slotsError: e.toString(),
        ),
      );
    }
  }

  void selectSlot(TimeSlotModel slot) {
    final current = state.value ?? BookingStates.initial();
    state = AsyncData(current.copyWith(selectedSlot: slot));
  }

  // ─── File attachments ────────────────────────────────────────────────────────

  Future<String?> pickAndUploadFiles({required String patientId}) async {
    final current = state.value ?? BookingStates.initial();

    List<PlatformFile>? picked;
    try {
      picked = await _uploadService.pickFiles();
    } catch (e) {
      log('File picker error: $e');
      return 'upload_failed';
    }

    if (picked == null || picked.isEmpty) return null;

    final errors = <String>[];
    final toUpload = <PlatformFile>[];

    for (final file in picked) {
      final alreadyAdded = current.attachments.any((a) => a.name == file.name);
      if (alreadyAdded) {
        errors.add('duplicate_file');
        continue;
      }
      final errorKey = _uploadService.validate(
        file,
        current.attachments.length + toUpload.length,
      );
      if (errorKey != null) {
        errors.add(errorKey);
        continue;
      }
      toUpload.add(file);
    }

    if (toUpload.isEmpty) return errors.isNotEmpty ? errors.first : null;

    final pending = toUpload.map((f) => BookingAttachment(
          name: f.name,
          sizeBytes: f.size,
          localPath: f.path ?? '',
          isUploading: true,
        ));

    state = AsyncData(
      (state.value ?? BookingStates.initial()).copyWith(
        attachments: [...(state.value?.attachments ?? []), ...pending],
      ),
    );

    await Future.wait(toUpload.map((f) => _uploadSingle(f, patientId)));

    return errors.isNotEmpty ? errors.first : null;
  }

  Future<void> _uploadSingle(PlatformFile platformFile, String patientId) async {
    final filePath = platformFile.path;
    if (filePath == null) {
      _markUploadError(platformFile.name, 'upload_failed');
      return;
    }
    try {
      final url = await _uploadService.upload(
        patientId: patientId,
        fileName: platformFile.name,
        file: File(filePath),
      );
      _markUploadDone(platformFile.name, url);
    } catch (e) {
      log('Upload failed for ${platformFile.name}: $e');
      _markUploadError(platformFile.name, 'upload_failed');
    }
  }

  void _markUploadDone(String fileName, String url) {
    final current = state.value ?? BookingStates.initial();
    final updated = current.attachments.map((a) {
      if (a.name != fileName) return a;
      return a.copyWith(isUploading: false, url: url, clearError: true);
    }).toList();
    state = AsyncData(current.copyWith(attachments: updated));
  }

  void _markUploadError(String fileName, String errorKey) {
    final current = state.value ?? BookingStates.initial();
    final updated = current.attachments.map((a) {
      if (a.name != fileName) return a;
      return a.copyWith(isUploading: false, uploadError: errorKey);
    }).toList();
    state = AsyncData(current.copyWith(attachments: updated));
  }

  void removeAttachment(String fileName) {
    final current = state.value ?? BookingStates.initial();
    final attachment =
        current.attachments.where((a) => a.name == fileName).firstOrNull;
    if (attachment?.url != null) {
      unawaited(_uploadService.deleteByUrl(attachment!.url!));
    }
    state = AsyncData(
      current.copyWith(
        attachments:
            current.attachments.where((a) => a.name != fileName).toList(),
      ),
    );
  }

  // ─── Booking submission ──────────────────────────────────────────────────────

  Future<void> submitBooking({
    required UserModel patient,
    required UserModel doctor,
    required TimeSlotModel slot,
    required String symptoms,
  }) async {
    final current = state.value ?? BookingStates.initial();
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    try {
      final start = DateTime.parse(slot.startTime);
      final date = DateFormat('yyyy-MM-dd').format(start);
      final time = DateFormat('hh:mm a').format(start);

      final number = await _bookingService.getNextAppointmentNumber(
        doctor.id,
        date,
      );

      final id =
          '${doctor.id}_${patient.id}_${DateTime.now().millisecondsSinceEpoch}';

      final appointment = AppointmentModel(
        id: id,
        patientId: patient.id,
        patientUserId: patient.id,
        patientName: patient.name,
        patientPhone: patient.phone,
        patientImageUrl: patient.imageUrl,
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty ?? '',
        doctorImageUrl: doctor.imageUrl,
        date: date,
        time: time,
        number: number,
        symptoms: symptoms,
        status: 'pending',
        address: doctor.hospitalAddress,
        timeSlotId: slot.id,
        actorRole: 'patient',
        attachments: current.attachmentUrls,
      );

      await _slotService.bookSlotWithAppointment(
        doctorId: doctor.id,
        slotId: slot.id,
        appointment: appointment,
      );

      state = AsyncData(current.copyWith(isLoading: false, isSuccess: true));

      unawaited(_sendBookingNotifications(
        patient: patient,
        doctor: doctor,
        appointment: appointment,
      ));
    } catch (e) {
      state = AsyncData(
        current.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  // ─── Post-booking notifications & reminders ──────────────────────────────────

  Future<void> _sendBookingNotifications({
    required UserModel patient,
    required UserModel doctor,
    required AppointmentModel appointment,
  }) async {
    try {
      final appointmentDateTime = DateTime.parse(
        '${appointment.date} ${appointment.time}',
      );

      // Notify doctor of new appointment
      unawaited(_notifService.send(
        userId: doctor.id,
        title: 'New Appointment',
        body: 'Patient ${patient.name} booked on ${appointment.date} at ${appointment.time}',
        type: NotificationType.appointment,
        priority: NotificationPriority.high,
        entityId: appointment.id,
        route: '/doctor-home',
      ));

      // Notify patient of booking confirmation
      unawaited(_notifService.send(
        userId: patient.id,
        title: 'Booking Confirmed',
        body: 'Your appointment with Dr. ${doctor.name} on ${appointment.date} at ${appointment.time} is confirmed.',
        type: NotificationType.appointment,
        priority: NotificationPriority.normal,
        entityId: appointment.id,
        route: '/patient-home',
      ));

      // Schedule 24h reminder
      final reminder24h = appointmentDateTime.subtract(const Duration(hours: 24));
      unawaited(_localNotif.schedule(
        title: 'Appointment Tomorrow',
        body: 'You have an appointment with Dr. ${doctor.name} tomorrow at ${appointment.time}.',
        delay: reminder24h.toIso8601String(),
        priority: 2,
      ));

      // Schedule 1h reminder
      final reminder1h = appointmentDateTime.subtract(const Duration(hours: 1));
      unawaited(_localNotif.schedule(
        title: 'Appointment in 1 Hour',
        body: 'Your appointment with Dr. ${doctor.name} starts at ${appointment.time}.',
        delay: reminder1h.toIso8601String(),
        priority: 2,
      ));
    } catch (e) {
      log('Post-booking notifications error: $e');
    }
  }

  // ─── Misc ────────────────────────────────────────────────────────────────────

  void reset() {
    state = AsyncData(BookingStates.initial());
  }
}
