import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/appointment_card.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../providers/doctor_home_provider.dart';
import '../../../medical_records/presentation/screens/medical_records_page.dart';

class DoctorRecordsPage extends ConsumerWidget {
  const DoctorRecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(doctorHomeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.tealLight : AppColors.teal;

    return Scaffold(
      appBar: SectionAppBar(
        title: LocaleKeys.records.tr(),
        showBackButton: false,
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(LocaleKeys.error_e.tr())),
        data: (state) {
          final cases = state.recentCases;
          if (cases.isEmpty) {
            return Center(
              child: Text(
                LocaleKeys.no_records_yet.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                LocaleKeys.recent_cases.tr(),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...cases.map((appointment) => AppointmentCard(
                    appointment: appointment,
                    showDate: true,
                    onTap: () => context.push(
                      MedicalRecordsPage.routeName,
                      extra: {
                        'patientId': appointment.patientId,
                        'patientName': appointment.patientName,
                      },
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
