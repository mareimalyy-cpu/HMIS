import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/enum/constants.dart';
import '../../../../core/local_services/local_storage.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../data/models/notification_states.dart';
import '../../data/services/notification_firestore_service.dart';

part 'generated/notifications_provider.g.dart';

@Riverpod(keepAlive: true)
class NotificationsNotifier extends _$NotificationsNotifier {
  late final NotificationFirestoreService _service;
  StreamSubscription<int>? _unreadSub;
  String? _userId;

  @override
  Future<NotificationsStates> build() async {
    _service = NotificationFirestoreService();
    _userId = _resolveUserId();

    if (_userId == null || _userId!.isEmpty) {
      return NotificationsStates.initial();
    }

    // Start real-time unread-count stream independently of pagination.
    _unreadSub?.cancel();
    _unreadSub = _service.watchUnreadCount(_userId!).listen(
      (count) {
        final current = state.value;
        if (current != null) {
          state = AsyncData(current.copyWith(unreadCount: count));
        }
      },
      onError: (e) => log('Unread count stream error: $e'),
    );
    ref.onDispose(() => _unreadSub?.cancel());

    // Fetch first page.
    final result = await _service.getPage(userId: _userId!);
    return NotificationsStates(
      notifications: result.items,
      lastDocument: result.lastDoc,
      hasMore: result.items.length >= 20,
    );
  }

  // ─── Pagination ────────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final result = await _service.getPage(
        userId: _userId!,
        after: current.lastDocument,
      );
      state = AsyncData(
        (state.value ?? NotificationsStates.initial()).copyWith(
          notifications: [...current.notifications, ...result.items],
          lastDocument: result.lastDoc,
          hasMore: result.items.length >= 20,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncData(
        (state.value ?? NotificationsStates.initial()).copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    if (_userId == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _service.getPage(userId: _userId!);
      return NotificationsStates(
        notifications: result.items,
        lastDocument: result.lastDoc,
        hasMore: result.items.length >= 20,
      );
    });
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        notifications: current.notifications
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList(),
      ),
    );
  }

  Future<void> markAllAsRead() async {
    if (_userId == null) return;
    await _service.markAllAsRead(_userId!);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        notifications:
            current.notifications.map((n) => n.copyWith(isRead: true)).toList(),
        unreadCount: 0,
      ),
    );
  }

  Future<void> deleteNotification(String id) async {
    await _service.softDelete(id);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        notifications: current.notifications
            .map((n) => n.id == id ? n.copyWith(isDeleted: true) : n)
            .toList(),
      ),
    );
  }

  // ─── Private ───────────────────────────────────────────────────────────────

  String? _resolveUserId() {
    final raw = LocalStorage.instance.get(Constants.userData.name);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      return UserModel.fromJson(map).id;
    } catch (e) {
      log('Could not resolve user ID for notifications: $e');
      return null;
    }
  }
}

// Shell pages read the unread count with:
//   ref.watch(notificationsNotifierProvider.select((s) => s.value?.unreadCount ?? 0))
