import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/booking_states.dart';
import '../services/remote/booking_remote_service.dart';

part 'generated/booking_provider.g.dart';

@Riverpod(keepAlive: true)
class Booking extends _$Booking {
  late final BookingRemoteService _remoteService;

  @override
  Future<BookingStates> build() async {
    _remoteService = BookingRemoteService();
    return BookingStates.initial();
  }

  Future<void> submitBooking({
    required UserModel patient,
    required UserModel doctor,
    required String dayName,
    required String time,
    required String symptoms,
  }) async {
    final current = state.value ?? BookingStates.initial();
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    try {
      final date = _nextDateForDay(dayName);
      final number =
          await _remoteService.getNextAppointmentNumber(doctor.id, date);

      final id = '${doctor.id}_${patient.id}_${DateTime.now().millisecondsSinceEpoch}';

      final appointment = AppointmentModel(
        id: id,
        patientId: patient.id,
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
      );

      await _remoteService.submitBooking(appointment);
      state = AsyncData(current.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      state = AsyncData(
        current.copyWith(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  void selectDay(String day) {
    final current = state.value ?? BookingStates.initial();
    state = AsyncData(current.copyWith(selectedDay: day, clearTime: true));
  }

  void selectTime(String time) {
    final current = state.value ?? BookingStates.initial();
    state = AsyncData(current.copyWith(selectedTime: time));
  }

  void reset() {
    state = AsyncData(BookingStates.initial());
  }

  String _nextDateForDay(String dayName) {
    const weekdays = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
      'الاثنين': 1,
      'الثلاثاء': 2,
      'الأربعاء': 3,
      'الخميس': 4,
      'الجمعة': 5,
      'السبت': 6,
      'الأحد': 7,
    };
    final targetWeekday = weekdays[dayName];
    if (targetWeekday == null) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    final now = DateTime.now();
    int daysUntil = (targetWeekday - now.weekday) % 7;
    if (daysUntil == 0) daysUntil = 7;
    return DateFormat('yyyy-MM-dd').format(now.add(Duration(days: daysUntil)));
  }
}
