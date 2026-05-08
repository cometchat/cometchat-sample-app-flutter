---
name: cometchat-flutter-v5-messages
description: >
  Use when working with CometChat Flutter UIKit v5 message components.
  Triggers on CometChatMessageList, CometChatMessageComposer, CometChatCompactMessageComposer,
  CometChatMessageHeader, CometChatThreadedHeader, message bubbles, text formatters,
  send message, edit message, delete message, messagesRequestBuilder, onThreadRepliesClick,
  messageComposerStyle, parentMessageId, CometChatMessageListStyle, message list,
  composer, header, keyboard, rich text, bubbles, threaded messages.
license: "MIT"
compatibility: "cometchat_chat_uikit ^5.2.14; cometchat_uikit_shared ^5.2.3"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter v5 messages list composer header bubbles threads"
---

# CometChat Flutter UIKit v5 — Messages

Components for displaying, sending, and managing messages.

## CometChatMessageList

Displays messages in a conversation. Fetches messages using `MessagesRequestBuilder`.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `user` | `User?` | User for 1-on-1 chat (one of user/group required) |
| `group` | `Group?` | Group for group chat |
| `messagesRequestBuilder` | `MessagesRequestBuilder?` | Custom message fetch builder |
| `style` | `CometChatMessageListStyle?` | Visual styling |
| `alignment` | `ChatAlignment` | `standard` (default) or `leftAligned` |
| `onThreadRepliesClick` | `ThreadRepliesClick?` | Callback for thread reply tap |
| `templates` | `List<CometChatMessageTemplate>?` | Custom message templates |
| `customSoundForMessages` | `String?` | Custom sound asset URL |
| `disableSoundForMessages` | `bool?` | Disable message sounds |
| `hideTimestamp` | `bool?` | Hide message timestamps |
| `avatarVisibility` | `bool` | Show/hide avatars (default: true) |
| `receiptsVisibility` | `bool` | Show/hide read receipts (default: true) |
| `disableReactions` | `bool` | Disable reactions (default: false) |
| `textFormatters` | `List<CometChatTextFormatter>?` | Custom text formatters |
| `disableMentions` | `bool?` | Disable @mentions |
| `parentMessageId` | — | Not a direct prop; use threaded header |
| `scrollController` | `ScrollController?` | Custom scroll controller |
| `headerView` | `Widget?` | Custom header widget above messages |
| `footerView` | `Widget?` | Custom footer widget below messages |
| `loadingStateView` | `WidgetBuilder?` | Custom loading state |
| `emptyStateView` | `WidgetBuilder?` | Custom empty state |
| `errorStateView` | `WidgetBuilder?` | Custom error state |
| `dateSeparatorPattern` | `String? Function(DateTime)?` | Custom date separator format |
| `dateSeparatorStyle` | `CometChatDateStyle?` | Date separator styling |
| `onError` | `OnError?` | Error callback |
| `onLoad` | `OnLoad<BaseMessage>?` | Called when messages load |
| `onEmpty` | `OnEmpty?` | Called when list is empty |
| `enableSmartReplies` | `bool` | Enable AI smart replies (default: false) |
| `enableConversationStarters` | `bool` | Enable conversation starters (default: false) |
| `hideStickyDate` | `bool` | Hide sticky date header (default: false) |
| `hideGroupActionMessages` | `bool` | Hide group action messages (default: false) |

### Usage

```dart
// ✅ CORRECT — basic message list
CometChatMessageList(
  user: user,
  alignment: ChatAlignment.standard,
  disableReactions: false,
  receiptsVisibility: true,
)

// ✅ CORRECT — with custom request builder
CometChatMessageList(
  group: group,
  messagesRequestBuilder: MessagesRequestBuilder()
    ..guid = group.guid
    ..limit = 30
    ..setTypes([MessageTypeConstants.text, MessageTypeConstants.image]),
)
```

