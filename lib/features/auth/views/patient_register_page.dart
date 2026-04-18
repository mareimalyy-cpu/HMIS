import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmis/core/services/helper.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/my_text_filed.dart';
import '../../../gen/assets.gen.dart';
import '../providers/auth_provider.dart';

class PatientRegisterPage extends ConsumerStatefulWidget {
  static const routeName = '/patient-register';

  const PatientRegisterPage({super.key});

  @override
  ConsumerState<PatientRegisterPage> createState() =>
      _PatientRegisterPageState();
}

class _PatientRegisterPageState extends ConsumerState<PatientRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int get _age {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month ||
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      GlassySnackbar.showError(context, 'يرجى اختيار تاريخ الميلاد');
      return;
    }
    ref
        .read(authProvider.notifier)
        .registerPatient(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          city: _cityController.text.trim(),
          age: _age,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      final state = next.value;
      if (state == null) return;
      if (state.errorMessage != null) {
        GlassySnackbar.showError(context, state.errorMessage!);
      }
      if (state.isAuthenticated && state.currentUser != null) {
        context.go('/patient-home');
      }
    });

    final isLoading = authState.value?.isLoading ?? false;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Assets.images.png.appLogo.image(height: 80),
                const SizedBox(height: 16),
                Text(
                  'patient_registration'.tr(),
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
                  validator: (v) => Validators.validateRequired(v, 'name'.tr()),
                ),
                const SizedBox(height: 12),
                MyTextField(
                  controller: _emailController,
                  hintText: 'email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,

                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 12),
                MyTextField(
                  controller: _cityController,
                  hintText: 'city'.tr(),
                  textInputAction: TextInputAction.next,

                  validator: (v) => Validators.validateRequired(v, 'city'.tr()),
                ),
                const SizedBox(height: 12),
                MyTextField(
                  controller: _phoneController,
                  hintText: 'phone'.tr(),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,

                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 12),

                // Date of Birth picker
                GestureDetector(
                  onTap: _pickDate,
                  child: MyTextField(
                    readOnly: true,
                    onTap: _pickDate,
                    hintText: _age.toString(),
                  ),
                ),

                const SizedBox(height: 12),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'create_password'.tr(),
                  obscureText: true,
                  textInputAction: TextInputAction.next,

                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 12),
                MyTextField(
                  controller: _confirmPasswordController,
                  hintText: 'confirm_password'.tr(),
                  obscureText: true,
                  textInputAction: TextInputAction.done,

                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'passwords_do_not_match'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  text: 'register'.tr(),
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already_have_an_account'.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    AppButton.text(
                      text: 'sign_in'.tr(),
                      onPressed: () => context.pop(),
                      height: 36,
                      textColor: AppColors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
