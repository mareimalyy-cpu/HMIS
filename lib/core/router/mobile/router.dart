import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/models/user_model.dart';
import '../../../features/auth/views/doctor_register_page.dart';
import '../../../features/auth/views/login_page.dart';
import '../../../features/auth/views/patient_register_page.dart';
import '../../../features/auth/views/role_selection_page.dart';
import '../../../features/booking/views/booking_page.dart';
import '../../../features/booking/views/booking_success_page.dart';
import '../../../features/clinics/views/clinics_page.dart';
import '../../../features/clinics/views/doctor_details_page.dart';
import '../../../features/onboarding/views/onboarding_page.dart';
import '../../../features/patient_home/models/specialty_model.dart';
import '../../../features/patient_home/views/patient_shell_page.dart';
import '../../../features/doctor_home/views/doctor_shell_page.dart';
import '../../../features/settings/views/settings_page.dart';
import '../../enum/constants.dart';
import '../../local_services/local_storage.dart';
import '../app_routing_base.dart';

class MobileRouting extends AppRoutingBase {
  static final MobileRouting _singleton = MobileRouting._internal();
  MobileRouting._internal() {
    _router = _buildRouter();
  }
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
      redirect: (context, state) {
        return null;
      },
      routes: [
        // Onboarding Route
        GoRoute(
          path: OnboardingPage.routeName,
          builder: (context, state) => const OnboardingPage(),
        ),

        // Auth Routes
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
          path: PatientRegisterPage.routeName,
          builder: (context, state) => const PatientRegisterPage(),
        ),
        GoRoute(
          path: DoctorRegisterPage.routeName,
          builder: (context, state) => const DoctorRegisterPage(),
        ),

        // Patient Routes
        GoRoute(
          path: PatientShellPage.routeName,
          builder: (context, state) => const PatientShellPage(),
        ),
        GoRoute(
          path: ClinicsPage.routeName,
          builder: (context, state) {
            final specialty = state.extra as SpecialtyModel;
            return ClinicsPage(specialty: specialty);
          },
        ),
        GoRoute(
          path: DoctorDetailsPage.routeName,
          builder: (context, state) {
            final doctor = state.extra as UserModel;
            return DoctorDetailsPage(doctor: doctor);
          },
        ),
        GoRoute(
          path: BookingPage.routeName,
          builder: (context, state) {
            final doctor = state.extra as UserModel;
            return BookingPage(doctor: doctor);
          },
        ),
        GoRoute(
          path: BookingSuccessPage.routeName,
          builder: (context, state) => const BookingSuccessPage(),
        ),

        // Doctor Routes
        GoRoute(
          path: DoctorShellPage.routeName,
          builder: (context, state) => const DoctorShellPage(),
        ),

        // Placeholder - Support & Notifications
        GoRoute(
          path: '/notifications',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Notifications'))),
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Supporrt'))),
        ),
        GoRoute(
          path: SettingsPage.routeName,
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );
  }

  static String _getInitialRoute() {
    final hideOnboarding =
        LocalStorage.instance.get(Constants.hideOnboarding.name) == true;
    if (!hideOnboarding) return OnboardingPage.routeName;
    return RoleSelectionPage.routeName;
  }
}
