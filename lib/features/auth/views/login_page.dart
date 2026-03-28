import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmis/core/services/helper.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/my_text_filed.dart';
import '../../../gen/assets.gen.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import 'patient_register_page.dart';
import 'doctor_register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const routeName = '/login';

  final UserRole role;
  const LoginPage({super.key, required this.role});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (prev, next) {
      final state = next.value;
      if (state == null) return;

      if (state.errorMessage != null) {
        GlassySnackbar.showError(context, state.errorMessage!);
      }

      if (state.isAuthenticated && state.currentUser != null) {
        // Navigate to home based on role
        if (state.currentUser!.role == UserRole.doctor) {
          context.go('/doctor-home');
        } else {
          context.go('/patient-home');
        }
      }
    });

    final isLoading = authState.value?.isLoading ?? false;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Assets.images.png.appLogo.image(height: 100),
                const SizedBox(height: 40),
                Text(
                  'sign_in'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                MyTextField(
                  controller: _emailController,
                  hintText: 'email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  fillColor: AppColors.cardBackground,
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'password'.tr(),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validatePassword,
                  fillColor: AppColors.cardBackground,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password
                    },
                    child: Text(
                      'forgot_password'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'sign_in'.tr(),
                  isLoading: isLoading,
                  grideantColor: AppColors.teal,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'dont_have_an_account'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.role == UserRole.patient) {
                          context.push(PatientRegisterPage.routeName);
                        } else {
                          context.push(DoctorRegisterPage.routeName);
                        }
                      },
                      child: Text(
                        'register_now'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
