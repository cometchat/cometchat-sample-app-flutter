---
name: cometchat-flutter-calls
description: >
  Use when implementing voice calls, video calls, or call UI with CometChat Flutter UIKit v6.
  Covers CometChatCallButtons, CometChatIncomingCall, CometChatOutgoingCall,
  CometChatOngoingCall, CometChatCallLogs, CometChatUIKitCalls, CallingConfiguration,
  CallButtonsBloc, IncomingCallBloc, OutgoingCallBloc, OngoingCallBloc, CallLogsBloc,
  CallEventService, CallOperationsServiceLocator, call_operations, call_settings,
  SessionSettingsBuilder, CallAppSettings, initiateCall, acceptCall, rejectCall,
  endSession, startSession, generateToken, CallNavigationContext,
  CometChatDisplayIncomingCallOverlay, CallScreenOverlay, native_call_kit,
  call permissions, audio call, video call, group call, call logs, call history,
  incoming call screen, outgoing call screen, ongoing call screen, call bubble,
  or "add calling to my app". Also use when seeing errors like
  "CallManager not found", "startSession null", "call token null",
  "session already started", or call-related crashes.
license: "MIT"
compatibility: "cometchat_chat_uikit ^6.0.0"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter calls voice video calling incoming outgoing ongoing call-logs"
---

# CometChat Flutter UIKit — Calls

Voice and video calling for 1:1 and group conversations. Call functionality is built into `cometchat_chat_uikit` — no separate package needed.

## Import

```dart
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';
```

The first import gives you chat components. The second gives you call-specific types.

## Rule: CALLS_INIT_AFTER_CHAT_INIT

`CometChatUIKitCalls.init()` MUST be called after `CometChatUIKit.init()` completes. The calls SDK needs the chat SDK's auth context.

```dart
// ✅ CORRECT — calls init after chat init
CometChatUIKit.init(
  uiKitSettings: settings,
  onSuccess: (_) {
    CometChatUIKitCalls.init(appId, region,
      onSuccess: (_) => debugPrint('Calls SDK ready'),
      onError: (e) => debugPrint('Calls init failed: ${e.message}'),
    );
  },
);

// ❌ WRONG — parallel init causes auth token null
CometChatUIKit.init(uiKitSettings: settings);
CometChatUIKitCalls.init(appId, region); // Race condition
```

## Rule: SINGLE_CALLS_INIT

`CometChatUIKitCalls.init()` must be called exactly once per app lifecycle. Calling it again after logout + re-login can cause "session already started" errors.

## Rule: CALLS_REINIT_AFTER_LOGOUT

After `CometChatUIKit.logout()`, the calls SDK session is invalidated. On the next login, `CometChatUIKitCalls.init()` must be called again.

## Architecture

```
call_ui/src/
├── call_buttons/          # Voice/video call buttons (CallButtonsBloc)
├── incoming_call/         # Incoming call screen (IncomingCallBloc)
├── outgoing_call/         # Outgoing call screen (OutgoingCallBloc)
├── ongoing_call/          # Active call screen — WebRTC (OngoingCallBloc)
├── call_logs/             # Call history list (CallLogsBloc + Clean Arch)
├── call_operations/       # Shared clean architecture (DI, use cases, repos)
├── call_bubble/           # Call message bubble in chat
├── call_settings/         # CometChatUIKitCalls, CallNavigationContext
├── native_call_kit/       # iOS CallKit / Android ConnectionService
├── utils/                 # CallUtils, CallStateService, CallPermissions
├── call_event_service.dart  # Centralized call event handling
└── calling_configuration.dart  # Top-level config object
```

## Components

### CometChatCallButtons

Voice and video call buttons. Typically placed in `CometChatMessageHeader`'s trailing view or standalone.

```dart
CometChatCallButtons(
  user: user,           // For 1:1 calls
  group: group,         // For group calls (meetings)
  hideVoiceCallButton: false,
  hideVideoCallButton: false,
  voiceCallIcon: Icon(Icons.call),
  videoCallIcon: Icon(Icons.videocam),
  callButtonsStyle: CometChatCallButtonsStyle(
    voiceCallIconColor: colorPalette.iconPrimary,
    videoCallIconColor: colorPalette.iconPrimary,
  ),
  outgoingCallConfiguration: CometChatOutgoingCallConfiguration(
    outgoingCallStyle: CometChatOutgoingCallStyle(...),
  ),
)
```

