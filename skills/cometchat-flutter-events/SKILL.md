---
name: cometchat-flutter-events
description: >
  Use when working with real-time events, SDK listeners, or UI event streams in
  CometChat Flutter UIKit v6. Triggers on mentions of CometChatMessageEvents,
  CometChatUserEvents, CometChatGroupEvents, CometChatCallEvents,
  CometChatConversationEvents, MessageListener, UserListener, GroupListener,
  CallListener, ConnectionListener, ccMessageSent, ccMessageEdited,
  ccMessageDeleted, ccUserBlocked, ccUserUnblocked, ccGroupMemberKicked,
  ccGroupMemberBanned, onMessageReceived, onTypingStarted, onTypingEnded,
  onUserOnline, onUserOffline, onMessageDelivered, onMessageRead,
  addMessageListener, removeMessageListener, ChatSDKEventInitializer,
  or any real-time update handling in CometChat.
license: "MIT"
compatibility: "cometchat_chat_uikit ^6.0.0; cometchat_sdk ^5.0.0"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter events listeners real-time typing receipts presence"
---

# CometChat Flutter UIKit — Events & Listeners

Two event systems: SDK listeners (from CometChat server) and UI events (from UIKit components).

## SDK Listeners (Server → App)

Register on CometChat SDK directly. These fire when the server pushes real-time data.

### Available Listener Types

| Listener Mixin | Register / Remove | Key Callbacks |
|----------------|-------------------|---------------|
| `MessageListener` | `CometChat.addMessageListener(id, this)` / `removeMessageListener(id)` | `onTextMessageReceived`, `onMediaMessageReceived`, `onCustomMessageReceived`, `onTypingStarted`, `onTypingEnded`, `onMessagesDelivered`, `onMessagesRead`, `onMessageEdited`, `onMessageDeleted` |
| `UserListener` | `CometChat.addUserListener(id, this)` / `removeUserListener(id)` | `onUserOnline`, `onUserOffline` |
| `GroupListener` | `CometChat.addGroupListener(id, this)` / `removeGroupListener(id)` | `onGroupMemberJoined`, `onGroupMemberLeft`, `onGroupMemberKicked`, `onGroupMemberBanned`, `onGroupMemberScopeChanged`, `onMemberAddedToGroup` |
| `CallListener` | `CometChat.addCallListener(id, this)` / `removeCallListener(id)` | `onIncomingCallReceived`, `onOutgoingCallAccepted`, `onOutgoingCallRejected`, `onIncomingCallCancelled` |
| `ConnectionListener` | `CometChat.addConnectionListener(id, this)` / `removeConnectionListener(id)` | `onConnected`, `onDisconnected`, `onConnecting`, `onFeatureThrottled` |

### Registration Pattern

```dart
class _MyScreenState extends State<MyScreen>
    with MessageListener, UserListener {
  late final String _listenerId;

  @override
  void initState() {
    super.initState();
    _listenerId = 'my_screen_${DateTime.now().millisecondsSinceEpoch}';
    CometChat.addMessageListener(_listenerId, this);
    CometChat.addUserListener(_listenerId, this);
  }

  @override
  void dispose() {
    CometChat.removeMessageListener(_listenerId);
    CometChat.removeUserListener(_listenerId);
    super.dispose();
  }

  @override
  void onTextMessageReceived(TextMessage message) {
    // Handle incoming text message
  }

  @override
  void onUserOnline(User user) {
    // Handle user coming online
  }

  @override
  void onUserOffline(User user) {
    // Handle user going offline
  }
}
```

## UI Events (UIKit Component → App)

These fire when UIKit components perform actions. Use these to react to user interactions across components.

### CometChatMessageEvents

```dart
// Listen
CometChatMessageEvents.addMessagesListener('my_listener', MyMessageEventListener());

// Remove
CometChatMessageEvents.removeMessagesListener('my_listener');

// Key callbacks in CometChatMessageEventListener:
// ccMessageSent(BaseMessage message, MessageStatus status)  — inProgress/sent/error
// ccMessageEdited(BaseMessage message, MessageEditStatus status)
// ccMessageDeleted(BaseMessage message, EventStatus status)
// ccMessageRead(BaseMessage message)
// ccLiveReaction(String reaction)
```

### CometChatUserEvents

```dart
CometChatUserEvents.addUsersListener('my_listener', MyUserEventListener());
CometChatUserEvents.removeUsersListener('my_listener');

// Key callbacks:
// ccUserBlocked(User user)
// ccUserUnblocked(User user)
```

### CometChatGroupEvents

