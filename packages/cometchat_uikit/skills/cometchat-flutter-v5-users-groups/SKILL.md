---
name: cometchat-flutter-v5-users-groups
description: >
  Use when working with CometChat Flutter UIKit v5 user and group list components.
  Triggers on CometChatUsers, CometChatGroups, CometChatGroupMembers, CometChatChangeScope,
  user list, group list, group members, change scope, usersRequestBuilder, groupsRequestBuilder,
  onItemTap, subtitleView, listItemView, usersStyle, groupsStyle, member management.
license: "MIT"
compatibility: "cometchat_chat_uikit ^5.2.14; cometchat_uikit_shared ^5.2.3"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter v5 users groups members scope contacts"
---

# CometChat Flutter UIKit v5 — Users & Groups

Components for displaying and managing users, groups, and group members.

## CometChatUsers

Displays a list of users, sorted alphabetically with optional sticky headers.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `usersRequestBuilder` | `UsersRequestBuilder?` | Custom fetch builder |
| `usersProtocol` | `UsersBuilderProtocol?` | Custom builder protocol |
| `usersStyle` | `CometChatUsersStyle` | Visual styling (default: `const CometChatUsersStyle()`) |
| `onItemTap` | `Function(BuildContext, User)?` | Tap callback |
| `onItemLongPress` | `Function(BuildContext, User)?` | Long press callback |
| `subtitleView` | `Widget? Function(BuildContext, User)?` | Custom subtitle per user |
| `listItemView` | `Widget Function(User)?` | Fully custom list item |
| `leadingView` | `Widget? Function()?` | Custom leading widget |
| `titleView` | `Widget? Function()?` | Custom title widget |
| `trailingView` | `Widget? Function()?` | Custom trailing widget |
| `title` | `String?` | List title |
| `showBackButton` | `bool` | Show back button (default: true) |
| `onBack` | `VoidCallback?` | Back button callback |
| `backButton` | `Widget?` | Custom back button |
| `hideSearch` | `bool` | Hide search bar (default: false) |
| `searchPlaceholder` | `String?` | Search placeholder text |
| `searchBoxIcon` | `Widget?` | Custom search icon |
| `selectionMode` | `SelectionMode?` | Enable selection mode |
| `onSelection` | `Function(List<User>?, BuildContext)?` | Selection callback |
| `activateSelection` | `ActivateSelection?` | Selection activation mode |
| `usersStatusVisibility` | `bool?` | Show online status (default: true) |
| `hideAppbar` | `bool?` | Hide app bar (default: false) |
| `appBarOptions` | `List<Widget> Function(BuildContext)?` | App bar trailing widgets |
| `loadingStateView` | `WidgetBuilder?` | Custom loading state |
| `emptyStateView` | `WidgetBuilder?` | Custom empty state |
| `errorStateView` | `WidgetBuilder?` | Custom error state |
| `stickyHeaderVisibility` | `bool?` | Show alphabetical headers (default: false) |
| `controllerTag` | `String?` | Custom GetX controller tag |
| `onError` | `OnError?` | Error callback |
| `onLoad` | `OnLoad?` | Load callback |
| `onEmpty` | `OnEmpty?` | Empty state callback |
| `setOptions` | `Function?` | Replace long-press options |
| `addOptions` | `Function?` | Add to long-press options |

### Usage

```dart
// ✅ CORRECT — basic users list
CometChatUsers(
  onItemTap: (context, user) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MessagesScreen(user: user),
    ));
  },
)

// ✅ CORRECT — with custom request builder
CometChatUsers(
  usersRequestBuilder: UsersRequestBuilder()
    ..limit = 30
    ..friendsOnly = true,
)

// ✅ CORRECT — selection mode
CometChatUsers(
  selectionMode: SelectionMode.multiple,
  onSelection: (users, context) {
    debugPrint('Selected ${users?.length} users');
  },
)
```

## CometChatGroups

