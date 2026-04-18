import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmis/core/services/helper.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/my_text_filed.dart';
import '../../../core/widgets/search_field.dart';
import '../../../gen/assets.gen.dart';
import '../../patient_home/models/specialty_model.dart';
import '../../patient_home/providers/specialties_provider.dart';
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

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecialty == null) {
      GlassySnackbar.showError(context, 'يرجى اختيار التخصص');
      return;
    }
    ref
        .read(authProvider.notifier)
        .registerDoctor(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          specialty: _selectedSpecialty!.id,
          hospital: _hospitalController.text.trim(),
          hospitalAddress: _hospitalAddressController.text.trim(),
        );
  }

  Future<void> _showSpecialtyPicker(List<SpecialtyModel> specialties) async {
    final lang = EasyLocalization.of(context)?.locale.languageCode ?? 'ar';
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpecialtyPickerSheet(
        specialties: specialties,
        languageCode: lang,
        onSelected: (s) {
          setState(() => _selectedSpecialty = s);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final lang = EasyLocalization.of(context)?.locale.languageCode ?? 'ar';

    ref.listen(authProvider, (_, next) {
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
    final specialties = specialtiesAsync.value ?? SpecialtyModel.defaults;

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
                  validator: (v) => Validators.validateRequired(v, 'name'.tr()),
                ),
                MyTextField(
                  controller: _emailController,
                  hintText: 'email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                ),
                MyTextField(
                  controller: _phoneController,
                  hintText: 'phone'.tr(),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePhone,
                ),

                // Specialty picker
                GestureDetector(
                  onTap: specialtiesAsync.isLoading
                      ? null
                      : () => _showSpecialtyPicker(specialties),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 18,
                          color: _selectedSpecialty != null
                              ? AppColors.teal
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedSpecialty == null
                                ? 'specialty'.tr()
                                : _selectedSpecialty!.localizedName(lang),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: _selectedSpecialty != null
                                      ? null
                                      : Colors.grey,
                                ),
                          ),
                        ),
                        if (specialtiesAsync.isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),

                MyTextField(
                  controller: _hospitalController,
                  hintText: 'hospital_name'.tr(),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.validateRequired(v, 'hospital_name'.tr()),
                ),
                MyTextField(
                  controller: _hospitalAddressController,
                  hintText: 'hospital_address'.tr(),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.validateRequired(v, 'hospital_address'.tr()),
                ),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'create_password'.tr(),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePassword,
                ),
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

class _SpecialtyPickerSheet extends StatefulWidget {
  final List<SpecialtyModel> specialties;
  final String languageCode;
  final ValueChanged<SpecialtyModel> onSelected;

  const _SpecialtyPickerSheet({
    required this.specialties,
    required this.languageCode,
    required this.onSelected,
  });

  @override
  State<_SpecialtyPickerSheet> createState() => _SpecialtyPickerSheetState();
}

class _SpecialtyPickerSheetState extends State<_SpecialtyPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.specialties.where((s) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return s.nameAr.toLowerCase().contains(q) ||
          s.nameEn.toLowerCase().contains(q);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'specialty'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.teal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchField(
              controller: _searchController,
              hintText: 'search'.tr(),
              onChanged: (q) => setState(() => _query = q),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final specialty = filtered[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: specialty.color.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: specialty.color,
                      size: 20,
                    ),
                  ),
                  title: Text(specialty.localizedName(widget.languageCode)),
                  subtitle: widget.languageCode == 'ar'
                      ? Text(
                          specialty.nameEn,
                          style: const TextStyle(fontSize: 12),
                        )
                      : Text(
                          specialty.nameAr,
                          style: const TextStyle(fontSize: 12),
                        ),
                  onTap: () => widget.onSelected(specialty),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
