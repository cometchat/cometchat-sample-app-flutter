---
name: cometchat-flutter-messages
description: >
  Use when implementing the messages screen with CometChat Flutter UIKit v6. Covers
  CometChatMessageList, CometChatMessageComposer, CometChatMessageHeader, MessageListBloc,
  MessageComposerBloc, SliverSpacing, keyboard-aware spacing, rich text toolbar,
  CometChatTextBubble, CometChatImageBubble, CometChatVideoBubble, CometChatAudioBubble,
  CometChatFileBubble, CometChatMessageBubble, bubble factories, message templates,
  send message, edit message, delete message, reply, thread, reactions, receipts,
  typing indicators, mentions, markdown formatting, text formatters, scroll to bottom,
  unread messages, mark as read, goToMessageId, message options, swipe to reply,
  smart replies, or conversation starters. Also use when
  the user asks about building a chat screen, message input, or message display.
license: "MIT"
compatibility: "cometchat_chat_uikit ^6.0.0; flutter_bloc ^8.1.0"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter messages composer header bubbles keyboard rich-text"
---

# CometChat Flutter UIKit — Messages

The messages screen is composed of three components: `CometChatMessageHeader`, `CometChatMessageList`, and `CometChatMessageComposer`.

## Complete Messages Screen

```dart
Scaffold(
  appBar: CometChatMessageHeader(
    user: user,
    group: group,
    onBack: () => Navigator.pop(context),
  ),
  body: Column(
    children: [
      Expanded(
        child: CometChatMessageList(
          user: user,
          group: group,
          textFormatters: [
            CometChatMentionsFormatter(user: user, group: group),
            MarkdownTextFormatter(),
            CometChatUrlFormatter(),
            CometChatPhoneNumberFormatter(),
            CometChatEmailFormatter(),
          ],
        ),
      ),
      CometChatMessageComposer(
        user: user,
        group: group,
        textFormatters: [
          CometChatMentionsFormatter(user: user, group: group),
          MarkdownTextFormatter(),
          CometChatUrlFormatter(),
        ],
      ),
    ],
  ),
)
```

## CometChatMessageList

Displays messages with `SliverAnimatedList`, O(1) lookups, and keyboard-aware spacing.

### Key Props

| Prop | Type | Purpose |
|------|------|---------|
| `user` / `group` | `User?` / `Group?` | Target conversation (one required) |
| `goToMessageId` | `int?` | Jump to specific message on load |
| `startFromUnreadMessages` | `bool` | Start from unread position |
| `hideDeletedMessages` | `bool` | Hide deleted message placeholders |
| `disableReceipts` | `bool` | Hide read/delivered receipts |
| `disableReactions` | `bool` | Hide reaction bar |
| `enableSwipeToReply` | `bool` | Swipe gesture for reply |
| `hideDateSeparator` | `bool` | Hide date headers |
| `textFormatters` | `List<CometChatTextFormatter>` | Formatters for message text |
| `onThreadRepliesClick` | `Function(BaseMessage, BuildContext, {template})` | Thread navigation callback |

### MessageListBloc Events

| Event | Purpose |
|-------|---------|
| `LoadMessages(conversationWith, conversationType)` | Initial load |
| `LoadOlderMessages` | Scroll up pagination |
| `LoadNewerMessages` | Scroll down pagination |
| `MessageReceived(message)` | Real-time incoming message |
| `MessageEdited(message)` | Real-time edit |
| `MessageDeleted(message)` | Real-time delete |
| `JumpToMessage(messageId)` | Scroll to specific message |
| `MarkMessageAsRead(message)` | Mark as read |
| `MarkMessageAsUnread(message)` | Mark as unread |

### MessageListState

```dart
MessageListState(
  status: MessageListStatus.loaded,  // initial, loading, loaded, empty, error
  messages: [...],
  isLoadingOlder: false,
  isLoadingNewer: false,
  hasMoreOlder: true,
  hasMoreNewer: false,
  unreadCount: 5,
  unreadMessageAnchor: message,
)
```

## CometChatMessageComposer

Rich text input with formatting toolbar, attachments, mentions, and audio recording.

### Key Props

| Prop | Type | Purpose |
|------|------|---------|
| `user` / `group` | `User?` / `Group?` | Target conversation |
| `disableTypingEvents` | `bool` | Stop sending typing indicators |
| `hideVoiceRecordingButton` | `bool` | Hide audio recorder |
| `hideSendButton` | `bool` | Hide send button |
| `hideAttachmentButton` | `bool` | Hide attachment picker |
| `hideStickersButton` | `bool` | Hide sticker panel |
| `disableMentions` | `bool` | Disable @mentions |
| `hideBottomSafeArea` | `bool` | Hide bottom safe area padding |
| `textFormatters` | `List<CometChatTextFormatter>` | Text formatters |

### Rich Text Formatting

The composer uses a WYSIWYG system (not the clean architecture module):
- `RichTextEditingController` — span tracking, markdown rendering, format application
- `SegmentComposerController` — multi-segment (normal text + code blocks)
- Toolbar buttons dispatch through `cometchat_message_composer.dart`

### buildWhen Optimization

