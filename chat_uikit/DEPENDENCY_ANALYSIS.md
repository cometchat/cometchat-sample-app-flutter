# Dependency Analysis for flutter_chat_ui and flutter_chat_core Integration

## Analysis Date
December 30, 2025

## Source Packages
- flutter_chat_ui: v2.11.1
- flutter_chat_core: v2.9.0

## Identified Dependencies

### flutter_chat_ui Dependencies
Based on analysis of imported packages in the copied source code:

1. **provider** - Used extensively for state management across multiple files
   - Files: chat_message.dart, is_typing.dart, empty_chat_list.dart, load_more.dart, avatar.dart, simple_text_message.dart, chat_animated_list.dart, chat.dart, username.dart, sliver_spacing.dart, scroll_to_bottom.dart, composer.dart

2. **cross_cache** - Used for caching functionality
   - Files: avatar.dart, chat.dart

3. **diffutil_dart** - Used for efficient list diffing in animated lists
   - Files: chat_animated_list.dart, message_list_diff.dart

4. **scrollview_observer** - Used for scroll observation in chat lists
   - Files: chat_animated_list.dart

### flutter_chat_core Dependencies
Based on analysis of imported packages in the copied source code:

1. **freezed_annotation** - Used for immutable data classes
   - Files: user.dart, message.dart, chat_theme.dart, builders.dart, link_preview_data.dart

2. **json_annotation** - Used for JSON serialization
   - Files: duration_converter.dart, epoch_date_time_converter.dart

## Current chat_uikit pubspec.yaml Dependencies

Existing dependencies in chat_uikit/pubspec.yaml:
- flutter (SDK)
- flutter_localizations (SDK)
- intl: any
- path_provider: ^2.1.2
- webview_flutter: ^4.4.3
- get: ^4.6.5
- url_launcher: ^6.1.12
- cometchat_uikit_shared (path dependency)
- cometchat_sdk: ^4.0.32
- gpt_markdown: ^1.1.2
- flutter_chat_ui: ^2.11.1 (TO BE REMOVED)
- flutter_chat_core: ^2.9.0 (TO BE REMOVED)

## Missing Dependencies to Add

The following dependencies are used by the internalized packages but not present in chat_uikit pubspec.yaml:

1. **provider** - MISSING (required by flutter_chat_ui)
2. **cross_cache** - MISSING (required by flutter_chat_ui)
3. **diffutil_dart** - MISSING (required by flutter_chat_ui)
4. **scrollview_observer** - MISSING (required by flutter_chat_ui)
5. **freezed_annotation** - MISSING (required by flutter_chat_core)
6. **json_annotation** - MISSING (required by flutter_chat_core)

## Recommended Actions

1. Add the following dependencies to chat_uikit/pubspec.yaml:
   ```yaml
   provider: ^6.0.0
   cross_cache: ^1.0.0
   diffutil_dart: ^3.0.0
   scrollview_observer: ^1.0.0
   freezed_annotation: ^2.0.0
   json_annotation: ^4.0.0
   ```

2. Remove the following dependencies:
   ```yaml
   flutter_chat_ui: ^2.11.1
   flutter_chat_core: ^2.9.0
   ```

3. Run `flutter pub get` to resolve dependencies

## Notes

- Version constraints should be verified against the latest compatible versions
- Some packages may have additional transitive dependencies that will be resolved automatically
- The freezed_annotation and json_annotation packages may require build_runner in dev_dependencies for code generation (if not already present)
