---
name: cometchat-flutter-v5-calls
description: >
  Use when working with CometChat Flutter UIKit v5 call components.
  Triggers on CometChatCallButtons, CometChatIncomingCall, CometChatOutgoingCall,
  CometChatOngoingCall, CometChatCallLogs, CometChatCallBubble, CometChatUIKitCalls,
  CallingConfiguration, CallNavigationContext, voice call, video call, call logs,
  incoming call, outgoing call, ongoing call, call settings, call init, CallSettingsBuilder,
  CallAppSettingBuilder, CometChatCalls.init, CometChatCallingExtension.
license: "MIT"
compatibility: "cometchat_calls_uikit ^5.0.15; cometchat_calls_sdk ^4.2.2; cometchat_sdk ^4.1.0"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter v5 calls voice video incoming outgoing ongoing logs"
---

# CometChat Flutter UIKit v5 — Calls

Components and utilities for voice/video calling, call logs, and call UI.

## Package Structure

Calls are in a **separate package**: `cometchat_calls_uikit` (v5.0.15).

```yaml
# pubspec.yaml
dependencies:
  cometchat_calls_uikit: ^5.0.15
```

Import everything from:
```dart
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
```

This re-exports `cometchat_uikit_shared`, `cometchat_sdk`, and `cometchat_calls_sdk`.

## Rule: CALLS_INIT_ORDER

CometChat Chat SDK must be initialized BEFORE Calls SDK. The calling extension handles this automatically when configured via `UIKitSettingsBuilder.callingExtension`.

```dart
// ✅ CORRECT — enable calling via UIKitSettings
final settings = (UIKitSettingsBuilder()
      ..appId = 'APP_ID'
      ..region = 'us'
      ..authKey = 'AUTH_KEY'
      ..subscriptionType = CometChatSubscriptionType.allUsers
      ..callingExtension = CometChatCallingExtension())
    .build();

await CometChatUIKit.init(uiKitSettings: settings);

// ❌ WRONG — initializing calls SDK before chat SDK
CometChatUIKitCalls.init('APP_ID', 'us');
CometChatUIKit.init(uiKitSettings: settings); // Chat SDK not ready yet
```

## Rule: CALL_NAVIGATION_CONTEXT

`CallNavigationContext.navigatorKey` must be set on your `MaterialApp` for call overlays (incoming/outgoing) to navigate correctly:

```dart
// ✅ CORRECT
MaterialApp(
  navigatorKey: CallNavigationContext.navigatorKey,
  // ...
)
```

## CometChatUIKitCalls

Static utility class wrapping the Calls SDK. Methods:

| Method | Description |
|--------|-------------|
| `CometChatUIKitCalls.init(appId, region)` | Initialize Calls SDK (usually done by CometChatCallingExtension) |
| `CometChatUIKitCalls.initiateCall(call)` | Start a call |
| `CometChatUIKitCalls.acceptCall(sessionId)` | Accept incoming call |
| `CometChatUIKitCalls.rejectCall(sessionId, status)` | Reject/cancel call |
| `CometChatUIKitCalls.generateToken(sessionId, authToken)` | Generate call token |
| `CometChatUIKitCalls.startSession(callToken, callSettings)` | Start call session (returns Widget) |
| `CometChatUIKitCalls.endSession()` | End active call session |
| `CometChatUIKitCalls.getUserAuthToken()` | Get user auth token |

## CometChatCallButtons

Displays voice and video call buttons for a user or group.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `user` | `User?` | Target user |
| `group` | `Group?` | Target group |
| `callButtonsStyle` | `CometChatCallButtonsStyle?` | Visual styling |
| `hideVoiceCallButton` | `bool?` | Hide voice call button |
| `hideVideoCallButton` | `bool?` | Hide video call button |
| `voiceCallIcon` | `Widget?` | Custom voice call icon |
| `videoCallIcon` | `Widget?` | Custom video call icon |
| `outgoingCallConfiguration` | `CometChatOutgoingCallConfiguration?` | Outgoing call config |
| `callSettingsBuilder` | `CallSettingsBuilder Function(User?, Group?, bool?)?` | Custom call settings |
| `onError` | `OnError?` | Error callback (passed via constructor) |

### Usage

```dart
// ✅ CORRECT — in message header or custom toolbar
CometChatCallButtons(
  user: user,
)

// ✅ CORRECT — group calls, hide voice
CometChatCallButtons(
  group: group,
  hideVoiceCallButton: true,
)
```

## CometChatIncomingCall