Displays a list of groups with type indicators (public, private, password-protected).

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `groupsRequestBuilder` | `GroupsRequestBuilder?` | Custom fetch builder |
| `groupsProtocol` | `GroupsBuilderProtocol?` | Custom builder protocol |
| `groupsStyle` | `CometChatGroupsStyle?` | Visual styling |
| `onItemTap` | `Function(BuildContext, Group)?` | Tap callback |
| `onItemLongPress` | `Function(BuildContext, Group)?` | Long press callback |
| `subtitleView` | `Widget? Function(BuildContext, Group)?` | Custom subtitle per group |
| `listItemView` | `Widget Function(Group)?` | Fully custom list item |
| `leadingView` | `Widget? Function()?` | Custom leading widget |
| `titleView` | `Widget? Function()?` | Custom title widget |
| `trailingView` | `Widget? Function()?` | Custom trailing widget |
| `title` | `String?` | List title |
| `showBackButton` | `bool` | Show back button (default: true) |
| `onBack` | `VoidCallback?` | Back button callback |
| `hideSearch` | `bool` | Hide search bar (default: false) |
| `searchPlaceholder` | `String?` | Search placeholder text |
| `selectionMode` | `SelectionMode?` | Enable selection mode |
| `onSelection` | `Function(List<Group>?)?` | Selection callback |
| `passwordGroupIcon` | `Widget?` | Icon for password groups |
| `privateGroupIcon` | `Widget?` | Icon for private groups |
| `groupTypeVisibility` | `bool` | Show group type icon (default: true) |
| `hideAppbar` | `bool?` | Hide app bar (default: false) |
| `appBarOptions` | `List<Widget> Function(BuildContext)?` | App bar trailing widgets |
| `loadingStateView` | `WidgetBuilder?` | Custom loading state |
| `emptyStateView` | `WidgetBuilder?` | Custom empty state |
| `errorStateView` | `WidgetBuilder?` | Custom error state |
| `controllerTag` | `String?` | Custom GetX controller tag |
| `onError` | `OnError?` | Error callback |
| `onLoad` | `OnLoad?` | Load callback |
| `onEmpty` | `OnEmpty?` | Empty state callback |
| `stateCallBack` | `Function(CometChatGroupsController)?` | Access controller |
| `setOptions` | `Function?` | Replace long-press options |
| `addOptions` | `Function?` | Add to long-press options |

### Usage

```dart
// ✅ CORRECT — basic groups list
CometChatGroups(
  onItemTap: (context, group) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MessagesScreen(group: group),
    ));
  },
)

// ✅ CORRECT — joined groups only
CometChatGroups(
  groupsRequestBuilder: GroupsRequestBuilder()
    ..limit = 30
    ..joinedOnly = true,
)
```

## CometChatGroupMembers

Displays members of a specific group with role indicators.

### Key Props

| Prop | Type | Description |
|------|------|-------------|
| `group` | `Group` | The group (required) |
| `groupMembersRequestBuilder` | `GroupMembersRequestBuilder?` | Custom fetch builder |
| `groupMembersProtocol` | `GroupMembersBuilderProtocol?` | Custom builder protocol |
| `groupMembersStyle` | `CometChatGroupMembersStyle?` | Visual styling |
| `subtitleView` | `Widget? Function(BuildContext, GroupMember)?` | Custom subtitle |
| `listItemView` | `Widget Function(GroupMember)?` | Custom list item |
| `trailingView` | `Widget? Function(BuildContext, GroupMember)?` | Custom trailing widget |
| `onItemTap` | `Function(BuildContext, GroupMember)?` | Tap callback |
| `onItemLongPress` | `Function(BuildContext, GroupMember)?` | Long press callback |
| `selectionMode` | `SelectionMode?` | Enable selection mode |
| `onSelection` | `Function(List<GroupMember>?, BuildContext)?` | Selection callback |
| `hideAppbar` | `bool?` | Hide app bar |
| `appBarOptions` | `List<Widget> Function(BuildContext)?` | App bar trailing widgets |
| `loadingStateView` | `WidgetBuilder?` | Custom loading state |
| `emptyStateView` | `WidgetBuilder?` | Custom empty state |
| `errorStateView` | `WidgetBuilder?` | Custom error state |
| `onError` | `OnError?` | Error callback |

### Usage

```dart
// ✅ CORRECT — show group members
CometChatGroupMembers(
  group: group,
  onItemTap: (context, member) {
    debugPrint('Tapped: ${member.name}, role: ${member.scope}');
  },
)
```

## CometChatChangeScope

Widget for changing a group member's scope/role (admin, moderator, participant).

### Usage

```dart
// ✅ CORRECT — change member scope
CometChatChangeScope(
  group: group,
  member: member,
)
```

## Anti-Patterns

```dart
// ❌ WRONG — not type-checking onItemTap callback signature
CometChatUsers(
  onItemTap: (user) { ... }, // Missing BuildContext parameter!
)

// ✅ CORRECT
CometChatUsers(
  onItemTap: (context, user) { ... },
)

// ❌ WRONG — CometChatGroups onItemTap also needs BuildContext
CometChatGroups(
  onItemTap: (group) { ... }, // Missing BuildContext!
)

// ✅ CORRECT
CometChatGroups(
  onItemTap: (context, group) { ... },
)
```

Note: `CometChatConversations.onItemTap` takes only `(Conversation)` — no BuildContext. But `CometChatUsers` and `CometChatGroups` take `(BuildContext, User/Group)`.

## Checklist — Users & Groups

- [ ] `onItemTap` callback signature matches component (Users/Groups include BuildContext)
- [ ] Custom request builders set appropriate limits
- [ ] Selection mode configured with `onSelection` callback
- [ ] Group members component receives the `group` object
- [ ] Let widgets manage their own GetX controller lifecycle
