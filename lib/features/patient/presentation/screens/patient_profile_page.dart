import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/screens/edit_profile_page.dart';
import '../../../medical_records/data/models/medical_record_model.dart';
import '../../../medical_records/presentation/providers/medical_record_provider.dart';

class PatientProfilePage extends ConsumerStatefulWidget {
  const PatientProfilePage({super.key});

  @override
  ConsumerState<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends ConsumerState<PatientProfilePage> {
  bool _recordsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  void _loadRecords() {
    if (_recordsLoaded) return;
    _recordsLoaded = true;
    final patientId = ref.read(authProvider).value?.currentUser?.id ?? '';
    if (patientId.isNotEmpty) {
      ref.read(medicalRecordProvider.notifier).loadRecordsForPatient(patientId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final recordsState = ref.watch(medicalRecordProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: SectionAppBar(
        title: LocaleKeys.my_account.tr(),
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(
              Icons.settings_rounded,
              color: isDark ? Colors.white70 : AppColors.white,
            ),
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(LocaleKeys.error_e.tr())),
        data: (state) {
          final user = state.currentUser;
          if (user == null) {
            return Center(child: Text(LocaleKeys.not_logged_in.tr()));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero header ────────────────────────────────────────────
                _ProfileHeader(user: user, isDark: isDark),

                const SizedBox(height: 20),

                // ── Edit profile ───────────────────────────────────────────
                AppButton.outlined(
                  text: LocaleKeys.edit_profile.tr(),
                  icon: Icons.edit_rounded,
                  height: 46,
                  onPressed: () => context.push(EditProfilePage.routeName),
                ),

                const SizedBox(height: 24),

                // ── Contact info ───────────────────────────────────────────
                _SectionLabel(LocaleKeys.contact_info.tr()),
                const SizedBox(height: 8),
                _InfoCard(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.mail_rounded,
                        text: user.email,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.phone_rounded,
                        text: user.phone,
                      ),
                      if (user.city.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.location_city_rounded,
                          text: user.city,
                        ),
                      ],
                      if (user.age != null) ...[
                        const SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.cake_rounded,
                          text: '${user.age} ${LocaleKeys.age.tr().replaceAll(':', '')}',
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Medical records ────────────────────────────────────────
                _SectionLabel(LocaleKeys.my_medical_records.tr()),
                const SizedBox(height: 8),

                recordsState.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Center(
                    child: Text(LocaleKeys.error_e.tr(),
                        style: const TextStyle(color: Colors.grey)),
                  ),
                  data: (records) => records.records.isEmpty
                      ? _InfoCard(
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.folder_open_rounded,
                                    size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 8),
                                Text(
                                  LocaleKeys.no_medical_records.tr(),
                                  style:
                                      const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: records.records
                              .take(5)
                              .map((r) => _MedicalRecordCard(record: r))
                              .toList(),
                        ),
                ),

                const SizedBox(height: 32),

                // ── Sign out ───────────────────────────────────────────────
                AppButton.danger(
                  text: LocaleKeys.sign_out.tr(),
                  icon: Icons.logout_rounded,
                  height: 48,
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/role-selection');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Profile header ──────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {

  const _ProfileHeader({required this.user, required this.isDark});
  final dynamic user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.tealDark, AppColors.teal.withValues(alpha: 0.6)]
              : [AppColors.teal, AppColors.tealDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (user.city?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        user.city!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage:
                (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                    ? NetworkImage(user.imageUrl!) as ImageProvider
                    : null,
            child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                ? const Icon(Icons.person_rounded,
                    size: 44, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.accent(context),
          ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.teal),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// ─── Medical record card ──────────────────────────────────────────────────────

class _MedicalRecordCard extends StatelessWidget {
  const _MedicalRecordCard({required this.record});
  final MedicalRecordModel record;

  @override
  Widget build(BuildContext context) {
    final date = record.visitDate.length >= 10
        ? record.visitDate.substring(0, 10)
        : record.visitDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.teal.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medical_information_rounded,
                    size: 16, color: AppColors.teal),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  LocaleKeys.dr_prefix
                      .tr(namedArgs: {'name': record.doctorName}),
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                date,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RecordRow(
              label: LocaleKeys.diagnosis.tr(),
              value: record.diagnosis),
          const SizedBox(height: 6),
          _RecordRow(
              label: LocaleKeys.treatment.tr(),
              value: record.treatment),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.accent(context),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
