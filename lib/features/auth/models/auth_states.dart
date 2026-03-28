import 'user_model.dart';

class AuthStates {
  final UserModel? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final UserRole? selectedRole;

  const AuthStates({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.selectedRole,
  });

  factory AuthStates.initial() => const AuthStates();

  bool get isDoctor => currentUser?.role == UserRole.doctor;
  bool get isPatient => currentUser?.role == UserRole.patient;

  AuthStates copyWith({
    UserModel? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    UserRole? selectedRole,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthStates(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}
