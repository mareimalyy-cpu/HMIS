import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/section_app_bar.dart';
import '../../auth/models/user_model.dart';
import '../../booking/views/booking_page.dart';

class DoctorDetailsPage extends StatelessWidget {
  static const routeName = '/doctor-details';

  final UserModel doctor;

  const DoctorDetailsPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  SectionAppBar(title: 'doctor_details'.tr()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Doctor Header
            Row(
              children: [
                // Name + Specialty + Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'dr_doctorname'.tr(),
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
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
                  backgroundColor: Colors.grey[300],
                  backgroundImage: doctor.imageUrl != null
                      ? NetworkImage(doctor.imageUrl!)
                      : null,
                  child: doctor.imageUrl == null
                      ? const Icon(Icons.person,
                          size: 50, color: Colors.white)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bio Section
            Text(
              'about'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              doctor.bio ?? 'no_bio_available'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 20),

            // Schedule & Location Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Work Days
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        doctor.workDays?.join(', ') ?? 'not_specified'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Work Hours
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${doctor.workHoursStart ?? ''} - ${doctor.workHoursEnd ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Address
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
                      const Icon(Icons.location_on, size: 20),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contact Info
            Text(
              'contact_info'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(doctor.email,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      const Icon(Icons.mail, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(doctor.phone,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      const Icon(Icons.phone, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Book Now Button
            CustomButton(
              text: 'book_now'.tr(),
              grideantColor: AppColors.teal,
              onPressed: () => context.push(
                BookingPage.routeName,
                extra: doctor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
