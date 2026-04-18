import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmis/core/services/helper.dart';
import 'package:hmis/generated/locale_keys.g.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/my_text_filed.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
  static const routeName = '/complete-profile';

  final UserModel user;
  const CompleteProfilePage({super.key, required this.user});

  @override
  ConsumerState<CompleteProfilePage> createState() =>
      _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _cityCtrl = TextEditingController(text: widget.user.city);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
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
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      GlassySnackbar.showError(context, 'يرجى اختيار تاريخ الميلاد');
      return;
    }
    ref
        .read(authProvider.notifier)
        .completeGoogleProfile(
          phone: _phoneCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          age: _age,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).value?.isLoading ?? false;

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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Avatar from Google
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.cardBackground,
                  backgroundImage: widget.user.imageUrl != null
                      ? NetworkImage(widget.user.imageUrl!)
                      : null,
                  child: widget.user.imageUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.user.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),

                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'أكمل بياناتك',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'نحتاج بعض المعلومات لإكمال حسابك',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 24),
                MyTextField(
                  controller: _phoneCtrl,
                  hintText: 'phone'.tr(),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,

                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 12),
                MyTextField(
                  controller: _cityCtrl,
                  hintText: 'city'.tr(),
                  textInputAction: TextInputAction.done,

                  validator: (v) => Validators.validateRequired(v, 'city'.tr()),
                ),
                const SizedBox(height: 12),

                // Date of Birth picker
                MyTextField(
                  readOnly: true,
                  onTap: _pickDate,
                  hintText: _age == 0 ? LocaleKeys.age.tr() : _age.toString(),
                ),

                const SizedBox(height: 32),
                AppButton.primary(
                  text: 'حفظ البيانات',
                  onPressed: isLoading ? null : _save,
                  isLoading: isLoading,
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
