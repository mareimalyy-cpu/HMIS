import '../../auth/models/user_model.dart';
import 'specialty_model.dart';

class PatientHomeStates {
  final UserModel? currentUser;
  final List<SpecialtyModel> specialties;
  final List<UserModel> allDoctors;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const PatientHomeStates({
    this.currentUser,
    this.specialties = const [],
    this.allDoctors = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  factory PatientHomeStates.initial() => PatientHomeStates(
        specialties: SpecialtyModel.defaults,
      );

  // Derived getters
  String get greeting => 'Welcome, ${currentUser?.name ?? ''}';

  List<UserModel> get filteredDoctors {
    if (searchQuery.isEmpty) return allDoctors;
    final query = searchQuery.toLowerCase();
    return allDoctors
        .where((d) =>
            d.name.toLowerCase().contains(query) ||
            (d.specialty?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  List<UserModel> doctorsBySpecialty(String specialtyId) {
    return allDoctors
        .where((d) => d.specialty?.toLowerCase() == specialtyId.toLowerCase())
        .toList();
  }

  PatientHomeStates copyWith({
    UserModel? currentUser,
    List<SpecialtyModel>? specialties,
    List<UserModel>? allDoctors,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PatientHomeStates(
      currentUser: currentUser ?? this.currentUser,
      specialties: specialties ?? this.specialties,
      allDoctors: allDoctors ?? this.allDoctors,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
