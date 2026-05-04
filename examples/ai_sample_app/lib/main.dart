import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:ai_sample_app/app_credentials.dart';
import 'package:ai_sample_app/screens/guard_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppCredentials.loadSavedCredentials();
  runApp(const AISampleApp());
}

class AISampleApp extends StatefulWidget {
  const AISampleApp({super.key});

  @override
  State<AISampleApp> createState() => _AISampleAppState();
}

class _AISampleAppState extends State<AISampleApp> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (AppCredentials.hasValidCredentials) {
      _initCometChat();
    }
  }

  Future<void> _initCometChat() async {
    try {
      final settingsBuilder = UIKitSettingsBuilder()
        ..subscriptionType = CometChatSubscriptionType.allUsers
        ..region = AppCredentials.region
        ..autoEstablishSocketConnection = true
        ..appId = AppCredentials.appId
        ..authKey = AppCredentials.authKey;

      final uiKitSettings = settingsBuilder.build();

      CometChatUIKit.init(
        uiKitSettings: uiKitSettings,
        onSuccess: (message) {
          debugPrint('✅ CometChat initialized: $message');
          if (mounted) setState(() => _isInitialized = true);
        },
        onError: (error) {
          debugPrint('❌ CometChat init error: ${error.code} - ${error.message}');
          if (mounted) setState(() => _error = error.toString());
        },
      );
    } catch (e) {
      debugPrint('❌ Exception during CometChat init: $e');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CometChat AI Sample App',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    // No credentials — show credentials entry screen
    if (!AppCredentials.hasValidCredentials) {
      return const AppCredentialsScreen();
    }

    // Error during init
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _error = null);
                  _initCometChat();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Still initializing
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

    // Initialized — check session
    return const GuardScreen();
  }
}
