import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import '../../../../shared_ui/src/clean_architecture/core/constants/enums.dart'
    as core_enums;

/// BLoC for managing message composer state and business logic
/// Handles message sending, editing, replying, and typing indicators
class MessageComposerBloc extends Bloc<MessageComposerEvent, MessageComposerState>
    with
        CometChatMessageEventListener,
        CometChatUIEventListener,
        CometChatUserEventListener {
  // ============================================================================
  // Use Cases
  // ============================================================================
  final SendTextMessageUseCase _sendTextMessageUseCase;
  final SendMediaMessageUseCase _sendMediaMessageUseCase;
  final SendCustomMessageUseCase _sendCustomMessageUseCase;
  final EditMessageUseCase _editMessageUseCase;
  final StartTypingUseCase _startTypingUseCase;
  final EndTypingUseCase _endTypingUseCase;
  final GetMessageComposerLoggedInUserUseCase _getLoggedInUserUseCase;

  // ============================================================================
  // Configuration
  // ============================================================================
  final bool disableTypingEvents;
  final bool disableSoundForMessages;
  final String? customSoundForMessage;
  final String? customSoundForMessagePackage;
  final int parentMessageId;
  final BuildContext context;

  // ============================================================================
  // Callbacks
  // ============================================================================
  final Function(BuildContext, BaseMessage, PreviewMessageMode?)?
      onSendButtonTap;
  final OnError? errorCallback;

  // ============================================================================
  // SDK Listener IDs
  // ============================================================================
  late final String _messageListenerKey;
  late final String _uiEventListenerKey;
  late final String _userEventListenerKey;

  // ============================================================================
  // Typing Debouncer
  // ============================================================================
  final Debouncer _typingDebouncer = Debouncer(milliseconds: 1000);
  bool _isTyping = false;

  // ============================================================================
  // ValueNotifier for isolated rebuilds
  // ============================================================================
  final ValueNotifier<bool> _typingNotifier = ValueNotifier<bool>(false);

  /// Get typing notifier for isolated UI rebuilds
  ValueNotifier<bool> get typingNotifier => _typingNotifier;

  /// Callback for when focus is requested on the composer text field.
  /// Set by the widget to avoid coupling BLoC to FocusNode.
  VoidCallback? onFocusRequested;

  // ============================================================================
  // Constructor
  // ============================================================================
  MessageComposerBloc({
    required this.context,
    this.disableTypingEvents = false,
    this.disableSoundForMessages = false,
    this.customSoundForMessage,
    this.customSoundForMessagePackage,
    this.parentMessageId = 0,
    this.onSendButtonTap,
    this.errorCallback,
    User? user,
    Group? group,
    SendTextMessageUseCase? sendTextMessageUseCase,
    SendMediaMessageUseCase? sendMediaMessageUseCase,
    SendCustomMessageUseCase? sendCustomMessageUseCase,
    EditMessageUseCase? editMessageUseCase,
    StartTypingUseCase? startTypingUseCase,
    EndTypingUseCase? endTypingUseCase,
    GetMessageComposerLoggedInUserUseCase? getLoggedInUserUseCase,
  })  : _sendTextMessageUseCase = sendTextMessageUseCase ??
            MessageComposerServiceLocator.instance.sendTextMessageUseCase,
        _sendMediaMessageUseCase = sendMediaMessageUseCase ??
            MessageComposerServiceLocator.instance.sendMediaMessageUseCase,
        _sendCustomMessageUseCase = sendCustomMessageUseCase ??
            MessageComposerServiceLocator.instance.sendCustomMessageUseCase,
        _editMessageUseCase = editMessageUseCase ??
            MessageComposerServiceLocator.instance.editMessageUseCase,
        _startTypingUseCase = startTypingUseCase ??
            MessageComposerServiceLocator.instance.startTypingUseCase,
        _endTypingUseCase = endTypingUseCase ??
            MessageComposerServiceLocator.instance.endTypingUseCase,
        _getLoggedInUserUseCase = getLoggedInUserUseCase ??
            MessageComposerServiceLocator.instance.getLoggedInUserUseCase,
        super(MessageComposerState(
          user: user,
          group: group,
          parentMessageId: parentMessageId,
          composerId: _buildComposerId(user, group, parentMessageId),
        )) {
    // Register event handlers
    on<InitializeComposer>(_onInitializeComposer);
    on<ComposerSetUser>(_onSetUser);
    on<ComposerSetGroup>(_onSetGroup);
    on<UpdateComposeText>(_onUpdateComposeText);
    on<ClearComposer>(_onClearComposer);
    on<SendTextMessage>(_onSendTextMessage);
    on<SendMediaMessage>(_onSendMediaMessage);
    on<SendCustomMessage>(_onSendCustomMessage);
    on<SetEditMessage>(_onSetEditMessage);
    on<ClearEditMessage>(_onClearEditMessage);
    on<EditTextMessage>(_onEditTextMessage);
    on<SetReplyMessage>(_onSetReplyMessage);
    on<ClearReplyMessage>(_onClearReplyMessage);
    on<StartTyping>(_onStartTyping);
    on<EndTyping>(_onEndTyping);
    on<ShowPanel>(_onShowPanel);
    on<HidePanel>(_onHidePanel);
    on<MessageEditedExternally>(_onMessageEditedExternally);
    on<ComposeMessageReceived>(_onComposeMessageReceived);
    on<UserBlockedStatusChanged>(_onUserBlockedStatusChanged);
    on<StartAudioRecording>(_onStartAudioRecording);
    on<CancelAudioRecording>(_onCancelAudioRecording);
    on<SubmitAudioRecording>(_onSubmitAudioRecording);
    on<LockBottomPadding>(_onLockBottomPadding);
    on<UnlockBottomPadding>(_onUnlockBottomPadding);

    // Initialize listeners
    _initializeListeners();

    // Initialize composer
    add(const InitializeComposer());
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  static Map<String, dynamic> _buildComposerId(
      User? user, Group? group, int parentMessageId) {
    final Map<String, dynamic> composerId = {};
    if (parentMessageId != 0) {
      composerId['parentMessageId'] = parentMessageId;
    }
    if (group != null) {
      composerId['guid'] = group.guid;
    } else if (user != null) {
      composerId['uid'] = user.uid;
    }
    return composerId;
  }

  bool _isForThisWidget(Map<String, dynamic>? id) {
    if (id == null) return true;

    final composerId = state.composerId;
    if (id.containsKey('parentMessageId') &&
        composerId.containsKey('parentMessageId')) {
      if (id['parentMessageId'] != composerId['parentMessageId']) {
        return false;
      }
    }
    if (id.containsKey('guid') && composerId.containsKey('guid')) {
      if (id['guid'] != composerId['guid']) {
        return false;
      }
    }
    if (id.containsKey('uid') && composerId.containsKey('uid')) {
      if (id['uid'] != composerId['uid']) {
        return false;
      }
    }
    return true;
  }

  void _playSound() {
    if (!disableSoundForMessages) {
      CometChatUIKit.soundManager.play(
        sound: Sound.outgoingMessage,
        customSound: customSoundForMessage,
        packageName: customSoundForMessage == null || customSoundForMessage == ""
            ? UIConstants.packageName
            : customSoundForMessagePackage,
      );
    }
  }

  // ============================================================================
  // SDK Listener Registration
  // ============================================================================

  void _initializeListeners() {
    final dateString = DateTime.now().millisecondsSinceEpoch.toString();
    _messageListenerKey = '${dateString}bloc_message_listener';
    _uiEventListenerKey = '${dateString}bloc_ui_event_listener';
    _userEventListenerKey = '${dateString}bloc_user_event_listener';

    CometChatMessageEvents.addMessagesListener(_messageListenerKey, this);
    CometChatUIEvents.addUiListener(_uiEventListenerKey, this);
    CometChatUserEvents.addUsersListener(_userEventListenerKey, this);
  }

  // ============================================================================
  // Event Handlers
  // ============================================================================

  Future<void> _onInitializeComposer(
    InitializeComposer event,
    Emitter<MessageComposerState> emit,
  ) async {
    final result = await _getLoggedInUserUseCase();
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('Failed to get logged in user: ${failure.message}');
        }
      },
      (user) {
        emit(state.copyWith(loggedInUser: user));
      },
    );
  }

  void _onSetUser(
    ComposerSetUser event,
    Emitter<MessageComposerState> emit,
  ) {
    final newComposerId = _buildComposerId(event.user, null, parentMessageId);
    emit(state.copyWith(
      user: event.user,
      clearGroup: true,
      composeText: '',
      clearEditMessage: true,
      clearReplyMessage: true,
      status: MessageComposerStatus.idle,
      composerId: newComposerId,
    ));
  }

  void _onSetGroup(
    ComposerSetGroup event,
    Emitter<MessageComposerState> emit,
  ) {
    final newComposerId = _buildComposerId(null, event.group, parentMessageId);
    emit(state.copyWith(
      group: event.group,
      clearUser: true,
      composeText: '',
      clearEditMessage: true,
      clearReplyMessage: true,
      status: MessageComposerStatus.idle,
      composerId: newComposerId,
    ));
  }

  void _onUpdateComposeText(
    UpdateComposeText event,
    Emitter<MessageComposerState> emit,
  ) {
    emit(state.copyWith(composeText: event.text));
  }

  void _onClearComposer(
    ClearComposer event,
    Emitter<MessageComposerState> emit,
  ) {
    emit(state.copyWith(
      composeText: '',
      clearEditMessage: true,
      clearReplyMessage: true,
      status: MessageComposerStatus.idle,
    ));
  }

  Future<void> _onSendTextMessage(
    SendTextMessage event,
    Emitter<MessageComposerState> emit,
  ) async {
    // Use processed message if provided (from widget with formatter processing)
    // Otherwise create a new message from state.composeText
    TextMessage textMessage;
    
    if (event.processedMessage != null) {
      textMessage = event.processedMessage!;
      // Merge any additional metadata from event
      if (event.metadata != null) {
        textMessage.metadata = {
          ...?textMessage.metadata,
          ...event.metadata!,
        };
      }
    } else {
      final text = state.composeText.trim();
      if (text.isEmpty) return;

      Map<String, dynamic>? metadata = event.metadata;

      textMessage = TextMessage(
        sender: state.loggedInUser,
        text: text,
        receiverUid: state.receiverId,
        receiverType: state.receiverType,
        type: MessageTypeConstants.text,
        metadata: metadata,
        parentMessageId: state.parentMessageId,
        muid: DateTime.now().microsecondsSinceEpoch.toString(),
        category: CometChatMessageCategory.message,
        sentAt: DateTime.now(),
      );

      // Set quoted message fields if in reply mode
      if (state.isReplyMode && state.replyMessage != null) {
        textMessage.quotedMessage = state.replyMessage;
        if (state.replyMessage!.id > 0) {
          textMessage.quotedMessageId = state.replyMessage!.id;
        }
      }
    }

    // Clear composer state
    debugPrint('[ComposerBloc] _onSendTextMessage: emitting sending state, clearReplyMessage=true, current isReplyMode=${state.isReplyMode}, replyMessage=${state.replyMessage}');
    emit(state.copyWith(
      status: MessageComposerStatus.sending,
      composeText: '',
      clearReplyMessage: true,
    ));

    // Check if custom send handler is provided
    if (onSendButtonTap != null) {
      onSendButtonTap!(context, textMessage, PreviewMessageMode.none);
      emit(state.copyWith(status: MessageComposerStatus.idle));
      return;
    }

    // Emit in-progress event
    CometChatMessageEvents.ccMessageSent(
        textMessage, core_enums.MessageStatus.inProgress);

    final result = await _sendTextMessageUseCase(textMessage);
    result.fold(
      (failure) {
        // Add error to metadata
        if (textMessage.metadata != null) {
          textMessage.metadata!['error'] = failure.message;
        } else {
          textMessage.metadata = {'error': failure.message};
        }
        CometChatMessageEvents.ccMessageSent(
            textMessage, core_enums.MessageStatus.error);
        errorCallback?.call(CometChatException(
          failure.code ?? 'SEND_ERROR',
          failure.message,
          failure.message,
        ));
        emit(state.copyWith(
          status: MessageComposerStatus.error,
          errorMessage: failure.message,
        ));
      },
      (sentMessage) {
        _playSound();
        // Preserve muid from the original message so the message list bloc
        // can match the sent message to the pending (inProgress) one.
        // The SDK response may not include the muid field.
        if (sentMessage.muid.isEmpty && textMessage.muid.isNotEmpty) {
          sentMessage.muid = textMessage.muid;
        }
        CometChatMessageEvents.ccMessageSent(
            sentMessage, core_enums.MessageStatus.sent);
        emit(state.copyWith(
          status: MessageComposerStatus.success,
          sentMessage: sentMessage,
        ));
      },
    );
  }

  Future<void> _onSendMediaMessage(
    SendMediaMessage event,
    Emitter<MessageComposerState> emit,
  ) async {
    final muid = DateTime.now().microsecondsSinceEpoch.toString();

    // Handle iOS file path prefixing
    String filePath = event.path;
    if (Platform.isIOS && !filePath.startsWith('file://')) {
      filePath = 'file://$filePath';
    }

    final mediaMessage = MediaMessage(
      receiverType: state.receiverType,
      type: event.messageType,
      receiverUid: state.receiverId,
      file: filePath,
      metadata: event.metadata,
      sender: state.loggedInUser,
      parentMessageId: state.parentMessageId,
      muid: muid,
      category: CometChatMessageCategory.message,
      sentAt: DateTime.now(),
    );

    // Set quoted message fields if in reply mode
    if (state.isReplyMode && state.replyMessage != null) {
      mediaMessage.quotedMessage = state.replyMessage;
      if (state.replyMessage!.id > 0) {
        mediaMessage.quotedMessageId = state.replyMessage!.id;
      }
    }

    emit(state.copyWith(
      status: MessageComposerStatus.sending,
      clearReplyMessage: true,
    ));

    // Emit in-progress event
    CometChatMessageEvents.ccMessageSent(
        mediaMessage, core_enums.MessageStatus.inProgress);

    final result = await _sendMediaMessageUseCase(mediaMessage);
    result.fold(
      (failure) {
        if (mediaMessage.metadata != null) {
          mediaMessage.metadata!['error'] = failure.message;
        } else {
          mediaMessage.metadata = {'error': failure.message};
        }
        CometChatMessageEvents.ccMessageSent(
            mediaMessage, core_enums.MessageStatus.error);
        errorCallback?.call(CometChatException(
          failure.code ?? 'SEND_ERROR',
          failure.message,
          failure.message,
        ));
        emit(state.copyWith(
          status: MessageComposerStatus.error,
          errorMessage: failure.message,
        ));
      },
      (sentMessage) {
        // Fix file path for iOS
        if (Platform.isIOS && sentMessage.file != null) {
          sentMessage.file = sentMessage.file?.replaceAll('file://', '');
        } else {
          sentMessage.file = event.path;
        }
        _playSound();
        // Preserve muid from the original message
        if (sentMessage.muid.isEmpty && mediaMessage.muid.isNotEmpty) {
          sentMessage.muid = mediaMessage.muid;
        }
        CometChatMessageEvents.ccMessageSent(
            sentMessage, core_enums.MessageStatus.sent);
        emit(state.copyWith(
          status: MessageComposerStatus.success,
          sentMessage: sentMessage,
        ));
      },
    );
  }

  Future<void> _onSendCustomMessage(
    SendCustomMessage event,
    Emitter<MessageComposerState> emit,
  ) async {
    final customMessage = CustomMessage(
      receiverUid: state.receiverId,
      type: event.type,
      customData: event.customData,
      receiverType: state.receiverType,
      sender: state.loggedInUser,
      parentMessageId: state.parentMessageId,
      muid: DateTime.now().microsecondsSinceEpoch.toString(),
      category: CometChatMessageCategory.custom,
      sentAt: DateTime.now(),
    );

    // Set quoted message fields if in reply mode
    if (state.isReplyMode && state.replyMessage != null) {
      customMessage.quotedMessage = state.replyMessage;
      if (state.replyMessage!.id > 0) {
        customMessage.quotedMessageId = state.replyMessage!.id;
      }
    }

    emit(state.copyWith(
      status: MessageComposerStatus.sending,
      clearReplyMessage: true,
    ));

    // Emit in-progress event
    CometChatMessageEvents.ccMessageSent(
        customMessage, core_enums.MessageStatus.inProgress);

    final result = await _sendCustomMessageUseCase(customMessage);
    result.fold(
      (failure) {
        if (customMessage.metadata != null) {
          customMessage.metadata!['error'] = failure.message;
        } else {
          customMessage.metadata = {'error': failure.message};
        }
        CometChatMessageEvents.ccMessageSent(
            customMessage, core_enums.MessageStatus.error);
        errorCallback?.call(CometChatException(
          failure.code ?? 'SEND_ERROR',
          failure.message,
          failure.message,
        ));
        emit(state.copyWith(
          status: MessageComposerStatus.error,
          errorMessage: failure.message,
        ));
      },
      (sentMessage) {
        _playSound();
        // Preserve muid from the original message
        if (sentMessage.muid.isEmpty && customMessage.muid.isNotEmpty) {
          sentMessage.muid = customMessage.muid;
        }
        CometChatMessageEvents.ccMessageSent(
            sentMessage, core_enums.MessageStatus.sent);
        emit(state.copyWith(
          status: MessageComposerStatus.success,
          sentMessage: sentMessage,
        ));
      },
    );
  }

  void _onSetEditMessage(
    SetEditMessage event,
    Emitter<MessageComposerState> emit,
  ) {
    String composeText = '';
    if (event.message is TextMessage) {
      composeText = (event.message as TextMessage).text;
    }
    emit(state.copyWith(
      status: MessageComposerStatus.editing,
      editMessage: event.message,
      composeText: composeText,
      clearReplyMessage: true,
    ));
  }

  void _onClearEditMessage(
    ClearEditMessage event,
    Emitter<MessageComposerState> emit,
  ) {
    emit(state.copyWith(
      status: MessageComposerStatus.idle,
      clearEditMessage: true,
      composeText: '',
    ));
  }

  Future<void> _onEditTextMessage(
    EditTextMessage event,
    Emitter<MessageComposerState> emit,
  ) async {
    if (state.editMessage == null || state.editMessage is! TextMessage) return;

    final originalMessage = state.editMessage as TextMessage;
    
    // Use processed message if provided (from widget with formatter processing)
    // Otherwise create a new message from state.composeText
    TextMessage editedMessage;
    
    if (event.processedMessage != null) {
      editedMessage = event.processedMessage!;
    } else {
      final newText = state.composeText.trim();
      final oldText = originalMessage.text.trim();

      // Check if there's any meaningful difference
      if (newText == oldText) return;

      editedMessage = TextMessage(
        id: originalMessage.id,
        sender: originalMessage.sender,
        text: newText,
        receiverUid: originalMessage.receiverUid,
        receiverType: originalMessage.receiverType,
        type: originalMessage.type,
        metadata: originalMessage.metadata,
        parentMessageId: originalMessage.parentMessageId,
        muid: originalMessage.muid,
        category: originalMessage.category,
        sentAt: originalMessage.sentAt,
        mentionedUsers: originalMessage.mentionedUsers,
      );
    }

    emit(state.copyWith(
      status: MessageComposerStatus.sending,
      composeText: '',
      clearEditMessage: true,
    ));

    // Check if custom send handler is provided
    if (onSendButtonTap != null) {
      onSendButtonTap!(context, editedMessage, PreviewMessageMode.edit);
      emit(state.copyWith(status: MessageComposerStatus.idle));
      return;
    }

    final result = await _editMessageUseCase(editedMessage);
    result.fold(
      (failure) {
        if (editedMessage.metadata != null) {
          editedMessage.metadata!['error'] = failure.message;
        } else {
          editedMessage.metadata = {'error': failure.message};
        }
        CometChatMessageEvents.ccMessageSent(
            editedMessage, core_enums.MessageStatus.error);
        errorCallback?.call(CometChatException(
          failure.code ?? 'EDIT_ERROR',
          failure.message,
          failure.message,
        ));
        emit(state.copyWith(
          status: MessageComposerStatus.error,
          errorMessage: failure.message,
        ));
      },
      (updatedMessage) {
        _playSound();
        debugPrint('[MessageComposerBloc] Edit success, firing ccMessageEdited with message.id=${updatedMessage.id}');
        CometChatMessageEvents.ccMessageEdited(
            updatedMessage, MessageEditStatus.success);
        emit(state.copyWith(
          status: MessageComposerStatus.success,
          sentMessage: updatedMessage,
        ));
      },
    );
  }

  void _onSetReplyMessage(
    SetReplyMessage event,
    Emitter<MessageComposerState> emit,
  ) {
    debugPrint('[ComposerBloc] _onSetReplyMessage: message=${event.message}, current status=${state.status}');
    emit(state.copyWith(
      status: MessageComposerStatus.replying,
      replyMessage: event.message,
      clearEditMessage: true,
    ));
  }

  void _onClearReplyMessage(
    ClearReplyMessage event,
    Emitter<MessageComposerState> emit,
  ) {
    debugPrint('[ComposerBloc] _onClearReplyMessage: current status=${state.status}, replyMessage=${state.replyMessage}');
    emit(state.copyWith(
      status: MessageComposerStatus.idle,
      clearReplyMessage: true,
    ));
  }

  Future<void> _onStartTyping(
    StartTyping event,
    Emitter<MessageComposerState> emit,
  ) async {
    if (disableTypingEvents) return;
    if (!state.userIsNotBlocked) return;

    if (!_isTyping) {
      _isTyping = true;
      _typingNotifier.value = true;
      await _startTypingUseCase(
        receiverUid: state.receiverId,
        receiverType: state.receiverType,
      );
    }

    // Reset debouncer to end typing after delay
    _typingDebouncer.run(() {
      add(const EndTyping());
    });
  }

  Future<void> _onEndTyping(
    EndTyping event,
    Emitter<MessageComposerState> emit,
  ) async {
    if (!_isTyping) return;

    _isTyping = false;
    _typingNotifier.value = false;
    await _endTypingUseCase(
      receiverUid: state.receiverId,
      receiverType: state.receiverType,
    );
  }

  void _onShowPanel(
    ShowPanel event,
    Emitter<MessageComposerState> emit,
  ) {
    if (!_isForThisWidget(event.id)) return;

    final widget = event.builder(context);
    final position = event.position;
    
    if (position == CustomUIPosition.composerTop) {
      emit(state.copyWith(headerPanel: widget));
    } else if (position == CustomUIPosition.composerBottom) {
      emit(state.copyWith(footerPanel: widget));
    } else if (position == CustomUIPosition.composerPreview) {
      emit(state.copyWith(previewPanel: widget));
    }
  }

  void _onHidePanel(
    HidePanel event,
    Emitter<MessageComposerState> emit,
  ) {
    if (!_isForThisWidget(event.id)) return;

    final position = event.position;
    
    if (position == CustomUIPosition.composerTop) {
      emit(state.copyWith(clearHeaderPanel: true));
    } else if (position == CustomUIPosition.composerBottom) {
      // Clear both footer panel AND locked bottom padding
      // This ensures no extra padding is shown when sticker keyboard is closed
      emit(state.copyWith(clearFooterPanel: true, clearLockedBottomPadding: true));
    } else if (position == CustomUIPosition.composerPreview) {
      emit(state.copyWith(clearPreviewPanel: true));
    }
  }

  void _onMessageEditedExternally(
    MessageEditedExternally event,
    Emitter<MessageComposerState> emit,
  ) {
    if (event.message.parentMessageId == state.parentMessageId) {
      emit(state.copyWith(
        status: MessageComposerStatus.editing,
        editMessage: event.message,
        composeText:
            event.message is TextMessage ? (event.message as TextMessage).text : '',
      ));
    }
  }

  void _onComposeMessageReceived(
    ComposeMessageReceived event,
    Emitter<MessageComposerState> emit,
  ) {
    if (!_isForThisWidget(event.id)) return;
    emit(state.copyWith(composeText: event.text));
  }

  void _onUserBlockedStatusChanged(
    UserBlockedStatusChanged event,
    Emitter<MessageComposerState> emit,
  ) {
    if (state.user?.uid == event.user.uid) {
      emit(state.copyWith(user: event.user));
    }
  }

  // ============================================================================
  // Audio Recording Event Handlers
  // ============================================================================

  void _onStartAudioRecording(
    StartAudioRecording event,
    Emitter<MessageComposerState> emit,
  ) {
    emit(state.copyWith(
      status: MessageComposerStatus.recording,
    ));
  }

  void _onCancelAudioRecording(
    CancelAudioRecording event,
    Emitter<MessageComposerState> emit,
  ) {
    emit(state.copyWith(
      status: MessageComposerStatus.idle,
    ));
  }

  Future<void> _onSubmitAudioRecording(
    SubmitAudioRecording event,
    Emitter<MessageComposerState> emit,
  ) async {
    // First exit recording mode
    emit(state.copyWith(
      status: MessageComposerStatus.idle,
    ));

    // Then send the audio message
    add(SendMediaMessage(
      path: event.filePath,
      messageType: MessageTypeConstants.audio,
      metadata: {'localPath': event.filePath},
    ));
  }

  // ============================================================================
  // Bottom Padding Lock Event Handlers (for sticker/emoji keyboard)
  // ============================================================================

  void _onLockBottomPadding(
    LockBottomPadding event,
    Emitter<MessageComposerState> emit,
  ) {
    emit(state.copyWith(lockedBottomPadding: event.height));
  }

  void _onUnlockBottomPadding(
    UnlockBottomPadding event,
    Emitter<MessageComposerState> emit,
  ) {
    emit(state.copyWith(clearLockedBottomPadding: true));
  }

  // ============================================================================
  // SDK Listener Callbacks
  // ============================================================================

  @override
  void ccMessageEdited(BaseMessage message, MessageEditStatus status) {
    if (status == MessageEditStatus.inProgress &&
        message.parentMessageId == state.parentMessageId) {
      add(MessageEditedExternally(message));
    }
  }

  @override
  void ccReplyToMessage(BaseMessage message) {
    // Only handle if this composer is for the same conversation
    final isForUser = state.user != null &&
        (message.receiverUid == state.user!.uid ||
            message.sender?.uid == state.user!.uid);
    final isForGroup = state.group != null &&
        message.receiverUid == state.group!.guid;
    if (isForUser || isForGroup) {
      add(SetReplyMessage(message));
    }
  }

  /// Clears reply state when any message is sent successfully.
  /// This handles the case where an extension (stickers, polls, etc.)
  /// sends a message while the reply preview is showing — the composer
  /// needs to dismiss the preview even though it didn't initiate the send.
  @override
  void ccMessageSent(BaseMessage message, core_enums.MessageStatus messageStatus) {
    // Only clear reply if message belongs to current conversation
    final isForUser = state.user != null &&
        (message.receiverUid == state.user!.uid ||
            (message.receiverType == ReceiverTypeConstants.user &&
                message.sender?.uid == state.user!.uid));
    final isForGroup = state.group != null &&
        message.receiverUid == state.group!.guid;
    
    if (state.isReplyMode &&
        (isForUser || isForGroup) &&
        (messageStatus == core_enums.MessageStatus.inProgress ||
         messageStatus == core_enums.MessageStatus.sent ||
         messageStatus == core_enums.MessageStatus.error)) {
      add(const ClearReplyMessage());
    }
  }

  @override
  void ccComposeMessage(String text, MessageEditStatus status) {
    add(ComposeMessageReceived(text: text));
  }

  @override
  void showPanel(
    Map<String, dynamic>? id,
    CustomUIPosition uiPosition,
    WidgetBuilder child,
  ) {
    add(ShowPanel(id: id, position: uiPosition, builder: child));
  }

  @override
  void hidePanel(Map<String, dynamic>? id, CustomUIPosition uiPosition) {
    add(HidePanel(id: id, position: uiPosition));
  }

  @override
  void lockBottomPadding(Map<String, dynamic>? id, double height) {
    if (!_isForThisWidget(id)) return;
    add(LockBottomPadding(height));
  }

  @override
  void unlockBottomPadding(Map<String, dynamic>? id) {
    if (!_isForThisWidget(id)) return;
    add(const UnlockBottomPadding());
  }

  @override
  void requestComposerFocus(Map<String, dynamic>? id) {
    if (!_isForThisWidget(id)) return;
    onFocusRequested?.call();
  }

  @override
  void ccUserBlocked(User user) {
    add(UserBlockedStatusChanged(user: user, isBlocked: true));
  }

  @override
  void ccUserUnblocked(User user) {
    add(UserBlockedStatusChanged(user: user, isBlocked: false));
  }

  // ============================================================================
  // Cleanup
  // ============================================================================

  @override
  Future<void> close() {
    // Remove SDK listeners
    CometChatMessageEvents.removeMessagesListener(_messageListenerKey);
    CometChatUIEvents.removeUiListener(_uiEventListenerKey);
    CometChatUserEvents.removeUsersListener(_userEventListenerKey);

    // Dispose typing notifier
    _typingNotifier.dispose();

    return super.close();
  }
}
