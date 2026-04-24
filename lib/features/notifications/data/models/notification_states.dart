import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'notification_model.dart';

class NotificationsStates {
  const NotificationsStates({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.lastDocument,
  });

  factory NotificationsStates.initial() => const NotificationsStates();

  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final DocumentSnapshot? lastDocument;

  /// Visible (non-deleted) notifications sorted by priority desc → date desc,
  /// then grouped into labelled day buckets: "today", "yesterday", or a
  /// formatted date string for anything older.
  Map<String, List<NotificationModel>> get grouped {
    final visible = notifications.where((n) => !n.isDeleted).toList()
      ..sort((a, b) {
        final pc = b.priority.weight.compareTo(a.priority.weight);
        if (pc != 0) return pc;
        return b.createdAt.compareTo(a.createdAt);
      });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final map = <String, List<NotificationModel>>{};

    for (final n in visible) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      final label = d == today
          ? 'today'
          : d == yesterday
              ? 'yesterday'
              : DateFormat('MMM d, yyyy').format(n.createdAt);
      map.putIfAbsent(label, () => []).add(n);
    }
    return map;
  }

  NotificationsStates copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    DocumentSnapshot? lastDocument,
    bool clearError = false,
    bool clearLastDocument = false,
  }) {
    return NotificationsStates(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastDocument:
          clearLastDocument ? null : (lastDocument ?? this.lastDocument),
    );
  }
}
