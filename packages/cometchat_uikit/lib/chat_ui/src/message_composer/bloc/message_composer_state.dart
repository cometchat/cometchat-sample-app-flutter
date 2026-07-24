import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import '../../../../cometchat_chat_uikit.dart';

/// Status enum for message composer operations
enum MessageComposerStatus {
  /// Initial/idle state
  idle,

  /// Sending a message
  sending,

  /// Editing a message
  editing,

  /// Replying to a message
  replying,

  /// AI is generating content
  /// @deprecated AI features have been removed
  aiGenerating,

  /// Recording audio message
  recording,

  /// Operation completed successfully
  success,

  /// Operation failed with error
  error,
}

/// Immutable state class for MessageComposerBloc
/// Uses Equatable for proper state comparison
class MessageComposerState extends Equatable {
  /// Current status of the composer
  final MessageComposerStatus status;

  /// User to send messages to (for 1:1 chats)
  final User? user;

  /// Group to send messages to (for group chats)
  final Group? group;

  /// Currently logged-in user
  final User? loggedInUser;

  /// Current text in the composer input
  final String composeText;

  /// Message being edited (when in edit mode)
  final BaseMessage? editMessage;

  /// Message being replied to (when in reply mode)
  final BaseMessage? replyMessage;

  /// Last sent/edited message (for success state)
  final BaseMessage? sentMessage;

  /// Error message (when in error state)
  final String? errorMessage;

  /// Parent message ID for threaded conversations
  final int parentMessageId;

  /// Whether user is currently typing
  final bool isTyping;

  /// Header panel widget
  final Widget? headerPanel;

  /// Footer panel widget
  final Widget? footerPanel;

  /// Preview panel widget
  final Widget? previewPanel;

  /// Composer ID for event filtering
  final Map<String, dynamic> composerId;

  /// Locked bottom padding height (when sticker/emoji keyboard is shown)
  /// When set, this overrides the keyboard-based bottom padding
  final double? lockedBottomPadding;

  /// Whether the AI is currently streaming a response
  final bool isActiveStreaming;

  const MessageComposerState({
    this.status = MessageComposerStatus.idle,
    this.user,
    this.group,
    this.loggedInUser,
    this.composeText = '',
    this.editMessage,
    this.replyMessage,
    this.sentMessage,
    this.errorMessage,
    this.parentMessageId = 0,
    this.isTyping = false,
    this.headerPanel,
    this.footerPanel,
    this.previewPanel,
    this.composerId = const {},
    this.lockedBottomPadding,
    this.isActiveStreaming = false,
  });

  // ============================================================================
  // Computed Properties
  // ============================================================================

  /// Get the receiver ID (user UID or group GUID)
  String get receiverId => user?.uid ?? group?.guid ?? '';

  /// Get the receiver type (user or group)
  String get receiverType =>
      user != null ? ReceiverTypeConstants.user : ReceiverTypeConstants.group;

  /// Check if composer is in edit mode
  bool get isEditMode => status == MessageComposerStatus.editing;

  /// Check if composer is in reply mode
  bool get isReplyMode => status == MessageComposerStatus.replying;

  /// Check if composer is in recording mode
  bool get isRecordingMode => status == MessageComposerStatus.recording;

  /// Check if user is not blocked (can send messages)
  bool get userIsNotBlocked =>
      user == null || (user!.blockedByMe != true && user!.hasBlockedMe != true);

  /// Check if compose text is valid for sending (not empty/whitespace)
  bool get canSend => composeText.trim().isNotEmpty;

  // ============================================================================
  // Copy With
  // ============================================================================

  /// Create a copy of this state with updated fields
  MessageComposerState copyWith({
    MessageComposerStatus? status,
    User? user,
    Group? group,
    User? loggedInUser,
    String? composeText,
    BaseMessage? editMessage,
    BaseMessage? replyMessage,
    BaseMessage? sentMessage,
    String? errorMessage,
    int? parentMessageId,
    bool? isTyping,
    Widget? headerPanel,
    Widget? footerPanel,
    Widget? previewPanel,
    Map<String, dynamic>? composerId,
    double? lockedBottomPadding,
    bool? isActiveStreaming,
    // Special flags to clear nullable fields
    bool clearEditMessage = false,
    bool clearReplyMessage = false,
    bool clearSentMessage = false,
    bool clearErrorMessage = false,
    bool clearHeaderPanel = false,
    bool clearFooterPanel = false,
    bool clearPreviewPanel = false,
    bool clearUser = false,
    bool clearGroup = false,
    bool clearLockedBottomPadding = false,
  }) {
    return MessageComposerState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      group: clearGroup ? null : (group ?? this.group),
      loggedInUser: loggedInUser ?? this.loggedInUser,
      composeText: composeText ?? this.composeText,
      editMessage: clearEditMessage ? null : (editMessage ?? this.editMessage),
      replyMessage: clearReplyMessage
          ? null
          : (replyMessage ?? this.replyMessage),
      sentMessage: clearSentMessage ? null : (sentMessage ?? this.sentMessage),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      parentMessageId: parentMessageId ?? this.parentMessageId,
      isTyping: isTyping ?? this.isTyping,
      headerPanel: clearHeaderPanel ? null : (headerPanel ?? this.headerPanel),
      footerPanel: clearFooterPanel ? null : (footerPanel ?? this.footerPanel),
      previewPanel: clearPreviewPanel
          ? null
          : (previewPanel ?? this.previewPanel),
      composerId: composerId ?? this.composerId,
      lockedBottomPadding: clearLockedBottomPadding
          ? null
          : (lockedBottomPadding ?? this.lockedBottomPadding),
      isActiveStreaming: isActiveStreaming ?? this.isActiveStreaming,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    group,
    loggedInUser,
    composeText,
    editMessage,
    replyMessage,
    sentMessage,
    errorMessage,
    parentMessageId,
    isTyping,
    headerPanel,
    footerPanel,
    previewPanel,
    composerId,
    lockedBottomPadding,
    isActiveStreaming,
  ];
}
