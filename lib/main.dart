import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

// ── Global navigator key ───────────────────────────────────────────────────────
// Used by NotificationService to navigate on notification tap from any state.
final navigatorKey = GlobalKey<NavigatorState>();

// ── FCM background handler (must be top-level) ────────────────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  
  // Save notification to local Hive storage
  await Hive.initFlutter();
  final box = await Hive.openBox('nutripump_notifications');
  
  final notification = message.notification;
  final title = notification?.title ?? message.data['title'] ?? 'NutriPump';
  final body = notification?.body ?? message.data['body'] ?? '';
  final imageUrl = notification?.android?.imageUrl
      ?? notification?.apple?.imageUrl
      ?? message.data['imageUrl'];
  final route = message.data['deepLink'] ?? message.data['route'];
  
  final payload = {
    'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    'title': title,
    'body': body,
    'imageUrl': imageUrl,
    'route': route,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'isRead': false,
  };
  await box.put(payload['id'], payload);

  debugPrint('[FCM] Background message saved to Hive: $title');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: '.env');

  // Initialize Hive for local persistence
  await Hive.initFlutter();
  await Hive.openBox('nutripump_cart');
  await Hive.openBox('nutripump_wishlist');
  await Hive.openBox('nutripump_notifications');

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Crashlytics — catch all Flutter errors in production
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // ── Firebase Cloud Messaging setup ────────────────────────────────────────
  // Register the background handler BEFORE the app starts.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission (iOS requires explicit prompt; Android 13+ also does)
  await NotificationService.instance.requestPermission();

  // Initialise the full notification service (channels, foreground, tap-routing)
  await NotificationService.instance.init(navigatorKey: navigatorKey);

  runApp(const ProviderScope(child: NutriPumpApp()));
}

class NutriPumpApp extends ConsumerWidget {
  const NutriPumpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'NutriPump Artisanal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      builder: (context, child) {
        // Cap text scale factor at 1.0 — prevents OS accessibility
        // settings from inflating text beyond design intent.
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
