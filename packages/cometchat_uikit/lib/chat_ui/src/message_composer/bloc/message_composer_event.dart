import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// Base class for all message composer events
/// Uses Equatable for proper event comparison in BLoC
abstract class MessageComposerEvent extends Equatable {
  const MessageComposerEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// User/Group Setup Events
// ============================================================================

/// Set the user to send messages to
class ComposerSetUser extends MessageComposerEvent {
  final User user;

  const ComposerSetUser(this.user);

  @override
  List<Object?> get props => [user];
}

/// Set the group to send messages to
class ComposerSetGroup extends MessageComposerEvent {
  final Group group;

  const ComposerSetGroup(this.group);

  @override
  List<Object?> get props => [group];
}

// ============================================================================
// Text Composition Events
// ============================================================================

/// Update the compose text
class UpdateComposeText extends MessageComposerEvent {
  final String text;

  const UpdateComposeText(this.text);

  @override
  List<Object?> get props => [text];
}

/// Clear the composer (text, edit mode, reply mode)
class ClearComposer extends MessageComposerEvent {
  const ClearComposer();
}

// ============================================================================
// Message Sending Events
// ============================================================================

/// Send a text message
class SendTextMessage extends MessageComposerEvent {
  final Map<String, dynamic>? metadata;
  final TextMessage? processedMessage;

  const SendTextMessage({this.metadata, this.processedMessage});

  @override
  List<Object?> get props => [metadata, processedMessage];
}

/// Send a media message (image, video, audio, file)
class SendMediaMessage extends MessageComposerEvent {
  final String path;
  final String messageType;
  final Map<String, dynamic>? metadata;

  const SendMediaMessage({
    required this.path,
    required this.messageType,
    this.metadata,
  });

  @override
  List<Object?> get props => [path, messageType, metadata];
}

/// Send a custom message
class SendCustomMessage extends MessageComposerEvent {
  final Map<String, String> customData;
  final String type;

  const SendCustomMessage({
    required this.customData,
    required this.type,
  });

  @override
  List<Object?> get props => [customData, type];
}

// ============================================================================
// Edit Mode Events
// ============================================================================

/// Set a message for editing
class SetEditMessage extends MessageComposerEvent {
  final BaseMessage message;

  const SetEditMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// Clear edit mode
class ClearEditMessage extends MessageComposerEvent {
  const ClearEditMessage();
}

/// Submit the edited text message
class EditTextMessage extends MessageComposerEvent {
  final TextMessage? processedMessage;
  
  const EditTextMessage({this.processedMessage});

  @override
  List<Object?> get props => [processedMessage];
}

// ============================================================================
// Reply Mode Events
// ============================================================================

/// Set a message for reply
class SetReplyMessage extends MessageComposerEvent {
  final BaseMessage message;

  const SetReplyMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// Clear reply mode
class ClearReplyMessage extends MessageComposerEvent {
  const ClearReplyMessage();
}

// ============================================================================
// Typing Indicator Events
// ============================================================================

/// Start typing indicator
class StartTyping extends MessageComposerEvent {
  const StartTyping();
}

/// End typing indicator
class EndTyping extends MessageComposerEvent {
  const EndTyping();
}

// ============================================================================
// Panel Events
// ============================================================================

/// Show a panel at a specific position
class ShowPanel extends MessageComposerEvent {
  final Map<String, dynamic>? id;
  final CustomUIPosition position;
  final Widget Function(BuildContext) builder;

  const ShowPanel({
    this.id,
    required this.position,
    required this.builder,
  });

  @override
  List<Object?> get props => [id, position];
}

/// Hide a panel at a specific position
class HidePanel extends MessageComposerEvent {
  final Map<String, dynamic>? id;
  final CustomUIPosition position;

  const HidePanel({
    this.id,
    required this.position,
  });

  @override
  List<Object?> get props => [id, position];
}

// ============================================================================
// AI Streaming Events
// ============================================================================



// ============================================================================
// Internal Events (triggered by SDK listeners)
// ============================================================================

/// Internal event: Message was edited externally
class MessageEditedExternally extends MessageComposerEvent {
  final BaseMessage message;

  const MessageEditedExternally(this.message);

  @override
  List<Object?> get props => [message];
}

/// Internal event: Compose message received from external source
class ComposeMessageReceived extends MessageComposerEvent {
  final String text;
  final Map<String, dynamic>? id;

  const ComposeMessageReceived({
    required this.text,
    this.id,
  });

  @override
  List<Object?> get props => [text, id];
}

/// Internal event: User blocked status changed
class UserBlockedStatusChanged extends MessageComposerEvent {
  final User user;
  final bool isBlocked;

  const UserBlockedStatusChanged({
    required this.user,
    required this.isBlocked,
  });

  @override
  List<Object?> get props => [user, isBlocked];
}

/// Initialize the BLoC with logged-in user
class InitializeComposer extends MessageComposerEvent {
  const InitializeComposer();
}

// ============================================================================
// Audio Recording Events
// ============================================================================

/// Start audio recording mode
class StartAudioRecording extends MessageComposerEvent {
  const StartAudioRecording();
}

/// Cancel audio recording and return to normal mode
class CancelAudioRecording extends MessageComposerEvent {
  const CancelAudioRecording();
}

/// Submit the recorded audio
class SubmitAudioRecording extends MessageComposerEvent {
  final String filePath;

  const SubmitAudioRecording(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

// ============================================================================
// Bottom Padding Lock Events (for sticker/emoji keyboard)
// ============================================================================

/// Lock the bottom padding to a specific height (used when showing sticker keyboard)
/// This prevents the layout from jumping when system keyboard closes
class LockBottomPadding extends MessageComposerEvent {
  final double height;

  const LockBottomPadding(this.height);

  @override
  List<Object?> get props => [height];
}

/// Unlock the bottom padding (return to normal keyboard-based padding)
class UnlockBottomPadding extends MessageComposerEvent {
  const UnlockBottomPadding();
}

/// Request the composer to focus its text field (opens OS keyboard)
class RequestComposerFocus extends MessageComposerEvent {
  const RequestComposerFocus();
}
