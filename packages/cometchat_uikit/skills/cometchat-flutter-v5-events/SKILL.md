---
name: cometchat-flutter-v5-events
description: >
  Use when working with CometChat Flutter UIKit v5 event system.
  Triggers on CometChatMessageEvents, CometChatUserEvents, CometChatGroupEvents,
  CometChatCallEvents, CometChatUIEvents, CometChatConversationEvents,
  CometChatAIAssistantEvents, listener registration, listener removal, real-time events,
  typing indicator, online status, receipts, SDK listener, ccMessageSent, ccMessageEdited,
  ccMessageDeleted, ccGroupCreated, ccOutgoingCall, ccCallAccepted.
license: "MIT"
compatibility: "cometchat_uikit_shared ^5.2.3; cometchat_sdk ^4.1.0"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter v5 events listeners real-time typing receipts"
---

# CometChat Flutter UIKit v5 — Events

The UIKit v5 event system for real-time updates. Two layers: SDK listeners (low-level) and UIKit events (high-level component coordination).

## Event System Architecture

### Layer 1: SDK Listeners (CometChat SDK)
Low-level listeners registered directly with the SDK. Used for raw message/call/user/group events.

### Layer 2: UIKit Events (CometChat UIKit)
High-level event classes that UIKit components emit and listen to for coordinating UI updates across components. These use a static `Map<String, Listener>` pattern.

## UIKit Event Classes

### CometChatMessageEvents

Emitted by UIKit when messages are sent, edited, deleted, or received.

**Static methods (emit):**
- `ccMessageSent(BaseMessage message, MessageStatus status)` — Message sent (inProgress/sent/error)
- `ccMessageEdited(BaseMessage message, MessageEditStatus status)` — Message edited
- `ccMessageDeleted(BaseMessage message, EventStatus status)` — Message deleted
- `ccMessageRead(BaseMessage message)` — Message marked as read
- `ccLiveReaction(String reaction, String receiverId)` — Live reaction sent
- `ccMessageForwarded(BaseMessage message, List<User>? users, List<Group>? groups, MessageStatus status)` — Message forwarded
- `ccReplyToMessage(BaseMessage message, MessageStatus status)` — Reply to message
- `onTextMessageReceived(TextMessage message)` — Text message received
- `onMediaMessageReceived(MediaMessage message)` — Media message received
- `onCustomMessageReceived(CustomMessage message)` — Custom message received
- `onTypingStarted(TypingIndicator indicator)` — Typing started
- `onTypingEnded(TypingIndicator indicator)` — Typing ended
- `onMessagesDelivered(MessageReceipt receipt)` — Messages delivered
- `onMessagesRead(MessageReceipt receipt)` — Messages read
- `onMessageEdited(BaseMessage message)` — Message edited (SDK)
- `onMessageDeleted(BaseMessage message)` — Message deleted (SDK)
- `onTransientMessageReceived(TransientMessage message)` — Transient message
- `onFormMessageReceived(FormMessage message)` — Form message
- `onCardMessageReceived(CardMessage message)` — Card message
- `onSchedulerMessageReceived(SchedulerMessage message)` — Scheduler message
- `onMessageReactionAdded(ReactionEvent event)` — Reaction added
- `onMessageReactionRemoved(ReactionEvent event)` — Reaction removed
- `onMessagesDeliveredToAll(MessageReceipt receipt)` — Delivered to all
- `onMessagesReadByAll(MessageReceipt receipt)` — Read by all
- `onMessageModerated(BaseMessage message)` — Message moderated

**Registration:**
```dart
CometChatMessageEvents.addMessagesListener(listenerId, listenerClass);
CometChatMessageEvents.removeMessagesListener(listenerId);
```

### CometChatUserEvents

Emitted when users are blocked/unblocked.

**Static methods:**
- `ccUserBlocked(User user)` — User blocked
- `ccUserUnblocked(User user)` — User unblocked

**Registration:**
```dart
CometChatUserEvents.addUsersListener(listenerId, listenerClass);
CometChatUserEvents.removeUsersListener(listenerId);
```

### CometChatGroupEvents

Emitted for group lifecycle events.

**Static methods:**
- `ccGroupCreated(Group group)` — Group created
- `ccGroupDeleted(Group group)` — Group deleted
- `ccGroupLeft(Action message, User leftUser, Group leftGroup)` — User left group
- `ccGroupMemberScopeChanged(Action message, User updatedUser, String scopeChangedTo, String scopeChangedFrom, Group group)` — Member scope changed
- `ccGroupMemberBanned(Action message, User bannedUser, User bannedBy, Group bannedFrom)` — Member banned
- `ccGroupMemberKicked(Action message, User kickedUser, User kickedBy, Group kickedFrom)` — Member kicked
- `ccGroupMemberUnbanned(Action message, User unbannedUser, User unbannedBy, Group unbannedFrom)` — Member unbanned
- `ccGroupMemberJoined(User joinedUser, Group joinedGroup)` — Member joined
- `ccGroupMemberAdded(List<Action> messages, List<User> usersAdded, Group groupAddedIn, User addedBy)` — Members added
- `ccOwnershipChanged(Group group, GroupMember newOwner)` — Ownership transferred

**Registration:**
```dart
CometChatGroupEvents.addGroupsListener(listenerId, listenerClass);
CometChatGroupEvents.removeGroupsListener(listenerId);
```

### CometChatCallEvents

Emitted for call lifecycle events.