Displays the incoming call screen with accept/decline buttons.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `call` | `Call` | The incoming call object (required) |
| `user` | `User?` | Custom user display |
| `incomingCallStyle` | `CometChatIncomingCallStyle?` | Visual styling |
| `callSettingsBuilder` | `CallSettingsBuilder?` | Custom call settings |
| `onDecline` | `Function(BuildContext, Call)?` | Decline callback |
| `onAccept` | `Function(BuildContext, Call)?` | Accept callback |
| `onError` | `OnError?` | Error callback |
| `disableSoundForCalls` | `bool?` | Disable ringtone |
| `customSoundForCalls` | `String?` | Custom ringtone asset |
| `titleView` | `Widget? Function(BuildContext, Call)?` | Custom title |
| `subTitleView` | `Widget? Function(BuildContext, Call)?` | Custom subtitle |
| `leadingView` | `Widget? Function(BuildContext, Call)?` | Custom leading view |
| `trailingView` | `Widget? Function(BuildContext, Call)?` | Custom trailing view |
| `itemView` | `Widget? Function(BuildContext, Call)?` | Custom item view |
| `declineButtonText` | `String?` | Custom decline text |
| `acceptButtonText` | `String?` | Custom accept text |
| `callIcon` | `Widget?` | Custom call icon |

### Usage

```dart
// ✅ CORRECT — typically shown as overlay via CometChatCallingExtension
// The extension handles incoming call display automatically.
// Manual usage:
CometChatIncomingCall(
  call: incomingCall,
  onAccept: (context, call) {
    // Handle accept
  },
  onDecline: (context, call) {
    // Handle decline
  },
)
```

## CometChatOutgoingCall

Displays the outgoing call screen while waiting for the recipient.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `call` | `Call` | The outgoing call object (required, passed via constructor) |
| `user` | `User?` | User being called |
| `outgoingCallStyle` | `CometChatOutgoingCallStyle?` | Visual styling |
| `callSettingsBuilder` | `CallSettingsBuilder?` | Custom call settings |
| `onCancelled` | `Function(BuildContext, Call)?` | Cancel callback |
| `onError` | `OnError?` | Error callback |
| `subtitleView` | `Widget? Function(BuildContext, Call)?` | Custom subtitle |
| `declineButtonIcon` | `Widget?` | Custom decline icon |
| `disableSoundForCalls` | `bool?` | Disable ringtone |
| `customSoundForCalls` | `String?` | Custom ringtone |
| `avatarView` | `Widget? Function(BuildContext, Call)?` | Custom avatar |
| `titleView` | `Widget? Function(BuildContext, Call)?` | Custom title |
| `cancelledView` | `Widget? Function(BuildContext, Call)?` | Custom cancelled view |

## CometChatOngoingCall

Displays the active call screen with the calling widget.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `callSettingsBuilder` | `CallSettingsBuilder` | Call settings (required) |
| `sessionId` | `String` | Call session ID (required) |
| `callWorkFlow` | `CallWorkFlow?` | Direct calling or default calling |
| `onError` | `OnError?` | Error callback |

### Usage

```dart
// ✅ CORRECT — navigate to ongoing call
Navigator.push(context, MaterialPageRoute(
  builder: (_) => CometChatOngoingCall(
    callSettingsBuilder: CallSettingsBuilder()
      ..enableDefaultLayout = true
      ..setAudioOnlyCall = isAudioOnly,
    sessionId: call.sessionId,
    callWorkFlow: CallWorkFlow.directCalling,
  ),
));
```

## CometChatCallLogs

