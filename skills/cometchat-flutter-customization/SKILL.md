---
name: cometchat-flutter-customization
description: >
  Customize CometChat Flutter UIKit v6 beyond defaults — four tiers: props/view slots,
  request builders, text formatters + message templates, and BubbleFactory/DataSource.
  Use when the user wants custom bubbles, custom headers, custom list items, custom
  message actions, or custom message types.
license: "MIT"
compatibility: "cometchat_chat_uikit ^6.0.0"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter customization bubbles templates formatters datasource"
---

# CometChat Flutter UIKit v6 — Customization Guide

Four tiers of customization, from lightest to deepest.

## 1. Four-Tier Customization Model

| Tier | Mechanism | Scope | When to Use |
|------|-----------|-------|-------------|
| 1 | Props & View Slots | Per-component UI overrides | Custom list items, subtitles, trailing widgets, headers |
| 2 | Request Builders | Data filtering & pagination | Filter conversations, users, groups, messages, group members |
| 3 | Text Formatters & Message Templates | Message rendering & actions | Custom text styling, custom long-press options, custom bubble slots |
| 4 | BubbleFactory & DataSource | New message types | Location bubbles, poll bubbles, any custom `category_type` |

Start at Tier 1. Move deeper only when the lighter tier can't solve the problem.

## 2. Tier 1: Props & View Slots

Every list-based component exposes view slot callbacks that let you replace individual parts of each list item without rebuilding the entire widget.

### CometChatConversations

```dart
CometChatConversations(
  // Replace the entire list item
  listItemView: (Conversation conversation) => MyCustomConversationTile(conversation),

  // Replace individual slots
  subtitleView: (BuildContext context, Conversation conversation) =>
      Text(conversation.lastMessage?.text ?? ''),
  trailingView: (Conversation conversation) =>
      Icon(Icons.chevron_right),
  leadingView: (BuildContext context, Conversation conversation) =>
      CircleAvatar(child: Text(conversation.conversationWith?.name?[0] ?? '')),
  titleView: (BuildContext context, Conversation conversation) =>
      Text(conversation.conversationWith?.name ?? '', style: TextStyle(fontWeight: FontWeight.bold)),

  // State views
  emptyStateView: (context) => Center(child: Text('No conversations yet')),
  errorStateView: (context) => Center(child: Text('Something went wrong')),
  loadingStateView: (context) => Center(child: CircularProgressIndicator()),
)
```

### CometChatUsers

```dart
CometChatUsers(
  listItemView: (User user) => MyCustomUserTile(user),
  subtitleView: (BuildContext context, User user) => Text(user.status ?? ''),
  trailingView: (BuildContext context, User user) => Icon(Icons.message),
  leadingView: (BuildContext context, User user) => CometChatAvatar(name: user.name),
  titleView: (BuildContext context, User user) => Text(user.name),
)
```

### CometChatGroups

```dart
CometChatGroups(
  listItemView: (Group group) => MyCustomGroupTile(group),
  subtitleView: (BuildContext context, Group group) =>
      Text('${group.membersCount} members'),
  trailingView: (BuildContext context, Group group) => Icon(Icons.arrow_forward),
  leadingView: (BuildContext context, Group group) => CometChatAvatar(name: group.name),
  titleView: (BuildContext context, Group group) => Text(group.name),
)
```

### CometChatMessageHeader

```dart
CometChatMessageHeader(
  user: user,
  group: group,
  subtitleView: (Group? group, User? user, BuildContext context) =>
      Text('Custom subtitle'),
  trailingView: (User? user, Group? group, BuildContext context) => [
    IconButton(icon: Icon(Icons.search), onPressed: () {}),
    IconButton(icon: Icon(Icons.info_outline), onPressed: () {}),
  ],
  listItemView: (Group? group, User? user, BuildContext context) =>
      MyCustomHeaderWidget(user: user, group: group),
  titleView: null, // use default
  leadingStateView: null, // use default
)
```

### CometChatMessageList