**Static methods:**
- `ccOutgoingCall(Call call)` — Outgoing call initiated
- `ccCallAccepted(Call call)` — Call accepted
- `ccCallRejected(Call call)` — Call rejected
- `ccCallEnded(Call call)` — Call ended

**Registration:**
```dart
CometChatCallEvents.addCallEventsListener(listenerId, listenerClass);
CometChatCallEvents.removeCallEventsListener(listenerId);
```

### CometChatUIEvents

Emitted for UI-level coordination between components.

**Static methods:**
- `showPanel(Map<String, dynamic>? id, CustomUIPosition position, WidgetBuilder child)` — Show UI panel
- `hidePanel(Map<String, dynamic>? id, CustomUIPosition position)` — Hide UI panel
- `ccActiveChatChanged(Map<String, dynamic>? id, BaseMessage? lastMessage, User? user, Group? group, int unreadCount)` — Active chat changed
- `openChat(User? user, Group? group)` — Open chat request
- `ccComposeMessage(String text, MessageEditStatus status)` — Compose message
- `onAiFeatureTapped(User? user, Group? group)` — AI feature tapped

**Registration:**
```dart
CometChatUIEvents.addUiListener(listenerId, listenerClass);
CometChatUIEvents.removeUiListener(listenerId);
```

### CometChatConversationEvents

Emitted for conversation list events.

**Static methods:**
- `ccConversationDeleted(Conversation conversation)` — Conversation deleted
- `ccUpdateConversation(Conversation conversation)` — Conversation updated

**Registration:**
```dart
CometChatConversationEvents.addConversationListListener(listenerId, listenerClass);
CometChatConversationEvents.removeConversationListListener(listenerId);
```

### CometChatAIAssistantEvents

Emitted for AI assistant events.

**Registration:**
```dart
CometChatAIAssistantEvents.addAIAssistantListener(listenerId, listenerClass);
CometChatAIAssistantEvents.removeAIAssistantListener(listenerId);
```

## Listener Registration Pattern

All UIKit event classes follow the same pattern:

```dart
// ✅ CORRECT — register in initState, remove in dispose
class _MyWidgetState extends State<MyWidget> {
  late final String _listenerId;

  @override
  void initState() {
    super.initState();
    _listenerId = 'my_widget_${DateTime.now().millisecondsSinceEpoch}';

    // UIKit events
    CometChatMessageEvents.addMessagesListener(
      _listenerId,
      CometChatMessageEventListener(
        onTextMessageReceived: (textMessage) {
          debugPrint('New message: ${textMessage.text}');
        },
        ccMessageSent: (message, status) {
          debugPrint('Message sent: ${status.name}');
        },
      ),
    );

    // SDK listeners (for raw events)
    CometChat.addMessageListener(_listenerId, this);
  }

  @override
  void dispose() {
    CometChatMessageEvents.removeMessagesListener(_listenerId);
    CometChat.removeMessageListener(_listenerId);
    super.dispose();
  }
}
```

## SDK Listeners (Low-Level)

For raw SDK events, use `CometChat.add{Type}Listener`:

```dart
// Message listener
CometChat.addMessageListener(listenerId, MessageListener());
CometChat.removeMessageListener(listenerId);

// User listener (online/offline)
CometChat.addUserListener(listenerId, UserListener());
CometChat.removeUserListener(listenerId);

// Group listener
CometChat.addGroupListener(listenerId, GroupListener());
CometChat.removeGroupListener(listenerId);

// Call listener
CometChat.addCallListener(listenerId, CallListener());
CometChat.removeCallListener(listenerId);

// Connection listener
CometChat.addConnectionListener(listenerId, ConnectionListener());
CometChat.removeConnectionListener(listenerId);
```

## Gotchas

### Unique Listener IDs
Always use unique IDs. Hardcoded IDs cause collisions when multiple instances of the same widget exist:

```dart
// ❌ WRONG — hardcoded ID
CometChat.addMessageListener('messages', this);

// ✅ CORRECT — unique ID
final id = 'messages_${DateTime.now().millisecondsSinceEpoch}';
CometChat.addMessageListener(id, this);
```

### Always Remove in dispose()
Forgetting to remove listeners causes memory leaks and duplicate event handling:

```dart
// ❌ WRONG — missing removal
@override
void dispose() {
  super.dispose(); // Listener leaks!
}

// ✅ CORRECT
@override
void dispose() {
  CometChat.removeMessageListener(_listenerId);
  CometChatMessageEvents.removeMessagesListener(_listenerId);
  super.dispose();
}
```

### UIKit Events vs SDK Listeners
- Use **UIKit events** (`CometChatMessageEvents`, etc.) when you need to react to UIKit-level actions (message sent via composer, group created via UI)
- Use **SDK listeners** (`CometChat.addMessageListener`, etc.) when you need raw SDK events (message received from network, user status change)
- UIKit components internally use both — they register SDK listeners in their controllers

## Anti-Patterns

```dart
// ❌ WRONG — registering listener without removing
class _BadState extends State<Bad> {
  @override
  void initState() {
    super.initState();
    CometChat.addMessageListener('static_id', this);
    // Never removed → leak
  }
}

// ❌ WRONG — registering in build()
@override
Widget build(BuildContext context) {
  CometChat.addMessageListener(id, this); // Called every rebuild!
  return Container();
}
```

## Checklist — Events

- [ ] Listener ID is unique (use timestamp or widget hashCode)
- [ ] Listener registered in `initState()`, not `build()`
- [ ] Listener removed in `dispose()` with same ID
- [ ] Using UIKit events for UI coordination, SDK listeners for raw events
- [ ] `subscriptionType` set in UIKitSettings for presence events to work
