import '../../../booking/data/models/appointment_model.dart';

class PatientAppointmentsStates {

  const PatientAppointmentsStates({
    this.appointments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory PatientAppointmentsStates.initial() =>
      const PatientAppointmentsStates();
  final List<AppointmentModel> appointments;
  final bool isLoading;
  final String? errorMessage;

  List<AppointmentModel> get upcoming => appointments
      .where((a) =>
          a.status == 'scheduled' ||
          a.status == 'pending' ||
          a.status == 'approved')
      .toList();

  List<AppointmentModel> get past => appointments
      .where((a) =>
          a.status == 'completed' ||
          a.status == 'cancelled' ||
          a.status == 'no_show')
      .toList();

  PatientAppointmentsStates copyWith({
    List<AppointmentModel>? appointments,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PatientAppointmentsStates(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