```dart
CometChatMessageList(
  user: user,
  group: group,
  headerView: (context, state) => MyCustomListHeader(),
  footerView: (context, state) => MyCustomListFooter(),
  emptyStateView: (context) => Center(child: Text('Start a conversation')),
  emptyChatGreetingView: (context) => WelcomeWidget(),
  loadingStateView: (context) => ShimmerList(),
  errorStateView: (context) => RetryWidget(),
)
```

### CometChatMessageComposer

```dart
CometChatMessageComposer(
  user: user,
  group: group,
  headerView: (context, state) => ReplyPreviewBanner(),
  footerView: (context, state) => SuggestedActionsBar(),
  auxiliaryButtonView: (context, user, group, composerState) =>
      IconButton(icon: Icon(Icons.gif), onPressed: () {}),
  secondaryButtonView: (context, user, group, composerState) =>
      IconButton(icon: Icon(Icons.attach_file), onPressed: () {}),
  sendButtonView: Icon(Icons.send, color: Colors.blue),
)
```

## 3. Tier 2: Request Builders

Override the SDK request builder to control what data is fetched.

### ConversationsRequestBuilder

```dart
CometChatConversations(
  conversationsRequestBuilder: ConversationsRequestBuilder()
    ..limit = 30
    ..conversationType = ConversationType.user // only 1-on-1 chats
    ..withTags = true
    ..tags = ['vip'],
)
```

### MessagesRequestBuilder

```dart
CometChatMessageList(
  user: user,
  messagesRequestBuilder: MessagesRequestBuilder()
    ..uid = user.uid
    ..limit = 50
    ..hideDeletedMessages = true
    ..searchKeyword = 'invoice'
    ..categories = [MessageCategoryConstants.message]
    ..types = [MessageTypeConstants.text, MessageTypeConstants.image],
)
```

### UsersRequestBuilder

```dart
CometChatUsers(
  usersRequestBuilder: UsersRequestBuilder()
    ..limit = 30
    ..friendsOnly = true
    ..searchKeyword = 'john'
    ..roles = ['admin', 'moderator'],
)
```

### GroupsRequestBuilder

```dart
CometChatGroups(
  groupsRequestBuilder: GroupsRequestBuilder()
    ..limit = 30
    ..joinedOnly = true
    ..searchKeyword = 'team'
    ..withTags = true
    ..tags = ['project-alpha'],
)
```

### GroupMembersRequestBuilder

```dart
CometChatGroupMembers(
  group: group,
  groupMembersRequestBuilder: GroupMembersRequestBuilder(group.guid)
    ..limit = 30
    ..scopes = [GroupMemberScope.admin, GroupMemberScope.moderator],
)
```

## 4. Tier 3: Text Formatters & Message Templates

### Text Formatters

`CometChatTextFormatter` is the abstract base class. Subclass it to create custom text styling in both the message list and the composer.

Built-in formatters:

| Formatter | Purpose |
|-----------|---------|
| `CometChatMentionsFormatter` | @mention users with suggestion list |
| `MarkdownTextFormatter` | Bold, italic, strikethrough, code, links, lists |
| `CometChatUrlFormatter` | Clickable URLs |
| `CometChatPhoneNumberFormatter` | Clickable phone numbers |
| `CometChatEmailFormatter` | Clickable email addresses |

Key properties on `CometChatTextFormatter`:

```dart
abstract class CometChatTextFormatter implements Formatter {
  String? trackingCharacter;       // e.g. '@' for mentions
  RegExp? pattern;                 // regex to match in text
  Function(String?)? onSearch;     // called when tracking character typed
  bool? showLoadingIndicator;
  BaseMessage? message;
  User? user;
  Group? group;
  StreamSink<List<SuggestionListItem>>? suggestionListEventSink;

  void init();
  void handlePreMessageSend(BuildContext context, BaseMessage baseMessage);
  void onScrollToBottom(TextEditingController textEditingController);
  void onChange(TextEditingController textEditingController, String previousText);

  List<AttributedText> buildInputFieldText({...});
  List<AttributedText> getAttributedText(String text, BuildContext context, BubbleAlignment? alignment, {...});
  TextStyle getMessageBubbleTextStyle(BuildContext context, BubbleAlignment? alignment, {bool forConversation = false});
  TextStyle getMessageInputTextStyle(BuildContext context);
}
```

