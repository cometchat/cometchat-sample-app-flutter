---
name: cometchat-contributor-performance
description: >
  Use when optimizing performance of cometchat_chat_uikit components or fixing jank.
  Covers theme caching with _themeInitialized flag, hybrid theme pattern (parent passes
  cached values to children), buildWhen optimization for BlocConsumer, O(1) lookups
  with findChildIndexCallback, SliverSpacing keyboard-aware spacing, MediaQuery.sizeOf
  vs MediaQuery.of, ValueNotifier for isolated rebuilds, RepaintBoundary, and the
  44-95ms build time problem during keyboard animation. Also use when seeing frame
  times above 16ms, scroll jank, keyboard animation stutter, or unnecessary widget
  rebuilds in CometChat components.
license: MIT
compatibility: "cometchat_chat_uikit ^6.0.0; flutter >=2.5.0"
metadata:
  author: CometChat
  version: "1.0.0"
  tags: "cometchat contributor performance jank keyboard theme-cache buildwhen"
---

# CometChat UIKit — Contributor Performance Patterns

Performance optimization patterns for contributors working on UIKit widget code.

## The Core Problem

During keyboard animation, `MediaQuery` changes trigger rebuilds every frame (~16ms). If widgets call `CometChatThemeHelper.getColorPalette(context)` in `build()`, each rebuild does an InheritedWidget traversal costing 44-95ms — well above the 16ms budget for 60fps.

## Pattern 1: Theme Caching (_themeInitialized)

Cache theme values once in `didChangeDependencies()`, never re-lookup during keyboard animation:

```dart
class _CometChatMessageListState extends State<CometChatMessageList> {
  late CometChatColorPalette _colorPalette;
  late CometChatSpacing _spacing;
  late CometChatTypography _typography;
  bool _themeInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeInitialized) {
      _colorPalette = CometChatThemeHelper.getColorPalette(context);
      _spacing = CometChatThemeHelper.getSpacing(context);
      _typography = CometChatThemeHelper.getTypography(context);
      _themeInitialized = true;
    }
  }
}
```

Why `didChangeDependencies()` not `initState()`: needs `context` for InheritedWidget lookup.
Why `_themeInitialized` flag: prevents re-initialization when `didChangeDependencies` fires again during keyboard animation (MediaQuery change triggers it).

## Pattern 2: Hybrid Theme (Parent → Child)

Parent caches theme once, passes to children as optional params. Children skip their own lookup:

```dart
// Parent (CometChatMessageList) — caches once
Widget _buildBubble(BaseMessage message) {
  return CometChatImageBubble(
    imageUrl: message.attachment?.fileUrl,
    colorPalette: _colorPalette,  // Pre-cached, zero lookup
    spacing: _spacing,
  );
}

// Child (CometChatImageBubble) — accepts optional, falls back to lookup
class CometChatImageBubble extends StatefulWidget {
  final CometChatColorPalette? colorPalette;  // Optional
  final CometChatSpacing? spacing;
}

class _CometChatImageBubbleState extends State<CometChatImageBubble> {
  late CometChatColorPalette colorPalette;
  bool _themeInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeInitialized) {
      colorPalette = widget.colorPalette ??
          CometChatThemeHelper.getColorPalette(context);
      _themeInitialized = true;
    }
  }

  @override
  void didUpdateWidget(CometChatImageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.colorPalette != oldWidget.colorPalette &&
        widget.colorPalette != null) {
      colorPalette = widget.colorPalette!;
    }
  }
}
```

Widgets already using this pattern: CometChatTextBubble, CometChatImageBubble, CometChatVideoBubble, CometChatFileBubble, CometChatAudioBubble, CometChatAvatar, CometChatMessageBubble, CometChatReceipt, CometChatReactions.

## Pattern 3: buildWhen Optimization

Prevent BlocConsumer rebuilds during keyboard animation — only rebuild on meaningful state changes:

```dart
BlocConsumer<MessageComposerBloc, MessageComposerState>(
  buildWhen: (previous, current) =>
      previous.isEditMode != current.isEditMode ||
      previous.isReplyMode != current.isReplyMode ||
      previous.isRecordingMode != current.isRecordingMode ||
      previous.editMessage != current.editMessage ||
      previous.replyMessage != current.replyMessage,
  listener: (context, state) { /* Still receives ALL state changes */ },
  builder: (context, state) { /* Only rebuilds on meaningful changes */ },
)
```

The listener still fires for every state change (for side effects). Only the builder is gated.

## Pattern 4: O(1) findChildIndexCallback

For `SliverAnimatedList`, provide O(1) lookup instead of `indexWhere`:

```dart
SliverAnimatedList(
  findChildIndexCallback: (Key key) {
    if (key is ValueKey<int>) {
      final index = widget.findMessageIndex?.call(key.value) ??
          _messages.indexWhere((m) => m.id == key.value);
      if (index != -1) return visualPosition(index);
    }
    return null;
  },
)

// Pass the BLoC's O(1) lookup
CometChatAnimatedMessageList(
  findMessageIndex: _messageListBloc.findMessageIndex,
)
```

