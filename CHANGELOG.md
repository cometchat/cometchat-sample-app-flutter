# Changelog

# v6.0.0-beta.2

## New
- Added AI Assistant support, including chat history, constants, events, and stream services to help developers build AI-powered messaging experiences within their applications.
- Added a new AI sample application in `examples/ai_sample_app` to demonstrate AI Assistant integration and implementation patterns.
- Added a call screen overlay for ongoing calls, allowing users to quickly return to active calls while navigating the application.
- Added emoji utility support for improved text rendering and emoji handling across messaging components.
- Added component toggles in the sample app to simplify feature configuration and testing across different UI scenarios.
- Added a test suite for the sample application to improve reliability and validation of core user flows.
- Added 15 AI agent skills covering components, theming, events, calling, migration, production readiness, and troubleshooting workflows.
- Added `AGENTS.md` support for AI coding assistant integration and automated developer workflows.
- Added `.claude-plugin` marketplace configuration support for AI tooling integration.

## Enhancements
- Updated the calling UI with improvements to call buttons, call logs, and incoming, outgoing, and ongoing call workflows for a more consistent calling experience.
- Improved the message composer with updated bloc architecture, events, state handling, and suggestion list behavior for smoother message composition.
- Enhanced the message list with updated data sources, repositories, use cases, and action overlays to improve message rendering and interactions.
- Updated conversation components, including blocs, subtitle utilities, list items, subtitle views, and trailing views for improved conversation management.
- Improved group and user components with updated blocs and list widgets to provide more consistent data handling and UI behavior.
- Updated the search component with revised bloc and event handling to improve search responsiveness and maintainability.
- Refined shared UI components, including list bases, message inputs, reaction lists, badges, list items, and action bubbles for a more cohesive user experience.
- Updated text bubbles, audio bubbles, card bubbles, and the image viewer to improve rendering consistency and interaction handling.
- Improved text formatting utilities and formatter behavior for more reliable content presentation across message types.
- Enhanced status indicators, marquee effects, and snack bar utilities to improve visual feedback and UI responsiveness.
- Updated the keyboard height plugin to improve input handling and keyboard interaction behavior on supported devices.
- Improved the Android native plugin and audio recorder components for better media handling and recording reliability.
- Updated sample app screens, including home, messages, threads, user info, group info, banned members, guard, and protected group join flows for improved usability and consistency.
- Updated the `cometchat_uikit` package with architectural improvements to support enhanced scalability and maintainability.

## Fixes
- None

## 6.0.0-beta.1

- Initial v6 beta release
- Unified UIKit package (`cometchat_uikit`)
