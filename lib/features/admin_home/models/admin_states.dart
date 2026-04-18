import '../../auth/models/user_model.dart';
import '../../booking/models/appointment_model.dart';

class AdminStates {
  final List<UserModel> doctors;
  final List<UserModel> patients;
  final List<AppointmentModel> appointments;
  final bool isLoading;
  final String? errorMessage;

  const AdminStates({
    this.doctors = const [],
    this.patients = const [],
    this.appointments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory AdminStates.initial() => const AdminStates();

  int get doctorCount => doctors.length;
  int get patientCount => patients.length;
  int get appointmentCount => appointments.length;

  AdminStates copyWith({
    List<UserModel>? doctors,
    List<UserModel>? patients,
    List<AppointmentModel>? appointments,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminStates(
      doctors: doctors ?? this.doctors,
      patients: patients ?? this.patients,
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
