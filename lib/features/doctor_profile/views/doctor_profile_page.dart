import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/section_app_bar.dart';
import '../../auth/providers/auth_provider.dart';

class DoctorProfilePage extends ConsumerWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.tealLight : AppColors.teal;
    final cardColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : AppColors.cardBackground;
    final iconColor = isDark ? accentColor : AppColors.primary;

    return Scaffold(
      appBar: SectionAppBar(
        title: 'doctor_profile'.tr(),
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.white70 : AppColors.white,
            ),
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('error_e'.tr())),
        data: (state) {
          final user = state.currentUser;
          if (user == null) {
            return  Center(child: Text('not_logged_in'.tr()));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Doctor Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'dr_username'.tr(namedArgs: {
                              'name': user.name
                            }),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                user.specialty ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                  Icons.star, color: Colors.amber, size: 18),
                              Text(
                                '${user.rating?.toInt() ?? 0}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          isDark ? Colors.grey[700] : Colors.grey[300],
                      backgroundImage: user.imageUrl != null
                          ? NetworkImage(user.imageUrl!)
                          : null,
                      child: user.imageUrl == null
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Bio
                Text(
                  'about'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.bio ?? 'no_bio_available'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),

                const SizedBox(height: 20),

                // Schedule Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            user.workDays?.join(', ') ?? 'not_specified'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${user.workHoursStart ?? ''} - ${user.workHoursEnd ?? ''}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time, size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              user.hospitalAddress ?? '',
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Contact Info
                Text(
                  'contact_info'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(user.email,
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(width: 8),
                          Icon(Icons.mail, color: iconColor),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(user.phone,
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(width: 8),
                          Icon(Icons.phone, color: iconColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
