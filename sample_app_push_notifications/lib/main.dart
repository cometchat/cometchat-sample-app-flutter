import 'dart:async';
import 'dart:ui';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sample_app_push_notifications/guard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sample_app_push_notifications/utils/page_manager.dart';
import 'notifications/services/firebase_services.dart';
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

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: handleNotificationTap,
  );

  try {
    print('Firebase initialized. BEFORE TRY');
    await Firebase.initializeApp(
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
