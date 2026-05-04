---
name: cometchat-contributor-architecture
description: >
  Use when adding new components, features, or fixing bugs inside the cometchat_chat_uikit
  source code. Covers Clean Architecture layer rules, file placement, naming conventions,
  BLoC patterns, ServiceLocator DI, repository/datasource structure, state class design,
  event class design, Style class with merge() and of(), custom view slots, ValueNotifier
  for isolated updates, O(1) Map lookups, BLoC adapter pattern for legacy compatibility,
  platform-specific DI, barrel exports, and the conversations reference implementation.
  Also use when asking "where do I put this new class", "how do I add a new component",
  or "what's the file structure for a new feature". Use for any PR or code review on
  the chat_uikit package source.
license: MIT
compatibility: "cometchat_chat_uikit ^6.0.0; flutter_bloc ^8.1.0"
metadata:
  author: CometChat
  version: "1.0.0"
  tags: "cometchat contributor architecture clean-architecture bloc di internal"
---

# CometChat UIKit — Contributor Architecture

Internal architecture rules for developers working on the `chat_uikit` package source code.

## Reference Implementation

ALWAYS reference the `conversations` module first:
- Location: `chat_uikit/lib/chat_ui/src/conversations/`
- This is the canonical example for every pattern below.

## Adding a New Component

Create this exact directory structure under `chat_ui/src/{component}/`:

```
{component}/
├── bloc/
│   ├── {component}_bloc.dart          # BLoC class
│   ├── {component}_event.dart         # Equatable events
│   ├── {component}_state.dart         # Equatable state with copyWith
│   └── bloc.dart                      # Barrel export
├── domain/
│   ├── usecases/
│   │   ├── get_{component}s_usecase.dart
│   │   └── ...
│   ├── repositories/
│   │   └── {component}_repository.dart  # Abstract interface
│   └── domain.dart                      # Barrel export
├── data/
│   ├── repositories/
│   │   └── {component}_repository_impl.dart
│   ├── datasources/
│   │   ├── {component}_remote_datasource.dart
│   │   └── {component}_local_datasource.dart  # Optional
│   └── data.dart                        # Barrel export
├── di/
│   ├── {component}_service_locator.dart
│   └── di.dart                          # Barrel export
├── widgets/
│   ├── cometchat_{component}.dart       # Main widget
│   ├── {component}_list.dart            # List widget if applicable
│   └── widgets.dart                     # Barrel export
├── cometchat_{component}_style.dart     # Style class
└── {component}.dart                     # Top-level barrel export
```

## Layer Rules

| Layer | Can Import | Cannot Import |
|-------|-----------|---------------|
| `bloc/` | `domain/`, `di/`, `shared_ui/` | `data/`, `widgets/`, other components' `bloc/` |
| `domain/` | Nothing (pure Dart) | `data/`, `bloc/`, `widgets/`, Flutter |
| `data/` | `domain/` (for interfaces), `shared_ui/` | `bloc/`, `widgets/` |
| `di/` | `domain/`, `data/` | `bloc/`, `widgets/` |
| `widgets/` | `bloc/`, `di/`, `shared_ui/` | `data/`, `domain/` directly |

## BLoC Pattern

```dart
class {Component}Bloc extends Bloc<{Component}Event, {Component}State> {
  // O(1) lookup map — maintain alongside list
  final Map<String, int> _indexMap = {};

  // ValueNotifier for high-frequency isolated updates (typing, presence)
  final Map<String, ValueNotifier<T>> _notifiers = {};

  ValueNotifier<T> getNotifier(String id) =>
    _notifiers.putIfAbsent(id, () => ValueNotifier<T>(initialValue));

  // SDK listener IDs — unique per instance, timestamp-based
  final String _messageListenerKey =
      '{component}_bloc_message_${DateTime.now().millisecondsSinceEpoch}';

  // Register listeners in constructor, remove in close()
  @override
  Future<void> close() {
    CometChat.removeMessageListener(_messageListenerKey);
    for (final notifier in _notifiers.values) { notifier.dispose(); }
    return super.close();
  }
}
```

## State Class Pattern

```dart
class {Component}State extends Equatable {
  final {Component}Status status;  // initial, loading, loaded, empty, error
  final List<{Entity}> items;
  final String? errorMessage;
  final bool hasMore;
  final bool isLoadingMore;

  const {Component}State({...});

  {Component}State copyWith({...}) => {Component}State(
    status: status ?? this.status,
    items: items ?? this.items,
    // ...
  );

  @override
  List<Object?> get props => [status, items, errorMessage, hasMore, isLoadingMore];
}
```

For states where SDK entity `==` only compares IDs (like `Conversation`), add a `_version` counter:
```dart
final int _version;
static int _nextVersion = 0;
{Component}Loaded(...) : _version = _nextVersion++;
```

## Event Class Pattern

```dart
abstract class {Component}Event extends Equatable {
  const {Component}Event();
  @override
  List<Object?> get props => [];
}

class Load{Component}s extends {Component}Event {
  final bool silent;  // true = keep existing list visible during refresh
  const Load{Component}s({this.silent = false});
  @override
  List<Object?> get props => [silent];
}
```

## ServiceLocator Pattern

