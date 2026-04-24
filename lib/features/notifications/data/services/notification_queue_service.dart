import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enum/constants.dart';
import '../models/notification_model.dart';
import 'notification_firestore_service.dart';

/// Client-side queue for high-load broadcasts.
///
/// Enqueue writes a lightweight job document to [Constants.notificationQueue].
/// [processQueue] reads pending jobs in batches, fans them out to individual
/// notification documents, and marks each job completed/failed with exponential
/// backoff (max 3 retries, up to 5-minute delay).
class NotificationQueueService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _queue =>
      _db.collection(Constants.notificationQueue.name);

  // ─── Enqueue ───────────────────────────────────────────────────────────────

  Future<void> enqueue({
    required String title,
    required String body,
    required NotificationType type,
    required NotificationPriority priority,
    List<String>? targetUserIds,
    String? route,
    Map<String, dynamic> payload = const {},
  }) async {
    final id = const Uuid().v4();
    await _queue.doc(id).set({
      'id': id,
      'title': title,
      'body': body,
      'type': type.toJson(),
      'priority': priority.toJson(),
      'targetUserIds': targetUserIds,
      'route': route,
      'payload': payload,
      'status': 'pending',
      'attempts': 0,
      'lastError': null,
      'processedAt': null,
      'nextRetryAt': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    log('📥 Notification queued: $title (targets: ${targetUserIds?.length ?? 'all'})');
  }

  // ─── Process ───────────────────────────────────────────────────────────────

  /// Call this from the admin flow.  [allUserIds] is only used for jobs where
  /// [targetUserIds] is null (i.e. broadcast-to-all).
  Future<void> processQueue({
    required List<String> allUserIds,
    required NotificationFirestoreService notificationService,
  }) async {
    final now = Timestamp.now();
    final snap = await _queue
        .where('status', isEqualTo: 'pending')
        .where('nextRetryAt', isLessThanOrEqualTo: now)
        .limit(10)
        .get();

    for (final doc in snap.docs) {
      await _processItem(
        doc: doc,
        allUserIds: allUserIds,
        notificationService: notificationService,
      );
    }
  }

  Future<void> _processItem({
    required QueryDocumentSnapshot<Map<String, dynamic>> doc,
    required List<String> allUserIds,
    required NotificationFirestoreService notificationService,
  }) async {
    final data = doc.data();
    final attempts = (data['attempts'] as int? ?? 0);

    try {
      await doc.reference.update({'status': 'processing', 'attempts': attempts + 1});

      final targetIds =
          (data['targetUserIds'] as List?)?.cast<String>() ?? allUserIds;
      final title = data['title'] as String;
      final body = data['body'] as String;
      final type = NotificationType.fromJson(data['type'] as String);
      final priority = NotificationPriority.fromJson(data['priority'] as String);
      final payload = (data['payload'] as Map<String, dynamic>?) ?? {};
      final route = data['route'] as String?;
      final now = DateTime.now();
      final groupKey = DateFormat('yyyy-MM-dd').format(now);

      final models = targetIds
          .map(
            (uid) => NotificationModel(
              id: const Uuid().v4(),
              userId: uid,
              title: title,
              body: body,
              type: type,
              priority: priority,
              createdAt: now,
              route: route,
              payload: payload,
              groupKey: groupKey,
            ),
          )
          .toList();

      await notificationService.createBatch(models);

      await doc.reference.update({
        'status': 'completed',
        'processedAt': FieldValue.serverTimestamp(),
      });

      log('✅ Queue job completed: $title → ${targetIds.length} users');
    } catch (e) {
      final nextAttempt = attempts + 1;
      final backoffSeconds = math.min(300, 30 * math.pow(2, attempts).toInt());
      final nextRetry = DateTime.now().add(Duration(seconds: backoffSeconds));

      final isFailed = nextAttempt >= 3;
      await doc.reference.update({
        'status': isFailed ? 'failed' : 'pending',
        'lastError': e.toString(),
        'nextRetryAt': Timestamp.fromDate(nextRetry),
      });

      log('❌ Queue job failed (attempt $nextAttempt): $e');
    }
  }
}
