import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmis/core/helper/help_functions.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/constants.dart';
import 'core/extension/theme_mode.dart';
import 'core/local_services/local_storage.dart';
import 'core/notifications/notification_initializer.dart';
import 'core/router/index.dart';
import 'core/services/life_cycle_manager.dart';
import 'core/services/scroll_behavior.dart';
import 'core/themes/style.dart';
import 'features/settings/providers/settings_provider.dart';
import 'firebase_options.dart';
import 'generated/codegen_loader.g.dart';

Future<void> firstInit() async {
  try {
    await LocalStorage.instance.init();
  } catch (e) {
    log('error_when_init_localstorage_e'.tr());
  }
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('firebase_initialized_successfully'.tr());
    }
  } catch (e) {
    debugPrint('firebase_initialization_etostring'.tr());
  }
  try {
    await GoogleSignIn.instance.initialize(
      serverClientId:
          '594079591247-un7h4qctt5qgc8vj5eg3o8ehp5cfam4j.apps.googleusercontent.com',
    );
  } catch (e) {
    log('Google Sign-In init error: $e');
  }
  // try {
  //   await PatientHomeRemoteService().seedSpecialties();
  // } catch (e) {
  //   log('Seed specialties error: $e');
  // }
  try {
    await NotificationInitializer.instance.init();
  } catch (e) {
    log('error_when_init_localnotificationsservice_e'.tr());
  }
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await firstInit();
      runApp(
        ProviderScope(
          child: EasyLocalization(
            supportedLocales: supportedLocales,
            path: translationsPath,
            fallbackLocale: Locale(getLanguageCodeHelper()),
            startLocale: Locale(getLanguageCodeHelper()),
            assetLoader: const CodegenLoader(),
            child: const MyApp(),
          ),
        ),
      );
    },
    (error, stackTrace) {
      log('error_error'.tr());
      log('stack_trace_stacktrace'.tr());
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch settings for theme/font reactivity
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = settingsAsync.value?.mode ?? Thememode.system;
    final fontFamily = settingsAsync.value?.fontFamily.displayName ?? '';
    final fontSize = settingsAsync.value?.fontSize;
    return GestureDetector(
      onTap: unfocusCurrent,
      child: ResponsiveBreakpoints(
        breakpoints: [
          Breakpoint(start: 0, end: 600, name: MOBILE),
          Breakpoint(start: 601, end: 1200, name: TABLET),
          Breakpoint(start: 1201, end: double.infinity, name: DESKTOP),
        ],
        child: LifeCycleManager(
          child: MaterialApp.router(
            scaffoldMessengerKey: scaffoldMessengerKey,
            scrollBehavior: CustomScrollBehavior(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            themeMode: Thememode.fromThememode(themeMode),
            theme: AppTheme.lightTheme(fontFamily: fontFamily),
            darkTheme: AppTheme.darkTheme(fontFamily: fontFamily),
            routerConfig: Routes.instance.getRoutes(),
            builder: (context, child) {
              return ResponsiveScaledBox(
                width: ResponsiveValue<double?>(
                  context,
                  conditionalValues: [
                    const Condition.equals(name: MOBILE, value: 450),
                    const Condition.between(start: 451, end: 800, value: 800),
                  ],
                ).value,
                child: Builder(
                  builder: (innerContext) {
                    final mediaQueryData = MediaQuery.of(innerContext);
                    return MediaQuery(
                      data: mediaQueryData.copyWith(
                        textScaler: TextScaler.linear(fontSize?.size ?? 1),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(innerContext).colorScheme.surface,
                        ),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
