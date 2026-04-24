import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_colors.dart';
import '../pages/notifications_page.dart';
import '../providers/notifications_provider.dart';

/// Drop-in AppBar action that shows the notification bell with a live unread
/// badge. Place it in any page's [AppBar.actions].
///
/// Example:
/// ```dart
/// AppBar(actions: const [NotificationBellButton()])
/// ```
class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(
      notificationsProvider.select((s) => s.value?.unreadCount ?? 0),
    );

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => context.push(NotificationsPage.routeName),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, size: 26),
          if (unread > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                constraints:
                    const BoxConstraints(minWidth: 17, minHeight: 17),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
