import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/section_app_bar.dart';
import '../../auth/providers/auth_provider.dart';

class PatientProfilePage extends ConsumerWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final accentColor = isDark ? AppColors.tealLight : AppColors.teal;
    final cardColor = isDark ? colorScheme.surfaceContainerHighest : AppColors.cardBackground;
    final iconColor = isDark ? accentColor : AppColors.primary;
    final subtleTextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      appBar: SectionAppBar(
        title: 'my_account'.tr(),
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings, color: isDark ? Colors.white70 : AppColors.white),
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
                const SizedBox(height: 16),
                // Avatar + Name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                        backgroundImage: user.imageUrl != null
                            ? NetworkImage(user.imageUrl!)
                            : null,
                        child: user.imageUrl == null
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

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

                const SizedBox(height: 24),

                // Medical History section placeholder
                Text(
                  'medical_history'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'no_medical_history_yet'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: subtleTextColor,
                        ),
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