The composer uses `buildWhen` to prevent rebuilds during keyboard animation:
```dart
BlocConsumer<MessageComposerBloc, MessageComposerState>(
  buildWhen: (previous, current) =>
      previous.isEditMode != current.isEditMode ||
      previous.isReplyMode != current.isReplyMode ||
      previous.isRecordingMode != current.isRecordingMode,
  // ...
)
```

## CometChatMessageHeader

Shows user/group info, typing indicators, and optional call buttons.

```dart
CometChatMessageHeader(
  user: user,
  group: group,
  onBack: () => Navigator.pop(context),
  hideVideoCallButton: false,
  hideVoiceCallButton: false,
  usersStatusVisibility: true,
  trailingView: (user, group, ctx) => [
    IconButton(icon: Icon(Icons.info_outline), onPressed: () { /* ... */ }),
  ],
  messageHeaderStyle: CometChatMessageHeaderStyle(
    backgroundColor: colorPalette.background1,
  ),
)
```

## Keyboard-Aware Spacing

`SliverSpacing` handles keyboard interaction inside the message list:
- At bottom: keyboard pushes list up (normal behavior)
- Scrolled up: list stays still, only composer moves
- Safe area: only added when keyboard is closed

## Message Bubbles

| Type | Widget | Key Features |
|------|--------|--------------|
| Text | `CometChatTextBubble` | Rich text, links, markdown |
| Image | `CometChatImageBubble` | Local/network, GIF, HEIC fallback |
| Video | `CometChatVideoBubble` | Thumbnail, play overlay |
| Audio | `CometChatAudioBubble` | Waveform, play/pause, duration |
| File | `CometChatFileBubble` | Type icon, download, size |
| Deleted | `CometChatDeletedBubble` | "Message was deleted" |

All bubble widgets accept optional `colorPalette`, `spacing`, `typography` params for the hybrid theme caching pattern.

## Sending Messages

```dart
// Text message
await CometChatUIKit.sendTextMessage(
  TextMessage(
    text: 'Hello!',
    receiverUid: user.uid,
    receiverType: ReceiverTypeConstants.user,
  ),
);

// Media message
await CometChatUIKit.sendMediaMessage(
  MediaMessage(
    file: '/path/to/image.jpg',
    type: MessageTypeConstants.image,
    receiverUid: user.uid,
    receiverType: ReceiverTypeConstants.user,
  ),
);

// Custom message
await CometChatUIKit.sendCustomMessage(
  CustomMessage(
    type: 'location',
    receiverUid: user.uid,
    receiverType: ReceiverTypeConstants.user,
    customData: {'latitude': 37.7749, 'longitude': -122.4194},
  ),
);
```

## Thread Replies

```dart
CometChatMessageList(
  onThreadRepliesClick: (message, ctx, {template}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Column(
          children: [
            CometChatThreadedHeader(
              parentMessage: message,
              loggedInUser: CometChatUIKit.loggedInUser!,
            ),
            Expanded(child: CometChatMessageList(
              user: user, group: group,
              parentMessageId: message.id,
            )),
            CometChatMessageComposer(
              user: user, group: group,
              parentMessageId: message.id,
            ),
          ],
        ),
      ),
    ));
  },
)
```

## Gotchas

- `textFormatters` should be the same list for both `CometChatMessageList` and `CometChatMessageComposer` to ensure consistent rendering.
- The rich text system has 3 implementations but only WYSIWYG is active at runtime. Bug fixes go in `rich_text_editing_controller.dart`, not the clean architecture module.
- `goToMessageId` loads messages around that ID, not from the beginning. The list may not have older messages loaded.
- Keep mutable `_user`/`_group` copies in your State class and update them from SDK listeners. Passing `widget.user`/`widget.group` directly means stale data after block/kick events.
- The CometChat SDK has an `Action` class (a `BaseMessage` subclass used in group events like kick/ban/scope-change). It conflicts with Flutter's built-in `Action` widget. If your messages screen uses SDK listener mixins that reference `Action`, use an import alias:
  ```dart
  import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
  // Then use: cc.Action instead of Action
  ```
  This is especially common when mixing `GroupListener` into a messages screen State class.

## Anti-Patterns

```dart
// ❌ WRONG — passing immutable widget params to UIKit components
CometChatMessageList(user: widget.user) // Stale after block/unblock

// ✅ CORRECT — mutable state copy
late User? _user = widget.user;
// Update _user from SDK listeners
CometChatMessageList(user: _user)
```

```dart
// ❌ WRONG — different formatters for list and composer
CometChatMessageList(textFormatters: [MarkdownTextFormatter()])
CometChatMessageComposer(textFormatters: []) // Inconsistent rendering

// ✅ CORRECT — same formatters
final formatters = [CometChatMentionsFormatter(user: user), MarkdownTextFormatter()];
CometChatMessageList(textFormatters: formatters)
CometChatMessageComposer(textFormatters: formatters)
```

## Checklist

- [ ] Both list and composer have matching `textFormatters`
- [ ] Mutable `_user`/`_group` state copies, not `widget.user`/`widget.group`
- [ ] `onThreadRepliesClick` navigates to thread screen with `parentMessageId`
- [ ] SDK listeners update `_user`/`_group` for block/kick/scope changes
- [ ] Colors from `CometChatThemeHelper`, cached in `didChangeDependencies()`
- [ ] If using SDK listener mixins with `Action`, import UIKit `as cc` to avoid Flutter name conflict
