import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../../features/auth/data/models/user_model.dart';

class DoctorCard extends StatelessWidget {

  const DoctorCard({
    required this.doctor, super.key,
    this.onTap,
  });
  final UserModel doctor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = isDark
        ? colorScheme.surfaceContainerHighest
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
            
            // Name & Specialty
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  doctor.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  doctor.specialty ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: subtleColor,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: avatarBgColor,
              backgroundImage: doctor.imageUrl != null
                  ? NetworkImage(doctor.imageUrl!)
                  : null,
              child: doctor.imageUrl == null
                  ? const Icon(Icons.person, size: 28, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
