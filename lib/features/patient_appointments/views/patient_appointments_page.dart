import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/section_app_bar.dart';

class PatientAppointmentsPage extends ConsumerWidget {
  const PatientAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Will be connected to booking provider later
    return Scaffold(
      appBar:  SectionAppBar(title: 'appointments'.tr(), showBackButton: false),
      body: Center(
        child: Text(
          'no_appointments_yet'.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}