```dart
CometChatGroupEvents.addGroupsListener('my_listener', MyGroupEventListener());
CometChatGroupEvents.removeGroupsListener('my_listener');

// Key callbacks:
// ccGroupMemberKicked(Action, User kickedUser, User kickedBy, Group)
// ccGroupMemberBanned(Action, User bannedUser, User bannedBy, Group)
// ccGroupMemberScopeChanged(Action, User updatedUser, String newScope, String oldScope, Group)
// ccGroupCreated(Group)
// ccGroupDeleted(Group)
// ccGroupLeft(Action, User, Group)
// ccOwnershipChanged(Group, GroupMember)
```

### CometChatConversationEvents

```dart
CometChatConversationEvents.addConversationListListener('my_listener', MyConvListener());
CometChatConversationEvents.removeConversationListListener('my_listener');

// Key callbacks:
// ccConversationDeleted(Conversation)
```

## SDK vs UI Events — When to Use Which

| Scenario | Use |
|----------|-----|
| Incoming message from another user | SDK `MessageListener.onTextMessageReceived` |
| Current user sent a message via composer | UI `CometChatMessageEvents.ccMessageSent` |
| Another user comes online | SDK `UserListener.onUserOnline` |
| Current user blocked someone via UIKit | UI `CometChatUserEvents.ccUserBlocked` |
| Group member kicked by another admin | SDK `GroupListener.onGroupMemberKicked` |
| Current user kicked someone via UIKit | UI `CometChatGroupEvents.ccGroupMemberKicked` |

Key distinction: SDK listeners fire for remote events. UI events fire for local user actions performed through UIKit components.

## BLoC Components Handle Listeners Automatically

The UIKit BLoCs (`ConversationsBloc`, `MessageListBloc`, etc.) register all necessary SDK listeners internally. You do NOT need to register listeners for components you're using — they handle their own real-time updates.

Register your own listeners only when you need to:
- Update custom UI outside UIKit components
- Track events for analytics
- Sync state between screens

## ChatSDKEventInitializer

Called automatically by `CometChatUIKit._initiateAfterLogin()`. Bridges SDK events to UIKit's internal event bus. You never need to call this manually.

## Gotchas

- Listener IDs MUST be unique per registration. Using the same ID overwrites the previous listener silently — no error thrown, old listener just stops receiving events.
- `onTypingStarted`/`onTypingEnded` only fire if `subscriptionType` was set in `UIKitSettings`. Omitting it silently disables all presence/typing events.
- SDK listeners fire on the main isolate. Heavy processing in callbacks blocks the UI thread. Offload to `compute()` if needed.
- `ccMessageSent` fires three times per message: once with `MessageStatus.inProgress`, once with `MessageStatus.sent` (success), or once with `MessageStatus.error` (failure). Filter by status.
- Connection listener's `onConnected` fires on reconnect — use it to trigger a silent refresh of your data.
- Group listener callbacks include an `Action` object (which is a `BaseMessage` subclass). Don't confuse it with the `Action` widget from Flutter.

## Anti-Patterns

```dart
// ❌ WRONG — hardcoded listener ID causes silent overwrite
CometChat.addMessageListener('messages', this);
// Later, another screen does the same:
CometChat.addMessageListener('messages', this); // First listener silently lost!

// ✅ CORRECT — unique ID per instance
final id = 'screen_${DateTime.now().millisecondsSinceEpoch}';
CometChat.addMessageListener(id, this);
```

```dart
// ❌ WRONG — registering SDK listeners for a UIKit component you're already using
// ConversationsBloc already handles MessageListener, UserListener, GroupListener internally
CometChat.addMessageListener('redundant', this); // Duplicate handling

// ✅ CORRECT — only register for custom logic outside UIKit components
// Let ConversationsBloc handle its own listeners
```

```dart
// ❌ WRONG — not filtering ccMessageSent status
void onCcMessageSent(BaseMessage msg, MessageStatus status) {
  addToList(msg); // Adds 3 times! (inProgress + sent + error)
}

// ✅ CORRECT — filter by status
void onCcMessageSent(BaseMessage msg, MessageStatus status) {
  if (status == MessageStatus.sent) {
    addToList(msg);
  }
}
```

## Checklist

- [ ] Listener IDs are unique (use timestamp or UUID suffix)
- [ ] All listeners registered in `initState()` are removed in `dispose()`
- [ ] `subscriptionType` set in UIKitSettings for presence/typing events
- [ ] `ccMessageSent` handlers filter by `MessageStatus`
- [ ] No redundant listeners for UIKit components that handle their own
- [ ] `Action` from CometChat SDK not confused with Flutter's `Action` widget (use `import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;` and `cc.Action`)
