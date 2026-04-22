import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/services/helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../booking/data/models/appointment_model.dart';
import 'clinics_page.dart';
import '../providers/patient_appointments_provider.dart';

class PatientAppointmentsPage extends ConsumerStatefulWidget {
  const PatientAppointmentsPage({super.key});

  @override
  ConsumerState<PatientAppointmentsPage> createState() =>
      _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState
    extends ConsumerState<PatientAppointmentsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOnce());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadOnce() {
    if (_loaded) return;
    _loaded = true;
    final patientId = ref.read(authProvider).value?.currentUser?.id ?? '';
    if (patientId.isNotEmpty) {
      ref
          .read(patientAppointmentsProvider.notifier)
          .loadForPatient(patientId);
    }
  }

  Future<void> _confirmCancel(AppointmentModel appt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleKeys.cancel_appointment.tr()),
        content: Text(
            '${LocaleKeys.cancel_appointment.tr()} ${appt.date} — ${appt.time}?'),
        actions: [
          AppButton.outlined(
            text: LocaleKeys.cancelButton.tr(),
            onPressed: () => Navigator.pop(ctx, false),
            height: 40,
            width: null,
          ),
          AppButton.danger(
            text: LocaleKeys.cancel_appointment.tr(),
            onPressed: () => Navigator.pop(ctx, true),
            height: 40,
            width: null,
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref
          .read(patientAppointmentsProvider.notifier)
          .cancelAppointment(appt.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(patientAppointmentsProvider);
    final patientId =
        ref.watch(authProvider).value?.currentUser?.id ?? '';

    ref.listen(patientAppointmentsProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    return Scaffold(
      appBar: SectionAppBar(
        title: LocaleKeys.my_appointments.tr(),
        showBackButton: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(ClinicsPage.routeName),
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text(LocaleKeys.book_now.tr()),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(LocaleKeys.error_e.tr())),
        data: (state) => Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: AppColors.teal,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.teal,
              tabs: [
                Tab(
                  text:
                      '${LocaleKeys.upcoming.tr()} (${state.upcoming.length})',
                ),
                Tab(
                  text:
                      '${LocaleKeys.records.tr()} (${state.past.length})',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ─── Upcoming ─────────────────────────────────
                  RefreshIndicator(
                    onRefresh: () => ref
                        .read(patientAppointmentsProvider.notifier)
                        .refresh(patientId),
                    child: state.upcoming.isEmpty
                        ? _EmptyState(
                            message: LocaleKeys.no_appointments_yet.tr())
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.upcoming.length,
                            itemBuilder: (_, i) => _AppointmentCard(
                              appt: state.upcoming[i],
                              isLoading: state.isLoading,
                              canCancel: true,
                              onCancel: () =>
                                  _confirmCancel(state.upcoming[i]),
                            ),
                          ),
                  ),

                  // ─── Past ─────────────────────────────────────
                  RefreshIndicator(
                    onRefresh: () => ref
                        .read(patientAppointmentsProvider.notifier)
                        .refresh(patientId),
                    child: state.past.isEmpty
                        ? _EmptyState(
                            message: LocaleKeys.no_records_yet.tr())
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.past.length,
                            itemBuilder: (_, i) => _AppointmentCard(
                              appt: state.past[i],
                              isLoading: state.isLoading,
                              canCancel: false,
                              onCancel: () {},
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {

  const _AppointmentCard({
    required this.appt,
    required this.isLoading,
    required this.canCancel,
    required this.onCancel,
  });
  final AppointmentModel appt;
  final bool isLoading;
  final bool canCancel;
  final VoidCallback onCancel;

  Color _statusColor() => switch (appt.status) {
        'completed' => AppColors.success,
        'cancelled' => AppColors.danger,
        'no_show' => Colors.grey,
        'pending' => Colors.orange,
        _ => AppColors.teal,
      };

  String _statusKey() => switch (appt.status) {
        'completed' => LocaleKeys.status_completed,
        'cancelled' => LocaleKeys.status_cancelled,
        'no_show' => LocaleKeys.status_no_show,
        'pending' => LocaleKeys.status_pending,
        _ => LocaleKeys.status_scheduled,
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // ─── Header ───────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusKey().tr(),
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  '${LocaleKeys.appointment_number.tr()} ${appt.number}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),

          // ─── Body ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Row(
                  icon: Icons.person_outline,
                  label: LocaleKeys.col_doctor.tr(),
                  value: LocaleKeys.dr_prefix
                      .tr(namedArgs: {'name': appt.doctorName}),
                  color: color,
                ),
                const SizedBox(height: 8),
                _Row(
                  icon: Icons.medical_services_outlined,
                  label: LocaleKeys.specialty.tr(),
                  value: appt.doctorSpecialty,
                  color: color,
                ),
                const SizedBox(height: 8),
                _Row(
                  icon: Icons.calendar_today_outlined,
                  label: LocaleKeys.select_day.tr(),
                  value: appt.date,
                  color: color,
                ),
                const SizedBox(height: 8),
                _Row(
                  icon: Icons.access_time_outlined,
                  label: LocaleKeys.select_time.tr(),
                  value: appt.time,
                  color: color,
                ),
                if (appt.address != null && appt.address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _Row(
                    icon: Icons.location_on_outlined,
                    label: LocaleKeys.col_clinic_location.tr(),
                    value: appt.address!,
                    color: color,
                  ),
                ],
                if (canCancel && appt.status != 'cancelled') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.outlined(
                      text: LocaleKeys.cancel_appointment.tr(),
                      onPressed: isLoading ? null : onCancel,
                      height: 40,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
        Icon(icon, size: 16, color: color),
      ],
    );
  }
}
