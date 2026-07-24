/// Barrel export for message list widgets
///
/// Re-exports widgets from shared_ui and provides chat_ui specific widgets.
library;

// Hide MessageItemBuilder from animated list to avoid conflict with BLoC version
export '../../../../shared_ui/src/cometchat_message_list/widgets/cometchat_animated_message_list.dart'
    hide MessageItemBuilder;
export '../../../../shared_ui/src/cometchat_message_list/widgets/empty_message_list.dart';
export '../../../../shared_ui/src/cometchat_message_list/widgets/load_more_indicator.dart';
export '../../../../shared_ui/src/cometchat_message_list/widgets/scroll_to_bottom_button.dart';
export '../../../../shared_ui/src/cometchat_message_list/widgets/sliver_spacing.dart';

// Export the BLoC-based message list widget
export 'cometchat_message_list.dart';

// Export the message action overlay
export 'cometchat_message_action_overlay.dart';

// Export the swipe-to-reply widget
export 'cometchat_message_swipe.dart';
