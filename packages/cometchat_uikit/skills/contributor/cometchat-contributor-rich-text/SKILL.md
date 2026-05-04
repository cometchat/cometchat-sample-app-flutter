---
name: cometchat-contributor-rich-text
description: >
  Use when fixing bugs or adding features to the rich text formatting system in
  cometchat_chat_uikit. Covers the three formatting systems (WYSIWYG active, clean
  architecture test-only, legacy deprecated), which files to edit for which bug type,
  RichTextEditingController, RichTextSpan, SegmentComposerController,
  SegmentComposerWidget, format_type.dart, format_compatibility.dart, toMarkdown
  serialization, ordered list renumbering, code block handling, paste URL on selection,
  and the runtime priority chain in the composer. CRITICAL: the clean architecture
  module in shared_ui/src/rich_text_formatting/ is NOT wired to the composer at runtime.
  Bug fixes go in the WYSIWYG system, not the clean architecture module.
license: MIT
compatibility: "cometchat_chat_uikit ^6.0.0"
metadata:
  author: CometChat
  version: "1.0.0"
  tags: "cometchat contributor rich-text wysiwyg formatting composer toolbar"
---

# CometChat UIKit — Rich Text Formatting (Contributor)

Three formatting systems exist. Only one is active at runtime. Editing the wrong one wastes time.

## System Map

| System | Status | Location | Used At Runtime? |
|--------|--------|----------|-----------------|
| WYSIWYG | **ACTIVE** | `chat_ui/src/message_composer/widgets/rich_text_toolbar/` | ✅ Yes |
| Clean Architecture | Test-only | `shared_ui/src/rich_text_formatting/` | ❌ No |
| Legacy Formatter | Deprecated | `shared_ui/src/formatter/rich_text/` | ❌ Fallback only |

## Rule: All Bug Fixes Go in WYSIWYG

The composer's runtime priority chain (line ~2900 of `cometchat_message_composer.dart`):

```
1. SegmentComposerController (if code blocks enabled + toolbar visible)
   └── delegates to RichTextEditingController per segment
2. RichTextEditingController directly (if toolbar visible, no segments)
3. RichTextFormatterManager (legacy fallback — only if controller is NOT RichTextEditingController)
```

In practice, path 1 or 2 always runs when the toolbar is enabled. Path 3 is dead code.

## WYSIWYG Files — Where to Edit

| Bug Type | Edit This File |
|----------|---------------|
| Inline format (bold/italic/strike/code/link) | `rich_text_editing_controller.dart` |
| Ordered/bullet list numbering | `rich_text_editing_controller.dart` → `_renumberOrderedListLines`, `_maybeContinueLineFormat` |
| Code block insert/remove/exit | `segment_composer_controller.dart` |
| Paste URL on selected text | `segment_composer_widget.dart` |
| Format compatibility (which buttons disabled) | `format_compatibility.dart` (shared) |
| Format type definitions | `format_type.dart` (shared) |
| Toolbar button dispatch | `cometchat_message_composer.dart` |
| Span persistence (toMarkdown) | `rich_text_span.dart` |

Full paths:
- `chat_ui/src/message_composer/widgets/rich_text_toolbar/rich_text_editing_controller.dart`
- `chat_ui/src/message_composer/widgets/rich_text_toolbar/rich_text_span.dart`
- `chat_ui/src/message_composer/widgets/rich_text_toolbar/segment_composer_controller.dart`
- `chat_ui/src/message_composer/widgets/rich_text_toolbar/segment_composer_widget.dart`
- `chat_ui/src/message_composer/widgets/cometchat_message_composer.dart`

## Shared Between Systems

These files are used by BOTH the WYSIWYG system and the clean architecture module:
- `shared_ui/src/rich_text_formatting/domain/entities/format_type.dart` — `FormatType` enum
- `shared_ui/src/rich_text_formatting/domain/entities/format_compatibility.dart` — compatibility matrix

Changes to these affect both systems. Test both suites.

## Key Classes