## CometChatMessageComposer

Input component for sending messages with attachments, voice recording, and AI features.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `user` | `User?` | Target user (one of user/group required) |
| `group` | `Group?` | Target group |
| `messageComposerStyle` | `CometChatMessageComposerStyle?` | Visual styling |
| `parentMessageId` | `int` | Thread parent message ID (default: 0) |
| `placeholderText` | `String?` | Input placeholder text |
| `text` | `String?` | Initial text |
| `onChange` | `Function(String)?` | Text change callback |
| `maxLine` | `int?` | Max input lines |
| `disableTypingEvents` | `bool` | Disable typing indicators (default: false) |
| `disableSoundForMessages` | `bool` | Disable send sound (default: false) |
| `customSoundForMessage` | `String?` | Custom send sound |
| `auxiliaryButtonView` | `ComposerWidgetBuilder?` | Custom auxiliary buttons |
| `secondaryButtonView` | `ComposerWidgetBuilder?` | Custom secondary buttons |
| `sendButtonView` | `Widget?` | Custom send button |
| `headerView` | `Widget?` | Header above composer |
| `footerView` | `Widget?` | Footer below composer |
| `attachmentOptions` | `ComposerActionsBuilder?` | Custom attachment options |
| `auxiliaryButtonsAlignment` | `AuxiliaryButtonsAlignment?` | Position of auxiliary buttons |
| `onSendButtonTap` | `Function?` | Custom send button handler |
| `hideVoiceRecordingButton` | `bool?` | Hide voice recording |
| `textFormatters` | `List<CometChatTextFormatter>?` | Custom text formatters |
| `disableMentions` | `bool?` | Disable @mentions |
| `textEditingController` | `TextEditingController?` | Custom text controller |
| `hideSendButton` | `bool?` | Hide send button |
| `hideAttachmentButton` | `bool?` | Hide attachment button |
| `onError` | `OnError?` | Error callback |
| `stateCallBack` | `Function(CometChatMessageComposerController)?` | Access controller |

### Usage

```dart
// ✅ CORRECT — basic composer
CometChatMessageComposer(
  user: user,
  placeholderText: 'Type a message...',
)

// ✅ CORRECT — threaded composer
CometChatMessageComposer(
  user: user,
  parentMessageId: parentMessage.id,
)
```

## CometChatCompactMessageComposer

A compact variant of the message composer with a more minimal UI.

### Key Props
Same as `CometChatMessageComposer` — accepts `user`, `group`, `messageComposerStyle` (uses `CometChatCompactMessageComposerStyle`), `parentMessageId`, etc.

## CometChatMessageHeader

Displays user/group info at the top of the messages screen. Implements `PreferredSizeWidget` for use as `appBar`.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `user` | `User?` | User to display (one of user/group required) |
| `group` | `Group?` | Group to display |
| `messageHeaderStyle` | `CometChatMessageHeaderStyle?` | Visual styling |
| `subtitleView` | `Widget? Function(Group?, User?, BuildContext)?` | Custom subtitle |
| `listItemView` | `Widget Function(Group?, User?, BuildContext)?` | Custom list item |
| `trailingView` | `List<Widget Function(User?, Group?, BuildContext)>?` | Trailing widgets |
| `showBackButton` | `bool?` | Show back button (default: true) |
| `backButton` | `WidgetBuilder?` | Custom back button |
| `onBack` | `VoidCallback?` | Back button callback |
| `hideVideoCallButton` | `bool?` | Hide video call button |
| `hideVoiceCallButton` | `bool?` | Hide voice call button |
| `titleView` | `Widget? Function()?` | Custom title view |
| `leadingStateView` | `Widget? Function()?` | Custom leading view |
| `auxiliaryButtonView` | `Widget? Function()?` | Custom auxiliary buttons |
| `usersStatusVisibility` | `bool` | Show online status (default: true) |

### Usage

