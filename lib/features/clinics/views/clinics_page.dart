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
  String _localQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(patientHomeProvider);

    return Scaffold(
      appBar: SectionAppBar(title: '${widget.specialty.name} ${LocaleKeys.clinics_suffix.tr()}'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchField(
              controller: _searchController,
              hintText: LocaleKeys.search.tr(),
              onChanged: (query) => setState(() => _localQuery = query),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: asyncState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(LocaleKeys.error_e.tr())),
                data: (state) {
                  var doctors =
                      state.doctorsBySpecialty(widget.specialty.name);
                  if (_localQuery.isNotEmpty) {
                    final q = _localQuery.toLowerCase();
                    doctors = doctors
                        .where((d) => d.name.toLowerCase().contains(q))
                        .toList();
                  }
                  if (doctors.isEmpty) {
                    return  Center(child: Text(LocaleKeys.no_doctors_found.tr()));
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
          ],
        ),
      ),
    );
  }
}
