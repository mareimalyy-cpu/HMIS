import 'user_model.dart';

class AuthStates {

  const AuthStates({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.selectedRole,
    this.needsProfileCompletion = false,
    this.needsEmailVerification = false,
  });

  factory AuthStates.initial() => const AuthStates();
  final UserModel? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final UserRole? selectedRole;
  final bool needsProfileCompletion;
  final bool needsEmailVerification;

  bool get isDoctor => currentUser?.role == UserRole.doctor;
  bool get isPatient => currentUser?.role == UserRole.patient;
  bool get isAdmin => currentUser?.role == UserRole.admin;
  bool get isReceptionist => currentUser?.role == UserRole.receptionist;
  bool get isPendingApproval => currentUser?.isPendingApproval ?? false;

  AuthStates copyWith({
    UserModel? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    UserRole? selectedRole,
    bool? needsProfileCompletion,
    bool? needsEmailVerification,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthStates(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      selectedRole: selectedRole ?? this.selectedRole,
      needsProfileCompletion:
          needsProfileCompletion ?? this.needsProfileCompletion,
      needsEmailVerification:
          needsEmailVerification ?? this.needsEmailVerification,
    );
  }
}
