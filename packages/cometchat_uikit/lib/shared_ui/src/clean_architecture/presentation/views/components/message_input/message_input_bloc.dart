import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class MessageInputEvent extends Equatable {
  const MessageInputEvent();

  @override
  List<Object?> get props => [];
}

class InitializeInputEvent extends MessageInputEvent {
  final String? initialText;

  const InitializeInputEvent({this.initialText});

  @override
  List<Object?> get props => [initialText];
}

class TextChangedEvent extends MessageInputEvent {
  final String text;

  const TextChangedEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class AttachmentAddedEvent extends MessageInputEvent {
  final String attachmentPath;
  final String attachmentType;

  const AttachmentAddedEvent({
    required this.attachmentPath,
    required this.attachmentType,
  });

  @override
  List<Object?> get props => [attachmentPath, attachmentType];
}

class AttachmentRemovedEvent extends MessageInputEvent {
  final String attachmentPath;

  const AttachmentRemovedEvent(this.attachmentPath);

  @override
  List<Object?> get props => [attachmentPath];
}

class MentionAddedEvent extends MessageInputEvent {
  final String userId;
  final String userName;

  const MentionAddedEvent({
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [userId, userName];
}

class SendMessageEvent extends MessageInputEvent {
  const SendMessageEvent();
}

class ClearInputEvent extends MessageInputEvent {
  const ClearInputEvent();
}

class ShowEmojiPickerEvent extends MessageInputEvent {
  final bool show;

  const ShowEmojiPickerEvent(this.show);

  @override
  List<Object?> get props => [show];
}

class ShowAttachmentPickerEvent extends MessageInputEvent {
  final bool show;

  const ShowAttachmentPickerEvent(this.show);

  @override
  List<Object?> get props => [show];
}

class MessageSentSuccessEvent extends MessageInputEvent {
  const MessageSentSuccessEvent();
}

class MessageSentErrorEvent extends MessageInputEvent {
  final String error;

  const MessageSentErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

// Attachment Model
class Attachment extends Equatable {
  final String path;
  final String type;
  final String? name;
  final int? size;

  const Attachment({
    required this.path,
    required this.type,
    this.name,
    this.size,
  });

  @override
  List<Object?> get props => [path, type, name, size];
}

// Mention Model
class Mention extends Equatable {
  final String userId;
  final String userName;

  const Mention({
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [userId, userName];
}

// States
abstract class MessageInputState extends Equatable {
  final String text;
  final List<Attachment> attachments;
  final List<Mention> mentions;
  final bool showEmojiPicker;
  final bool showAttachmentPicker;
  final String? error;

  const MessageInputState({
    this.text = '',
    this.attachments = const [],
    this.mentions = const [],
    this.showEmojiPicker = false,
    this.showAttachmentPicker = false,
    this.error,
  });

  // Computed properties
  bool get isEmpty => text.trim().isEmpty && attachments.isEmpty;
  bool get hasAttachments => attachments.isNotEmpty;
  bool get hasMentions => mentions.isNotEmpty;
  bool get canSend => text.trim().isNotEmpty || attachments.isNotEmpty;
  int get characterCount => text.length;

  @override
  List<Object?> get props => [
        text,
        attachments,
        mentions,
        showEmojiPicker,
        showAttachmentPicker,
        error,
      ];
}

class MessageInputInitial extends MessageInputState {
  const MessageInputInitial();
}

class MessageInputEditing extends MessageInputState {
  const MessageInputEditing({
    required super.text,
    required super.attachments,
    required super.mentions,
    required super.showEmojiPicker,
    required super.showAttachmentPicker,
  });

  MessageInputEditing copyWith({
    String? text,
    List<Attachment>? attachments,
    List<Mention>? mentions,
    bool? showEmojiPicker,
    bool? showAttachmentPicker,
  }) {
    return MessageInputEditing(
      text: text ?? this.text,
      attachments: attachments ?? this.attachments,
      mentions: mentions ?? this.mentions,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      showAttachmentPicker: showAttachmentPicker ?? this.showAttachmentPicker,
    );
  }
}

class MessageInputSending extends MessageInputState {
  const MessageInputSending({
    required super.text,
    required super.attachments,
    required super.mentions,
  });
}

class MessageInputSent extends MessageInputState {
  const MessageInputSent();
}

class MessageInputError extends MessageInputState {
  const MessageInputError({
    required super.text,
    required super.attachments,
    required super.mentions,
    required super.error,
  });
}

// BLoC
class MessageInputBloc extends Bloc<MessageInputEvent, MessageInputState> {
  MessageInputBloc() : super(const MessageInputInitial()) {
    on<InitializeInputEvent>(_onInitialize);
    on<TextChangedEvent>(_onTextChanged);
    on<AttachmentAddedEvent>(_onAttachmentAdded);
    on<AttachmentRemovedEvent>(_onAttachmentRemoved);
    on<MentionAddedEvent>(_onMentionAdded);
    on<SendMessageEvent>(_onSendMessage);
    on<ClearInputEvent>(_onClearInput);
    on<ShowEmojiPickerEvent>(_onShowEmojiPicker);
    on<ShowAttachmentPickerEvent>(_onShowAttachmentPicker);
    on<MessageSentSuccessEvent>(_onMessageSentSuccess);
    on<MessageSentErrorEvent>(_onMessageSentError);
  }

  void _onInitialize(
    InitializeInputEvent event,
    Emitter<MessageInputState> emit,
  ) {
    emit(MessageInputEditing(
      text: event.initialText ?? '',
      attachments: const [],
      mentions: const [],
      showEmojiPicker: false,
      showAttachmentPicker: false,
    ));
  }

  void _onTextChanged(
    TextChangedEvent event,
    Emitter<MessageInputState> emit,
  ) {
    if (state is MessageInputEditing) {
      final currentState = state as MessageInputEditing;
      emit(currentState.copyWith(text: event.text));
    }
  }

  void _onAttachmentAdded(
    AttachmentAddedEvent event,
    Emitter<MessageInputState> emit,
  ) {
    if (state is MessageInputEditing) {
      final currentState = state as MessageInputEditing;
      final newAttachments = List<Attachment>.from(currentState.attachments)
        ..add(Attachment(
          path: event.attachmentPath,
          type: event.attachmentType,
        ));
      emit(currentState.copyWith(attachments: newAttachments));
    }
  }

  void _onAttachmentRemoved(
    AttachmentRemovedEvent event,
    Emitter<MessageInputState> emit,
  ) {
    if (state is MessageInputEditing) {
      final currentState = state as MessageInputEditing;
      final newAttachments = currentState.attachments
          .where((a) => a.path != event.attachmentPath)
          .toList();
      emit(currentState.copyWith(attachments: newAttachments));
    }
  }

  void _onMentionAdded(
    MentionAddedEvent event,
    Emitter<MessageInputState> emit,
  ) {
    if (state is MessageInputEditing) {
      final currentState = state as MessageInputEditing;
      final newMentions = List<Mention>.from(currentState.mentions)
        ..add(Mention(
          userId: event.userId,
          userName: event.userName,
        ));
      emit(currentState.copyWith(mentions: newMentions));
    }
  }

  void _onSendMessage(
    SendMessageEvent event,
    Emitter<MessageInputState> emit,
  ) {
    if (state is MessageInputEditing) {
      final currentState = state as MessageInputEditing;
      if (currentState.canSend) {
        emit(MessageInputSending(
          text: currentState.text,
          attachments: currentState.attachments,
          mentions: currentState.mentions,
        ));
      }
    }
  }

  void _onClearInput(
    ClearInputEvent event,
    Emitter<MessageInputState> emit,
  ) {
    emit(const MessageInputEditing(
      text: '',
      attachments: [],
      mentions: [],
      showEmojiPicker: false,
      showAttachmentPicker: false,
    ));
  }

  void _onShowEmojiPicker(
    ShowEmojiPickerEvent event,
    Emitter<MessageInputState> emit,
  ) {
    if (state is MessageInputEditing) {
      final currentState = state as MessageInputEditing;
      emit(currentState.copyWith(
        showEmojiPicker: event.show,
        showAttachmentPicker: false, // Close attachment picker
      ));
    }
  }

  void _onShowAttachmentPicker(
    ShowAttachmentPickerEvent event,
    Emitter<MessageInputState> emit,
  ) {
    if (state is MessageInputEditing) {
      final currentState = state as MessageInputEditing;
      emit(currentState.copyWith(
        showAttachmentPicker: event.show,
        showEmojiPicker: false, // Close emoji picker
      ));
    }
  }

  void _onMessageSentSuccess(
    MessageSentSuccessEvent event,
    Emitter<MessageInputState> emit,
  ) {
    emit(const MessageInputSent());
    // Reset to editing state
    emit(const MessageInputEditing(
      text: '',
      attachments: [],
      mentions: [],
      showEmojiPicker: false,
      showAttachmentPicker: false,
    ));
  }

  void _onMessageSentError(
    MessageSentErrorEvent event,
    Emitter<MessageInputState> emit,
  ) {
    if (state is MessageInputSending) {
      emit(MessageInputError(
        text: state.text,
        attachments: state.attachments,
        mentions: state.mentions,
        error: event.error,
      ));
      // Return to editing state
      emit(MessageInputEditing(
        text: state.text,
        attachments: state.attachments,
        mentions: state.mentions,
        showEmojiPicker: false,
        showAttachmentPicker: false,
      ));
    }
  }
}
