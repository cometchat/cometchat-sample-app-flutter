import 'dart:async';
import 'dart:ui';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart' as cc;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:sample_app_push_notifications/guard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sample_app_push_notifications/utils/page_manager.dart';
import 'firebase_options.dart';
import 'notifications/services/android_notification_service/local_notification_handler.dart';
import 'prefs/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesClass.init();
  Get.put(PageManager());

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings());

  await LocalNotificationService.flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        LocalNotificationService.handleNotificationTap,
  );

  // Check for notification launch in terminated state
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await LocalNotificationService.flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();

  final didNotificationLaunchApp =
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;

  if (didNotificationLaunchApp &&
      notificationAppLaunchDetails?.notificationResponse != null) {
    // Manually trigger tap handler
    LocalNotificationService.handleNotificationTap(
      notificationAppLaunchDetails?.notificationResponse,
      isTerminatedState: true,
    );
  }

  try {
    print('Firebase initialized. BEFORE TRY');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully.');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale('en'),
        Locale('en', 'GB'),
        Locale('ar'),
        Locale('de'),
        Locale('es'),
        Locale('fr'),
        Locale('hi'),
        Locale('hu'),
        Locale('ja'),
        Locale('ko'),
        Locale('lt'),
        Locale('ms'),
        Locale('nl'),
        Locale('pt'),
        Locale('ru'),
        Locale('sv'),
        Locale('tr'),
        Locale('zh'),
        Locale('zh', 'TW'),
      ],
      localizationsDelegates: const [
        cc.Translations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          scrolledUnderElevation: 0.0,
        ),
      ),
      title: 'CometChat Flutter Sample App',
      navigatorKey: CallNavigationContext.navigatorKey,
      home: GuardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
