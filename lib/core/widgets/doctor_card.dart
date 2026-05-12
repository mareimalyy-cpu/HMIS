import 'package:flutter/material.dart';

import '../../features/auth/data/models/user_model.dart';
import '../themes/app_colors.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({required this.doctor, super.key, this.onTap});

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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: avatarBgColor,
          backgroundImage: doctor.imageUrl != null
              ? NetworkImage(doctor.imageUrl!)
              : null,
          child: doctor.imageUrl == null
              ? const Icon(Icons.person, size: 28, color: Colors.white)
              : null,
        ),
        title: Text(
          doctor.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          doctor.specialty ?? '',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: subtleColor),
        ),
        trailing: onTap == null
            ? null
            : Icon(Icons.chevron_right, color: subtleColor),
      ),
    );
  }
}
