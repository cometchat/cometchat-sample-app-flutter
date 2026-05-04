# CometChat Flutter UIKit v6 Skills

Agent skills for building with CometChat Flutter UIKit v6.0.0.

## Quick Install

```bash
# Install all consumer skills (for app developers)
npx skills add cometchat/flutter-uikit -g -y

# Install all contributor skills (for package developers)
npx skills add cometchat/flutter-uikit --contributor -g -y
```

## Available Skills

### For App Developers (using cometchat_chat_uikit in your app)

These skills help you integrate and use CometChat UIKit correctly in your Flutter application.
Install these if you `import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart'`.

| Skill | Triggers On |
|-------|-------------|
| `cometchat-flutter-uikit` | Any CometChat UIKit usage, project setup, component names, error codes |
| `cometchat-flutter-core` | Init, login, logout, hard rules, lifecycle, Completer bridge, architecture patterns |
| `cometchat-flutter-theming` | Colors, dark mode, typography, spacing, Style classes, CometChatThemeHelper |
| `cometchat-flutter-conversations` | Conversation list, recent chats, ConversationsBloc, typing indicators |
| `cometchat-flutter-messages` | Message list, composer, header, bubbles, keyboard, rich text, send/edit/delete |
| `cometchat-flutter-users-groups` | User list, group list, group members, contacts, selection |
| `cometchat-flutter-events` | SDK listeners, UI events, real-time updates, typing, presence, receipts |
| `cometchat-flutter-v5-to-v6-migration` | Migrating from v5 (GetX + separate calls package) to v6 (unified package, no GetX) |

### For Package Contributors (working on cometchat_chat_uikit source code)

These skills help you follow the internal architecture rules when adding features,
fixing bugs, or submitting PRs to the cometchat_chat_uikit codebase.
Install these only if you clone and modify the chat_uikit repo itself.

| Skill | Triggers On |
|-------|-------------|
| `cometchat-contributor-architecture` | Adding new components, file placement, layer rules, naming conventions, DI patterns |
| `cometchat-contributor-testing` | Writing tests, coverage targets, BLoC tests, widget tests, test fixtures |
| `cometchat-contributor-migration` | GetX to BLoC migration, Rx conversion, adapter pattern, legacy compatibility |
| `cometchat-contributor-performance` | Theme caching, buildWhen, O(1) lookups, keyboard jank, ValueNotifier isolation |
| `cometchat-contributor-rich-text` | Rich text formatting bugs, WYSIWYG vs clean arch vs legacy, which file to edit |

## How Auto-Detection Works

Each skill has a `description` field that lists trigger keywords. When you mention
something related, the agent matches your question to the description and loads the
full skill. You never need to manually select a skill.

## Compatibility

- Flutter >=2.5.0
- Dart >=2.17.0
- cometchat_chat_uikit ^6.0.0
- flutter_bloc ^8.1.0
- Works with: Kiro, Claude Code, Cursor, Copilot, and other AI coding assistants
  that support the Agent Skills specification