Pass the same formatters to both list and composer:

```dart
final formatters = [
  CometChatMentionsFormatter(user: user, group: group),
  MarkdownTextFormatter(),
  CometChatUrlFormatter(),
  CometChatPhoneNumberFormatter(),
  CometChatEmailFormatter(),
];

CometChatMessageList(user: user, textFormatters: formatters)
CometChatMessageComposer(user: user, textFormatters: formatters)
```

### Message Templates

`CometChatMessageTemplate` controls how a message type renders in the bubble and what long-press options appear.

```dart
class CometChatMessageTemplate {
  CometChatMessageTemplate({
    required this.type,       // e.g. 'text', 'image', or 'location'
    required this.category,   // e.g. 'message' or 'custom'
    this.bubbleView,          // replaces the ENTIRE bubble
    this.headerView,          // top of bubble (sender name area)
    this.contentView,         // main content area
    this.footerView,          // below statusInfoView
    this.bottomView,          // below contentView
    this.statusInfoView,      // receipts/time area
    this.threadView,          // thread reply indicator
    this.replyView,           // quoted reply preview
    this.options,             // long-press menu options
  });
}
```

Override templates on `CometChatMessageList`:

```dart
CometChatMessageList(
  user: user,
  // Replace all templates
  templates: [
    CometChatMessageTemplate(
      type: MessageTypeConstants.text,
      category: MessageCategoryConstants.message,
      contentView: (message, context, alignment, {additionalConfigurations}) =>
          MyCustomTextContent(message: message),
      options: (loggedInUser, message, context, group, additionalConfigurations) => [
        CometChatMessageOption(
          id: 'bookmark',
          title: 'Bookmark',
          icon: Icon(Icons.bookmark_border, size: 24),
          onItemClick: (message, state) {
            // handle bookmark
          },
        ),
      ],
    ),
  ],
  // Or add templates alongside defaults
  addTemplate: [
    CometChatMessageTemplate(
      type: 'location',
      category: 'custom',
      contentView: (message, context, alignment, {additionalConfigurations}) =>
          LocationBubbleContent(message: message as CustomMessage),
    ),
  ],
)
```

`CometChatMessageOption` model:

```dart
CometChatMessageOption(
  id: 'pin',                    // unique identifier
  title: 'Pin Message',         // display text
  icon: Icon(Icons.push_pin),   // leading icon
  onItemClick: (BaseMessage message, CometChatMessageListControllerProtocol state) {
    // your action
  },
  messageOptionSheetStyle: CometChatMessageOptionSheetStyle(...),
)
```

## 5. Tier 4: BubbleFactory & DataSource

### BubbleFactory

The deepest customization for rendering message content. Each factory handles one `category_type` key.

```dart
/// Abstract factory — one per message type.
abstract class BubbleFactory<T extends BaseMessage> {
  Widget build(
    BuildContext context,
    T message,
    BubbleAlignment alignment, {
    CometChatColorPalette? colorPalette,
    CometChatTypography? typography,
    CometChatSpacing? spacing,
  });

  /// Returns "category_type" key, or "deleted" for deleted messages.
  static String getFactoryKey(BaseMessage message);

  /// Creates a key from category + type strings.
  static String createKey(String category, String type) => '${category}_$type';
}
```

### DefaultBubbleFactories

The built-in registry:

```dart
class DefaultBubbleFactories {
  static Map<String, BubbleFactory> getDefaults({
    List<CometChatTextFormatter>? textFormatters,
    CometChatTextBubbleStyle? incomingTextStyle,
    CometChatTextBubbleStyle? outgoingTextStyle,
    CometChatImageBubbleStyle? imageStyle,
    CometChatVideoBubbleStyle? videoStyle,
    CometChatAudioBubbleStyle? audioStyle,
    CometChatFileBubbleStyle? fileStyle,
  });
}
```

Default keys registered:
- `message_text` → `TextBubbleFactory`
- `message_image` → `ImageBubbleFactory`
- `message_video` → `VideoBubbleFactory`
- `message_audio` → `AudioBubbleFactory`
- `message_file` → `FileBubbleFactory`
- `deleted` → `DeletedBubbleFactory`

