import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/helper.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/my_text_filed.dart';
import '../../../generated/locale_keys.g.dart';
import '../../attachments/data/services/supabase_storage_service.dart';
import '../data/models/user_model.dart';
import '../presentation/providers/auth_provider.dart';


class EditProfilePage extends ConsumerStatefulWidget {

  const EditProfilePage({super.key});
  static const routeName = '/edit-profile';

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _specialtyCtrl;
  late final TextEditingController _hospitalCtrl;
  late final TextEditingController _hospitalAddressCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _workHoursStartCtrl;
  late final TextEditingController _workHoursEndCtrl;

  final _selectedImage = ValueNotifier<File?>(null);
  final _isUploadingImage = ValueNotifier<bool>(false);

  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _user = ref.read(authProvider).value?.currentUser;

    _nameCtrl = TextEditingController(text: _user?.name ?? '');
    _phoneCtrl = TextEditingController(text: _user?.phone ?? '');
    _cityCtrl = TextEditingController(text: _user?.city ?? '');
    _ageCtrl = TextEditingController(text: _user?.age?.toString() ?? '');
    _specialtyCtrl = TextEditingController(text: _user?.specialty ?? '');
    _hospitalCtrl = TextEditingController(text: _user?.hospital ?? '');
    _hospitalAddressCtrl =
        TextEditingController(text: _user?.hospitalAddress ?? '');
    _bioCtrl = TextEditingController(text: _user?.bio ?? '');
    _workHoursStartCtrl =
        TextEditingController(text: _user?.workHoursStart ?? '');
    _workHoursEndCtrl = TextEditingController(text: _user?.workHoursEnd ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _ageCtrl.dispose();
    _specialtyCtrl.dispose();
    _hospitalCtrl.dispose();
    _hospitalAddressCtrl.dispose();
    _bioCtrl.dispose();
    _workHoursStartCtrl.dispose();
    _workHoursEndCtrl.dispose();
    _selectedImage.dispose();
    _isUploadingImage.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      _selectedImage.value = File(picked.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    String? newImageUrl = _user!.imageUrl;

    if (_selectedImage.value != null) {
      _isUploadingImage.value = true;
      try {
        newImageUrl = await SupabaseStorageService.instance.uploadImage(
          userId: _user!.id,
          imageFile: _selectedImage.value!,
        );
      } catch (e) {
        if (mounted) GlassySnackbar.showError(context, e.toString());
        _isUploadingImage.value = false;
        return;
      }
      _isUploadingImage.value = false;
    }

    final updated = _user!.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      imageUrl: newImageUrl,
      age: _user!.role == UserRole.patient
          ? int.tryParse(_ageCtrl.text.trim())
          : _user!.age,
      specialty: _user!.role == UserRole.doctor
          ? _specialtyCtrl.text.trim()
          : _user!.specialty,
      hospital: _user!.role == UserRole.doctor
          ? _hospitalCtrl.text.trim()
          : _user!.hospital,
      hospitalAddress: _user!.role == UserRole.doctor
          ? _hospitalAddressCtrl.text.trim()
          : _user!.hospitalAddress,
      bio: _user!.role == UserRole.doctor
          ? _bioCtrl.text.trim()
          : _user!.bio,
      workHoursStart: _user!.role == UserRole.doctor
          ? _workHoursStartCtrl.text.trim()
          : _user!.workHoursStart,
      workHoursEnd: _user!.role == UserRole.doctor
          ? _workHoursEndCtrl.text.trim()
          : _user!.workHoursEnd,
    );

    ref.read(authProvider.notifier).updateProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(authProvider);
    final isLoading = asyncState.value?.isLoading ?? false;

    ref.listen(authProvider, (prev, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
      if (prev?.value?.isLoading == true &&
          next.value?.isLoading == false &&
          next.value?.errorMessage == null) {
        GlassySnackbar.showSuccess(context, LocaleKeys.profile_updated.tr());
      }
    });

    if (_user == null) {
      return Scaffold(
        body: Center(child: Text(LocaleKeys.no_user.tr())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.edit_profile.tr()),
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _AvatarPicker(
                user: _user!,
                selectedImage: _selectedImage,
                isUploading: _isUploadingImage,
                onTap: isLoading ? null : _pickImage,
              )),
              const SizedBox(height: 24),
              MyTextField(
                controller: _nameCtrl,
                labelText: LocaleKeys.full_name.tr(),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? LocaleKeys.required_field.tr()
                        : null,
              ),
              const SizedBox(height: 12),
              MyTextField(
                controller: _phoneCtrl,
                labelText: LocaleKeys.phone.tr(),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              MyTextField(
                controller: _cityCtrl,
                labelText: LocaleKeys.city.tr(),
              ),
              const SizedBox(height: 12),

              if (_user!.role == UserRole.patient) ...[
                MyTextField(
                  controller: _ageCtrl,
                  labelText: LocaleKeys.age.tr(),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
              ],

              if (_user!.role == UserRole.doctor) ...[
                MyTextField(
                  controller: _specialtyCtrl,
                  labelText: LocaleKeys.specialty.tr(),
                ),
                const SizedBox(height: 12),
                MyTextField(
                  controller: _hospitalCtrl,
                  labelText: LocaleKeys.hospital.tr(),
                ),
                const SizedBox(height: 12),
                MyTextField(
                  controller: _hospitalAddressCtrl,
                  labelText: LocaleKeys.hospital_address.tr(),
                ),
                const SizedBox(height: 12),
                MyTextField(
                  controller: _bioCtrl,
                  labelText: LocaleKeys.bio.tr(),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        controller: _workHoursStartCtrl,
                        labelText: LocaleKeys.work_hours_start.tr(),
                        hintText: '09:00 AM',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyTextField(
                        controller: _workHoursEndCtrl,
                        labelText: LocaleKeys.work_hours_end.tr(),
                        hintText: '05:00 PM',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: _isUploadingImage,
                builder: (_, uploading, _) => AppButton(
                  text: LocaleKeys.save_changes.tr(),
                  isLoading: isLoading || uploading,
                  onPressed: (isLoading || uploading) ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.user,
    required this.selectedImage,
    required this.isUploading,
    required this.onTap,
  });

  final UserModel user;
  final ValueNotifier<File?> selectedImage;
  final ValueNotifier<bool> isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ValueListenableBuilder<File?>(
            valueListenable: selectedImage,
            builder: (_, file, _) => CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.tealLight,
              backgroundImage: file != null
                  ? FileImage(file)
                  : (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                      ? NetworkImage(user.imageUrl!) as ImageProvider
                      : null,
              child: (file == null &&
                      (user.imageUrl == null || user.imageUrl!.isEmpty))
                  ? const Icon(Icons.person, size: 48, color: Colors.white)
                  : null,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isUploading,
            builder: (_, uploading, _) => uploading
                ? const SizedBox(
                    width: 104,
                    height: 104,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
