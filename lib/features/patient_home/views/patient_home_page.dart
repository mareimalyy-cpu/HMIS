import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/specialty_card.dart';
import '../../../gen/assets.gen.dart';
import '../../clinics/views/clinics_page.dart';
import '../providers/patient_home_provider.dart';

class PatientHomePage extends ConsumerWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(patientHomeProvider);

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('error_e'.tr())),
      data: (state) => RefreshIndicator(
        onRefresh: () => ref.read(patientHomeProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Notification bell
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                      const Spacer(),
                      // Logo
                      Assets.images.png.appLogo.image(height: 50),
                      const Spacer(),
                      // Support call
                      IconButton(
                        onPressed: () => context.push('/support'),
                        icon: const Icon(Icons.phone_outlined),
                        color: AppColors.teal,
                      ),
                    ],
                  ),
                ),
              ),

              // Greeting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  state.greeting,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'book_now'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),

              const SizedBox(height: 12),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchField(
                  hintText: 'search_for_doctor'.tr(),
                  onTap: () {
                    // Switch to search tab via parent shell
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Specialties Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'specialties'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: 12),

              // Specialties Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: state.specialties.length,
                  itemBuilder: (context, index) {
                    final specialty = state.specialties[index];
                    return SpecialtyCard(
                      specialty: specialty,
                      onTap: () => context.push(
                        ClinicsPage.routeName,
                        extra: specialty,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