### Creating a Custom BubbleFactory

Example: a location message bubble.

```dart
class LocationBubbleFactory extends BubbleFactory<CustomMessage> {
  @override
  Widget build(
    BuildContext context,
    CustomMessage message,
    BubbleAlignment alignment, {
    CometChatColorPalette? colorPalette,
    CometChatTypography? typography,
    CometChatSpacing? spacing,
  }) {
    final data = message.customData;
    final lat = data?['latitude'] as double? ?? 0;
    final lng = data?['longitude'] as double? ?? 0;

    return GestureDetector(
      onTap: () => _openMap(lat, lng),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=15&size=300x200&key=YOUR_KEY',
            width: 240,
            height: 160,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(spacing?.padding2 ?? 8),
            child: Text(
              '📍 $lat, $lng',
              style: typography?.body?.regular,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Registering Custom Factories

Merge your custom factories with the defaults using `CometChatMessageTemplate.addTemplate` on the message list, or by providing a custom `templates` list that includes a `contentView` for your custom type.

The `CometChatMessageBubble` widget supports two modes:
- Smart mode: pass `message` and the factory registry resolves the content widget via `BubbleFactory.getFactoryKey(message)` → O(1) map lookup.
- Manual mode: pass `contentView` directly — bypasses the factory.

```dart
// Using addTemplate to register a custom type alongside defaults
CometChatMessageList(
  user: user,
  addTemplate: [
    CometChatMessageTemplate(
      type: 'location',
      category: 'custom',
      contentView: (message, context, alignment, {additionalConfigurations}) {
        final factory = LocationBubbleFactory();
        return factory.build(context, message as CustomMessage, alignment);
      },
    ),
  ],
)
```

### DataSource Pattern

Each component follows Clean Architecture with its own data source layer. The data sources abstract SDK calls behind interfaces:

```dart
// Example: ConversationsRemoteDataSource
abstract class ConversationsRemoteDataSource {
  Future<List<Conversation>> getConversations({ConversationsRequest? request});
  Future<void> deleteConversation(String conversationWith);
}

class ConversationsRemoteDataSourceImpl implements ConversationsRemoteDataSource {
  // Delegates to CometChat SDK
}
```

To customize data fetching, provide a custom BLoC instance:

```dart
CometChatConversations(
  conversationsBloc: MyCustomConversationsBloc(),
)

CometChatUsers(
  usersBloc: MyCustomUsersBloc(),
)

CometChatGroups(
  groupsBloc: MyCustomGroupsBloc(),
)

CometChatMessageList(
  messageListBloc: MyCustomMessageListBloc(),
)
```

## 6. Style Overrides

Every component has a `CometChat{Component}Style` class that extends `ThemeExtension`. Styles use a `merge()` pattern — your overrides layer on top of theme defaults.

### Pattern

```dart
@immutable
class CometChatTextBubbleStyle extends ThemeExtension<CometChatTextBubbleStyle> {
  const CometChatTextBubbleStyle({
    this.textStyle,
    this.textColor,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.messageBubbleAvatarStyle,
    this.messageBubbleDateStyle,
    this.messageBubbleBackgroundImage,
    this.senderNameTextStyle,
    this.messageReceiptStyle,
    // ...
  });

  // Factory to get theme-registered instance
  static CometChatTextBubbleStyle of(BuildContext context) => const CometChatTextBubbleStyle();

  // Merge your overrides on top of theme defaults
  CometChatTextBubbleStyle merge(CometChatTextBubbleStyle? style);

  // copyWith for selective overrides
  CometChatTextBubbleStyle copyWith({...});
}
```

### Usage

```dart
CometChatConversations(
  conversationsStyle: CometChatConversationsStyle(
    backgroundColor: Colors.grey[100],
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  ),
)

CometChatMessageHeader(
  user: user,
  messageHeaderStyle: CometChatMessageHeaderStyle(
    backgroundColor: colorPalette.background1,
  ),
)

CometChatMessageList(
  user: user,
  style: CometChatMessageListStyle(
    backgroundColor: Colors.white,
  ),
)

