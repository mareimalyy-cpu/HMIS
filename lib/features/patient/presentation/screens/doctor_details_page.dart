import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../booking/presentation/screens/booking_page.dart';

class DoctorDetailsPage extends StatelessWidget {

  const DoctorDetailsPage({required this.doctor, super.key});
  static const routeName = '/doctor-details';

  final UserModel doctor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.cardBackground;
    final accentColor = isDark ? AppColors.tealLight : AppColors.teal;
    final iconColor = isDark ? AppColors.tealLight : AppColors.primary;
    final subtleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      appBar: SectionAppBar(title: LocaleKeys.doctor_details.tr()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Doctor Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        LocaleKeys.dr_doctorname.tr(
                          namedArgs: {'name': doctor.name},
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            doctor.specialty ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(
                            '${doctor.rating?.toInt() ?? 0}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                  backgroundImage: doctor.imageUrl != null
                      ? NetworkImage(doctor.imageUrl!)
                      : null,
                  child: doctor.imageUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bio Section
            Text(
              LocaleKeys.about.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              doctor.bio ?? LocaleKeys.no_bio_available.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: subtleColor),
            ),

            const SizedBox(height: 20),

            // Schedule & Location Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        doctor.workDays?.join(', ') ??
                            LocaleKeys.not_specified.tr(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: subtleColor),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.calendar_today, size: 18, color: subtleColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${doctor.workHoursStart ?? ''} - ${doctor.workHoursEnd ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 20, color: subtleColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          doctor.hospitalAddress ?? '',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, size: 20, color: subtleColor),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contact Info
            Text(
              LocaleKeys.contact_info.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        doctor.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.mail, color: iconColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        doctor.phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.phone, color: iconColor),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            AppButton.primary(
              text: LocaleKeys.book_now.tr(),
              onPressed: () =>
                  context.push(BookingPage.routeName, extra: doctor),
            ),
          ],
        ),
      ),
    );
  }
}
