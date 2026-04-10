/// CometChat Message List - Shared UI Components
///
/// This module only contains the UI widgets and utilities.
/// All logic (BLoC, Domain, Data, DI) lives in chat_ui/src/message_list/.
library cometchat_message_list;

// =============================================================================
// UI Utils (stays in shared_ui)
// =============================================================================
export 'utils/keyboard_mixin.dart';
export 'utils/composer_height_notifier.dart';

// =============================================================================
// Widgets (UI - stays in shared_ui)
// =============================================================================
export 'widgets/cometchat_message_list.dart';
export 'widgets/cometchat_animated_message_list.dart';
export 'widgets/scroll_to_bottom_button.dart';
export 'widgets/load_more_indicator.dart';
export 'widgets/empty_message_list.dart';
export 'widgets/sliver_spacing.dart';
export 'widgets/cometchat_new_message_indicator.dart';
export 'widgets/cometchat_new_message_indicator_style.dart';

// =============================================================================
// Style
// =============================================================================
export 'cometchat_message_list_style.dart';
