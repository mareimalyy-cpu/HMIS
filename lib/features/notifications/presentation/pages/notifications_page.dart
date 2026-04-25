import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_empty_state.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  static const routeName = '/notifications';

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 250) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(notificationsProvider);

    ref.listen(notificationsProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        actions: [
          asyncState.maybeWhen(
            data: (s) => s.unreadCount > 0
                ? TextButton(
                    onPressed: () => ref
                        .read(notificationsProvider.notifier)
                        .markAllAsRead(),
                    child: const Text('Mark all read'),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          log('Failed to load notifications: $e');
          return Center(
            child: Text(
              'Failed to load notifications: $e',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
          );
        },
        data: (state) {
          final grouped = state.grouped;

          return RefreshIndicator(
            color: AppColors.teal,
            onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
            child: grouped.isEmpty && !state.isLoading
                ? const CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(child: NotificationEmptyState()),
                    ],
                  )
                : CustomScrollView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      for (final entry in grouped.entries) ...[
                        SliverToBoxAdapter(
                          child: _DayHeader(label: _resolveLabel(entry.key)),
                        ),
                        SliverList.builder(
                          itemCount: entry.value.length,
                          itemBuilder: (context, i) {
                            final n = entry.value[i];
                            return NotificationCard(
                              notification: n,
                              onTap: () => _handleTap(n),
                              onDismiss: () => ref
                                  .read(notificationsProvider.notifier)
                                  .deleteNotification(n.id),
                            );
                          },
                        ),
                      ],
                      if (state.isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.teal,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      if (!state.hasMore && grouped.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                "You've seen all notifications",
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.lightTextSecondary,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      // Bottom safe-area padding
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
          );
        },
      ),
    );
  }

  String _resolveLabel(String key) {
    if (key == 'today') return 'Today';
    if (key == 'yesterday') return 'Yesterday';
    return key;
  }

  void _handleTap(NotificationModel notification) {
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }
    final route = notification.route;
    if (route == null || route.isEmpty) return;
    final payload = notification.payload;
    if (payload.isNotEmpty) {
      context.go(route, extra: payload);
    } else {
      context.go(route);
    }
  }
}

// ─── Day header ───────────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
