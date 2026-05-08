---
name: cometchat-flutter-v5-core
description: >
  Use when writing any code that uses CometChat Flutter UIKit v5 (cometchat_chat_uikit v5.2.14,
  cometchat_calls_uikit v5.0.15, cometchat_uikit_shared v5.2.3). Contains hard rules that prevent
  silent failures, crashes, and subtle bugs. Covers CometChatUIKit.init, login, logout,
  UIKitSettings, UIKitSettingsBuilder, listener lifecycle, theme caching, Scaffold
  resizeToAvoidBottomInset, subscriptionType, region, muid preservation, and the
  GetX-based component pattern. Also use when seeing errors like "Authentication null",
  "APP ID null", ERR_ALREADY_LOGGED_IN, or GetX controller not found. Make sure to use
  this skill for any CometChat Flutter UIKit v5 code, even simple widget usage.
  Triggers: CometChatUIKit, UIKitSettings, UIKitSettingsBuilder, init, login, logout,
  cometchat_chat_uikit, cometchat_calls_uikit, cometchat_uikit_shared, GetBuilder,
  GetxController, Get.put, authentication null, APP ID null.
license: "MIT"
compatibility: "cometchat_chat_uikit ^5.2.14; cometchat_calls_uikit ^5.0.15; cometchat_uikit_shared ^5.2.3; cometchat_sdk ^4.1.0; get ^4.6.5"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter v5 core rules init login logout lifecycle getx"
---

# CometChat Flutter UIKit v5 — Core Rules

Non-negotiable constraints for all CometChat UIKit v5 code. Violating these causes silent failures or crashes.

## Key v5 Architecture Facts

- State management: **GetX** (GetBuilder, GetxController, Get.put, Get.find, Get.delete)
- Separate packages: `cometchat_chat_uikit` (v5.2.14) + `cometchat_calls_uikit` (v5.0.15) + `cometchat_uikit_shared` (v5.2.3)
- SDK: `cometchat_sdk ^4.1.0` + `cometchat_calls_sdk ^4.2.2`
- Import everything from: `package:cometchat_calls_uikit/cometchat_calls_uikit.dart` (re-exports chat + shared + SDK)
- `CometChatUIKit.login(uid)` takes a **String** directly (not an object)
- No ServiceLocator pattern — controllers are created via `Get.put()` internally
- Style classes use `ThemeExtension` with `merge()` pattern

## Rule: INIT_FIRST

`CometChatUIKit.init()` must complete before any login, component usage, or SDK call.

```dart
// ✅ CORRECT
final settings = (UIKitSettingsBuilder()
      ..appId = 'APP_ID'
      ..region = 'us'
      ..authKey = 'AUTH_KEY'
      ..subscriptionType = CometChatSubscriptionType.allUsers)
    .build();

await CometChatUIKit.init(
  uiKitSettings: settings,
  onSuccess: (_) => debugPrint('Init done'),
  onError: (e) => debugPrint('Init failed: ${e.message}'),
);

// ❌ WRONG — login before init completes
CometChatUIKit.init(uiKitSettings: settings);
CometChatUIKit.login('uid'); // Race condition
```

## Rule: AUTH_CHECK_AFTER_INIT

After `CometChatUIKit.init()` completes (in its `onSuccess`), the static field `CometChatUIKit.loggedInUser` is already populated if a cached session exists. Use this synchronous check — do NOT call `CometChat.getLoggedInUser()` separately.

```dart
// ✅ CORRECT — synchronous check after init completes
CometChatUIKit.init(
  uiKitSettings: settings,
  onSuccess: (_) {
    final hasUser = CometChatUIKit.loggedInUser != null;
    // Route to home or login based on hasUser
  },
);

// ❌ WRONG — separate async getLoggedInUser call after init
CometChatUIKit.init(
  uiKitSettings: settings,
  onSuccess: (_) {
    CometChat.getLoggedInUser(
      onSuccess: (user) { ... },  // Unreliable when no session exists
      onError: (e) { ... },
    );
  },
);
```

