---
name: cometchat-contributor-migration
description: >
  Use when migrating CometChat UIKit components from GetX to BLoC, or when working
  on components that still use GetX patterns. Covers Rx to immutable state conversion,
  GetBuilder to BlocBuilder, Obx to BlocSelector/ValueListenableBuilder, Get.put to
  BlocProvider, Get.find to context.read, onInit to constructor events, onClose to
  close(), the BLoC adapter pattern for legacy protocol compatibility, and the
  migration status of each component. Also use when seeing GetxController, RxList,
  RxBool, .obs, .value, or when a PR reviewer flags GetX usage.
license: MIT
compatibility: "cometchat_chat_uikit ^6.0.0; flutter_bloc ^8.1.0"
metadata:
  author: CometChat
  version: "1.0.0"
  tags: "cometchat contributor migration getx bloc adapter legacy"
---

# CometChat UIKit — GetX to BLoC Migration

Guide for migrating components from GetX to Clean Architecture + BLoC.

## Migration Status

| Component | Status | Notes |
|-----------|--------|-------|
| conversations | ✅ BLoC | Reference implementation |
| message_list | ✅ BLoC | Uses BlocAdapter for legacy protocol |
| message_composer | ✅ BLoC | |
| message_header | ✅ BLoC | |
| users | ✅ BLoC | |
| groups | ✅ BLoC | |
| group_members | ✅ BLoC | Has legacy GetX controller alongside BLoC |
| search | ✅ BLoC | |
| threaded_header | ✅ BLoC | |
| message_information | ✅ BLoC | |

## Conversion Table

| GetX | BLoC Equivalent |
|------|-----------------|
| `RxList<T>` | `List<T>` in immutable state |
| `RxBool` | `enum Status` field in state |
| `.obs` | Immutable state class |
| `.value = x` | `emit(state.copyWith(...))` |
| `GetBuilder` | `BlocBuilder` |
| `Obx(() => ...)` | `BlocSelector` or `ValueListenableBuilder` |
| `Get.put()` | `BlocProvider(create: ...)` |
| `Get.find()` | `context.read<Bloc>()` |
| `onInit()` | Constructor + initial event dispatch |
| `onClose()` | `close()` override |
| `update()` | `emit(newState)` |

## Migration Steps

### 1. Create State Class
Convert all `Rx` variables into immutable state properties:

```dart
// BEFORE (GetX)
class UsersController extends GetxController {
  final RxList<User> users = <User>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
}

// AFTER (BLoC)
class UsersState extends Equatable {
  final UsersStatus status;
  final List<User> users;
  final bool hasMore;

  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.hasMore = true,
  });

  UsersState copyWith({UsersStatus? status, List<User>? users, bool? hasMore}) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [status, users, hasMore];
}
```

### 2. Create Events
Convert public methods that modify state into event classes:

```dart
// BEFORE: controller.loadUsers()
// AFTER:
class LoadUsers extends UsersEvent { const LoadUsers(); }
class LoadMoreUsers extends UsersEvent { const LoadMoreUsers(); }
class SearchUsers extends UsersEvent {
  final String query;
  const SearchUsers(this.query);
}
```

### 3. Move SDK Listeners
Move from controller to BLoC, dispatch events instead of mutating state:

```dart
// BEFORE (GetX)
@override
void onUserOnline(User user) {
  final index = users.indexWhere((u) => u.uid == user.uid);
  if (index != -1) { users[index] = user; update(); }
}

// AFTER (BLoC)
@override
void onUserOnline(User user) {
  add(UserStatusChanged(user));  // Dispatch event, don't mutate
}
```

### 4. Add O(1) Lookups
Replace `indexWhere` with Map:

```dart
// BEFORE: O(n)
final index = users.indexWhere((u) => u.uid == user.uid);

// AFTER: O(1)
final Map<String, int> _userIndexMap = {};
final index = _userIndexMap[user.uid];
```

### 5. Replace Widget Bindings

```dart
// BEFORE
GetBuilder<UsersController>(
  init: UsersController(),
  builder: (controller) => ListView.builder(
    itemCount: controller.users.length,
    itemBuilder: (_, i) => UserItem(controller.users[i]),
  ),
)

// AFTER
BlocProvider(
  create: (_) => UsersBloc()..add(const LoadUsers()),
  child: BlocBuilder<UsersBloc, UsersState>(
    builder: (context, state) => ListView.builder(
      itemCount: state.users.length,
      itemBuilder: (_, i) => UserItem(state.users[i]),
    ),
  ),
)
```

## BLoC Adapter Pattern

When a migrated component has legacy consumers that expect the old protocol interface, use an adapter:

```dart
class MessageListBlocAdapter implements LegacyMessageListProtocol {
  final MessageListBloc bloc;
  MessageListBlocAdapter(this.bloc);

  @override
  void addElement(BaseMessage msg) => bloc.add(InsertMessage(msg));

  @override
  void removeElement(BaseMessage msg) => bloc.add(RemoveMessage(msg));

  @override
  List<BaseMessage> getList() => bloc.state.messages;
}
```

Key rules:
- Adapter delegates to BLoC events, never holds its own state
- Getters read from `bloc.state`
- Reference: `message_list/bloc/message_list_bloc_adapter.dart`

## Gotchas

- `Obx(() => widget)` rebuilds on ANY observable change. Replace with `BlocSelector` or `ValueListenableBuilder` for isolated rebuilds — don't just swap to `BlocBuilder` which also rebuilds on every state change.
- GetX `update()` is synchronous. BLoC `emit()` is also synchronous but state comparison uses Equatable. If your state doesn't include all changing fields in `props`, emissions get silently skipped.
- `Get.find<Controller>()` works anywhere. `context.read<Bloc>()` requires the BLoC to be in the widget tree above. If you need BLoC access outside the tree, pass it as a constructor parameter.
- The `group_members` component has BOTH a legacy GetX controller AND a BLoC. The widget uses BLoC, but `cometchat_group_members_controller.dart` still exists for backward compatibility.

## Anti-Patterns

```dart
// ❌ WRONG — mutating list in place (GetX habit)
state.items.add(newItem);
emit(state);

// ✅ CORRECT — create new list
emit(state.copyWith(items: [...state.items, newItem]));
```

```dart
// ❌ WRONG — using Get.find in BLoC code
final controller = Get.find<SomeController>();

// ✅ CORRECT — inject via constructor
class MyBloc extends Bloc<MyEvent, MyState> {
  final SomeRepository _repository;
  MyBloc({required SomeRepository repository}) : _repository = repository;
}
```

```dart
// ❌ WRONG — BlocBuilder without buildWhen (rebuilds on every state change, like Obx)
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) => ExpensiveWidget(state),
)

// ✅ CORRECT — buildWhen limits rebuilds
BlocBuilder<MyBloc, MyState>(
  buildWhen: (prev, curr) => prev.status != curr.status,
  builder: (context, state) => ExpensiveWidget(state),
)
```

## Checklist — Migration PR

- [ ] All `Rx` variables converted to immutable state properties
- [ ] All public methods converted to event classes
- [ ] SDK listeners dispatch events, not mutate state
- [ ] O(1) Map maintained alongside List
- [ ] `GetBuilder`/`Obx` replaced with `BlocBuilder`/`BlocSelector`/`ValueListenableBuilder`
- [ ] `Get.put()` replaced with `BlocProvider`
- [ ] `Get.find()` replaced with `context.read()` or constructor injection
- [ ] `onClose()` logic moved to `close()` with listener cleanup
- [ ] BLoC adapter created if legacy consumers exist
- [ ] Tests written for new BLoC (90% coverage target)
