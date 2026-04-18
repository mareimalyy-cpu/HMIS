import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../patient_home/models/specialty_model.dart';
import '../../../patient_home/providers/specialties_provider.dart';

class Specialty extends ConsumerStatefulWidget {
  final SpecialtyModel? value;
  final ValueChanged<SpecialtyModel> onSelected;
  final String? Function(SpecialtyModel?)? validator;

  const Specialty({
    super.key,
    required this.onSelected,
    this.value,
    this.validator,
  });

  @override
  ConsumerState<Specialty> createState() => _SpecialtyState();
}

class _SpecialtyState extends ConsumerState<Specialty> {
  final _fieldKey = GlobalKey<FormFieldState<SpecialtyModel>>();

  Future<void> _showPicker(
    List<SpecialtyModel> specialties,
    String lang,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpecialtyPickerSheet(
        specialties: specialties,
        languageCode: lang,
        onSelected: (s) {
          widget.onSelected(s);
          _fieldKey.currentState?.didChange(s);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final specialties = specialtiesAsync.value ?? SpecialtyModel.defaults;
    final lang = EasyLocalization.of(context)?.locale.languageCode ?? 'ar';

    return FormField<SpecialtyModel>(
      key: _fieldKey,
      initialValue: widget.value,
      validator: widget.validator,
      builder: (field) {
        final hasError = field.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: specialtiesAsync.isLoading
                  ? null
                  : () => _showPicker(specialties, lang),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: hasError ? AppColors.danger : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 18,
                      color: widget.value != null
                          ? AppColors.teal
                          : (hasError ? AppColors.danger : Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.value == null
                            ? 'specialty'.tr()
                            : widget.value!.localizedName(lang),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.value != null
                              ? null
                              : (hasError ? AppColors.danger : Colors.grey),
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
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 12, left: 12),
                child: Text(
                  field.errorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
          ],
        );
      },
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
