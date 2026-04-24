import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum NotificationType {
  appointment,
  system,
  reminder,
  approval,
  billing;

  String toJson() => name;

  static NotificationType fromJson(String value) => NotificationType.values
      .firstWhere((e) => e.name == value, orElse: () => NotificationType.system);
}

enum NotificationPriority {
  low,
  normal,
  high,
  critical;

  String toJson() => name;

  static NotificationPriority fromJson(String value) =>
      NotificationPriority.values.firstWhere(
        (e) => e.name == value,
        orElse: () => NotificationPriority.normal,
      );

  int get weight {
    switch (this) {
      case NotificationPriority.critical:
        return 4;
      case NotificationPriority.high:
        return 3;
      case NotificationPriority.normal:
        return 2;
      case NotificationPriority.low:
        return 1;
    }
  }
}

// ─── Extensions ──────────────────────────────────────────────────────────────

extension NotificationPriorityX on NotificationPriority {
  Color get color {
    switch (this) {
      case NotificationPriority.critical:
        return AppColors.danger;
      case NotificationPriority.high:
        return AppColors.warning;
      case NotificationPriority.normal:
        return AppColors.lightTextSecondary;
      case NotificationPriority.low:
        return AppColors.tealLight;
    }
  }

  Color get surfaceColor {
    switch (this) {
      case NotificationPriority.critical:
        return const Color(0x0AE53935);
      case NotificationPriority.high:
        return const Color(0x0AFB8C00);
      case NotificationPriority.normal:
        return Colors.transparent;
      case NotificationPriority.low:
        return Colors.transparent;
    }
  }

  String get label {
    switch (this) {
      case NotificationPriority.critical:
        return 'Critical';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.low:
        return 'Low';
    }
  }
}

extension NotificationTypeX on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.appointment:
        return Icons.calendar_today_outlined;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.reminder:
        return Icons.alarm_outlined;
      case NotificationType.approval:
        return Icons.verified_user_outlined;
      case NotificationType.billing:
        return Icons.receipt_long_outlined;
    }
  }

  Color get iconColor {
    switch (this) {
      case NotificationType.appointment:
        return AppColors.teal;
      case NotificationType.system:
        return AppColors.lightTextSecondary;
      case NotificationType.reminder:
        return AppColors.warning;
      case NotificationType.approval:
        return AppColors.success;
      case NotificationType.billing:
        return AppColors.danger;
    }
  }

  /// Android channel ID per notification type for custom sounds / vibration.
  String get channelId {
    switch (this) {
      case NotificationType.appointment:
        return 'appointment_channel';
      case NotificationType.system:
        return 'system_channel';
      case NotificationType.reminder:
        return 'reminder_channel';
      case NotificationType.approval:
        return 'approval_channel';
      case NotificationType.billing:
        return 'billing_channel';
    }
  }
}

// ─── Model ───────────────────────────────────────────────────────────────────

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
    this.isDeleted = false,
    this.entityId,
    this.route,
    this.payload = const {},
    this.groupKey,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        type: NotificationType.fromJson(json['type'] as String? ?? 'system'),
        priority: NotificationPriority.fromJson(
          json['priority'] as String? ?? 'normal',
        ),
        isRead: json['isRead'] as bool? ?? false,
        isDeleted: json['isDeleted'] as bool? ?? false,
        createdAt:
            (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        entityId: json['entityId'] as String?,
        route: json['route'] as String?,
        payload: (json['payload'] as Map<String, dynamic>?) ?? {},
        groupKey: json['groupKey'] as String?,
      );

  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final String? entityId;
  final String? route;
  final Map<String, dynamic> payload;
  final String? groupKey;
  final bool isDeleted;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type.toJson(),
        'priority': priority.toJson(),
        'isRead': isRead,
        'isDeleted': isDeleted,
        'createdAt': Timestamp.fromDate(createdAt),
        'entityId': entityId,
        'route': route,
        'payload': payload,
        'groupKey': groupKey,
      };

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    bool? isDeleted,
    DateTime? createdAt,
    String? entityId,
    String? route,
    Map<String, dynamic>? payload,
    String? groupKey,
  }) =>
      NotificationModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        body: body ?? this.body,
        type: type ?? this.type,
        priority: priority ?? this.priority,
        isRead: isRead ?? this.isRead,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        entityId: entityId ?? this.entityId,
        route: route ?? this.route,
        payload: payload ?? this.payload,
        groupKey: groupKey ?? this.groupKey,
      );
}
