import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/doctor_card.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/section_app_bar.dart';
import '../../../gen/assets.gen.dart';
import '../../clinics/views/doctor_details_page.dart';
import '../../patient_home/providers/patient_home_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(patientHomeProvider);

    return Scaffold(
      appBar:  SectionAppBar(
        title:'search_for_doctor'.tr(),
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchField(
              controller: _searchController,
              hintText: 'search'.tr(),
              onChanged: (query) {
                ref.read(patientHomeProvider.notifier).updateSearch(query);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: asyncState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('error_e'.tr())),
                data: (state) {
                  final doctors = state.filteredDoctors;
                  if (doctors.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.images.svg.noSearch,
                          height: 200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_results_found'.tr(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
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
          ],
        ),
      ),
    );
  }
}
