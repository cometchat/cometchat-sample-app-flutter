# CometChat Flutter UIKit v6 Skills

Agent skills for building with CometChat Flutter UIKit v6.0.0 — chat and calls combined.

## Quick Install

```bash
npx skills add cometchat/flutter-uikit -g -y
```

## Available Skills

| Skill | Triggers On |
|-------|-------------|
| `cometchat-flutter-uikit` | Any CometChat UIKit usage, project setup, component names, error codes |
| `cometchat-flutter-core` | Init, login, logout, hard rules, lifecycle, Completer bridge, architecture patterns |
| `cometchat-flutter-conversations` | Conversation list, recent chats, ConversationsBloc, typing indicators |
| `cometchat-flutter-messages` | Message list, composer, header, bubbles, keyboard, rich text, send/edit/delete |
| `cometchat-flutter-users-groups` | User list, group list, group members, contacts, selection |
| `cometchat-flutter-calls` | Voice/video calls, CometChatCallButtons, incoming/outgoing/ongoing call, call logs, CallingConfiguration |
| `cometchat-flutter-theming` | Colors, dark mode, typography, spacing, Style classes, CometChatThemeHelper |
| `cometchat-flutter-events` | SDK listeners, UI events, real-time updates, typing, presence, receipts |
| `cometchat-flutter-v5-to-v6-migration` | Migrating from v5 (GetX + separate calls package) to v6 (unified package, no GetX) |

### v5 Skills (for projects still on UIKit v5)

| Skill | Triggers On |
|-------|-------------|
| `cometchat-flutter-v5-uikit` | Any CometChat v5 UIKit usage, project setup, component names |
| `cometchat-flutter-v5-core` | v5 init, login, logout, UIKitSettings, GetX patterns, lifecycle |
| `cometchat-flutter-v5-conversations` | v5 conversation list, recent chats, GetX controller |
| `cometchat-flutter-v5-messages` | v5 message list, composer, header, bubbles, threads |
| `cometchat-flutter-v5-users-groups` | v5 user list, group list, group members, scope |
| `cometchat-flutter-v5-calls` | v5 voice/video calls, CometChatCallingExtension, call logs |
| `cometchat-flutter-v5-theming` | v5 colors, dark mode, typography, spacing, Style classes |
| `cometchat-flutter-v5-events` | v5 SDK listeners, UI events, typing, presence, receipts |

## How Auto-Detection Works

Each skill has a `description` field that lists trigger keywords. When you mention
something related, the agent matches your question to the description and loads the
full skill. You never need to manually select a skill.

## Compatibility

- Flutter >=2.5.0
- Dart >=2.17.0
- cometchat_chat_uikit ^6.0.0
- cometchat_calls_sdk ^5.0.0-beta
- flutter_bloc ^8.1.0
- Works with: Kiro, Claude Code, Cursor, Copilot, and other AI coding assistants
  that support the Agent Skills specification
