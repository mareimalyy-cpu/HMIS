import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/local_services/local_storage.dart';
import '../models/auth_states.dart';
import '../models/user_model.dart';
import '../services/local/auth_local_service.dart';
import '../services/remote/auth_remote_service.dart';

part 'generated/auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthRemoteService _remoteService;
  late final AuthLocalService _localService;

  @override
  Future<AuthStates> build() async {
    _remoteService = AuthRemoteService();
    _localService = AuthLocalService(LocalStorage.instance);
    try {
      return _loadFromLocal() ?? AuthStates.initial();
    } catch (e) {
      return AuthStates(errorMessage: e.toString());
    }
  }

  AuthStates? _loadFromLocal() {
    final cachedUser = _localService.getUser();
    if (cachedUser != null) {
      return AuthStates(
        currentUser: cachedUser,
        isAuthenticated: true,
        selectedRole: cachedUser.role,
      );
    }
    return null;
  }

  void selectRole(UserRole role) {
    state = AsyncData(state.value!.copyWith(
      selectedRole: role,
      clearError: true,
    ));
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = AsyncData(state.value!.copyWith(
      isLoading: true,
      clearError: true,
    ));

    try {
      final user = await _remoteService.login(
        email: email,
        password: password,
      );
      unawaited(_localService.saveUser(user));
      state = AsyncData(AuthStates(
        currentUser: user,
        isAuthenticated: true,
        selectedRole: user.role,
      ));
    } catch (e) {
      log('Login error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: _mapFirebaseError(e),
      ));
    }
  }

  Future<void> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String city,
    required int age,
  }) async {
    state = AsyncData(state.value!.copyWith(
      isLoading: true,
      clearError: true,
    ));

    try {
      final user = await _remoteService.registerPatient(
        name: name,
        email: email,
        password: password,
        phone: phone,
        city: city,
        age: age,
      );
      unawaited(_localService.saveUser(user));
      state = AsyncData(AuthStates(
        currentUser: user,
        isAuthenticated: true,
        selectedRole: UserRole.patient,
      ));
    } catch (e) {
      log('Register patient error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: _mapFirebaseError(e),
      ));
    }
  }

  Future<void> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String specialty,
    required String hospital,
    required String hospitalAddress,
  }) async {
    state = AsyncData(state.value!.copyWith(
      isLoading: true,
      clearError: true,
    ));

    try {
      final user = await _remoteService.registerDoctor(
        name: name,
        email: email,
        password: password,
        phone: phone,
        specialty: specialty,
        hospital: hospital,
        hospitalAddress: hospitalAddress,
      );
      unawaited(_localService.saveUser(user));
      state = AsyncData(AuthStates(
        currentUser: user,
        isAuthenticated: true,
        selectedRole: UserRole.doctor,
      ));
    } catch (e) {
      log('Register doctor error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: _mapFirebaseError(e),
      ));
    }
  }

  Future<void> logout() async {
    try {
      await _remoteService.logout();
      await _localService.clearUser();
      state = AsyncData(AuthStates.initial());
    } catch (e) {
      log('Logout error: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _remoteService.getCurrentUser();
      if (user != null) {
        unawaited(_localService.saveUser(user));
        return AuthStates(
          currentUser: user,
          isAuthenticated: true,
          selectedRole: user.role,
        );
      }
      return _loadFromLocal() ?? AuthStates.initial();
    });
  }

  String _mapFirebaseError(Object e) {
    final message = e.toString();
    if (message.contains('user-not-found')) {
      return 'No account found with this email';
    } else if (message.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (message.contains('email-already-in-use')) {
      return 'This email is already registered';
    } else if (message.contains('weak-password')) {
      return 'Password is too weak';
    } else if (message.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (message.contains('network-request-failed')) {
      return 'Network error, please check your connection';
    }
    return 'An unexpected error occurred';
  }
}
