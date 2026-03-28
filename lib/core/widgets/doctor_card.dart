import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../../features/auth/models/user_model.dart';

class DoctorCard extends StatelessWidget {
  final UserModel doctor;
  final VoidCallback? onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
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
            // Rating
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor.rating?.toInt() ?? 0}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Name & Specialty
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  doctor.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  doctor.specialty ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
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
