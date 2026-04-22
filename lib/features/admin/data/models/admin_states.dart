import '../../../auth/data/models/user_model.dart';
import '../../../booking/data/models/appointment_model.dart';

class AdminStates {

  const AdminStates({
    this.doctors = const [],
    this.pendingDoctors = const [],
    this.patients = const [],
    this.appointments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory AdminStates.initial() => const AdminStates();
  final List<UserModel> doctors;
  final List<UserModel> pendingDoctors;
  final List<UserModel> patients;
  final List<AppointmentModel> appointments;
  final bool isLoading;
  final String? errorMessage;

  int get doctorCount => doctors.length;
  int get patientCount => patients.length;
  int get appointmentCount => appointments.length;
  int get pendingDoctorCount => pendingDoctors.length;

  AdminStates copyWith({
    List<UserModel>? doctors,
    List<UserModel>? pendingDoctors,
    List<UserModel>? patients,
    List<AppointmentModel>? appointments,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminStates(
      doctors: doctors ?? this.doctors,
      pendingDoctors: pendingDoctors ?? this.pendingDoctors,
      patients: patients ?? this.patients,
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
