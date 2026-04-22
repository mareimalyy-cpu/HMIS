import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/services/helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../../../admin/presentation/providers/admin_provider.dart';
import '../../../booking/data/models/appointment_model.dart';
import '../../../patient/presentation/screens/clinics_page.dart';

class ReceptionistAppointmentsPage extends ConsumerStatefulWidget {
  const ReceptionistAppointmentsPage({super.key});

  @override
  ConsumerState<ReceptionistAppointmentsPage> createState() =>
      _ReceptionistAppointmentsPageState();
}

class _ReceptionistAppointmentsPageState
    extends ConsumerState<ReceptionistAppointmentsPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context, ) {
    final asyncState = ref.watch(adminProvider);

    ref.listen(adminProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    return Scaffold(
      appBar: SectionAppBar(
        title: LocaleKeys.appointments.tr(),
        showBackButton: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(ClinicsPage.routeName),
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text(LocaleKeys.create_appointment.tr()),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(LocaleKeys.error_e.tr())),
        data: (state) {
          final filtered = _applyFilter(state.appointments);

          return Column(
            children: [
              _FilterBar(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminProvider.notifier).refresh(),
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            LocaleKeys.no_appointments_yet.tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _AppointmentCard(
                            appt: filtered[i],
                            isLoading: state.isLoading,
                            onDelete: () => ref
                                .read(adminProvider.notifier)
                                .deleteAppointment(filtered[i].id),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AppointmentModel> _applyFilter(List<AppointmentModel> all) {
    if (_filter == 'all') return all;
    return all.where((a) => a.status == _filter).toList();
  }
}

class _FilterBar extends StatelessWidget {

  const _FilterBar({required this.selected, required this.onSelected});
  final String selected;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('all', LocaleKeys.filter_all.tr()),
      ('scheduled', LocaleKeys.status_scheduled.tr()),
      ('completed', LocaleKeys.status_completed.tr()),
      ('cancelled', LocaleKeys.status_cancelled.tr()),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: filters.map((f) {
          final isSelected = selected == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f.$2),
              selected: isSelected,
              selectedColor: AppColors.teal,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => onSelected(f.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {

  const _AppointmentCard({
    required this.appt,
    required this.isLoading,
    required this.onDelete,
  });
  final AppointmentModel appt;
  final bool isLoading;
  final VoidCallback onDelete;

  Color _statusColor() => switch (appt.status) {
        'completed' => AppColors.success,
        'cancelled' => AppColors.danger,
        'no_show' => Colors.grey,
        _ => AppColors.teal,
      };

  String _statusLabel() => switch (appt.status) {
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              AppButton.danger(
                text: LocaleKeys.delete.tr(),
                onPressed: isLoading ? null : onDelete,
                height: 34,
                fontSize: 11,
                width: null,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    appt.patientName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    LocaleKeys.dr_prefix.tr(namedArgs: {'name': appt.doctorName}),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel().tr(),
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${appt.date}  ${appt.time}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