```dart
class {Component}ServiceLocator {
  static final {Component}ServiceLocator _instance = {Component}ServiceLocator._internal();
  {Component}ServiceLocator._internal();
  static {Component}ServiceLocator get instance => _instance;

  bool _isInitialized = false;
  late {Component}Repository _repository;
  late Get{Component}sUseCase _getUseCase;

  void setup() {
    if (_isInitialized) return;
    final dataSource = {Component}RemoteDataSourceImpl();
    _repository = {Component}RepositoryImpl(remoteDataSource: dataSource);
    _getUseCase = Get{Component}sUseCase(_repository);
    _isInitialized = true;
  }

  Get{Component}sUseCase get getUseCase { _ensureInitialized(); return _getUseCase; }
  void _ensureInitialized() { if (!_isInitialized) throw StateError('Not initialized'); }
  Future<void> reset() async { _isInitialized = false; }
}
```

## Style Class Pattern

```dart
@immutable
class CometChat{Component}Style extends ThemeExtension<CometChat{Component}Style> {
  final Color? backgroundColor;
  final TextStyle? titleStyle;

  const CometChat{Component}Style({this.backgroundColor, this.titleStyle});

  // merge() — null-aware override
  CometChat{Component}Style merge(CometChat{Component}Style? other) {
    if (other == null) return this;
    return CometChat{Component}Style(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      titleStyle: other.titleStyle ?? titleStyle,
    );
  }

  // of() — default factory from context
  static CometChat{Component}Style of(BuildContext context) => const CometChat{Component}Style();

  @override
  ThemeExtension<CometChat{Component}Style> copyWith({...}) => ...;
  @override
  ThemeExtension<CometChat{Component}Style> lerp(...) => this;
}
```

## Custom View Slots

Every list component MUST expose these:
```dart
final Widget Function({Entity})? listItemView;       // Replace entire item
final Widget? Function(BuildContext, {Entity})? leadingView;
final Widget? Function(BuildContext, {Entity})? titleView;
final Widget? Function(BuildContext, {Entity})? subtitleView;
final Widget? Function(BuildContext, {Entity})? trailingView;
```

## BLoC Adapter Pattern (Legacy Compatibility)

When a component has legacy protocol consumers, bridge with an adapter:
```dart
class {Component}BlocAdapter implements Legacy{Component}Protocol {
  final {Component}Bloc bloc;
  @override
  addElement(Entity e) => bloc.add(EntityAdded(e));
  @override
  List<Entity> getList() => bloc.state.items;
}
```
Reference: `message_list/bloc/message_list_bloc_adapter.dart`

## Platform-Specific DI

For web implementations, create a separate service locator with the same repository interface:
```dart
class {Component}WebServiceLocator {
  late {Component}WebDataSource _webDataSource;
  late {Component}Repository _repository;  // Same interface as native!
  late Get{Component}sUseCase _useCase;    // Same use case!
}
```
Reference: `apps/conversations_web/lib/data/conversations_web_service_locator.dart`

## Result Pattern

Use `Result<T>` for error handling in use cases and repositories:
```dart
sealed class Result<T> {}
class Success<T> extends Result<T> { final T data; }
class Failure<T> extends Result<T> { final String message; final String code; }
```

## Barrel Exports

Every subdirectory MUST have a barrel file (`bloc.dart`, `domain.dart`, `data.dart`, `di.dart`, `widgets.dart`). The top-level `{component}.dart` re-exports all barrels. Add public classes to `cometchat_chat_uikit.dart` barrel.

## Gotchas

- `domain/` must be pure Dart — no Flutter imports, no SDK imports. Only abstract interfaces and entities.
- SDK listener IDs must be unique per BLoC instance. Use `{component}_bloc_{type}_${DateTime.now().millisecondsSinceEpoch}`.
- `close()` must remove ALL SDK listeners registered in the constructor. Missing one causes memory leaks and duplicate events.
- `ConversationsLoaded._version` pattern is needed when the SDK entity's `==` only compares IDs. Without it, BLoC skips emissions when only nested properties change.
- Rich text formatting has 3 systems but only WYSIWYG is active at runtime. Bug fixes go in `rich_text_editing_controller.dart`, NOT the clean architecture module in `shared_ui/src/rich_text_formatting/`.

## Anti-Patterns

```dart
// ❌ WRONG — importing data layer from BLoC
import '../data/datasources/my_datasource.dart'; // BLoC should only know domain

// ✅ CORRECT — BLoC imports use cases from domain
import '../domain/usecases/get_items_usecase.dart';
```

```dart
// ❌ WRONG — mutable state class
class MyState { List<Item> items = []; } // Mutating in place

// ✅ CORRECT — immutable with copyWith
class MyState extends Equatable {
  final List<Item> items;
  MyState copyWith({List<Item>? items}) => MyState(items: items ?? this.items);
}
```

```dart
// ❌ WRONG — O(n) lookup in hot path
final index = items.indexWhere((i) => i.id == targetId); // O(n) per lookup

// ✅ CORRECT — O(1) via maintained Map
final index = _indexMap[targetId]; // O(1)
```

## Checklist — Before Merging a New Component

- [ ] Clean Architecture: BLoC + Repository + Use Cases + DI
- [ ] ValueNotifier for frequently-changing isolated state (typing, presence)
- [ ] O(1) lookups via Map maintained alongside List
- [ ] Style class with `merge()` and `of()`, registered as ThemeExtension
- [ ] Custom view slots (listItemView, leadingView, titleView, subtitleView, trailingView)
- [ ] Accessibility: interactive elements wrapped with `Semantics`
- [ ] Listener cleanup in `close()` — every registered listener removed
- [ ] Barrel exports at every level + added to `cometchat_chat_uikit.dart`
- [ ] Result<T> pattern for error handling
- [ ] Tests: BLoC 90%, Use Cases 95%, Repository 90%, Widgets 80%