CometChatMessageComposer(
  user: user,
  messageComposerStyle: CometChatMessageComposerStyle(
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.circular(24),
  ),
)
```

### Theme Caching

For performance, parent widgets cache theme lookups in `didChangeDependencies()` and pass them to children via optional `colorPalette`, `spacing`, `typography` params. This avoids expensive `CometChatThemeHelper` lookups during keyboard animation rebuilds.

```dart
// Parent caches once
late CometChatColorPalette _colorPalette;
bool _themeInitialized = false;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (!_themeInitialized) {
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    _themeInitialized = true;
  }
}

// Pass to children
CometChatMessageBubble(
  colorPalette: _colorPalette,  // pre-cached, zero lookups in child
  spacing: _spacing,
)
```

## 7. Anti-Patterns

```dart
// ❌ WRONG — different formatters for list and composer
CometChatMessageList(textFormatters: [MarkdownTextFormatter()])
CometChatMessageComposer(textFormatters: []) // inconsistent rendering

// ✅ CORRECT — same formatter list
final formatters = [CometChatMentionsFormatter(user: user), MarkdownTextFormatter()];
CometChatMessageList(textFormatters: formatters)
CometChatMessageComposer(textFormatters: formatters)
```

```dart
// ❌ WRONG — calling CometChatThemeHelper in build() of a frequently-rebuilt widget
@override
Widget build(BuildContext context) {
  final colorPalette = CometChatThemeHelper.getColorPalette(context); // expensive every rebuild
  return Container(color: colorPalette.primary);
}

// ✅ CORRECT — cache in didChangeDependencies, use _themeInitialized flag
```

```dart
// ❌ WRONG — overriding templates without providing options (loses default long-press menu)
CometChatMessageList(
  templates: [
    CometChatMessageTemplate(
      type: MessageTypeConstants.text,
      category: MessageCategoryConstants.message,
      contentView: (msg, ctx, align, {additionalConfigurations}) => Text(msg.text),
      // options: null — no long-press menu at all!
    ),
  ],
)

// ✅ CORRECT — use addTemplate to add new types, or include options when overriding templates
```

```dart
// ❌ WRONG — creating a BubbleFactory that ignores the colorPalette/spacing params
class BadFactory extends BubbleFactory<CustomMessage> {
  @override
  Widget build(BuildContext context, CustomMessage message, BubbleAlignment alignment, {
    CometChatColorPalette? colorPalette,
    CometChatTypography? typography,
    CometChatSpacing? spacing,
  }) {
    return Container(color: Colors.blue); // hardcoded color, ignores theme
  }
}

// ✅ CORRECT — use the passed theme values
return Container(color: colorPalette?.primary ?? Colors.blue);
```

```dart
// ❌ WRONG — forgetting resizeToAvoidBottomInset: false on Scaffold with composer
Scaffold(
  body: Column(children: [
    Expanded(child: CometChatMessageList(user: user)),
    CometChatMessageComposer(user: user),
  ]),
)

// ✅ CORRECT
Scaffold(
  resizeToAvoidBottomInset: false,
  body: Column(children: [
    Expanded(child: CometChatMessageList(user: user)),
    CometChatMessageComposer(user: user),
  ]),
)
```

## 8. Checklist

- [ ] Start at Tier 1 (props/view slots) before going deeper
- [ ] Same `textFormatters` list passed to both `CometChatMessageList` and `CometChatMessageComposer`
- [ ] Use `addTemplate` to add new message types alongside defaults (don't replace `templates` unless intentional)
- [ ] Custom `BubbleFactory.build()` uses the passed `colorPalette`/`typography`/`spacing` params, not hardcoded values
- [ ] Style overrides use `merge()` pattern, not constructor replacement
- [ ] Theme lookups cached in `didChangeDependencies()` with `_themeInitialized` flag
- [ ] `Scaffold` containing `CometChatMessageComposer` has `resizeToAvoidBottomInset: false`
- [ ] Custom `CometChatMessageOption.onItemClick` handles both `BaseMessage` and the controller protocol
- [ ] Request builders set `limit` to a reasonable value (default 30–50)
- [ ] Mutable `_user`/`_group` state copies passed to UIKit components, not `widget.user`/`widget.group`