### RichTextEditingController
The core WYSIWYG controller. Manages:
- Span tracking (which ranges have which formats)
- Markdown rendering (converting spans to visual TextSpan tree)
- Ordered list renumbering (auto-increment on Enter)
- Format application (bold, italic, etc.)
- `toMarkdown()` serialization (spans → markdown string for sending)

### RichTextSpan + RichTextSpanManager
The span model. `RichTextSpanManager` provides:
- `addFormat(range, format)` — apply format to selection
- `removeFormat(range, format)` — remove format from selection
- `toMarkdown()` — serialize spans to markdown

### SegmentComposerController
Multi-segment controller for code blocks. A "segment" is either:
- Normal text (handled by `RichTextEditingController`)
- Code block (plain text, no formatting)

Handles code block insert, remove, exit (Enter at end of empty code block).

### SegmentComposerWidget
Widget layer that handles:
- Paste interception (URL pasted on selected text → auto-link)
- Keyboard shortcuts (Ctrl+B, Ctrl+I, etc.)
- Backspace handling at segment boundaries

## Test Suites

| Suite | Location | Count | Run Command |
|-------|----------|-------|-------------|
| WYSIWYG | `test/chat_ui/message_composer/widgets/rich_text_toolbar/` | 288 | `flutter test test/chat_ui/message_composer/widgets/rich_text_toolbar/` |
| Clean Architecture | `test/shared_ui/rich_text_formatting/` | 164 | `flutter test test/shared_ui/rich_text_formatting/` |

Run from `chat_uikit/` directory.

## Gotchas

- The clean architecture module (`shared_ui/src/rich_text_formatting/`) has proper repository/datasource/use-case layers and passes all 164 tests, but the composer does NOT use it at runtime. `OrderedListFormatterDataSource.handleEnterKey()` and `_renumberFrom()` are tested but never called by the composer. Don't fix bugs there.
- `RichTextFormatterManager` in `shared_ui/src/formatter/rich_text/` is marked `@Deprecated`. It only runs if the text controller is a plain `TextEditingController` (not `RichTextEditingController`). In practice this path is never hit when the toolbar is enabled.
- `format_type.dart` and `format_compatibility.dart` are shared between systems. If you change the `FormatType` enum, run BOTH test suites.
- `toMarkdown()` serialization must round-trip correctly: compose → send → receive → render. Test both directions.
- The toolbar button dispatch in `cometchat_message_composer.dart` (~line 2900) has a priority chain. If you add a new format, you need to handle it in the correct controller based on whether code blocks are active.

## Anti-Patterns

```dart
// ❌ WRONG — fixing ordered list bug in clean architecture module
// File: shared_ui/src/rich_text_formatting/data/datasources/ordered_list_formatter_datasource.dart
// This file is NOT used at runtime!

// ✅ CORRECT — fix in WYSIWYG controller
// File: chat_ui/src/message_composer/widgets/rich_text_toolbar/rich_text_editing_controller.dart
// Method: _renumberOrderedListLines() or _maybeContinueLineFormat()
```

```dart
// ❌ WRONG — editing the deprecated legacy formatter
// File: shared_ui/src/formatter/rich_text/bold_text_formatter.dart
// This is @Deprecated and only runs as a fallback

// ✅ CORRECT — edit the WYSIWYG system
// File: rich_text_editing_controller.dart for inline formats
// File: segment_composer_controller.dart for code blocks
```

```dart
// ❌ WRONG — adding a new FormatType without testing both suites
// format_type.dart is shared — changes affect both systems

// ✅ CORRECT — run both test suites after changing shared files
// flutter test test/chat_ui/message_composer/widgets/rich_text_toolbar/
// flutter test test/shared_ui/rich_text_formatting/
```

## Checklist — Rich Text PR

- [ ] Bug fix is in the WYSIWYG system, NOT the clean architecture module
- [ ] Correct file identified from the "Where to Edit" table
- [ ] `toMarkdown()` round-trips correctly (compose → send → receive → render)
- [ ] WYSIWYG test suite passes (288 tests)
- [ ] If shared files changed (`format_type.dart`, `format_compatibility.dart`), clean architecture tests also pass (164 tests)
- [ ] New format handled in the correct controller based on code block state
- [ ] Toolbar button dispatch updated if new format added