The `init()` method internally calls `getLoggedInUser()` and sets `CometChatUIKit.loggedInUser` before firing `onSuccess`.

## Rule: SCAFFOLD_NO_RESIZE

Any `Scaffold` containing `CometChatMessageComposer` MUST set `resizeToAvoidBottomInset: false`. The composer handles keyboard spacing internally. Leaving it `true` causes double-compensation and layout jumps.

```dart
// ✅ CORRECT
Scaffold(
  resizeToAvoidBottomInset: false,
  body: Column(
    children: [
      Expanded(child: CometChatMessageList(user: user)),
      CometChatMessageComposer(user: user),
    ],
  ),
)

// ❌ WRONG — default is true, causes double keyboard compensation
Scaffold(
  body: Column(
    children: [
      Expanded(child: CometChatMessageList(user: user)),
      CometChatMessageComposer(user: user),
    ],
  ),
)
```

## Rule: LISTENER_LIFECYCLE

SDK listeners MUST be registered with a unique ID in `initState()` and removed with the same ID in `dispose()`. Forgetting removal causes duplicate events and memory leaks.

```dart
// ✅ CORRECT
class _MyScreenState extends State<MyScreen> with MessageListener {
  late final String _listenerId;

  @override
  void initState() {
    super.initState();
    _listenerId = 'my_screen_${DateTime.now().millisecondsSinceEpoch}';
    CometChat.addMessageListener(_listenerId, this);
  }

  @override
  void dispose() {
    CometChat.removeMessageListener(_listenerId);
    super.dispose();
  }
}

// ❌ WRONG — hardcoded ID causes collisions; missing dispose removal
class _MyScreenState extends State<MyScreen> with MessageListener {
  @override
  void initState() {
    super.initState();
    CometChat.addMessageListener('messages', this); // Collision!
  }
  // Missing dispose → listener leaks
}
```

## Rule: THEME_CACHE

Cache theme values in `didChangeDependencies()` with a `_themeInitialized` flag. Never call `CometChatThemeHelper.getColorPalette(context)` in `build()` — during keyboard animation, `MediaQuery` changes trigger rebuilds, and each lookup does expensive InheritedWidget traversal.

```dart
// ✅ CORRECT — Hybrid pattern
class _MyWidgetState extends State<MyWidget> {
  late CometChatColorPalette _colorPalette;
  late CometChatSpacing _spacing;
  late CometChatTypography _typography;
  bool _themeInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeInitialized) {
      _colorPalette = CometChatThemeHelper.getColorPalette(context);
      _spacing = CometChatThemeHelper.getSpacing(context);
      _typography = CometChatThemeHelper.getTypography(context);
      _themeInitialized = true;
    }
  }
}

// ❌ WRONG — lookup in build causes jank
@override
Widget build(BuildContext context) {
  final colors = CometChatThemeHelper.getColorPalette(context); // Expensive!
  return Container(color: colors.primary);
}
```

## Rule: SUBSCRIPTION_TYPE_REQUIRED

Omitting `subscriptionType` in `UIKitSettingsBuilder` silently disables all presence events (online/offline, typing indicators). No error is thrown.

```dart
// ✅ CORRECT
UIKitSettingsBuilder()
  ..subscriptionType = CometChatSubscriptionType.allUsers

// ❌ WRONG — no error, but presence events never fire
UIKitSettingsBuilder()
  ..appId = 'APP_ID'
  ..region = 'us'
```

## Rule: REGION_LOWERCASE

Region must be a lowercase string. The SDK validates against `['us', 'eu', 'in']`.

```dart
// ✅ CORRECT
..region = 'us'

// ❌ WRONG — throws ERR_INVALID_REGION
..region = 'US'
```

## Rule: MUID_PRESERVATION

When sending messages, the SDK may return an empty `muid` in the success callback. The UIKit preserves the original `muid` for pending→sent deduplication. If you handle `ccMessageSent` events, compare by `muid` first, then `id`.

## Pattern: Callback → Async Bridge (Completer)

The CometChat SDK uses callback-based APIs (`onSuccess`/`onError`). Wrap them with `Completer` for async/await:

