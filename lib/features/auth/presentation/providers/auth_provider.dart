import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/local_services/local_storage.dart';
import '../../../../core/notifications/remote_notifications_service.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/data/services/notification_firestore_service.dart';
import '../../data/models/auth_states.dart';
import '../../data/models/user_model.dart';
import '../../data/services/local/auth_local_service.dart';
import '../../data/services/remote/auth_remote_service.dart';

part 'generated/auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthRemoteService _remoteService;
  late final AuthLocalService _localService;
  late final NotificationFirestoreService _notifService;

  @override
  Future<AuthStates> build() async {
    _remoteService = AuthRemoteService();
    _localService = AuthLocalService(LocalStorage.instance);
    _notifService = NotificationFirestoreService();
    try {
      final local = _loadFromLocal();
      if (local != null) {
        // Always re-verify doctor approval status from Firestore in background
        if (local.currentUser?.role == UserRole.doctor) {
          unawaited(_refreshDoctorStatus());
        }
        return local;
      }
      return AuthStates.initial();
    } catch (e) {
      return AuthStates(errorMessage: e.toString());
    }
  }

  AuthStates? _loadFromLocal() {
    final cachedUser = _localService.getUser();
    if (cachedUser == null) return null;
    // For doctors, use cached approval status — Firestore refresh happens in background
    final isAuthenticated =
        cachedUser.role != UserRole.doctor || cachedUser.isApprovedDoctor;
    return AuthStates(
      currentUser: cachedUser,
      isAuthenticated: isAuthenticated,
      selectedRole: cachedUser.role,
    );
  }

  Future<void> verifyDoctorApproval() => _refreshDoctorStatus();

  Future<void> _refreshDoctorStatus() async {
    try {
      final user = await _remoteService.getCurrentUser();
      if (user == null) return;
      unawaited(_localService.saveUser(user));
      final isApproved = user.isApprovedDoctor;
      state = AsyncData(AuthStates(
        currentUser: user,
        isAuthenticated: isApproved,
        selectedRole: user.role,
      ));
    } catch (e) {
      log('Doctor status refresh failed: $e');
    }
  }

  void selectRole(UserRole role) {
    state = AsyncData(
      state.value!.copyWith(selectedRole: role, clearError: true),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final user = await _remoteService.login(email: email, password: password);
      unawaited(_localService.saveUser(user));
      unawaited(FirebaseMessagingService.instance.saveTokenForUser(user.id));
      // Doctors pending approval cannot access the app
      final isApproved = user.role != UserRole.doctor || user.isApprovedDoctor;
      state = AsyncData(
        AuthStates(
          currentUser: user,
          isAuthenticated: isApproved,
          selectedRole: user.role,
        ),
      );
    } on EmailNotVerifiedException {
      state = AsyncData(
        state.value!.copyWith(isLoading: false, needsEmailVerification: true),
      );
    } catch (e) {
      log('Login error: $e');
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: _mapFirebaseError(e),
        ),
      );
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _remoteService.sendEmailVerification();
    } catch (e) {
      log('Send verification error: $e');
    }
  }

  Future<void> checkEmailVerified({
    required String email,
    required String password,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.reloadUser();
      if (_remoteService.isEmailVerified) {
        // Re-run full login now that email is verified
        await login(email: email, password: password);
      } else {
        state = AsyncData(
          state.value!.copyWith(
            isLoading: false,
            errorMessage: 'البريد الإلكتروني لم يتم التحقق منه بعد',
          ),
        );
      }
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: _mapFirebaseError(e),
        ),
      );
    }
  }

  Future<void> loginWithGoogle({UserRole role = UserRole.patient}) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final user = await _remoteService.loginWithGoogle(role: role);
      final isIncomplete = user.phone.isEmpty || user.city.isEmpty;
      if (isIncomplete) {
        state = AsyncData(
          AuthStates(
            currentUser: user,
            isAuthenticated: false,
            needsProfileCompletion: true,
            selectedRole: user.role,
          ),
        );
      } else {
        unawaited(_localService.saveUser(user));
        final isApproved =
            user.role != UserRole.doctor || user.isApprovedDoctor;
        state = AsyncData(
          AuthStates(
            currentUser: user,
            isAuthenticated: isApproved,
            selectedRole: user.role,
          ),
        );
      }
    } catch (e) {
      log('Google login error: $e');
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: _mapFirebaseError(e),
        ),
      );
    }
  }

  Future<void> completeGoogleProfile({
    required String phone,
    required String city,
    required int age,
    String? specialty,
  }) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      final updated = state.value!.currentUser!.copyWith(
        phone: phone,
        city: city,
        age: age,
        specialty: specialty,
      );
      await _remoteService.updateUser(updated);
      unawaited(_localService.saveUser(updated));
      // Doctors completing their Google profile still need admin approval
      if (updated.role == UserRole.doctor) {
        unawaited(
          _notifyAdminsNewDoctor(
            doctorName: updated.name,
            doctorId: updated.id,
          ),
        );
        state = AsyncData(
          AuthStates(
            currentUser: updated,
            isAuthenticated: false,
            selectedRole: updated.role,
          ),
        );
      } else {
        state = AsyncData(
          AuthStates(
            currentUser: updated,
            isAuthenticated: true,
            selectedRole: updated.role,
          ),
        );
      }
    } catch (e) {
      log('Complete profile error: $e');
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: _mapFirebaseError(e),
        ),
      );
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
      unawaited(_remoteService.sendEmailVerification());
      state = AsyncData(
        AuthStates(
          currentUser: user,
          isAuthenticated: false,
          needsEmailVerification: true,
          selectedRole: UserRole.patient,
        ),
      );
    } catch (e) {
      log('Register patient error: $e');
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: _mapFirebaseError(e),
        ),
      );
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
      // Doctor stays unauthenticated until admin approves; verify email too
      unawaited(_localService.saveUser(user));
      unawaited(_remoteService.sendEmailVerification());
      unawaited(_notifyAdminsNewDoctor(doctorName: name, doctorId: user.id));
      state = AsyncData(
        AuthStates(
          currentUser: user,
          isAuthenticated: false,
          needsEmailVerification: true,
          selectedRole: UserRole.doctor,
        ),
      );
    } catch (e) {
      log('Register doctor error: $e');
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: _mapFirebaseError(e),
        ),
      );
    }
  }

  Future<void> _notifyAdminsNewDoctor({
    required String doctorName,
    required String doctorId,
  }) async {
    try {
      final adminIds = await _remoteService.getAdminIds();
      if (adminIds.isEmpty) return;
      await _notifService.broadcast(
        userIds: adminIds,
        title: 'طلب تفعيل طبيب جديد',
        body: 'د. $doctorName طلب الانضمام وينتظر موافقتك',
        type: NotificationType.approval,
        priority: NotificationPriority.high,
        route: '/admin-home',
        payload: {'doctorId': doctorId, 'tab': '2'},
      );
    } catch (e) {
      log('Failed to notify admins of new doctor: $e');
    }
  }

  Future<void> updateProfile(UserModel updated) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.updateUser(updated);
      unawaited(_localService.saveUser(updated));
      state = AsyncData(
        state.value!.copyWith(currentUser: updated, isLoading: false),
      );
    } catch (e) {
      log('Update profile error: $e');
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: 'فشل تحديث البيانات',
        ),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    state = AsyncData(state.value!.copyWith(isLoading: true, clearError: true));
    try {
      await _remoteService.resetPassword(email);
      state = AsyncData(state.value!.copyWith(isLoading: false));
    } catch (e) {
      log('Reset password error: $e');
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: _mapFirebaseError(e),
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      final userId = state.value?.currentUser?.id;
      if (userId != null) {
        unawaited(FirebaseMessagingService.instance.deleteTokenForUser(userId));
      }
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
