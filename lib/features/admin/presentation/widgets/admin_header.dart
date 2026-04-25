import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../settings/presentation/screens/settings_page.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../gen/assets.gen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/widgets/notification_bell_button.dart';

class AdminHeader extends ConsumerWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value?.currentUser;
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'ar').format(now);
    final dateStr = '${now.day}-${now.month}-${now.year}';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                const NotificationBellButton(),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user?.name ?? 'المدير',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Admin',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.push(SettingsPage.routeName),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.cardBackground,
                    backgroundImage: user?.imageUrl != null
                        ? NetworkImage(user!.imageUrl!)
                        : null,
                    child: user?.imageUrl == null
                        ? const Icon(Icons.person, size: 28, color: Colors.grey)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 6),
                Text(
                  dayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
