import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';

import 'package:sample_app/app_credentials.dart';
import 'package:sample_app/screens/app_credentials_screen.dart';
import 'package:sample_app/screens/home_screen.dart';
import 'package:sample_app/screens/guard_screen.dart';

/// Global navigator key for the app.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Share the navigator key with CometChat's call overlay system
  CallNavigationContext.navigatorKey = navigatorKey;

  // Try to load saved credentials from SharedPreferences
  await AppCredentials.loadSavedCredentials();

  runApp(const SampleApp());
}

class SampleApp extends StatelessWidget {
  const SampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample App',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: AppCredentials.hasValidCredentials
          ? const SampleAppHome()
          : const AppCredentialsScreen(),
    );
  }
}

/// The main app home that initializes CometChat and shows the appropriate screen.
///
/// Separated from [SampleApp] so that [AppCredentialsScreen] can navigate
/// here after the user enters valid credentials.
class SampleAppHome extends StatefulWidget {
  const SampleAppHome({super.key});

  @override
  State<SampleAppHome> createState() => _SampleAppHomeState();
}

class _SampleAppHomeState extends State<SampleAppHome> {
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCometChat();
  }

  /// Initialize the Calls SDK for a cached (auto-login) session.
  Future<void> _initCallsSdk() async {
    await CallEventService.instance.init(
      configuration: CallingConfiguration(),
    );
  }

  Future<void> _initCometChat() async {
    try {
      final uiKitSettings = (UIKitSettingsBuilder()
            ..subscriptionType = CometChatSubscriptionType.allUsers
            ..region = AppCredentials.region
            ..autoEstablishSocketConnection = true
            ..appId = AppCredentials.appId
            ..authKey = AppCredentials.authKey
            ..enableCalls = true
            ..callingConfiguration = CallingConfiguration())
          .build();

      debugPrint('🚀 Initializing CometChat UIKit...');

      CometChatUIKit.init(
        uiKitSettings: uiKitSettings,
        onSuccess: (message) async {
          debugPrint('✅ CometChat initialized: $message');

          final cachedUser = await CometChatUIKit.getLoggedInUser();
          if (cachedUser != null) {
            await _initCallsSdk();
          }
          if (mounted) {
            setState(() {
              _isLoggedIn = cachedUser != null;
              _isInitialized = true;
            });
          }
        },
        onError: (error) {
          debugPrint(
              '❌ CometChat init error: ${error.code} - ${error.message}');
          if (mounted) setState(() => _error = error.toString());
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Exception during CometChat init: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Error: $_error',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _error = null);
                  _initCometChat();
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await AppCredentials.clearCredentials();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const AppCredentialsScreen(),
                    ),
                    (_) => false,
                  );
                },
                child: const Text('Change Credentials'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing CometChat...'),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const HomeScreen() : const GuardScreen();
  }
}
