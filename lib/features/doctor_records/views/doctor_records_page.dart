import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/appointment_card.dart';
import '../../../core/widgets/section_app_bar.dart';
import '../../doctor_home/providers/doctor_home_provider.dart';

class DoctorRecordsPage extends ConsumerWidget {
  const DoctorRecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(doctorHomeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.tealLight : AppColors.teal;

    return Scaffold(
      appBar:  SectionAppBar(
        title: 'records'.tr(),
        showBackButton: false,
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('error_e'.tr())),
        data: (state) {
          final cases = state.recentCases;
          if (cases.isEmpty) {
            return Center(
              child: Text(
                'no_records_yet'.tr(),
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
                'recent_cases'.tr(),
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
                  )),
            ],
          );
        },
      ),
    );
  }
}
