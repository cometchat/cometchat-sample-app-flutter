import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';
import 'package:ai_sample_app/app_credentials.dart';
import 'package:ai_sample_app/screens/guard_screen.dart';
import 'package:ai_sample_app/screens/app_credentials_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CallNavigationContext.navigatorKey = navigatorKey;
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
  bool _isLoggedIn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (AppCredentials.hasValidCredentials) {
      _initCometChat();
    } else {
      setState(() => _isInitialized = true);
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
      CometChatUIKit.init(
        uiKitSettings: settingsBuilder.build(),
        onSuccess: (message) async {
          final cachedUser = await CometChatUIKit.getLoggedInUser();
          if (mounted) setState(() {
            _isLoggedIn = cachedUser != null;
            _isInitialized = true;
          });
        },
        onError: (error) {
          if (mounted) setState(() => _error = error.toString());
        },
      );
    } catch (e) {
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_error != null) {
      return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text('Error: $_error'),
        ElevatedButton(onPressed: _initCometChat, child: const Text('Retry')),
      ])));
    }
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!AppCredentials.hasValidCredentials) {
      return const AppCredentialsScreen();
    }
    return _isLoggedIn ? const GuardScreen() : const GuardScreen();
  }
}
