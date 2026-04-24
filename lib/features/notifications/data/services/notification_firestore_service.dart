import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enum/constants.dart';
import '../models/notification_model.dart';

// Firestore composite indexes required (create in Firebase Console):
//   notifications: (userId ASC, isDeleted ASC, createdAt DESC)
//   notifications: (userId ASC, isRead ASC, isDeleted ASC)

class NotificationFirestoreService {
  final _db = FirebaseFirestore.instance;

  static const int _pageSize = 20;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(Constants.notifications.name);

  // ─── Read ──────────────────────────────────────────────────────────────────

  /// Fetches one page of notifications for [userId], optionally starting after
  /// [after] for cursor-based pagination.
  Future<({List<NotificationModel> items, DocumentSnapshot? lastDoc})> getPage({
    required String userId,
    DocumentSnapshot? after,
  }) async {
    Query<Map<String, dynamic>> query = _col
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(_pageSize);

    if (after != null) query = query.startAfterDocument(after);

    final snap = await query.get();
    final items =
        snap.docs.map((d) => NotificationModel.fromJson(d.data())).toList();
    final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
    return (items: items, lastDoc: lastDoc);
  }

  /// Real-time stream of the unread-notification count for [userId].
  Stream<int> watchUnreadCount(String userId) => _col
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
      .where('isDeleted', isEqualTo: false)
      .snapshots()
      .map((s) => s.docs.length);

  // ─── Write ─────────────────────────────────────────────────────────────────

  Future<void> create(NotificationModel notification) async {
    await _col.doc(notification.id).set(notification.toJson());
  }

  /// Writes [notifications] in Firestore batches of ≤ 500 documents.
  Future<void> createBatch(List<NotificationModel> notifications) async {
    const chunkSize = 500;
    for (var i = 0; i < notifications.length; i += chunkSize) {
      final batch = _db.batch();
      final chunk = notifications.skip(i).take(chunkSize);
      for (final n in chunk) {
        batch.set(_col.doc(n.id), n.toJson());
      }
      await batch.commit();
    }
  }

  Future<void> markAsRead(String id) =>
      _col.doc(id).update({'isRead': true});

  /// Marks every unread notification for [userId] as read in a single batch.
  Future<void> markAllAsRead(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    const chunkSize = 500;
    for (var i = 0; i < snap.docs.length; i += chunkSize) {
      final batch = _db.batch();
      for (final doc in snap.docs.skip(i).take(chunkSize)) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
  }

  /// Soft-delete: sets isDeleted = true so the record can be audited later.
  Future<void> softDelete(String id) =>
      _col.doc(id).update({'isDeleted': true});

  // ─── Factory helpers ───────────────────────────────────────────────────────

  /// Creates a [NotificationModel] and persists it. Returns the model.
  Future<NotificationModel> send({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    required NotificationPriority priority,
    String? entityId,
    String? route,
    Map<String, dynamic> payload = const {},
  }) async {
    final now = DateTime.now();
    final model = NotificationModel(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      body: body,
      type: type,
      priority: priority,
      createdAt: now,
      entityId: entityId,
      route: route,
      payload: payload,
      groupKey: DateFormat('yyyy-MM-dd').format(now),
    );
    await create(model);
    log('📬 Notification sent to $userId: $title');
    return model;
  }

  /// Broadcasts [title]/[body] to every user in [userIds] as batched writes.
  Future<void> broadcast({
    required List<String> userIds,
    required String title,
    required String body,
    required NotificationType type,
    required NotificationPriority priority,
    String? route,
    Map<String, dynamic> payload = const {},
  }) async {
    if (userIds.isEmpty) return;
    final now = DateTime.now();
    final groupKey = DateFormat('yyyy-MM-dd').format(now);

    final models = userIds
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

    await createBatch(models);
    log('📢 Broadcast sent to ${userIds.length} users: $title');
  }
}
