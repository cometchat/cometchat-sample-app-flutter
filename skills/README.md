# CometChat Flutter UIKit v6 — Skills

Agent skills for building with the CometChat Flutter UIKit v6. Install individually or browse all available skills.

## How It Works

Skills are bundled in this repository under `skills/`. When you clone the repo and open it in a supported AI coding assistant, skills auto-trigger based on what you're doing — mention "conversations" and the conversations skill loads, ask about "theming" and the theming skill loads. No manual activation needed.

To use these skills in your own project, copy the `skills/` folder into your project root:

```bash
cp -r skills/ /path/to/your/project/skills/
```

## Available Skills

### Core

| Skill | Triggers On |
|-------|-------------|
| `cometchat-flutter-uikit` | Entry-point dispatcher — detects project, routes to the right skill based on context |
| `cometchat-flutter-core` | Init, login, logout, UIKitSettings, listener lifecycle, theme caching, Clean Architecture + BLoC pattern |
| `cometchat-flutter-placement` | Widget placement, Scaffold integration, navigation patterns |

### Components

| Skill | Triggers On |
|-------|-------------|
| `cometchat-flutter-conversations` | CometChatConversations, ConversationsBloc, typing indicators, unread counts, custom views |
| `cometchat-flutter-messages` | CometChatMessageList, CometChatMessageComposer, CometChatMessageHeader, bubbles, threads |
| `cometchat-flutter-users-groups` | CometChatUsers, CometChatGroups, CometChatGroupMembers, selection, request builders |
| `cometchat-flutter-calls` | CometChatCallButtons, incoming/outgoing/ongoing call, call logs, CallingConfiguration |
| `cometchat-flutter-components` | Shared UI components, list items, badges, avatars, status indicators |

### Features

| Skill | Triggers On |
|-------|-------------|
| `cometchat-flutter-theming` | CometChatThemeHelper, CometChatColorPalette, dark mode, Style classes, merge pattern |
| `cometchat-flutter-events` | SDK listeners, UI event streams, typing, presence, receipts, message events |
| `cometchat-flutter-customization` | Custom views, overrides, configuration objects, style customization |
| `cometchat-flutter-features` | Extensions, smart replies, reactions, stickers, polls |

### Production & Migration

| Skill | Triggers On |
|-------|-------------|
| `cometchat-flutter-production` | Production hardening, error handling, performance, best practices |
| `cometchat-flutter-troubleshooting` | Common issues, debugging, error resolution |
| `cometchat-flutter-v5-to-v6-migration` | Upgrading from v5 (GetX + separate calls package) to v6 (unified package, BLoC, no GetX) |

## How Auto-Detection Works

Each skill has a `description` field in its YAML frontmatter that lists trigger keywords. When you mention something related (like "add conversations" or "customize theme"), the agent reads the description, decides the skill is relevant, and loads its full content. You never need to manually select a skill.

## Compatibility

- CometChat Flutter UIKit v6 (6.0.0-beta.2+)
- Flutter 3.x
- Dart 3.x
- Works with: Kiro, Claude Code, Cursor, Copilot, and other AI coding assistants that support the skills ecosystem
