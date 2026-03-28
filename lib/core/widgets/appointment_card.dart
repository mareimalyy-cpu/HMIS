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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Number or Date
            Text(
              showDate ? appointment.date : '#${appointment.number}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
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
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  appointment.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[300],
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
