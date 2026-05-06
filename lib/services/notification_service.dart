// lib/services/notification_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Full notification management:
//   • Foreground: shows heads-up system notification via flutter_local_notifications
//   • Background & Terminated: FCM shows notification natively (no code needed)
//   • Tap routing: navigates to the correct screen based on message.data['route']
//   • Token management: saves FCM token to Firestore on auth state change
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── Singleton ─────────────────────────────────────────────────────────────────
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fln = FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;

  /// Must be called in `main()` after Firebase.initializeApp()
  Future<void> init({required GlobalKey<NavigatorState> navigatorKey}) async {
    _navigatorKey = navigatorKey;

    // ── Android notification channel ─────────────────────────────────────────
    const channel = AndroidNotificationChannel(
      'nutripump_high_importance', // channel id
      'NutriPump Notifications',   // channel name
      description: 'Order updates, promotions & alerts from NutriPump.',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin = _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);

    // ── Initialise flutter_local_notifications ───────────────────────────────
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false, // we'll request via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _fln.initialize(
      const InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsIOS,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // ── FCM: override the default channel on Android ──────────────────────────
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── Print the FCM token to the console for testing ────────────────────────
    try {
      final token = await _messaging.getToken();
      debugPrint('\n======================================================');
      debugPrint('🔥 FCM DEVICE TOKEN:');
      debugPrint(token);
      debugPrint('======================================================\n');
    } catch (e) {
      debugPrint('[FCM] Could not get token (expected on iOS Simulator): $e');
    }

    // ── Foreground message handler ────────────────────────────────────────────
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // ── Background tap handler ────────────────────────────────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // ── Terminated-state tap handler ─────────────────────────────────────────
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);

    // ── Subscribe to broadcast topic ─────────────────────────────────────────
    // All devices subscribe to 'all_users' so the admin can broadcast without
    // querying Firestore for individual FCM tokens.
    try {
      await _messaging.subscribeToTopic('all_users');
      debugPrint('[FCM] Subscribed to topic: all_users');
    } catch (e) {
      debugPrint('[FCM] Failed to subscribe to topic: $e');
    }
  }

  // ── Navigator key (set by main) ───────────────────────────────────────────
  GlobalKey<NavigatorState>? _navigatorKey;

  // ── Token refresh subscription (stored to prevent leaks) ──────────────────
  StreamSubscription<String>? _tokenRefreshSub;

  // ── Token ─────────────────────────────────────────────────────────────────
  /// Call this after a user signs in to persist the token in Firestore.
  Future<void> saveTokenForUser(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'fcmToken': token, 'fcmUpdatedAt': FieldValue.serverTimestamp()},
              SetOptions(merge: true));
      debugPrint('[FCM] Token saved for $uid');

      // Cancel any previous refresh listener before attaching a new one
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'fcmToken': newToken, 'fcmUpdatedAt': FieldValue.serverTimestamp()},
                SetOptions(merge: true));
        debugPrint('[FCM] Token refreshed for $uid');
      });
    } catch (e) {
      debugPrint('[FCM] Failed to save token: $e');
    }
  }

  // ── Foreground heads-up notification ──────────────────────────────────────
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'NutriPump';
    final body = notification?.body ?? message.data['body'] ?? '';
    // Check platform-specific image first, then fall back to data payload.
    // The top-level notification.imageUrl does not exist in this SDK version.
    final imageUrl = notification?.android?.imageUrl
        ?? notification?.apple?.imageUrl
        ?? message.data['imageUrl'];
    final route = message.data['deepLink'] ?? message.data['route'];

    debugPrint('[FCM] Foreground message — title: $title, body: $body, image: $imageUrl');

    // ── Save to local history ────────────────────────────────────────────────
    final payload = {
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'route': route,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isRead': false,
    };
    try {
      await Hive.box('nutripump_notifications').put(payload['id'], payload);
    } catch (e) {
      debugPrint('[FCM] Failed to save notification history: $e');
    }

    StyleInformation styleInfo = BigTextStyleInformation(body);

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await Dio().get<List<int>>(imageUrl,
          options: Options(responseType: ResponseType.bytes));
        final file = File('${Directory.systemTemp.path}/fcm_img_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.data!);
        styleInfo = BigPictureStyleInformation(
          FilePathAndroidBitmap(file.path),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          contentTitle: title,
          summaryText: body,
        );
      } catch (e) {
        debugPrint('[FCM] Failed to download image for notification: $e');
      }
    }

    await _fln.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'nutripump_high_importance',
          'NutriPump Notifications',
          channelDescription: 'Order updates, promotions & alerts.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // Rich notification: show large icon for NutriPump branding
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: styleInfo,
          color: const Color(0xFFD4A843), // NutriPump primary
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // Encode the route so tap handler can navigate
      payload: message.data['deepLink'] ?? message.data['route'],
    );
  }

  // ── Notification tap → navigate ───────────────────────────────────────────
  void _onNotificationTap(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty) {
      _navigate(route);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final route = message.data['deepLink'] ?? message.data['route'];
    if (route != null && route.isNotEmpty) {
      _navigate(route);
    } else {
      // Default: open the in-app notification inbox
      _navigate('/notifications');
    }
  }

  void _navigate(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // GoRouter uses appRouter globally for path-based routing
      if (_navigatorKey?.currentContext != null) {
        // Deep link push using GoRouter
        GoRouter.of(_navigatorKey!.currentContext!).push(route);
      }
    });
  }

  // ── Request permissions ───────────────────────────────────────────────────
  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }
}
