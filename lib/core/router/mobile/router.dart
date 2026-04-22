import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/admin/presentation/screens/admin_patient_detail_page.dart';
import '../../../features/admin/presentation/screens/admin_shell_page.dart';
import '../../../features/auth/data/models/user_model.dart';
import '../../../features/profile/presentation/screens/complete_profile_page.dart';
import '../../../features/auth/presentation/screens/doctor_register_page.dart';
import '../../../features/auth/presentation/screens/login_page.dart';
import '../../../features/auth/presentation/screens/patient_register_page.dart';
import '../../../features/auth/presentation/screens/pending_approval_page.dart';
import '../../../features/auth/presentation/screens/role_selection_page.dart';
import '../../../features/booking/presentation/screens/booking_page.dart';
import '../../../features/booking/presentation/screens/booking_success_page.dart';
import '../../../features/patient/presentation/screens/clinics_page.dart';
import '../../../features/patient/presentation/screens/doctor_details_page.dart';
import '../../../features/medical_records/presentation/screens/medical_records_page.dart';
import '../../../features/onboarding/presentation/screens/onboarding_page.dart';
import '../../../features/patient/data/models/specialty_model.dart';
import '../../../features/patient/presentation/screens/patient_shell_page.dart';
import '../../../features/doctor/presentation/screens/doctor_shell_page.dart';
import '../../../features/profile/presentation/screens/edit_profile_page.dart';
import '../../../features/receptionist/presentation/screens/receptionist_shell_page.dart';
import '../../../features/settings/presentation/screens/settings_page.dart';
import '../../../features/doctor/presentation/screens/time_slots_page.dart';

import '../../enum/constants.dart';
import '../../local_services/local_storage.dart';
import '../app_routing_base.dart';

class MobileRouting extends AppRoutingBase {
  MobileRouting._internal() {
    _router = _buildRouter();
  }
  static final MobileRouting _singleton = MobileRouting._internal();
  static MobileRouting get instance => _singleton;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter _router;

  GoRouter get router => _router;

  @override
  GoRouter getRoutes({List<NavigatorObserver>? observers}) {
    return _router;
  }

  GoRouter _buildRouter() {
    return GoRouter(
      navigatorKey: navigatorKey,
      debugLogDiagnostics: true,
      initialLocation: _getInitialRoute(),
      errorBuilder: (context, state) => const Scaffold(),
      redirect: (context, state) => null,
      routes: [
        // ── Onboarding ──────────────────────────────────────────
        GoRoute(
          path: OnboardingPage.routeName,
          builder: (context, state) => const OnboardingPage(),
        ),

        // ── Auth ────────────────────────────────────────────────
        GoRoute(
          path: RoleSelectionPage.routeName,
          builder: (context, state) => const RoleSelectionPage(),
        ),
        GoRoute(
          path: LoginPage.routeName,
          builder: (context, state) {
            final role = state.extra as UserRole? ?? UserRole.patient;
            return LoginPage(role: role);
          },
        ),
        GoRoute(
          path: CompleteProfilePage.routeName,
          builder: (context, state) => const CompleteProfilePage(),
        ),
        GoRoute(
          path: PatientRegisterPage.routeName,
          builder: (context, state) => const PatientRegisterPage(),
        ),
        GoRoute(
          path: DoctorRegisterPage.routeName,
          builder: (context, state) => const DoctorRegisterPage(),
        ),
        GoRoute(
          path: PendingApprovalPage.routeName,
          builder: (context, state) => const PendingApprovalPage(),
        ),

        // ── Patient ─────────────────────────────────────────────
        GoRoute(
          path: PatientShellPage.routeName,
          builder: (context, state) => const PatientShellPage(),
        ),
        GoRoute(
          path: ClinicsPage.routeName,
          builder: (context, state) {
            final specialty = state.extra as SpecialtyModel?;
            return ClinicsPage(specialty: specialty);
          },
        ),
        GoRoute(
          path: DoctorDetailsPage.routeName,
          builder: (context, state) {
            final doctor = state.extra! as UserModel;
            return DoctorDetailsPage(doctor: doctor);
          },
        ),
        GoRoute(
          path: BookingPage.routeName,
          builder: (context, state) {
            final doctor = state.extra! as UserModel;
            return BookingPage(doctor: doctor);
          },
        ),
        GoRoute(
          path: BookingSuccessPage.routeName,
          builder: (context, state) => const BookingSuccessPage(),
        ),

        // ── Doctor ──────────────────────────────────────────────
        GoRoute(
          path: DoctorShellPage.routeName,
          builder: (context, state) => const DoctorShellPage(),
        ),

        // ── Admin ───────────────────────────────────────────────
        GoRoute(
          path: AdminShellPage.routeName,
          builder: (context, state) => const AdminShellPage(),
        ),
        GoRoute(
          path: '/admin-patient-detail',
          builder: (context, state) {
            final patient = state.extra! as UserModel;
            return AdminPatientDetailPage(patient: patient);
          },
        ),

        // ── Receptionist ─────────────────────────────────────────
        GoRoute(
          path: ReceptionistShellPage.routeName,
          builder: (context, state) => const ReceptionistShellPage(),
        ),

        // ── Shared ──────────────────────────────────────────────
        GoRoute(
          path: '/notifications',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Notifications'))),
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Support'))),
        ),
        GoRoute(
          path: SettingsPage.routeName,
          name: SettingsPage.routeName,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: EditProfilePage.routeName,
          builder: (context, state) => const EditProfilePage(),
        ),

        // ── Doctor sub-pages ────────────────────────────────────
        GoRoute(
          path: TimeSlotsPage.routeName,
          builder: (context, state) => const TimeSlotsPage(),
        ),
        GoRoute(
          path: MedicalRecordsPage.routeName,
          builder: (context, state) {
            final extra = state.extra! as Map<String, String>;
            return MedicalRecordsPage(
              patientId: extra['patientId'] ?? '',
              patientName: extra['patientName'] ?? '',
            );
          },
        ),
      ],
    );
  }

  static String _getInitialRoute() {
    final storage = LocalStorage.instance;

    final hideOnboarding =
        storage.get(Constants.hideOnboarding.name) == true;
    if (!hideOnboarding) return OnboardingPage.routeName;

    final roleStr = storage.get(Constants.userRole.name) as String?;
    if (roleStr != null) {
      switch (UserRole.fromString(roleStr)) {
        case UserRole.patient:
          return PatientShellPage.routeName;
        case UserRole.doctor:
          return DoctorShellPage.routeName;
        case UserRole.admin:
          return AdminShellPage.routeName;
        case UserRole.receptionist:
          return ReceptionistShellPage.routeName;
      }
    }

    return RoleSelectionPage.routeName;
  }
}
