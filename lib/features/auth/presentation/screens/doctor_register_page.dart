import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/my_text_filed.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../patient/data/models/specialty_model.dart';
import '../providers/auth_provider.dart';
import 'email_verification_page.dart';
import '../widgets/specialty.dart';

class DoctorRegisterPage extends ConsumerStatefulWidget {

  const DoctorRegisterPage({super.key});
  static const routeName = '/doctor-register';

  @override
  ConsumerState<DoctorRegisterPage> createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends ConsumerState<DoctorRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _hospitalAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  SpecialtyModel? _selectedSpecialty;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _hospitalController.dispose();
    _hospitalAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPending = false;

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    _isPending = true;
    ref
        .read(authProvider.notifier)
        .registerDoctor(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          specialty: _selectedSpecialty?.nameEn ??'',
          hospital: _hospitalController.text.trim(),
          hospitalAddress: _hospitalAddressController.text.trim(),
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
      if (state.isPendingApproval && state.currentUser != null) {
        _isPending = false;
        context.go('/pending-approval');
        return;
      }
      if (state.isAuthenticated && state.currentUser != null) {
        _isPending = false;
        context.go('/doctor-home');
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
              spacing: 12,
              children: [
                const SizedBox(height: 30),
                Assets.images.png.appLogo.image(height: 80),
                const SizedBox(height: 16),
                Text(
                  LocaleKeys.doctor_registration.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                MyTextField(
                  controller: _nameController,
                  hintText: LocaleKeys.name.tr(),
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.validateRequired(v, LocaleKeys.name.tr()),
                ),
                MyTextField(
                  controller: _emailController,
                  hintText: LocaleKeys.email.tr(),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                ),
                MyTextField(
                  controller: _phoneController,
                  hintText: LocaleKeys.phone.tr(),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePhone,
                ),

                // Specialty picker
                Specialty(
                  value: _selectedSpecialty,
                  onSelected: (s) => setState(() => _selectedSpecialty = s),
                  validator: (v) => v == null ? LocaleKeys.select_specialty.tr() : null,
                ),

                MyTextField(
                  controller: _hospitalController,
                  hintText: LocaleKeys.hospital_name.tr(),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.validateRequired(v, LocaleKeys.hospital_name.tr()),
                ),
                MyTextField(
                  controller: _hospitalAddressController,
                  hintText: LocaleKeys.hospital_address.tr(),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.validateRequired(v, LocaleKeys.hospital_address.tr()),
                ),
                MyTextField(
                  controller: _passwordController,
                  hintText: LocaleKeys.create_password.tr(),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePassword,
                ),
                MyTextField(
                  controller: _confirmPasswordController,
                  hintText: LocaleKeys.confirm_password.tr(),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return LocaleKeys.passwords_do_not_match.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  text: LocaleKeys.register.tr(),
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.already_have_an_account.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    AppButton.text(
                      text: LocaleKeys.sign_in.tr(),
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
