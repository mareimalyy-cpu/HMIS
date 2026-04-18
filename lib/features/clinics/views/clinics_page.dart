import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/doctor_card.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/section_app_bar.dart';
import '../../../generated/locale_keys.g.dart';
import '../../patient_home/models/specialty_model.dart';
import '../../patient_home/providers/patient_home_provider.dart';
import 'doctor_details_page.dart';

class ClinicsPage extends ConsumerStatefulWidget {
  static const routeName = '/clinics';

  final SpecialtyModel specialty;

  const ClinicsPage({super.key, required this.specialty});

  @override
  ConsumerState<ClinicsPage> createState() => _ClinicsPageState();
}

class _ClinicsPageState extends ConsumerState<ClinicsPage> {
  final _searchController = TextEditingController();
  final _query = ValueNotifier<String>('');

  @override
  void dispose() {
    _searchController.dispose();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(patientHomeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode =
        EasyLocalization.of(context)?.locale.languageCode ?? 'ar';

    return Scaffold(
      appBar: SectionAppBar(
        title:
            '${widget.specialty.localizedName(langCode)} ${LocaleKeys.clinics_suffix.tr()}',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchField(
              controller: _searchController,
              hintText: LocaleKeys.search.tr(),
              onChanged: (query) => _query.value = query,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: asyncState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text(LocaleKeys.error_e.tr())),
                data: (state) => ValueListenableBuilder<String>(
                  valueListenable: _query,
                  builder: (context, query, _) {
                    var doctors =
                        state.doctorsBySpecialty(widget.specialty.id);
                    if (query.isNotEmpty) {
                      final q = query.toLowerCase();
                      doctors = doctors
                          .where((d) => d.name.toLowerCase().contains(q))
                          .toList();
                    }
                    if (doctors.isEmpty) {
                      return Center(
                        child: Text(
                          LocaleKeys.no_doctors_found.tr(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];
                        return DoctorCard(
                          doctor: doctor,
                          onTap: () => context.push(
                            DoctorDetailsPage.routeName,
                            extra: doctor,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
