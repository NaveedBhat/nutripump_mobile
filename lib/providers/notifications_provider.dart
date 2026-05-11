import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_notification.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final Box _box;
  StreamSubscription<BoxEvent>? _boxSub;

  NotificationsNotifier()
      : _box = Hive.box('nutripump_notifications'),
        super([]) {
    _loadNotifications();
    _boxSub = _box.watch().listen((_) => _loadNotifications());
  }

  @override
  void dispose() {
    _boxSub?.cancel();
    super.dispose();
  }

  void _loadNotifications() {
    final List<AppNotification> loaded = [];
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value is Map) {
        loaded.add(AppNotification.fromMap(value));
      }
    }
    // Sort descending by timestamp
    loaded.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = loaded;
  }

  Future<void> addNotification(AppNotification notification) async {
    await _box.put(notification.id, notification.toMap());
    _loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    final value = _box.get(id);
    if (value != null && value is Map) {
      final updated = Map.from(value)..['isRead'] = true;
      await _box.put(id, updated);
      _loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value is Map && value['isRead'] == false) {
        final updated = Map.from(value)..['isRead'] = true;
        await _box.put(key, updated);
      }
    }
    _loadNotifications();
  }

  Future<void> deleteNotification(String id) async {
    await _box.delete(id);
    _loadNotifications();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _loadNotifications();
  }
}
