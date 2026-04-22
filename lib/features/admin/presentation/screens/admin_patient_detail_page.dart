import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../booking/data/models/appointment_model.dart';
import '../../data/services/remote/admin_remote_service.dart';

final _patientAppointmentsProvider =
    FutureProvider.family<List<AppointmentModel>, String>((ref, patientId) {
  return AdminRemoteService().getPatientAppointments(patientId);
});

class AdminPatientDetailPage extends ConsumerWidget {

  const AdminPatientDetailPage({required this.patient, super.key});
  final UserModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAppts = ref.watch(_patientAppointmentsProvider(patient.id));

    return Scaffold(
      appBar: SectionAppBar(
        title: LocaleKeys.patient_data.tr(),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  patient.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.cardBackground,
                  backgroundImage: patient.imageUrl != null
                      ? NetworkImage(patient.imageUrl!)
                      : null,
                  child: patient.imageUrl == null
                      ? const Icon(Icons.person,
                          size: 40, color: Colors.grey)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            _SectionTitle(title: LocaleKeys.contact_info.tr()),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _InfoRow(icon: Icons.email_rounded, text: patient.email),
                  const Divider(height: 16),
                  _InfoRow(icon: Icons.phone_rounded, text: patient.phone),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        patient.id.isNotEmpty
                            ? patient.id.substring(0, 6).toUpperCase()
                            : '---',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ID',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SectionTitle(title: LocaleKeys.medical_history.tr()),
            const SizedBox(height: 8),

            asyncAppts.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Text('${LocaleKeys.error_e.tr()}: $e'),
              data: (appts) {
                if (appts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        LocaleKeys.no_medical_records.tr(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return Column(
                  children: appts
                      .map((appt) => _AppointmentHistoryCard(appt: appt))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.bold,
            ),
      ),
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ],
    );
  }
}

class _AppointmentHistoryCard extends StatelessWidget {
  const _AppointmentHistoryCard({required this.appt});
  final AppointmentModel appt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.print_rounded,
                    color: AppColors.teal.withValues(alpha: 0.8)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                LocaleKeys.examined_on.tr(namedArgs: {'date': appt.date}),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    LocaleKeys.doctor_prefix
                        .tr(namedArgs: {'name': appt.doctorName}),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppColors.teal),
                  ),
                  Text(appt.doctorSpecialty),
                ],
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.cardBackground,
                backgroundImage: appt.doctorImageUrl != null
                    ? NetworkImage(appt.doctorImageUrl!)
                    : null,
                child: appt.doctorImageUrl == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
            ],
          ),
          if (appt.symptoms.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(appt.symptoms),
                const SizedBox(width: 4),
                Text(
                  LocaleKeys.case_condition.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
