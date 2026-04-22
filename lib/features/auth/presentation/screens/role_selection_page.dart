import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../gen/assets.gen.dart';
import '../../data/models/user_model.dart';
import 'login_page.dart';

class RoleSelectionPage extends ConsumerWidget {

  const RoleSelectionPage({super.key});
  static const routeName = '/role-selection';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4F1F4), Color(0xFFB8E6E8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'welcome_tonhmis'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Assets.images.png.appLogo.image(height: 120),
              const Spacer(),
              // Register Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'register_now'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton.primary(
                      text: 'doctor'.tr(),
                      onPressed: () => context.push(
                        LoginPage.routeName,
                        extra: UserRole.doctor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton.primary(
                      text: 'patient'.tr(),
                      onPressed: () => context.push(
                        LoginPage.routeName,
                        extra: UserRole.patient,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
