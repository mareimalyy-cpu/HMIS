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
import '../providers/auth_provider.dart';

class DoctorRegisterPage extends ConsumerStatefulWidget {
  static const routeName = '/doctor-register';

  const DoctorRegisterPage({super.key});

  @override
  ConsumerState<DoctorRegisterPage> createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends ConsumerState<DoctorRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _hospitalAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _hospitalController.dispose();
    _hospitalAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authProvider.notifier)
        .registerDoctor(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          specialty: _specialtyController.text.trim(),
          hospital: _hospitalController.text.trim(),
          hospitalAddress: _hospitalAddressController.text.trim(),
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
        context.go('/doctor-home');
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
              spacing: 12,
              children: [
                const SizedBox(height: 30),
                Assets.images.png.appLogo.image(height: 80),
                const SizedBox(height: 16),
                Text(
                  'doctor_registration'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                MyTextField(
                  controller: _nameController,
                  hintText: 'name'.tr(),
                  textInputAction: TextInputAction.next,

                  fillColor: AppColors.cardBackground,
                  validator: (v) => Validators.validateRequired(v, 'name'.tr()),
                ),
                MyTextField(
                  controller: _emailController,
                  hintText: 'email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,

                  fillColor: AppColors.cardBackground,
                  validator: Validators.validateEmail,
                ),
                MyTextField(
                  controller: _phoneController,
                  hintText: 'phone'.tr(),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,

                  fillColor: AppColors.cardBackground,
                  validator: Validators.validatePhone,
                ),
                MyTextField(
                  controller: _specialtyController,
                  hintText: 'specialty'.tr(),
                  textInputAction: TextInputAction.next,

                  fillColor: AppColors.cardBackground,
                  validator: (v) => Validators.validateRequired(v, 'specialty'.tr()),
                ),
                MyTextField(
                  controller: _hospitalController,
                  hintText: 'hospital_name'.tr(),
                  textInputAction: TextInputAction.next,

                  fillColor: AppColors.cardBackground,
                  validator: (v) =>
                      Validators.validateRequired(v, 'hospital_name'.tr()),
                ),
                MyTextField(
                  controller: _hospitalAddressController,
                  hintText: 'hospital_address'.tr(),
                  textInputAction: TextInputAction.next,

                  fillColor: AppColors.cardBackground,
                  validator: (v) =>
                      Validators.validateRequired(v, 'hospital_address'.tr()),
                ),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'create_password'.tr(),
                  obscureText: true,
                  textInputAction: TextInputAction.next,

                  fillColor: AppColors.cardBackground,
                  validator: Validators.validatePassword,
                ),
                MyTextField(
                  controller: _confirmPasswordController,
                  hintText: 'confirm_password'.tr(),
                  obscureText: true,
                  textInputAction: TextInputAction.done,

                  fillColor: AppColors.cardBackground,
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'passwords_do_not_match'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'register'.tr(),
                  isLoading: isLoading,
                  grideantColor: AppColors.teal,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already_have_an_account'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'sign_in'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