```dart
import 'dart:async';

Future<User> loginAsync(String uid) {
  final completer = Completer<User>();
  CometChatUIKit.login(uid,
    onSuccess: (user) => completer.complete(user),
    onError: (e) => completer.completeError(e),
  );
  return completer.future;
}

// Usage
try {
  final user = await loginAsync('user123');
} on CometChatException catch (e) {
  debugPrint('Login failed: ${e.message}');
}
```

## v5 Component Architecture Pattern (GetX)

Every component follows this structure:

```
{component}/
├── cometchat_{component}.dart              # StatefulWidget
├── cometchat_{component}_controller.dart   # extends GetxController
├── cometchat_{component}_style.dart        # ThemeExtension with merge()
└── {component}_builder_protocol.dart       # Request builder protocol
```

Components use `GetBuilder` internally:
```dart
// Internal pattern — components create their own controllers
@override
void initState() {
  super.initState();
  tag = widget.controllerTag ?? 'default_tag_for_${component}_$dateString';
  controller = Get.put<Controller>(Controller(...), tag: tag);
}

@override
void dispose() {
  if (widget.controllerTag == null) {
    Get.delete<Controller>(tag: tag);
  }
  super.dispose();
}
```

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Widget | `CometChat{Name}` | `CometChatConversations` |
| Controller | `CometChat{Name}Controller` | `CometChatConversationsController` |
| Style | `CometChat{Name}Style` | `CometChatConversationsStyle` |
| Builder Protocol | `{Name}BuilderProtocol` | `ConversationsBuilderProtocol` |
| Request Builder | `{Name}RequestBuilder` | `ConversationsRequestBuilder` |

## Android Build Requirements

### gradle.properties
```properties
android.useAndroidX=true
android.enableJetifier=true
```

### minSdk 26
In `android/app/build.gradle`:
```groovy
defaultConfig {
    minSdk 26  // Required by cometchat_calls_sdk
}
```

### ProGuard / R8 Keep Rules
Create `android/app/proguard-rules.pro`:
```
-keep class com.cometchat.** { *; }
-keep interface com.cometchat.** { *; }
-dontwarn com.cometchat.calls.**
```

Reference it in `build.gradle`:
```groovy
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

## Top 10 Error Debugging

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Authentication null" | `CometChatUIKit.init()` not called | Call init before login/components |
| "APP ID null" | appId not set in UIKitSettingsBuilder | Set `..appId = 'YOUR_APP_ID'` |
| Double keyboard compensation | Scaffold `resizeToAvoidBottomInset` is true | Set to `false` when using composer |
| No typing indicators / presence | `subscriptionType` not set | Set `..subscriptionType = CometChatSubscriptionType.allUsers` |
| Theme jank during keyboard | Theme looked up in `build()` | Cache in `didChangeDependencies()` with flag |
| Listener leak / duplicate events | Listener not removed in `dispose()` | Always remove with same ID used to register |
| "ERR_ALREADY_LOGGED_IN" | Calling login when session exists | Check `CometChatUIKit.loggedInUser` first |
| GetX controller not found | Using `Get.find()` before `Get.put()` | Let UIKit components manage their own controllers |
| Region error | Uppercase region string | Use lowercase: 'us', 'eu', 'in' |
| Release build crash | Missing ProGuard keep rules | Add `-keep class com.cometchat.** { *; }` |

## Checklist — Every CometChat v5 Screen

- [ ] `CometChatUIKit.init()` called before any usage
- [ ] Auth check uses `CometChatUIKit.loggedInUser` after init
- [ ] `subscriptionType` set in UIKitSettingsBuilder
- [ ] `region` is lowercase
- [ ] Scaffold has `resizeToAvoidBottomInset: false` if composer is present
- [ ] Theme cached in `didChangeDependencies()`, not `build()`
- [ ] SDK listeners registered with unique ID, removed in `dispose()`
- [ ] Colors from `CometChatThemeHelper`, never hardcoded
- [ ] Import from `package:cometchat_calls_uikit/cometchat_calls_uikit.dart`
