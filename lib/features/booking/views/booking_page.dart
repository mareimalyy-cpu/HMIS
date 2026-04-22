import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/helper.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/my_text_filed.dart';
import '../../../core/widgets/section_app_bar.dart';
import '../../../generated/locale_keys.g.dart';
import '../../attachments/data/models/booking_attachment.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../doctor/data/models/time_slot_model.dart';
import '../presentation/providers/booking_provider.dart';
import '../presentation/screens/booking_success_page.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({required this.doctor, super.key});
  static const routeName = '/booking';

  final UserModel doctor;

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  final _symptomsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).loadAvailableSlots(widget.doctor.id);
    });
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _onPickFiles(String patientId) async {
    final errorKey = await ref
        .read(bookingProvider.notifier)
        .pickAndUploadFiles(patientId: patientId);
    if (errorKey != null && mounted) {
      GlassySnackbar.showError(context, errorKey.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bookingAsync = ref.watch(bookingProvider);
    final booking = bookingAsync.value;
    final currentUser = authState.value?.currentUser;
    final cardColor = AppColors.card(context);
    final isLoading = booking?.isLoading ?? false;
    final isUploading = booking?.isUploading ?? false;
    final isSlotsLoading = booking?.isSlotsLoading ?? false;
    final selectedSlot = booking?.selectedSlot;
    final attachments = booking?.attachments ?? const [];
    final slotsByDate = booking?.slotsByDate ?? {};
    final slotsError = booking?.slotsError;

    final canSubmit = !isLoading && !isUploading && !isSlotsLoading;

    ref.listen(bookingProvider, (_, next) {
      final s = next.value;
      if (s == null) return;
      if (s.errorMessage != null) {
        GlassySnackbar.showError(context, s.errorMessage!);
        ref.read(bookingProvider.notifier).reset();
      }
      if (s.isSuccess) {
        ref.read(bookingProvider.notifier).reset();
        context.go(BookingSuccessPage.routeName);
      }
    });

    return Scaffold(
      appBar: SectionAppBar(title: LocaleKeys.book_with_doctor.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Doctor mini card ──────────────────────────────────────────
              _DoctorCard(doctor: widget.doctor, cardColor: cardColor),

              const SizedBox(height: 20),

              // ── Section title ─────────────────────────────────────────────
              Text(
                LocaleKeys.booking_details.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // ── Patient name ──────────────────────────────────────────────
              Text(
                LocaleKeys.patient_name.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              _ReadOnlyField(
                text: currentUser?.name ?? '',
                cardColor: cardColor,
              ),

              const SizedBox(height: 12),

              // ── Phone ─────────────────────────────────────────────────────
              Text(
                LocaleKeys.phone.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              _ReadOnlyField(
                text: currentUser?.phone ?? '',
                cardColor: cardColor,
              ),

              const SizedBox(height: 12),

              // ── Symptoms ──────────────────────────────────────────────────
              Text(
                LocaleKeys.symptoms.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              MyTextField(
                controller: _symptomsController,
                hintText: LocaleKeys.describe_your_symptoms.tr(),
                textAlign: TextAlign.right,
                fillColor: cardColor,
                maxLines: 2,
              ),

              const SizedBox(height: 20),

              // ── Available slots section ───────────────────────────────────
              _SlotsSection(
                isSlotsLoading: isSlotsLoading,
                slotsError: slotsError,
                slotsByDate: slotsByDate,
                selectedSlot: selectedSlot,
                cardColor: cardColor,
                isDisabled: isLoading,
                onRetry: () => ref
                    .read(bookingProvider.notifier)
                    .loadAvailableSlots(widget.doctor.id),
                onSelect: (slot) =>
                    ref.read(bookingProvider.notifier).selectSlot(slot),
              ),

              const SizedBox(height: 20),

              // ── Attachments section ───────────────────────────────────────
              _AttachmentsSection(
                attachments: attachments,
                cardColor: cardColor,
                isDisabled: isLoading,
                onAddTapped: () => _onPickFiles(currentUser?.id ?? ''),
                onRemove: (name) =>
                    ref.read(bookingProvider.notifier).removeAttachment(name),
              ),

              const SizedBox(height: 24),

              // ── Submit ────────────────────────────────────────────────────
              AppButton.primary(
                text: isUploading
                    ? LocaleKeys.uploading.tr()
                    : LocaleKeys.confirm_booking.tr(),
                isLoading: isLoading,
                onPressed: canSubmit
                    ? () {
                        if (selectedSlot == null) {
                          GlassySnackbar.showError(
                            context,
                            LocaleKeys.please_select_a_day_and_time.tr(),
                          );
                          return;
                        }
                        if (currentUser == null) return;
                        ref
                            .read(bookingProvider.notifier)
                            .submitBooking(
                              patient: currentUser,
                              doctor: widget.doctor,
                              slot: selectedSlot,
                              symptoms: _symptomsController.text.trim(),
                            );
                      }
                    : null,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Doctor mini card ─────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {

  const _DoctorCard({required this.doctor, required this.cardColor});
  final UserModel doctor;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text('${doctor.rating?.toInt() ?? 0}'),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                doctor.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                doctor.specialty ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            backgroundImage: doctor.imageUrl != null
                ? NetworkImage(doctor.imageUrl!)
                : null,
            child: doctor.imageUrl == null
                ? const Icon(Icons.person, size: 24, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Read-only field ──────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {

  const _ReadOnlyField({required this.text, required this.cardColor});
  final String text;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, textAlign: TextAlign.right),
    );
  }
}

// ─── Slots section ────────────────────────────────────────────────────────────

class _SlotsSection extends StatelessWidget {
  const _SlotsSection({
    required this.isSlotsLoading,
    required this.slotsError,
    required this.slotsByDate,
    required this.selectedSlot,
    required this.cardColor,
    required this.isDisabled,
    required this.onRetry,
    required this.onSelect,
  });
  final bool isSlotsLoading;
  final String? slotsError;
  final Map<String, List<TimeSlotModel>> slotsByDate;
  final TimeSlotModel? selectedSlot;
  final Color cardColor;
  final bool isDisabled;
  final VoidCallback onRetry;
  final void Function(TimeSlotModel) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Section title
        Row(
          children: [
            if (isSlotsLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            const Spacer(),
            Text(
              LocaleKeys.available_slots.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (isSlotsLoading)
          _SlotsShimmer(cardColor: cardColor)
        else if (slotsError != null)
          _ErrorRetry(cardColor: cardColor, onRetry: onRetry)
        else if (slotsByDate.isEmpty)
          _EmptySlots(cardColor: cardColor)
        else
          ...slotsByDate.entries.map(
            (entry) => _DateGroup(
              dateKey: entry.key,
              slots: entry.value,
              selectedSlot: selectedSlot,
              isDisabled: isDisabled,
              onSelect: onSelect,
            ),
          ),
      ],
    );
  }
}

// ── Slot loading shimmer ───────────────────────────────────────────────────────

class _SlotsShimmer extends StatelessWidget {
  const _SlotsShimmer({required this.cardColor});
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        2,
        (_) => Container(
          width: double.infinity,
          height: 48,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ── Error retry ───────────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.cardColor, required this.onRetry});
  final Color cardColor;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.grey[400], size: 40),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.error_e.tr(),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(LocaleKeys.retry.tr()),
            style: TextButton.styleFrom(foregroundColor: AppColors.teal),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptySlots extends StatelessWidget {
  const _EmptySlots({required this.cardColor});
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, color: Colors.grey[300], size: 48),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.no_available_slots.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Slots grouped by date ─────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {

  const _DateGroup({
    required this.dateKey,
    required this.slots,
    required this.selectedSlot,
    required this.isDisabled,
    required this.onSelect,
  });
  final String dateKey;
  final List<TimeSlotModel> slots;
  final TimeSlotModel? selectedSlot;
  final bool isDisabled;
  final void Function(TimeSlotModel) onSelect;

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(dateKey);
    final label = dt != null
        ? DateFormat('EEEE, d MMMM yyyy').format(dt)
        : dateKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: slots.map((slot) {
            final isSelected = selectedSlot?.id == slot.id;
            final start = DateTime.tryParse(slot.startTime);
            final end = DateTime.tryParse(slot.endTime);
            final label = (start != null && end != null)
                ? '${TimeOfDay.fromDateTime(start).format(context)} — ${TimeOfDay.fromDateTime(end).format(context)}'
                : slot.startTime;

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              selectedColor: AppColors.teal,
              backgroundColor: AppColors.card(context),
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              onSelected: isDisabled ? null : (_) => onSelect(slot),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Attachments section ──────────────────────────────────────────────────────

class _AttachmentsSection extends StatelessWidget {
  const _AttachmentsSection({
    required this.attachments,
    required this.cardColor,
    required this.isDisabled,
    required this.onAddTapped,
    required this.onRemove,
  });
  final List<BookingAttachment> attachments;
  final Color cardColor;
  final bool isDisabled;
  final VoidCallback onAddTapped;
  final void Function(String name) onRemove;

  @override
  Widget build(BuildContext context) {
    final atMaxFiles = attachments.length >= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            if (!atMaxFiles && !isDisabled)
              TextButton.icon(
                onPressed: onAddTapped,
                icon: const Icon(Icons.attach_file_rounded, size: 18),
                label: Text(
                  LocaleKeys.add_attachment.tr(),
                  style: const TextStyle(fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (attachments.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${attachments.length}/3',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  LocaleKeys.attachments.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            LocaleKeys.allowed_file_types.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ),
        if (attachments.isNotEmpty) const SizedBox(height: 8),
        ...attachments.map(
          (a) => _FileTile(
            attachment: a,
            cardColor: cardColor,
            onRemove: isDisabled ? null : () => onRemove(a.name),
          ),
        ),
      ],
    );
  }
}

// ─── File tile ────────────────────────────────────────────────────────────────

class _FileTile extends StatelessWidget {

  const _FileTile({
    required this.attachment,
    required this.cardColor,
    required this.onRemove,
  });
  final BookingAttachment attachment;
  final Color cardColor;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: attachment.uploadError != null
            ? Border.all(color: AppColors.danger, width: 1)
            : null,
      ),
      child: Row(
        children: [
          if (attachment.isUploading)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: onRemove == null ? Colors.grey : AppColors.danger,
              ),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: LocaleKeys.remove_file.tr(),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  attachment.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  attachment.isUploading
                      ? LocaleKeys.uploading.tr()
                      : attachment.uploadError != null
                      ? LocaleKeys.upload_failed.tr()
                      : attachment.displaySize,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: attachment.uploadError != null
                        ? AppColors.danger
                        : attachment.isUploading
                        ? AppColors.teal
                        : Colors.grey[500],
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _FileIcon(attachment: attachment),
        ],
      ),
    );
  }
}

// ─── File icon / thumbnail ────────────────────────────────────────────────────

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.attachment});
  final BookingAttachment attachment;

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage && attachment.localPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(attachment.localPath),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _iconBox(
            Icons.image_rounded,
            Colors.teal.shade100,
            AppColors.teal,
          ),
        ),
      );
    }
    if (attachment.isPdf) {
      return _iconBox(
        Icons.picture_as_pdf_rounded,
        Colors.red.shade50,
        Colors.red.shade400,
      );
    }
    if (attachment.isExcel) {
      return _iconBox(
        Icons.table_chart_rounded,
        Colors.green.shade50,
        Colors.green.shade600,
      );
    }
    if (attachment.isWord) {
      return _iconBox(
        Icons.description_rounded,
        Colors.blue.shade50,
        Colors.blue.shade600,
      );
    }
    return _iconBox(
      Icons.insert_drive_file_rounded,
      Colors.grey.shade100,
      Colors.grey,
    );
  }

  Widget _iconBox(IconData icon, Color bg, Color fg) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: fg, size: 22),
    );
  }
}