```dart
// ✅ CORRECT — as Scaffold appBar
Scaffold(
  resizeToAvoidBottomInset: false, // REQUIRED with composer
  appBar: CometChatMessageHeader(
    user: user,
    onBack: () => Navigator.pop(context),
  ),
  body: Column(
    children: [
      Expanded(child: CometChatMessageList(user: user)),
      CometChatMessageComposer(user: user),
    ],
  ),
)
```

## CometChatThreadedHeader

Displays the parent message for threaded conversations.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `parentMessage` | `BaseMessage` | The parent message (required) |
| `loggedInUser` | `User?` | Current logged-in user |
| `threadedHeaderStyle` | `CometChatThreadedHeaderStyle?` | Visual styling |
| `closeIcon` | `Widget?` | Custom close icon |
| `onClose` | `VoidCallback?` | Close callback |
| `bubbleView` | `Widget Function(BaseMessage)?` | Custom bubble view |

### Threaded Messages Pattern

```dart
// ✅ CORRECT — threaded messages screen
Scaffold(
  resizeToAvoidBottomInset: false,
  body: Column(
    children: [
      CometChatThreadedHeader(
        parentMessage: parentMessage,
        onClose: () => Navigator.pop(context),
      ),
      Expanded(
        child: CometChatMessageList(
          user: user,
          messagesRequestBuilder: MessagesRequestBuilder()
            ..uid = user.uid
            ..parentMessageId = parentMessage.id
            ..limit = 30,
        ),
      ),
      CometChatMessageComposer(
        user: user,
        parentMessageId: parentMessage.id,
      ),
    ],
  ),
)
```

## Sending Messages Programmatically

Use `CometChatUIKit` static methods (not `CometChat` directly) to ensure events fire:

```dart
// ✅ CORRECT — text message
final message = TextMessage(
  text: 'Hello!',
  receiverUid: user.uid,
  receiverType: ReceiverTypeConstants.user,
);
await CometChatUIKit.sendTextMessage(message,
  onSuccess: (sentMessage) => debugPrint('Sent: ${sentMessage.id}'),
  onError: (e) => debugPrint('Error: ${e.message}'),
);

// ✅ CORRECT — media message
final mediaMessage = MediaMessage(
  receiverUid: user.uid,
  receiverType: ReceiverTypeConstants.user,
  type: MessageTypeConstants.image,
  file: '/path/to/image.jpg',
);
await CometChatUIKit.sendMediaMessage(mediaMessage);

// ❌ WRONG — using CometChat.sendMessage directly
// This bypasses UIKit events (ccMessageSent won't fire)
CometChat.sendMessage(message, onSuccess: ...);
```

## Text Formatters

Custom text formatters transform message text display:

```dart
CometChatMessageList(
  user: user,
  textFormatters: [
    CometChatMentionsFormatter(),
    // Add custom formatters here
  ],
)
```

## Golden Path — Messages Screen

```dart
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

## Anti-Patterns

```dart
// ❌ WRONG — missing resizeToAvoidBottomInset
Scaffold(
  body: Column(children: [
    Expanded(child: CometChatMessageList(user: user)),
    CometChatMessageComposer(user: user),
  ]),
)

// ❌ WRONG — passing both user AND group
CometChatMessageList(user: user, group: group) // Assertion error

// ❌ WRONG — using CometChat.sendMessage instead of CometChatUIKit.sendTextMessage
CometChat.sendMessage(message, onSuccess: ...); // Events won't fire
```

## Checklist — Messages Screen

- [ ] Scaffold has `resizeToAvoidBottomInset: false`
- [ ] Only one of `user` or `group` passed to each component
- [ ] Same `user`/`group` passed to Header, List, and Composer
- [ ] Thread replies use `parentMessageId` on both List and Composer
- [ ] Messages sent via `CometChatUIKit.sendTextMessage()` not `CometChat.sendMessage()`
