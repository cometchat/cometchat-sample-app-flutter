# CometChat Flutter UIKit v6 — API Reference

Load this file when you need the full API surface for a specific component.

## Package Imports

```dart
// Chat components (conversations, messages, users, groups, search, etc.)
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

// Call components (incoming, outgoing, ongoing, call logs)
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';

// Resolve Action name conflict (CometChat Action vs Flutter Action)
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
// Then use: cc.Action
```

## Widget Quick Reference

| Widget | Required Props | Key Optional Props | onItemTap Signature |
|--------|---------------|-------------------|-------------------|
| `CometChatConversations` | — | `onItemTap`, `conversationsStyle`, `subtitleView`, `trailingView`, `listItemView`, `textFormatters`, `conversationsRequestBuilder` | `Function(Conversation)` |
| `CometChatMessageList` | `user` OR `group` | `goToMessageId`, `textFormatters`, `onThreadRepliesClick`, `hideDeletedMessages`, `disableReceipts`, `disableReactions`, `enableSwipeToReply` | — |
| `CometChatMessageComposer` | `user` OR `group` | `textFormatters`, `disableTypingEvents`, `hideVoiceRecordingButton`, `hideSendButton`, `hideAttachmentButton`, `disableMentions` | — |
| `CometChatMessageHeader` | `user` OR `group` | `onBack`, `trailingView`, `messageHeaderStyle`, `hideVideoCallButton`, `hideVoiceCallButton`, `usersStatusVisibility` | — |
| `CometChatUsers` | — | `onItemTap`, `usersStyle`, `usersRequestBuilder`, `selectionMode`, `subtitleView`, `trailingView` | `Function(BuildContext, User)` |
| `CometChatGroups` | — | `onItemTap`, `groupsStyle`, `groupsRequestBuilder`, `selectionMode`, `groupTypeVisibility` | `Function(BuildContext, Group)` |
| `CometChatGroupMembers` | `group` | `groupMembersStyle`, `selectionMode` | — |
| `CometChatSearch` | — | `searchStyle`, `onItemTap` | — |
| `CometChatThreadedHeader` | `parentMessage`, `loggedInUser` | `style`, `template`, `receiptsVisibility`, `textFormatters`, `colorPalette`, `typography`, `spacing` | — |

## BLoC Quick Reference

| BLoC | Key Events | State Type |
|------|-----------|------------|
| `ConversationsBloc` | `LoadConversations`, `LoadMoreConversations`, `DeleteConversation`, `SetActiveConversation` | `ConversationsInitial/Loading/Loaded/Empty/Error` |
| `MessageListBloc` | `LoadMessages`, `LoadOlderMessages`, `MessageReceived`, `MessageEdited`, `JumpToMessage` | `MessageListState` (single class with `status` enum) |
| `MessageComposerBloc` | Send events, edit/reply mode toggles | `MessageComposerState` |
| `UsersBloc` | `LoadUsers`, `LoadMoreUsers`, `SearchUsers` | Status-based states |
| `GroupsBloc` | `LoadGroups`, `LoadMoreGroups`, `SearchGroups` | Status-based states |

## ServiceLocator Quick Reference

All follow the same pattern:
```dart
{Component}ServiceLocator.instance.setup();  // Call once
{Component}ServiceLocator.instance.{useCase}; // Access use cases
{Component}ServiceLocator.instance.reset();   // For testing
```

Available: `ConversationsServiceLocator`, `MessageListServiceLocator`, `MessageComposerServiceLocator`, `UsersServiceLocator`, `GroupsServiceLocator`, `GroupMembersServiceLocator`, `CallLogsServiceLocator`.

## Text Formatters

| Formatter | Purpose |
|-----------|---------|
| `CometChatMentionsFormatter(user:, group:)` | @mention detection and rendering |
| `MarkdownTextFormatter()` | Bold, italic, strikethrough, code, links |
| `CometChatUrlFormatter()` | URL detection and link rendering |
| `CometChatPhoneNumberFormatter()` | Phone number detection |
| `CometChatEmailFormatter()` | Email detection |

## Message Types (SDK Constants)

| Constant | Value |
|----------|-------|
| `MessageTypeConstants.text` | `'text'` |
| `MessageTypeConstants.image` | `'image'` |
| `MessageTypeConstants.video` | `'video'` |
| `MessageTypeConstants.audio` | `'audio'` |
| `MessageTypeConstants.file` | `'file'` |

## Receiver Types

| Constant | Value |
|----------|-------|
| `ReceiverTypeConstants.user` | `'user'` |
| `ReceiverTypeConstants.group` | `'group'` |

## Error Codes

| Code | Message | Cause |
|------|---------|-------|
| `ERR` | Authentication null | `CometChatUIKit.init()` not called |
| `appIdErr` | APP ID null | `appId` not set in UIKitSettingsBuilder |
| `ERR_ALREADY_LOGGED_IN` | User already logged in | Calling login when session exists |
| `ERR_INVALID_REGION` | Invalid region | Region not lowercase or not in ['us', 'eu', 'in'] |