Call buttons are built into `CometChatMessageHeader` by default:
```dart
CometChatMessageHeader(
  user: user,
  group: group,
  hideVoiceCallButton: false,
  hideVideoCallButton: false,
)
```

### CometChatIncomingCall

Displays when the logged-in user receives a call. Supports accept/decline with custom views.

```dart
CometChatIncomingCall(
  call: call,                    // Required — the active Call object
  user: callerUser,              // Caller info for display
  onAccept: (ctx, call) { },
  onDecline: (ctx, call) { },
  disableSoundForCalls: false,
  customSoundForCalls: 'assets/ringtone.mp3',
  incomingCallStyle: CometChatIncomingCallStyle(
    backgroundColor: colorPalette.background3,
    acceptButtonColor: colorPalette.success,
    declineButtonColor: colorPalette.error,
  ),
  // Custom view slots
  titleView: (ctx, call) => Text('Custom Title'),
  subTitleView: (ctx, call) => Text('Custom Subtitle'),
  leadingView: (ctx, call) => Icon(Icons.call),
  trailingView: (ctx, call) => CometChatAvatar(image: user.avatar),
)
```

### CometChatOutgoingCall

Displays when the logged-in user initiates a call.

```dart
CometChatOutgoingCall(
  call: call,
  user: receiverUser,
  outgoingCallStyle: CometChatOutgoingCallStyle(
    backgroundColor: colorPalette.background1,
  ),
)
```

### CometChatOngoingCall

The active call screen with WebRTC video/audio. Rendered after a call is accepted.

```dart
CometChatOngoingCall(
  callSettingsBuilder: sessionSettingsBuilder,
  sessionId: call.sessionId,
  callWorkFlow: CallWorkFlow.directCalling,
)
```

### CometChatCallLogs

Scrollable list of call history. Clean Architecture + BLoC with `CallLogsServiceLocator`.

```dart
CometChatCallLogs(
  onItemClick: (callLog) { /* Navigate or initiate call */ },
  callLogsStyle: CallLogsStyle(backgroundColor: colorPalette.background1),
)
```

### CometChatCallBubble

Message bubble for call events in the message list. Automatically rendered for call-type messages.

## CallingConfiguration

Top-level configuration object bundling all call component configs:

```dart
CallingConfiguration(
  outgoingCallConfiguration: CometChatOutgoingCallConfiguration(...),
  incomingCallConfiguration: CometChatIncomingCallConfiguration(...),
  callButtonsConfiguration: CallButtonsConfiguration(...),
  groupSessionSettingsBuilder: sessionSettingsBuilder,
)
```

## CometChatUIKitCalls API

| Method | Purpose |
|--------|---------|
| `CometChatUIKitCalls.init(appId, region)` | Initialize calls SDK |
| `CometChatUIKitCalls.initiateCall(call)` | Start a call |
| `CometChatUIKitCalls.acceptCall(sessionId)` | Accept incoming call |
| `CometChatUIKitCalls.rejectCall(sessionId, status)` | Reject/cancel call |
| `CometChatUIKitCalls.generateToken(sessionId)` | Generate call token |
| `CometChatUIKitCalls.startSession(sessionId, settings)` | Start WebRTC session |
| `CometChatUIKitCalls.endSession()` | End active call session |

## Call Flow — 1:1 Direct Call

```
Caller                              Receiver
  |-- CometChatCallButtons tap ------->|
  |-- initiateCall(Call) ------------->|
  |-- CometChatOutgoingCall shown ---->|
  |                                    |-- CometChatIncomingCall shown
  |                                    |-- acceptCall(sessionId)
  |<-- onOutgoingCallAccepted ---------|
  |-- generateToken(sessionId) ------->|
  |-- startSession(token, settings) -->|
  |-- CometChatOngoingCall shown ----->|-- CometChatOngoingCall shown
  |-- endSession() ------------------>|-- endSession()
```

