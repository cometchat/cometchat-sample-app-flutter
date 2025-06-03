import 'dart:async';
import 'dart:ui';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_app/guard_screen.dart';
import 'package:sample_app/utils/page_manager.dart';
import 'prefs/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesClass.init();
  Get.put(PageManager());

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
