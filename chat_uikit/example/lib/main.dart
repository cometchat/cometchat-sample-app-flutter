import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// Credentials from https://app.cometchat.com. Pass them at run time:
///
///   flutter run --dart-define=APP_ID=xxx --dart-define=REGION=us \
///               --dart-define=AUTH_KEY=xxx
const appId = String.fromEnvironment('APP_ID');
const region = String.fromEnvironment('REGION');
const authKey = String.fromEnvironment('AUTH_KEY');

/// The user to log in as. Every CometChat app ships with a `cometchat-uid-1`
/// test user.
const uid = String.fromEnvironment('UID', defaultValue: 'cometchat-uid-1');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings =
      (UIKitSettingsBuilder()
            ..appId = appId
            ..region = region
            ..authKey = authKey
            ..subscriptionType = CometChatSubscriptionType.allUsers
            ..autoEstablishSocketConnection = true)
          .build();

  await CometChatUIKit.init(
    uiKitSettings: settings,
    onError: (e) => debugPrint('CometChat init failed: ${e.message}'),
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CometChat UI Kit Example',
      // Required: the UI Kit's widgets read their strings from here.
      localizationsDelegates: Translations.localizationsDelegates,
      home: LoginGate(),
    );
  }
}

/// Logs the user in, then hands off to the conversation list. `login` uses the
/// auth key and is intended for prototyping only — in production, authenticate
/// on your server and call [CometChatUIKit.loginWithAuthToken].
class LoginGate extends StatefulWidget {
  const LoginGate({super.key});

  @override
  State<LoginGate> createState() => _LoginGateState();
}

class _LoginGateState extends State<LoginGate> {
  String? _error;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _login();
  }

  Future<void> _login() async {
    await CometChatUIKit.login(
      uid,
      onSuccess: (user) {
        if (mounted) setState(() => _busy = false);
      },
      onError: (e) {
        if (mounted) setState(() => _error = e.message ?? 'Login failed');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }
    if (_busy) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const ConversationsScreen();
  }
}

/// Drops in the conversation list. Tapping a row opens that chat.
class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CometChatConversations(
          onItemTap: (conversation) {
            final target = conversation.conversationWith;
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MessagesScreen(
                  user: target is User ? target : null,
                  group: target is Group ? target : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A complete chat screen: header, message list and composer.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key, this.user, this.group});

  final User? user;
  final Group? group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CometChatMessageHeader(user: user, group: group),
            Expanded(
              child: CometChatMessageList(user: user, group: group),
            ),
            CometChatMessageComposer(user: user, group: group),
          ],
        ),
      ),
    );
  }
}
