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
    state = AsyncData(state.value!.copyWith(selectedRole: role, clearError: true));
  }

  Future<void> login({required String email, required String password}) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final user = await _remoteService.login(email: email, password: password);
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

  Future<void> loginWithGoogle() async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final user = await _remoteService.loginWithGoogle();
      final isIncomplete = user.phone.isEmpty || user.city.isEmpty;
      if (isIncomplete) {
        state = AsyncData(AuthStates(
          currentUser: user,
          isAuthenticated: false,
          needsProfileCompletion: true,
          selectedRole: user.role,
        ));
      } else {
        unawaited(_localService.saveUser(user));
        state = AsyncData(AuthStates(
          currentUser: user,
          isAuthenticated: true,
          selectedRole: user.role,
        ));
      }
    } catch (e) {
      log('Google login error: $e');
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        errorMessage: _mapFirebaseError(e),
      ));
    }
  }

  Future<void> completeGoogleProfile({
    required String phone,
    required String city,
    required int age,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final updated = state.value!.currentUser!.copyWith(
        phone: phone,
        city: city,
        age: age,
      );
      await _remoteService.updateUser(updated);
      unawaited(_localService.saveUser(updated));
      state = AsyncData(AuthStates(
        currentUser: updated,
        isAuthenticated: true,
        selectedRole: updated.role,
      ));
    } catch (e) {
      log('Complete profile error: $e');
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
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
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
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
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

  Future<void> resetPassword(String email) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.resetPassword(email);
      state = AsyncData(state.value!.copyWith(isLoading: false));
    } catch (e) {
      log('Reset password error: $e');
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
    final msg = e.toString();
    if (msg.contains('user-not-found') || msg.contains('invalid-credential')) {
      return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
    } else if (msg.contains('wrong-password')) {
      return 'كلمة المرور غير صحيحة';
    } else if (msg.contains('email-already-in-use')) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    } else if (msg.contains('weak-password')) {
      return 'كلمة المرور ضعيفة جداً';
    } else if (msg.contains('invalid-email')) {
      return 'البريد الإلكتروني غير صحيح';
    } else if (msg.contains('network-request-failed')) {
      return 'خطأ في الاتصال بالإنترنت';
    } else if (msg.contains('sign_in_cancelled') || msg.contains('cancelled')) {
      return 'تم إلغاء تسجيل الدخول';
    } else if (msg.contains('too-many-requests')) {
      return 'محاولات كثيرة، يرجى المحاولة لاحقاً';
    } else if (msg.contains('User not found')) {
      return 'المستخدم غير موجود في قاعدة البيانات';
    }
    return 'حدث خطأ غير متوقع';
  }
}
