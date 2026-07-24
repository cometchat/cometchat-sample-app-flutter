import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

// Replace these placeholders with your own credentials from the
// CometChat Dashboard: https://app.cometchat.com/
const String _appId = 'YOUR_APP_ID';
const String _region = 'YOUR_REGION'; // e.g. 'us', 'eu', 'in'
const String _authKey = 'YOUR_AUTH_KEY';
const String _uid = 'cometchat-uid-1'; // a sample user in your app

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final uiKitSettings = (UIKitSettingsBuilder()
        ..subscriptionType = CometChatSubscriptionType.allUsers
        ..region = _region
        ..autoEstablishSocketConnection = true
        ..appId = _appId
        ..authKey = _authKey)
      .build();

  CometChatUIKit.init(
    uiKitSettings: uiKitSettings,
    onSuccess: (_) {
      CometChatUIKit.login(
        _uid,
        onSuccess: (user) => debugPrint('Logged in as ${user.uid}'),
        onError: (e) => debugPrint('CometChat login failed: $e'),
      );
    },
    onError: (e) => debugPrint('CometChat UI Kit init failed: $e'),
  );

  runApp(const CometChatExampleApp());
}

class CometChatExampleApp extends StatelessWidget {
  const CometChatExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CometChat UI Kit Example',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: Translations.localizationsDelegates,
      supportedLocales: Translations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(title: const Text('Conversations')),
        body: const SafeArea(child: CometChatConversations()),
      ),
    );
  }
}