## Pattern 5: ValueNotifier for Isolated Rebuilds

For high-frequency updates (typing indicators, online status), use ValueNotifier per entity instead of BLoC state:

```dart
// In BLoC — one notifier per conversation
final Map<String, ValueNotifier<List<TypingIndicator>>> _typingNotifiers = {};

ValueNotifier<List<TypingIndicator>> getTypingNotifier(String id) {
  return _typingNotifiers.putIfAbsent(
    id, () => ValueNotifier<List<TypingIndicator>>([]),
  );
}

// In widget — only this item rebuilds
ValueListenableBuilder<List<TypingIndicator>>(
  valueListenable: bloc.getTypingNotifier(conversationId),
  builder: (_, typingList, __) => TypingView(typingList),
)
```

This prevents the entire list from rebuilding when one person types.

## Pattern 6: Keyboard-Aware Spacing (SliverSpacing)

`SliverSpacing` in `cometchat_message_list/widgets/sliver_spacing.dart` handles keyboard interaction:
- At bottom: keyboard pushes list up
- Scrolled up: list stays still, only composer moves
- Safe area: only added when keyboard is closed

Requires `Scaffold(resizeToAvoidBottomInset: false)` — the Scaffold must NOT resize, the spacing widget handles it.

Uses `WidgetsBindingObserver.didChangeMetrics` for keyboard detection, tracks scroll position via listener (not in build), captures at-bottom state when keyboard starts opening.

## Pattern 7: MediaQuery Optimization

```dart
// ❌ Subscribes to ALL MediaQuery changes (size, padding, orientation, etc.)
final size = MediaQuery.of(context).size;

// ✅ Only subscribes to size changes
final size = MediaQuery.sizeOf(context);

// ✅ Only subscribes to text scaler changes
final scaler = MediaQuery.textScalerOf(context);
```

## Gotchas

- `_themeInitialized = false` is the default. If you add a new widget and forget the flag, theme lookups happen every `didChangeDependencies` call during keyboard animation — same jank as doing it in `build()`.
- `didUpdateWidget` must update cached theme values when parent passes new ones. Without it, theme changes (e.g., dark mode toggle) don't propagate to children.
- `buildWhen` only gates the builder, not the listener. If you need to gate the listener too, use `listenWhen`.
- `SliverSpacing` assumes `resizeToAvoidBottomInset: false`. If a contributor adds a new screen with the composer and forgets this, the keyboard compensation doubles.
- ValueNotifier must be disposed in `close()`. Forgetting this leaks notifiers for every conversation the user scrolls through.

## Anti-Patterns

```dart
// ❌ WRONG — theme lookup in build (44-95ms per frame during keyboard)
@override
Widget build(BuildContext context) {
  final colors = CometChatThemeHelper.getColorPalette(context);
  return Container(color: colors.primary);
}

// ✅ CORRECT — cached in didChangeDependencies
late CometChatColorPalette _colors;
bool _init = false;
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (!_init) { _colors = CometChatThemeHelper.getColorPalette(context); _init = true; }
}
```

```dart
// ❌ WRONG — BlocBuilder without buildWhen on a frequently-updating BLoC
BlocBuilder<MessageListBloc, MessageListState>(
  builder: (ctx, state) => _buildEntireList(state), // Rebuilds on every event
)

// ✅ CORRECT — only rebuild on status changes
BlocBuilder<MessageListBloc, MessageListState>(
  buildWhen: (prev, curr) => prev.status != curr.status,
  builder: (ctx, state) => _buildEntireList(state),
)
```

```dart
// ❌ WRONG — O(n) lookup in findChildIndexCallback (called per frame during scroll)
findChildIndexCallback: (key) {
  return _messages.indexWhere((m) => m.id == (key as ValueKey).value);
}

// ✅ CORRECT — O(1) via Map
findChildIndexCallback: (key) {
  return _messageIndexMap[(key as ValueKey<int>).value];
}
```

## Checklist — Performance PR

- [ ] Theme cached in `didChangeDependencies()` with `_themeInitialized` flag
- [ ] Child widgets accept optional `colorPalette`/`spacing`/`typography` params
- [ ] `didUpdateWidget` updates cached theme when parent passes new values
- [ ] `buildWhen` used on BlocConsumer/BlocBuilder for frequently-updating BLoCs
- [ ] O(1) Map used for lookups in hot paths (findChildIndexCallback, event handlers)
- [ ] ValueNotifier used for high-frequency isolated updates (typing, presence)
- [ ] `MediaQuery.sizeOf(context)` instead of `MediaQuery.of(context).size`
- [ ] All ValueNotifiers disposed in `close()`/`dispose()`
- [ ] No theme lookups in `build()` method
