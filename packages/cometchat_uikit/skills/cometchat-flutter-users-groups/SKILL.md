---
name: cometchat-flutter-users-groups
description: >
  Use when implementing user lists, group lists, or group member management with
  CometChat Flutter UIKit v6. Triggers on mentions of CometChatUsers, CometChatGroups,
  CometChatGroupMembers, UsersBloc, GroupsBloc, UsersServiceLocator, GroupsServiceLocator,
  user list, group list, contacts, members, group info, add members, ban members,
  transfer ownership, change scope, UsersRequestBuilder, GroupsRequestBuilder,
  GroupMembersRequestBuilder, or customizing user/group list items.
license: "MIT"
compatibility: "cometchat_chat_uikit ^6.0.0; flutter_bloc ^8.1.0"
allowed-tools: "executeBash, readFile, readCode, fileSearch, listDirectory, grepSearch"
metadata:
  author: "CometChat"
  version: "1.0.0"
  tags: "cometchat flutter users groups members contacts"
---

# CometChat Flutter UIKit — Users & Groups

Components for displaying and managing users, groups, and group members.

## CometChatUsers

Displays a searchable, alphabetically-sorted list of users.

```dart
CometChatUsers(
  onItemTap: (context, user) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MessagesScreen(user: user),
    ));
  },
  usersStyle: CometChatUsersStyle(
    backgroundColor: colorPalette.background1,
  ),
  usersStatusVisibility: true,
  showBackButton: true,
  onBack: () => Navigator.pop(context),
)
```

### Custom Request Builder

```dart
CometChatUsers(
  usersRequestBuilder: UsersRequestBuilder()
    ..limit = 30
    ..friendsOnly = true
    ..roles = ['default']
    ..searchKeyword = 'john',
)
```

### View Slots

```dart
CometChatUsers(
  listItemView: (user) => MyCustomUserItem(user),
  subtitleView: (context, user) => Text(user.status ?? 'offline'),
  trailingView: (context, user) => Icon(Icons.chat),
)
```

## CometChatGroups

Displays a searchable list of groups with type indicators (public/private/password).

```dart
CometChatGroups(
  onItemTap: (context, group) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MessagesScreen(group: group),
    ));
  },
  groupsStyle: CometChatGroupsStyle(
    backgroundColor: colorPalette.background1,
  ),
  groupTypeVisibility: true,
)
```

### Custom Request Builder

```dart
CometChatGroups(
  groupsRequestBuilder: GroupsRequestBuilder()
    ..limit = 30
    ..joinedOnly = true
    ..searchKeyword = 'team'
    ..withTags = true
    ..tags = ['project'],
)
```

## CometChatGroupMembers

Displays members of a specific group with role indicators and management actions.

```dart
CometChatGroupMembers(
  group: group,
  groupMembersStyle: CometChatGroupMembersStyle(
    backgroundColor: colorPalette.background1,
  ),
)
```

### Group Member Actions

The component supports scope changes, kick, and ban based on the logged-in user's role:

| Logged-in Role | Can Change Scope | Can Kick | Can Ban |
|----------------|-----------------|----------|---------|
| Owner | ✅ All members | ✅ All | ✅ All |
| Admin | ✅ Participants only | ✅ Participants | ✅ Participants |
| Participant | ❌ | ❌ | ❌ |

## Architecture (All Three)

All follow the same Clean Architecture + BLoC pattern:

```
{component}/
├── bloc/{component}_bloc.dart       # State management + SDK listeners
├── domain/usecases/                 # Get{Component}sUseCase, etc.
├── data/repositories/               # SDK wrapper
├── di/{component}_service_locator.dart  # Singleton DI
└── widgets/                         # List item, empty/error/loading views
```

## BLoC State Pattern

All three use the same state pattern:

```dart
// Status-based states
{Component}Initial → {Component}Loading → {Component}Loaded / {Component}Empty / {Component}Error

// Loaded state has:
final List<{Entity}> items;
final bool hasMore;
final Set<String> selectedItems;  // For selection mode
final bool isLoadingMore;
```

## Selection Mode

All list components support selection:

```dart
CometChatUsers(
  selectionMode: SelectionMode.multiple,
  onSelection: (selectedUsers) {
    // Handle selected users
  },
  activateSelection: ActivateSelection.onLongClick,
)
```

## Gotchas

- `CometChatGroupMembers` has been fully migrated to BLoC + Clean Architecture (bloc/, data/, di/, domain/, widgets/). A `GroupMembersBlocAdapter` wraps the BLoC to implement the legacy `CometChatGroupMembersControllerProtocol` for backward compatibility. The old `cometchat_group_members_controller.dart` file still exists but the BLoC is the active implementation.
- Group type icons (lock for private, shield for password) are controlled by `groupTypeVisibility`. Setting it to `false` hides all type indicators.
- `friendsOnly: true` on `UsersRequestBuilder` only works if your CometChat plan supports the friends feature.
- When a user is blocked, they still appear in `CometChatUsers` unless you set `includeBlockedUsers: false` on the conversations BLoC or filter in the request builder.

## Anti-Patterns

```dart
// ❌ WRONG — not handling group join for password-protected groups
onItemTap: (context, group) => Navigator.push(context, MaterialPageRoute(
  builder: (_) => MessagesScreen(group: group), // Fails if not joined
))

// ✅ CORRECT — check membership, handle password groups
onItemTap: (context, group) {
  if (group.hasJoined) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MessagesScreen(group: group),
    ));
  } else if (group.type == GroupTypeConstants.password) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => JoinProtectedGroupScreen(group: group),
    ));
  } else {
    // Join public group first, then navigate
  }
}
```

```dart
// ❌ WRONG — hardcoded role check strings
if (member.scope == 'admin') { ... }

// ✅ CORRECT — use SDK constants
if (member.scope == GroupMemberScope.admin) { ... }
```

```dart
// ❌ WRONG — creating ServiceLocator per widget instance
final locator = GroupsServiceLocator(); // New instance each time

// ✅ CORRECT — use singleton
final locator = GroupsServiceLocator.instance;
locator.setup();
```

## Checklist

- [ ] `onItemTap` handles group join state (joined vs password vs public)
- [ ] Group member actions respect role hierarchy
- [ ] Selection mode configured if multi-select needed
- [ ] Request builder customized for app's user/group filtering needs
- [ ] ServiceLocator accessed via `.instance` singleton
- [ ] Colors from `CometChatThemeHelper`, not hardcoded
