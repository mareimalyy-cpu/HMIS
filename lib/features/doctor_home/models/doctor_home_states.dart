import '../../auth/models/user_model.dart';
import '../../booking/models/appointment_model.dart';

class DoctorHomeStates {
  final UserModel? currentDoctor;
  final List<AppointmentModel> todayAppointments;
  final List<AppointmentModel> allAppointments;
  final bool isLoading;
  final String? errorMessage;

  const DoctorHomeStates({
    this.currentDoctor,
    this.todayAppointments = const [],
    this.allAppointments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory DoctorHomeStates.initial() => const DoctorHomeStates();

  // Derived getters
  String get greeting => 'Welcome, Dr. ${currentDoctor?.name ?? ''}';

  List<AppointmentModel> get newPatients {
    final seen = <String>{};
    return todayAppointments.where((a) => seen.add(a.patientId)).toList();
  }

  List<AppointmentModel> get recentCases {
    final sorted = List<AppointmentModel>.from(allAppointments)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  int get todayCount => todayAppointments.length;

  DoctorHomeStates copyWith({
    UserModel? currentDoctor,
    List<AppointmentModel>? todayAppointments,
    List<AppointmentModel>? allAppointments,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DoctorHomeStates(
      currentDoctor: currentDoctor ?? this.currentDoctor,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      allAppointments: allAppointments ?? this.allAppointments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
