---
name: cometchat-flutter-v5-uikit
description: >
  Use when building chat with CometChat Flutter UIKit v5 (cometchat_chat_uikit v5.2.14,
  cometchat_calls_uikit v5.0.15). Orchestrator skill that routes to feature-specific skills.
  Triggers on CometChatUIKit, CometChatConversations, CometChatMessageList,
  CometChatMessageComposer, CometChatMessageHeader, CometChatUsers, CometChatGroups,
  UIKitSettings, CometChatThemeHelper, CometChatColorPalette, CometChatCallButtons,
  CometChatTextBubble, CometChatImageBubble, CometChatMentionsFormatter,
  ERR_ALREADY_LOGGED_IN, ERR_INVALID_REGION, authentication null. Also for adding chat
  to Flutter, customizing bubbles, theming, real-time messages. Use whenever user mentions
  CometChat v5 or says "chat UI" with v5 packages.
license: "MIT"
compatibility: "cometchat_chat_uikit ^5.2.14; cometchat_calls_uikit ^5.0.15; cometchat_uikit_shared ^5.2.3; cometchat_sdk ^4.1.0; get ^4.6.5"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter v5 chat uikit messaging conversations getx"
---

# CometChat Flutter UIKit v5 — Orchestrator

Entry point skill for the CometChat UIKit v5 packages. Routes to feature skills based on context.

## Project Detection

Confirm the project uses CometChat UIKit v5 by checking `pubspec.yaml` for:

```yaml
dependencies:
  cometchat_chat_uikit: ^5.2.14
  cometchat_calls_uikit: ^5.0.15  # Optional, for calling features
```

Or if using the shared package directly:
```yaml
dependencies:
  cometchat_uikit_shared: ^5.2.3
```

The v5 uses **separate packages** (unlike v6 which bundles everything):
- `cometchat_chat_uikit` — Chat UI components (conversations, messages, users, groups)
- `cometchat_calls_uikit` — Call UI components (call buttons, incoming/outgoing/ongoing call, call logs)
- `cometchat_uikit_shared` — Shared utilities (theme, events, formatters, models, views)

Import everything from the calls package (it re-exports chat + shared + SDK):
```dart
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
```

Or if not using calls:
```dart
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
```

## Key v5 vs v6 Differences

| Aspect | v5 | v6 |
|--------|----|----|
| State management | GetX (GetBuilder, GetxController) | BLoC (Bloc, Equatable) |
| Packages | Separate (chat_uikit + calls_uikit) | Single (cometchat_chat_uikit) |
| Login | `CometChatUIKit.login('uid')` (String) | `CometChatUIKit.login('uid')` |
| Controllers | `Get.put()` internally | ServiceLocator pattern |
| Style resolution | `ThemeExtension` + `merge()` | `ThemeExtension` + `merge()` |
| SDK | `cometchat_sdk ^4.1.0` | `cometchat_sdk ^5.0.0` |

## Skill Routing

| User mentions | Route to skill |
|---------------|---------------|
| init, login, logout, UIKitSettings, setup, credentials, appId, region, GetX, GetBuilder | `cometchat-flutter-v5-core` |
| theme, colors, dark mode, styling, CometChatColorPalette, CometChatSpacing, typography, Style class, merge() | `cometchat-flutter-v5-theming` |
| conversations, conversation list, recent chats, CometChatConversationsController | `cometchat-flutter-v5-conversations` |
| messages, message list, composer, header, keyboard, rich text, bubbles, send message, threaded | `cometchat-flutter-v5-messages` |
| users, groups, group members, contacts, user list, CometChatChangeScope | `cometchat-flutter-v5-users-groups` |
| calls, voice call, video call, CometChatCallButtons, incoming call, outgoing call, ongoing call, call logs, CallingConfiguration, CometChatUIKitCalls | `cometchat-flutter-v5-calls` |
| events, listeners, real-time, typing indicator, online status, receipts, SDK listener | `cometchat-flutter-v5-events` |

## Architecture Overview

The UIKit v5 follows a **GetX controller pattern**:

```
{component}/
├── cometchat_{component}.dart              # StatefulWidget
├── cometchat_{component}_controller.dart   # extends GetxController
├── cometchat_{component}_style.dart        # ThemeExtension with merge()
└── {component}_builder_protocol.dart       # Request builder protocol
```

Components manage their own GetX controllers internally:
- `Get.put()` in `initState()` with a unique tag
- `Get.delete()` in `dispose()` (unless `controllerTag` is externally provided)
- `GetBuilder` in `build()` for reactive UI

## Package Structure

