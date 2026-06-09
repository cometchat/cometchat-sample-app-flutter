# Message List Golden Tests

## Overview

Golden tests capture pixel-perfect visual snapshots of message list items in known states.
They catch visual regressions that widget tests miss — spacing changes, color shifts, icon sizing, dark mode breakage.

## Variants Covered

| # | Variant | What it tests |
|---|---------|---------------|
| 1 | Sent + Read | Blue double-tick receipt icon |
| 2 | Sent + Delivered | Grey double-tick receipt icon |
| 3 | Sent only | Single tick receipt icon |
| 4 | Received | Incoming message bubble alignment |
| 5 | Long text | Multi-line wrapping behavior |
| 6 | Emoji only | Scaled emoji bubble (no background) |

Each variant is rendered in both light and dark themes (12 total visual states).

## Running

```bash
# Generate/update goldens
flutter test test/chat_ui/message_list/goldens/ --update-goldens

# Verify goldens match
flutter test test/chat_ui/message_list/goldens/
```

## CI Behavior

- In CI (`CI` env var set): Platform-specific goldens are skipped. Only the CI variant (Ahem font) runs.
- Locally: Full platform goldens are generated for human review.

## Output Structure

```
goldens/
├── ci/                          # Cross-platform (Ahem font)
│   └── message_list_variants.png
├── macos/                       # Human-readable (system fonts)
│   └── message_list_variants.png
├── message_list_golden_test.dart
└── README.md
```

## Intentional Simplifications

- `lastMessage: null` is used to avoid pulling in formatter/moderation chains
- Messages use `FakeTextMessage` with minimal fields to isolate visual rendering
- No real BLoC is instantiated — variants render message content directly
