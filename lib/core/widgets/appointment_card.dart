import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../features/booking/data/models/appointment_model.dart';
import '../../generated/locale_keys.g.dart';
import '../themes/app_colors.dart';
import 'app_button.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    required this.appointment,
    super.key,
    this.onTap,
    this.showDate = false,
    this.onApprove,
    this.onReject,
    this.onComplete,
    this.onNoShow,
  });

  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final bool showDate;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final VoidCallback? onNoShow;

  Color get _statusColor => switch (appointment.status) {
    'approved' => AppColors.teal,
    'completed' => AppColors.success,
    'cancelled' || 'rejected' => AppColors.danger,
    'no_show' => Colors.grey,
    'pending' => Colors.orange,
    _ => AppColors.teal,
  };

  String get _statusLabel => switch (appointment.status) {
    'approved' => LocaleKeys.approve,
    'completed' => LocaleKeys.status_completed,
    'cancelled' => LocaleKeys.status_cancelled,
    'rejected' => LocaleKeys.reject,
    'no_show' => LocaleKeys.status_no_show,
    'pending' => LocaleKeys.status_pending,
    _ => LocaleKeys.status_scheduled,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : AppColors.cardBackground;
    final accentColor = isDark ? AppColors.tealLight : AppColors.teal;
    final subtleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final statusColor = _statusColor;

    final showPendingActions =
        (onApprove != null || onReject != null) &&
        appointment.status == 'pending';

    final showApprovedActions =
        (onComplete != null || onNoShow != null) &&
        appointment.status == 'approved' &&
        appointment.isAppointmentDue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            // ── Status strip ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel.tr(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    showDate ? appointment.date : '#${appointment.number}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: subtleColor),
                  ),
                ],
              ),
            ),

            // ── Main row ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Time + date (if showDate already showing in strip)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDate)
                        Text(
                          appointment.time,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: subtleColor),
                        )
                      else
                        Text(
                          appointment.time,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: subtleColor),
                        ),
                    ],
                  ),
                  const Spacer(),
                  // Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        appointment.patientName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (appointment.symptoms.isNotEmpty == true)
                        Text(
                          appointment.symptoms,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: subtleColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isDark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    backgroundImage: appointment.patientImageUrl != null
                        ? NetworkImage(appointment.patientImageUrl!)
                        : null,
                    child: appointment.patientImageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 22,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),

            // ── Pending actions: Confirm / Reject ────────────────────
            if (showPendingActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(
                  children: [
                    if (onReject != null)
                      Expanded(
                        child: AppButton.danger(
                          text: LocaleKeys.reject_appt.tr(),
                          onPressed: onReject,
                          height: 36,
                          fontSize: 12,
                        ),
                      ),
                    if (onApprove != null && onReject != null)
                      const SizedBox(width: 8),
                    if (onApprove != null)
                      Expanded(
                        child: AppButton.primary(
                          text: LocaleKeys.confirm_appt.tr(),
                          onPressed: onApprove,
                          height: 36,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

            // ── Approved actions: Completed / No-Show ────────────────
            if (showApprovedActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(
                  children: [
                    if (onNoShow != null)
                      Expanded(
                        child: AppButton.outlined(
                          text: LocaleKeys.mark_no_show.tr(),
                          onPressed: onNoShow,
                          height: 36,
                          fontSize: 12,
                          borderColor: Colors.grey,
                          textColor: Colors.grey,
                        ),
                      ),
                    if (onComplete != null && onNoShow != null)
                      const SizedBox(width: 8),
                    if (onComplete != null)
                      Expanded(
                        child: AppButton(
                          text: LocaleKeys.mark_completed.tr(),
                          onPressed: onComplete,
                          type: AppButtonType.primary,
                          color: AppColors.success,
                          height: 36,
                          fontSize: 12,
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
