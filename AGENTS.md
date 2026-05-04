# CometChat Flutter UIKit v6

This repository contains the CometChat Flutter UIKit v6 with sample apps. When working with this codebase, use the agent skills in the `skills/` directory for SDK-specific guidance.

## Skills

Load the relevant skill based on the task:

### Core
- `skills/cometchat-flutter-uikit/SKILL.md` — Entry-point dispatcher, detects project, routes to the right skill
- `skills/cometchat-flutter-core/SKILL.md` — Init, login, logout, UIKitSettings, listener lifecycle, Clean Architecture + BLoC pattern
- `skills/cometchat-flutter-placement/SKILL.md` — Widget placement, Scaffold integration, navigation patterns

### Components
- `skills/cometchat-flutter-conversations/SKILL.md` — CometChatConversations, ConversationsBloc, typing indicators, unread counts
- `skills/cometchat-flutter-messages/SKILL.md` — CometChatMessageList, CometChatMessageComposer, CometChatMessageHeader, bubbles, threads
- `skills/cometchat-flutter-users-groups/SKILL.md` — CometChatUsers, CometChatGroups, CometChatGroupMembers, selection, request builders
- `skills/cometchat-flutter-calls/SKILL.md` — CometChatCallButtons, incoming/outgoing/ongoing call, call logs, CallingConfiguration
- `skills/cometchat-flutter-components/SKILL.md` — Shared UI components, list items, badges, avatars, status indicators

### Features
- `skills/cometchat-flutter-theming/SKILL.md` — CometChatThemeHelper, CometChatColorPalette, dark mode, Style classes, merge pattern
- `skills/cometchat-flutter-events/SKILL.md` — SDK listeners, UI event streams, typing, presence, receipts, message events
- `skills/cometchat-flutter-customization/SKILL.md` — Custom views, overrides, configuration objects, style customization
- `skills/cometchat-flutter-features/SKILL.md` — Extensions, smart replies, reactions, stickers, polls

### Production & Migration
- `skills/cometchat-flutter-production/SKILL.md` — Production hardening, error handling, performance, best practices
- `skills/cometchat-flutter-troubleshooting/SKILL.md` — Common issues, debugging, error resolution
- `skills/cometchat-flutter-v5-to-v6-migration/SKILL.md` — Upgrading from v5 (GetX + separate calls package) to v6 (unified package, BLoC, no GetX)

## Key Rules

- v6 uses BLoC pattern (not GetX from v5)
- Single unified package: `cometchat_uikit` (no separate calls package)
- Clean Architecture: data → domain → presentation layers
- Theme: use `CometChatThemeHelper` and `CometChatColorPalette`
- Always wrap CometChat widgets with proper `Scaffold` and `resizeToAvoidBottomInset`
- Language: Dart 3.x, Flutter 3.x
- Documentation: https://www.cometchat.com/docs
