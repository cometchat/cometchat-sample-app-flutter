/// Re-export file for backward compatibility.
///
/// This file re-exports the CometChatMessageComposer widget from its new
/// location in the widgets directory. This ensures existing imports continue
/// to work without modification.
///
/// The actual implementation is now in:
/// `widgets/cometchat_message_composer.dart`
library;

export 'widgets/cometchat_message_composer.dart';
export 'utils/cometchat_keyboard_diagnostics.dart';

// Multi-attachment staging tray (composer-side of the gallery feature).
export 'upload/attachment_tray_controller.dart';
export 'widgets/attachment_tray/cometchat_attachment_tray.dart';
export 'widgets/attachment_tray/cometchat_attachment_tile.dart';
export 'widgets/attachment_tray/cometchat_attachment_tray_style.dart';
export 'widgets/cometchat_attachment_error_snackbar.dart';