```
cometchat_chat_uikit/lib/
├── cometchat_chat_uikit.dart           # Main barrel export
├── src/
│   ├── conversations/                  # CometChatConversations
│   ├── message_list/                   # CometChatMessageList
│   ├── message_composer/               # CometChatMessageComposer
│   ├── compact_message_composer/       # CometChatCompactMessageComposer
│   ├── message_header/                 # CometChatMessageHeader
│   ├── threaded_header/                # CometChatThreadedHeader
│   ├── users/                          # CometChatUsers
│   ├── groups/                         # CometChatGroups
│   ├── group_members/                  # CometChatGroupMembers, CometChatChangeScope
│   ├── search/                         # CometChatSearch
│   ├── message_information/            # CometChatMessageInformation
│   ├── ai/                             # AI features
│   ├── ai_assistant_chat_history/      # AI assistant chat history
│   └── extensions/                     # Extensions

cometchat_calls_uikit/lib/
├── cometchat_calls_uikit.dart          # Barrel (re-exports shared + SDK)
├── src/
│   ├── call_buttons/                   # CometChatCallButtons
│   ├── call_bubble/                    # CometChatCallBubble
│   ├── call_logs/                      # CometChatCallLogs
│   ├── call_settings/                  # CometChatUIKitCalls, CallNavigationContext
│   ├── incoming_call/                  # CometChatIncomingCall
│   ├── outgoing_call/                  # CometChatOutgoingCall
│   ├── ongoing_call/                   # CometChatOngoingCall
│   └── utils/                          # Call utilities

cometchat_uikit_shared/lib/
├── cometchat_uikit_shared.dart         # Shared barrel export
├── src/
│   ├── cometchat_ui_kit/               # CometChatUIKit, UIKitSettings
│   ├── theme/                          # Colors, Spacing, Typography, ThemeHelper
│   ├── events/                         # All event classes
│   ├── formatter/                      # Text formatters (mentions, etc.)
│   ├── views/                          # Shared views (avatar, badge, date, etc.)
│   └── models/                         # Shared models
```

## Golden Path — Minimal Chat App (v5)

```dart
import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';

const String appId = 'YOUR_APP_ID';
const String region = 'us';
const String authKey = 'YOUR_AUTH_KEY';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initializing = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _initCometChat();
  }

  void _initCometChat() {
    final settings = (UIKitSettingsBuilder()
          ..appId = appId
          ..region = region
          ..authKey = authKey
          ..subscriptionType = CometChatSubscriptionType.allUsers
          ..callingExtension = CometChatCallingExtension())
        .build();

    CometChatUIKit.init(
      uiKitSettings: settings,
      onSuccess: (_) {
        setState(() {
          _loggedIn = CometChatUIKit.loggedInUser != null;
          _initializing = false;
        });
      },
      onError: (e) {
        debugPrint('Init failed: ${e.message}');
        setState(() => _initializing = false);
      },
    );
  }

  void _onLoginSuccess() => setState(() => _loggedIn = true);
  void _onLogout() => setState(() => _loggedIn = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: CallNavigationContext.navigatorKey,
      home: _initializing
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _loggedIn
              ? HomeScreen(onLogout: _onLogout)
              : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _uidController = TextEditingController();
  bool _loggingIn = false;
  String? _error;

  void _login() {
    final uid = _uidController.text.trim();
    if (uid.isEmpty) return;
    setState(() { _loggingIn = true; _error = null; });

    CometChatUIKit.login(uid,
      onSuccess: (_) {
        if (mounted) widget.onLoginSuccess();
      },
      onError: (e) {
        if (mounted) setState(() { _loggingIn = false; _error = e.message; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _uidController,
              decoration: const InputDecoration(labelText: 'User ID'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loggingIn ? null : _login,
              child: _loggingIn
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              CometChatUIKit.logout(
                onSuccess: (_) => onLogout(),
                onError: (e) => debugPrint('Logout failed: ${e.message}'),
              );
            },
          ),
        ],
      ),
      body: CometChatConversations(
        onItemTap: (conversation) {
          final user = conversation.conversationWith is User
              ? conversation.conversationWith as User
              : null;
          final group = conversation.conversationWith is Group
              ? conversation.conversationWith as Group
              : null;
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => MessagesScreen(user: user, group: group),
          ));
        },
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  final User? user;
  final Group? group;
  const MessagesScreen({super.key, this.user, this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // REQUIRED
      appBar: CometChatMessageHeader(
        user: user,
        group: group,
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          Expanded(child: CometChatMessageList(user: user, group: group)),
          CometChatMessageComposer(user: user, group: group),
        ],
      ),
    );
  }
}
```

Key points:
- Import from `package:cometchat_calls_uikit/cometchat_calls_uikit.dart`
- `CometChatUIKit.login(uid)` takes a String directly
- `CometChatUIKit.loggedInUser` checked synchronously after `init()`
- `CallNavigationContext.navigatorKey` set on MaterialApp
- `CometChatCallingExtension()` set on UIKitSettingsBuilder
- `resizeToAvoidBottomInset: false` on messages Scaffold

## Autonomous Mode

- If `pubspec.yaml` has `cometchat_chat_uikit` v5.x or `cometchat_calls_uikit` v5.x → proceed without asking
- If credentials exist in code → reuse them
- If user says "messages screen" → generate Scaffold + Header + List + Composer with `resizeToAvoidBottomInset: false`
- Always add `subscriptionType` to UIKitSettingsBuilder
- Always use `CometChatThemeHelper` for colors, never hardcode
- Always import from `cometchat_calls_uikit` barrel if calls package is present

## Android Build Requirements

### gradle.properties
```properties
android.useAndroidX=true
android.enableJetifier=true
```

### minSdk 26
```groovy
defaultConfig {
    minSdk 26
}
```

### ProGuard
```
-keep class com.cometchat.** { *; }
-keep interface com.cometchat.** { *; }
-dontwarn com.cometchat.calls.**
```