Displays a list of call history/logs.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `callLogsRequestBuilder` | `CallLogRequestBuilder?` | Custom fetch builder |
| `callLogsBuilderProtocol` | `CallLogsBuilderProtocol?` | Custom builder protocol |
| `callLogsStyle` | `CometChatCallLogsStyle?` | Visual styling |
| `listItemView` | `Widget? Function(CallLog, BuildContext)?` | Custom list item |
| `subTitleView` | `Widget? Function(CallLog, BuildContext)?` | Custom subtitle |
| `trailingView` | `Function(BuildContext, CallLog)?` | Custom trailing widget |
| `leadingStateView` | `Widget? Function()?` | Custom leading view |
| `titleView` | `Widget? Function()?` | Custom title view |
| `onItemClick` | `Function(CallLog)?` | Tap callback |
| `onItemLongPress` | `Function?` | Long press callback |
| `onCallLogIconClicked` | `Function?` | Call icon tap callback |
| `onBack` | `VoidCallback?` | Back button callback |
| `hideAppbar` | `bool` | Hide app bar (default: false) |
| `showBackButton` | `bool?` | Show back button |
| `appBarOptions` | `List<Widget> Function(BuildContext)?` | App bar trailing widgets |
| `datePattern` | `String?` | Custom date format |
| `dateSeparatorPattern` | `String?` | Date separator format |
| `audioCallIcon` | `Widget?` | Custom audio call icon |
| `videoCallIcon` | `Widget?` | Custom video call icon |
| `incomingCallIcon` | `Widget?` | Custom incoming call icon |
| `outgoingCallIcon` | `Widget?` | Custom outgoing call icon |
| `missedCallIcon` | `Widget?` | Custom missed call icon |
| `outgoingCallConfiguration` | `CometChatOutgoingCallConfiguration?` | Outgoing call config |
| `loadingStateView` | `WidgetBuilder?` | Custom loading state |
| `emptyStateView` | `WidgetBuilder?` | Custom empty state |
| `errorStateView` | `WidgetBuilder?` | Custom error state |
| `onError` | `OnError?` | Error callback |
| `onLoad` | `OnLoad?` | Load callback |
| `onEmpty` | `OnEmpty?` | Empty state callback |

### Usage

```dart
// ✅ CORRECT — basic call logs
CometChatCallLogs(
  onItemClick: (callLog) {
    debugPrint('Call log: ${callLog.initiator?.name}');
  },
)
```

## CometChatCallBubble

Displays a call message bubble within the message list.

## CallingConfiguration

Configuration object for the calling extension:

```dart
CallingConfiguration(
  outgoingCallConfiguration: CometChatOutgoingCallConfiguration(...),
  incomingCallConfiguration: CometChatIncomingCallConfiguration(...),
  callButtonsConfiguration: CallButtonsConfiguration(...),
  groupCallSettingsBuilder: CallSettingsBuilder()..enableDefaultLayout = true,
)
```

## Golden Path — Enable Calling

```dart
// 1. Configure calling extension in UIKitSettings
final settings = (UIKitSettingsBuilder()
      ..appId = 'APP_ID'
      ..region = 'us'
      ..authKey = 'AUTH_KEY'
      ..subscriptionType = CometChatSubscriptionType.allUsers
      ..callingExtension = CometChatCallingExtension())
    .build();

// 2. Init
await CometChatUIKit.init(uiKitSettings: settings);

// 3. Set navigator key for call overlays
MaterialApp(
  navigatorKey: CallNavigationContext.navigatorKey,
  // ...
)

// 4. Call buttons appear automatically in CometChatMessageHeader
// Or add them manually:
CometChatCallButtons(user: user)
```

## Call Flow — Outgoing

1. User taps call button → `CometChatCallButtons` controller calls `CometChatUIKitCalls.initiateCall(call)`
2. `CometChatOutgoingCall` screen is pushed
3. Recipient accepts → `CometChatOngoingCall` screen replaces outgoing
4. Call ends → screens pop back

## Call Flow — Incoming

1. `CometChatCallingExtension` listens for incoming calls via SDK listener
2. `CometChatIncomingCall` overlay is displayed via `CallNavigationContext.navigatorKey`
3. User accepts → `CometChatUIKitCalls.acceptCall(sessionId)` → `CometChatOngoingCall`
4. User declines → `CometChatUIKitCalls.rejectCall(sessionId, status)`

## Anti-Patterns

```dart
// ❌ WRONG — forgetting to set navigatorKey
MaterialApp(
  // Missing: navigatorKey: CallNavigationContext.navigatorKey
)

// ❌ WRONG — initializing calls before chat
CometChatUIKitCalls.init('APP_ID', 'us');
// Chat SDK not initialized yet!

// ❌ WRONG — not enabling calling extension
final settings = (UIKitSettingsBuilder()
      ..appId = 'APP_ID'
      ..region = 'us')
    .build();
// Missing: ..callingExtension = CometChatCallingExtension()
```

## Checklist — Calls

- [ ] `CometChatCallingExtension()` set on `UIKitSettingsBuilder.callingExtension`
- [ ] `CallNavigationContext.navigatorKey` set on `MaterialApp.navigatorKey`
- [ ] Chat SDK initialized before Calls SDK (handled by extension)
- [ ] `cometchat_calls_uikit` added to `pubspec.yaml`
- [ ] Import from `package:cometchat_calls_uikit/cometchat_calls_uikit.dart`
