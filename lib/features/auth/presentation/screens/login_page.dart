import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/services/helper.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dialog.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../../core/widgets/my_text_filed.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../../profile/presentation/screens/complete_profile_page.dart';
import 'doctor_register_page.dart';
import 'email_verification_page.dart';
import 'patient_register_page.dart';
import 'pending_approval_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({required this.role, super.key});
  static const routeName = '/login';

  final UserRole role;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  bool _isPending = false;

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    _isPending = true;
    ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    AppDialog.show(
      context: context,
      title: LocaleKeys.forgot_password.tr(),
      icon: Icons.lock_reset_rounded,
      contentWidget: MyTextField(
        controller: emailCtrl,
        hintText: LocaleKeys.email.tr(),
        keyboardType: TextInputType.emailAddress,
      ),
      actions: [
        AppDialogAction(
          label: LocaleKeys.cancelButton.tr(),
          type: AppButtonType.outlined,
          onPressed: () => Navigator.pop(context),
        ),
        AppDialogAction(
          label: LocaleKeys.send.tr(),
          onPressed: () {
            Navigator.pop(context);
            ref
                .read(authProvider.notifier)
                .resetPassword(emailCtrl.text.trim());
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (!_isPending) return;
      final state = next.value;
      if (state == null) return;

      if (state.errorMessage != null) {
        _isPending = false;
        GlassySnackbar.showError(context, state.errorMessage!);
        return;
      }

      if (state.needsEmailVerification) {
        _isPending = false;
        context.push(
          EmailVerificationPage.routeName,
          extra: {
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          },
        );
        return;
      }

      if (state.needsProfileCompletion && state.currentUser != null) {
        _isPending = false;
        context.push(CompleteProfilePage.routeName);
        return;
      }

      if (state.isPendingApproval && state.currentUser != null) {
        _isPending = false;
        context.go(PendingApprovalPage.routeName);
        return;
      }

      if (state.isAuthenticated && state.currentUser != null) {
        _isPending = false;
        final role = state.currentUser!.role;
        switch (role) {
          case UserRole.doctor:
            context.go('/doctor-home');
          case UserRole.admin:
            context.go('/admin-home');
          case UserRole.receptionist:
            context.go('/receptionist-home');
          case UserRole.patient:
            context.go('/patient-home');
        }
      }
    });

    final isLoading = authState.value?.isLoading ?? false;

    return AppLoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
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
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscurePassword,
                    builder: (_, obscure, _) => MyTextField(
                      controller: _passwordController,
                      hintText: 'password'.tr(),
                      obscureText: obscure,
                      textInputAction: TextInputAction.done,
                      validator: Validators.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () =>
                            _obscurePassword.value = !_obscurePassword.value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton.text(
                      text: LocaleKeys.forgot_password.tr(),
                      onPressed: _showForgotPasswordDialog,
                      height: 36,
                      textColor: AppColors.teal,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton.primary(
                    text: 'sign_in'.tr(),
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _handleLogin,
                  ),

                  // Google sign-in — only for non-admin roles
                  if (widget.role != UserRole.admin) ...[
                    const SizedBox(height: 12),
                    _OrDivider(),
                    const SizedBox(height: 12),
                    AppButton.outlined(
                      text: LocaleKeys.sign_in_with_google.tr(),
                      onPressed: isLoading
                          ? null
                          : () {
                              _isPending = true;
                              ref
                                  .read(authProvider.notifier)
                                  .loginWithGoogle(role: widget.role);
                            },
                      icon: Icons.g_mobiledata_rounded,
                      fontSize: 14,
                    ),
                  ],

                  // Register link — only for non-admin roles
                  if (widget.role != UserRole.admin) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'dont_have_an_account'.tr(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        AppButton.text(
                          text: 'register_now'.tr(),
                          onPressed: () {
                            if (widget.role == UserRole.patient) {
                              context.push(PatientRegisterPage.routeName);
                            } else {
                              context.push(DoctorRegisterPage.routeName);
                            }
                          },
                          height: 36,
                          textColor: AppColors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            LocaleKeys.or.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