## Golden Path — Messages Screen with Calls

```dart
Scaffold(
  resizeToAvoidBottomInset: false,
  appBar: CometChatMessageHeader(
    user: user,
    group: group,
    onBack: () => Navigator.pop(context),
    hideVoiceCallButton: false,
    hideVideoCallButton: false,
  ),
  body: Column(
    children: [
      Expanded(child: CometChatMessageList(user: user, group: group)),
      CometChatMessageComposer(user: user, group: group),
    ],
  ),
)
```

## BLoC Events

### CallButtonsBloc
| Event | Purpose |
|-------|---------|
| `InitiateVoiceCall` | Start audio call |
| `InitiateVideoCall` | Start video call |

### IncomingCallBloc
| Event | Purpose |
|-------|---------|
| `AcceptCall` | Accept the incoming call |
| `RejectCall` | Decline the incoming call |

### OutgoingCallBloc
| Event | Purpose |
|-------|---------|
| `CancelCall` | Cancel the outgoing call |
| `CallAccepted(call)` | Receiver accepted |
| `CallRejected(call)` | Receiver rejected |

### OngoingCallBloc
| Event | Purpose |
|-------|---------|
| `StartSession(sessionId, settings)` | Begin WebRTC session |
| `EndSession` | End the call |

### CallLogsBloc
| Event | Purpose |
|-------|---------|
| `LoadCallLogs` | Initial load |
| `LoadMoreCallLogs` | Pagination |

## Gotchas

- `CometChatUIKitCalls.init()` must happen AFTER `CometChatUIKit.init()` — parallel init causes "auth token null".
- After logout, the calls SDK session is invalidated. Re-init required on next login.
- `startSession` on Android can return `null` with a 5-second timeout and no error feedback. Known platform issue.
- `SessionType.audio` is ignored on Android in some SDK versions — always opens with video. Known external SDK bug.
- Group calls use `CometChat.Group` not `CometChat.User` on `CometChatCallButtons`.
- Incoming call handling must be global (mounted at app root level) so calls ring on every screen.
- `CallOperationsServiceLocator` must be initialized before using call BLoCs directly. UIKit widgets handle this automatically.
- After logout, call `CallOperationsServiceLocator.instance.reset()` to clean up.
- On iOS, CallKit integration via `native_call_kit` shows the native call UI. Ensure `Info.plist` has the `voip` background mode.
- On Android, the ongoing call foreground service shows a notification during active calls. Launched automatically by `startSession`.

## Anti-Patterns

```dart
// ❌ WRONG — init calls SDK before chat SDK
CometChatUIKitCalls.init(appId, region);
CometChatUIKit.init(uiKitSettings: settings);

// ✅ CORRECT — calls init in chat init's onSuccess
CometChatUIKit.init(
  uiKitSettings: settings,
  onSuccess: (_) {
    CometChatUIKitCalls.init(appId, region);
  },
);
```

```dart
// ❌ WRONG — not handling incoming calls globally
CometChatIncomingCall(call: call, user: user) // Only on messages screen

// ✅ CORRECT — mount incoming call overlay at app root
MaterialApp(
  builder: (context, child) {
    return Stack(children: [child!, /* Global incoming call listener */]);
  },
)
```

## Checklist

- [ ] `CometChatUIKitCalls.init()` called after `CometChatUIKit.init()` completes
- [ ] Incoming call handling is global (app root level), not per-screen
- [ ] Camera + microphone permissions handled (automatic via `CallPermissions`)
- [ ] `resizeToAvoidBottomInset: false` on any Scaffold with call UI
- [ ] Call buttons visible in `CometChatMessageHeader` (default) or standalone
- [ ] After logout, calls SDK re-initialized on next login
- [ ] Android: `minSdk = 26`, ProGuard rules for `com.cometchat.**`
- [ ] iOS: `voip` background mode in `Info.plist` for CallKit
- [ ] Theme cached in `didChangeDependencies()`, not `build()`
- [ ] SDK listeners cleaned up in `dispose()`