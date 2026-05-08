---
name: cometchat-flutter-v5-conversations
description: >
  Use when working with CometChat Flutter UIKit v5 conversation list component.
  Triggers on CometChatConversations, conversation list, recent chats, conversationsRequestBuilder,
  conversationsStyle, CometChatConversationsController, onItemTap, subtitleView, listItemView,
  trailingView, leadingView, titleView, ConversationsBuilderProtocol, conversation screen.
license: "MIT"
compatibility: "cometchat_chat_uikit ^5.2.14; cometchat_uikit_shared ^5.2.3"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter v5 conversations list recent chats"
---

# CometChat Flutter UIKit v5 — Conversations

The `CometChatConversations` component displays a list of recent conversations.

## CometChatConversations

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `conversationsRequestBuilder` | `ConversationsRequestBuilder?` | Custom fetch builder |
| `conversationsProtocol` | `ConversationsBuilderProtocol?` | Custom builder protocol |
| `conversationsStyle` | `CometChatConversationsStyle` | Visual styling (default: `const CometChatConversationsStyle()`) |
| `onItemTap` | `Function(Conversation)?` | Tap callback |
| `onItemLongPress` | `Function(Conversation)?` | Long press callback |
| `subtitleView` | `Widget? Function(BuildContext, Conversation)?` | Custom subtitle per item |
| `listItemView` | `Widget Function(Conversation)?` | Fully custom list item |
| `trailingView` | `Widget? Function(Conversation)?` | Custom trailing widget |
| `leadingView` | `Widget? Function(BuildContext, Conversation)?` | Custom leading widget |
| `titleView` | `Widget? Function(BuildContext, Conversation)?` | Custom title widget |
| `title` | `String?` | List title (default: "Chats") |
| `showBackButton` | `bool` | Show back button (default: false) |
| `onBack` | `VoidCallback?` | Back button callback |
| `backButton` | `Widget?` | Custom back button |
| `hideAppbar` | `bool?` | Hide app bar (default: false) |
| `appBarOptions` | `List<Widget>?` | App bar trailing widgets |
| `selectionMode` | `SelectionMode?` | Enable selection mode |
| `onSelection` | `Function(List<Conversation>?)?` | Selection callback |
| `activateSelection` | `ActivateSelection?` | Selection activation mode |
| `usersStatusVisibility` | `bool?` | Show online status (default: true) |
| `receiptsVisibility` | `bool?` | Show read receipts (default: true) |
| `protectedGroupIcon` | `Widget?` | Icon for protected groups |
| `privateGroupIcon` | `Widget?` | Icon for private groups |
| `readIcon` | `Widget?` | Custom read receipt icon |
| `deliveredIcon` | `Widget?` | Custom delivered receipt icon |
| `sentIcon` | `Widget?` | Custom sent receipt icon |
| `datePattern` | `String Function(Conversation)?` | Custom date format |
| `typingIndicatorText` | `String?` | Custom typing text |
| `hideError` | `bool?` | Hide error dialog |
| `loadingStateView` | `WidgetBuilder?` | Custom loading state |
| `emptyStateView` | `WidgetBuilder?` | Custom empty state |
| `errorStateView` | `WidgetBuilder?` | Custom error state |
| `listItemStyle` | `ListItemStyle?` | Style for list items |
| `textFormatters` | `List<CometChatTextFormatter>?` | Text formatters for subtitles |
| `deleteConversationOptionVisibility` | `bool?` | Show delete option (default: true) |
| `groupTypeVisibility` | `bool?` | Show group type icon (default: true) |
| `controllerTag` | `String?` | Custom GetX controller tag |
| `onError` | `OnError?` | Error callback |
| `onLoad` | `OnLoad<Conversation>?` | Load callback |
| `onEmpty` | `OnEmpty?` | Empty state callback |
| `customSoundForMessages` | `String?` | Custom message sound |
| `disableSoundForMessages` | `bool?` | Disable message sounds (default: false) |
| `hideSearch` | `bool?` | Hide search bar |
| `searchReadOnly` | `bool` | Read-only search (default: false) |
| `onSearchTap` | `GestureTapCallback?` | Search tap callback |
| `setOptions` | `List<CometChatOption>? Function(Conversation, CometChatConversationsController, BuildContext)?` | Replace long-press options |
| `addOptions` | `List<CometChatOption>? Function(Conversation, CometChatConversationsController, BuildContext)?` | Add to long-press options |

### Basic Usage

```dart
// ✅ CORRECT — minimal conversations list
CometChatConversations(
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
)
```

### Custom Subtitle

```dart
// ✅ CORRECT — custom subtitle view
CometChatConversations(
  subtitleView: (context, conversation) {
    final lastMessage = conversation.lastMessage;
    if (lastMessage is TextMessage) {
      return Text(
        lastMessage.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return null; // Falls back to default
  },
)
```

### Custom Request Builder

```dart
// ✅ CORRECT — filter conversations
CometChatConversations(
  conversationsRequestBuilder: ConversationsRequestBuilder()
    ..limit = 30
    ..setConversationType(ConversationTypeConstants.user),
)
```

### Styling

```dart
CometChatConversations(
  conversationsStyle: CometChatConversationsStyle(
    backgroundColor: Colors.white,
    titleTextColor: Colors.black,
    separatorColor: Colors.grey.shade200,
  ),
)
```

## Internal Architecture (GetX)

The component creates a `CometChatConversationsController` via `Get.put()` in `initState()` and deletes it in `dispose()` (unless `controllerTag` is provided externally).

```dart
// Internal pattern:
conversationsController = Get.put<CometChatConversationsController>(
  CometChatConversationsController(
    conversationsBuilderProtocol: widget.conversationsProtocol ??
        UIConversationsBuilder(
          widget.conversationsRequestBuilder ?? ConversationsRequestBuilder(),
        ),
    mode: widget.selectionMode,
    // ...
  ),
  tag: tag,
);
```

Theme values are cached in `didChangeDependencies()`:
```dart
@override
void didChangeDependencies() {
  typography = CometChatThemeHelper.getTypography(context);
  colorPalette = CometChatThemeHelper.getColorPalette(context);
  spacing = CometChatThemeHelper.getSpacing(context);
  style = CometChatThemeHelper.getTheme<CometChatConversationsStyle>(
      context: context, defaultTheme: CometChatConversationsStyle.of)
    .merge(widget.conversationsStyle);
  super.didChangeDependencies();
}
```

## Golden Path — Conversations Screen

```dart
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
```

## Anti-Patterns

```dart
// ❌ WRONG — trying to access controller before component mounts
final controller = Get.find<CometChatConversationsController>();

// ❌ WRONG — manually creating controller outside the widget
Get.put(CometChatConversationsController(...)); // Let the widget manage it

// ❌ WRONG — not extracting User/Group from conversation
onItemTap: (conversation) {
  // conversation.conversationWith is AppEntity, not User or Group directly
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => MessagesScreen(user: conversation.conversationWith), // Type error
  ));
}
```

## Checklist — Conversations

- [ ] `onItemTap` extracts `User`/`Group` from `conversation.conversationWith` with type check
- [ ] Navigation to messages screen passes extracted `user` or `group`
- [ ] Custom styles passed via `conversationsStyle` prop
- [ ] Let the widget manage its own GetX controller lifecycle
