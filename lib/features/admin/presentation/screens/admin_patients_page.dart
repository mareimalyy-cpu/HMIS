import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/helper.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../auth/data/models/user_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_header.dart';

class AdminPatientsPage extends ConsumerStatefulWidget {
  const AdminPatientsPage({super.key});

  @override
  ConsumerState<AdminPatientsPage> createState() => _AdminPatientsPageState();
}

class _AdminPatientsPageState extends ConsumerState<AdminPatientsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(adminProvider);

    ref.listen(adminProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('${LocaleKeys.error_e.tr()}: $e')),
      data: (state) {
        final filtered = _query.isEmpty
            ? state.patients
            : state.patients
                .where((p) =>
                    p.name.contains(_query) ||
                    p.phone.contains(_query) ||
                    p.id.contains(_query))
                .toList();

        return RefreshIndicator(
          onRefresh: () => ref.read(adminProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const AdminHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: SearchField(
                        controller: _searchController,
                        hintText: LocaleKeys.search_patient_hint.tr(),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _PatientCard(patient: filtered[index]),
                    childCount: filtered.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _TotalCard(
                    label: LocaleKeys.total_patients.tr(),
                    count: state.patientCount,
                    icon: Icons.people_alt_rounded,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        );
      },
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});
  final UserModel patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppButton.primary(
            text: LocaleKeys.view.tr(),
            onPressed: () =>
                context.push('/admin-patient-detail', extra: patient),
            icon: Icons.remove_red_eye,
            height: 40,
            width: 90,
            fontSize: 13,
            borderRadius: 10,
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                patient.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(patient.id.isNotEmpty
                      ? patient.id.substring(0, 6).toUpperCase()
                      : '---'),
                  const SizedBox(width: 6),
                  Text(
                    'ID',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(patient.phone),
                  const SizedBox(width: 6),
                  Icon(Icons.phone_in_talk,
                      size: 16, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.cardBackground,
            backgroundImage: patient.imageUrl != null
                ? NetworkImage(patient.imageUrl!)
                : null,
            child: patient.imageUrl == null
                ? const Icon(Icons.person, size: 28, color: Colors.grey)
                : null,
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {

  const _TotalCard({
    required this.label,
    required this.count,
    required this.icon,
  });
  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 48, color: AppColors.teal),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
