import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/appointment_card.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../../../admin/presentation/providers/admin_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/widgets/notification_bell_button.dart';
import '../../../patient/presentation/screens/clinics_page.dart';

class ReceptionistHomePage extends ConsumerWidget {
  const ReceptionistHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(adminProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value?.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.tealLight : AppColors.teal;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? LocaleKeys.goodMorning.tr()
        : LocaleKeys.goodEvening.tr();

    return Scaffold(
      appBar: SectionAppBar(
        title: LocaleKeys.receptionist.tr(),
        showBackButton: false,
        actions: const [NotificationBellButton()],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(LocaleKeys.error_e.tr())),
        data: (state) {
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final todayAppts = state.appointments
              .where((a) => a.date == today)
              .toList();
          final pendingAppts = state.appointments
              .where((a) => a.status == 'scheduled' || a.status == 'pending')
              .toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(adminProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                // ─── Greeting header ──────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.teal, AppColors.tealDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(greeting,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                user?.name ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.support_agent_rounded,
                            color: Colors.white54, size: 48),
                      ],
                    ),
                  ),
                ),

                // ─── Stats row ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: LocaleKeys.todays_appointments.tr(),
                            count: todayAppts.length,
                            icon: Icons.today_rounded,
                            color: AppColors.teal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: LocaleKeys.patients_count.tr(),
                            count: state.patientCount,
                            icon: Icons.people_alt_rounded,
                            color: const Color(0xFF4ABCCA),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: LocaleKeys.upcoming.tr(),
                            count: pendingAppts.length,
                            icon: Icons.pending_actions_rounded,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Quick actions ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      LocaleKeys.create_appointment.tr(),
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _QuickActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      label: LocaleKeys.create_appointment.tr(),
                      subtitle: 'Search a doctor and book for a patient',
                      color: AppColors.teal,
                      onTap: () => context.push(ClinicsPage.routeName),
                    ),
                  ),
                ),

                // ─── Today's appointments ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      LocaleKeys.todays_appointments.tr(),
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),
                if (todayAppts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          LocaleKeys.no_appointments_today.tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) =>
                            AppointmentCard(appointment: todayAppts[i]),
                        childCount: todayAppts.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(height: 6),
          Text(count.toString(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
