import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../generated/locale_keys.g.dart';

import '../../../core/services/helper.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../doctor/data/models/time_slot_model.dart';
import '../../doctor/presentation/providers/time_slot_provider.dart';

class TimeSlotsPage extends ConsumerStatefulWidget {
  const TimeSlotsPage({super.key});
  static const routeName = '/time-slots';

  @override
  ConsumerState<TimeSlotsPage> createState() => _TimeSlotsPageState();
}

class _TimeSlotsPageState extends ConsumerState<TimeSlotsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorId = ref.read(authProvider).value?.currentUser?.id ?? '';
      if (doctorId.isNotEmpty) {
        ref.read(timeSlotProvider.notifier).loadSlotsForDoctor(doctorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(timeSlotProvider);
    final doctorId = ref.watch(authProvider).value?.currentUser?.id ?? '';

    ref.listen(timeSlotProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.work_schedule.tr(),
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '${LocaleKeys.error_e.tr()}: $e',
            style: const TextStyle(color: AppColors.danger),
            textAlign: TextAlign.center,
          ),
        ),
        data: (state) => Column(
          children: [
            _AddSlotForm(
              onAdd: (start, end) => ref
                  .read(timeSlotProvider.notifier)
                  .addSlot(doctorId: doctorId, startTime: start, endTime: end),
              isLoading: state.isLoading,
            ),
            Expanded(
              child: state.slots.isEmpty
                  ? _EmptySlots()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: state.slots.length,
                      itemBuilder: (_, i) => _SlotCard(
                        slot: state.slots[i],
                        onDelete: state.isLoading
                            ? null
                            : () => ref
                                  .read(timeSlotProvider.notifier)
                                  .deleteSlot(
                                    doctorId: doctorId,
                                    slotId: state.slots[i].id,
                                  ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────────

class _EmptySlots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 72,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            LocaleKeys.no_slots.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─── Add slot form ───────────────────────────────────────────────────────────

class _AddSlotForm extends StatefulWidget {
 

  const _AddSlotForm({required this.onAdd, required this.isLoading}); final Future<void> Function(String start, String end) onAdd;
  final bool isLoading;

  @override
  State<_AddSlotForm> createState() => _AddSlotFormState();
}

class _AddSlotFormState extends State<_AddSlotForm> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return dt.toIso8601String();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
    }
  }

  bool get _canAdd =>
      _selectedDate != null && _startTime != null && _endTime != null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_alarm_rounded,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                LocaleKeys.add_new_slot.tr(),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton.outlined(
            text: _selectedDate == null
                ? LocaleKeys.pick_date.tr()
                : DateFormat('yyyy-MM-dd').format(_selectedDate!),
            icon: Icons.calendar_today_rounded,
            height: 44,
            fontSize: 13,
            onPressed: _pickDate,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  text: _startTime == null
                      ? LocaleKeys.start_time.tr()
                      : _startTime!.format(context),
                  icon: Icons.access_time_rounded,
                  height: 44,
                  fontSize: 13,
                  onPressed: () => _pickTime(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton.outlined(
                  text: _endTime == null
                      ? LocaleKeys.end_time.tr()
                      : _endTime!.format(context),
                  icon: Icons.access_time_filled_rounded,
                  height: 44,
                  fontSize: 13,
                  onPressed: () => _pickTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton.primary(
            text: LocaleKeys.add.tr(),
            icon: Icons.add_rounded,
            isLoading: widget.isLoading,
            height: 46,
            onPressed: _canAdd
                ? () => widget.onAdd(
                    _formatDateTime(_selectedDate!, _startTime!),
                    _formatDateTime(_selectedDate!, _endTime!),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Slot card ───────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
 

  const _SlotCard({required this.slot, this.onDelete}); final TimeSlotModel slot;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final start = DateTime.tryParse(slot.startTime);
    final end = DateTime.tryParse(slot.endTime);
    final isBooked = slot.isBooked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBooked
              ? AppColors.danger.withValues(alpha: 0.25)
              : AppColors.success.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isBooked
                  ? AppColors.danger.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBooked
                  ? Icons.event_busy_rounded
                  : Icons.event_available_rounded,
              color: isBooked ? AppColors.danger : AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  start != null
                      ? DateFormat('yyyy-MM-dd').format(start)
                      : slot.startTime,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  start != null && end != null
                      ? '${TimeOfDay.fromDateTime(start).format(context)} — ${TimeOfDay.fromDateTime(end).format(context)}'
                      : '${slot.startTime} — ${slot.endTime}',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isBooked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                LocaleKeys.booked.tr(),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            AppButton.danger(
              text: LocaleKeys.delete.tr(),
              icon: Icons.delete_outline_rounded,
              width: 120,
              height: 36,
              fontSize: 12,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
