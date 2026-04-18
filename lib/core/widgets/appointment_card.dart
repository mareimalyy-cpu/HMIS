import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../../features/booking/models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final bool showDate;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : AppColors.cardBackground;
    final accentColor = isDark ? AppColors.tealLight : AppColors.teal;
    final subtleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final avatarBgColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Number or Date
            Text(
              showDate ? appointment.date : '#${appointment.number}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subtleColor,
                  ),
            ),
            const Spacer(),
            // Name & Time
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
                Text(
                  appointment.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: subtleColor,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: avatarBgColor,
              backgroundImage: appointment.patientImageUrl != null
                  ? NetworkImage(appointment.patientImageUrl!)
                  : null,
              child: appointment.patientImageUrl == null
                  ? const Icon(Icons.person, size: 24, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
