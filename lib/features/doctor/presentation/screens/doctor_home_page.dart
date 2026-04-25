import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/appointment_card.dart';
import '../../../../gen/assets.gen.dart';
import '../../../notifications/presentation/widgets/notification_bell_button.dart';
import '../providers/doctor_home_provider.dart';

class DoctorHomePage extends ConsumerWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(doctorHomeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.tealLight : AppColors.teal;

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('error_e'.tr())),
      data: (state) => RefreshIndicator(
        onRefresh: () => ref.read(doctorHomeProvider.notifier).refresh(),
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
                      IconButton(
                        onPressed: () => context.push('/support'),
                        icon: Icon(
                          Icons.phone_outlined,
                          color: accentColor,
                        ),
                      ),
                      const Spacer(),
                      Assets.images.png.appLogo.image(height: 50),
                      const Spacer(),
                      const NotificationBellButton(),
                    ],
                  ),
                ),
              ),

              // Doctor Avatar + Greeting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.greeting,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          isDark ? Colors.grey[700] : Colors.grey[300],
                      backgroundImage: state.currentDoctor?.imageUrl != null
                          ? NetworkImage(state.currentDoctor!.imageUrl!)
                          : null,
                      child: state.currentDoctor?.imageUrl == null
                          ? const Icon(Icons.person,
                              size: 36, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Pending Appointments ─────────────────────────
              if (state.pendingAppointments.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${state.pendingAppointments.length}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'pending_appointments'.tr(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.pendingAppointments.length,
                  itemBuilder: (context, index) {
                    final appt = state.pendingAppointments[index];
                    return AppointmentCard(
                      appointment: appt,
                      showDate: true,
                      onApprove: () => ref
                          .read(doctorHomeProvider.notifier)
                          .approveAppointment(appt.id),
                      onReject: () => ref
                          .read(doctorHomeProvider.notifier)
                          .rejectAppointment(appt.id),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Today's Appointments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'todays_appointments'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),

              if (state.todayAppointments.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'no_appointments_today'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.todayAppointments.length,
                  itemBuilder: (context, index) {
                    final appt = state.todayAppointments[index];
                    final isPending = appt.status == 'pending' ||
                        appt.status == 'scheduled';
                    final isApproved = appt.status == 'approved';
                    return AppointmentCard(
                      appointment: appt,
                      onApprove: isPending
                          ? () => ref
                              .read(doctorHomeProvider.notifier)
                              .approveAppointment(appt.id)
                          : null,
                      onReject: isPending
                          ? () => ref
                              .read(doctorHomeProvider.notifier)
                              .rejectAppointment(appt.id)
                          : null,
                      onComplete: isApproved
                          ? () => ref
                              .read(doctorHomeProvider.notifier)
                              .completeAppointment(appt.id)
                          : null,
                      onNoShow: isApproved
                          ? () => ref
                              .read(doctorHomeProvider.notifier)
                              .markNoShow(appt.id)
                          : null,
                    );
                  },
                ),

              const SizedBox(height: 20),

              // New Patients
              if (state.newPatients.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'new_patients'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.newPatients.length,
                  itemBuilder: (context, index) => AppointmentCard(
                    appointment: state.newPatients[index],
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
