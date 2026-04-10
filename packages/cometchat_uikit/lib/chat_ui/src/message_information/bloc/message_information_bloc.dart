import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared_ui/cometchat_uikit_shared.dart';
import '../di/message_information_service_locator.dart';
import '../domain/usecases/fetch_message_receipts_usecase.dart';
import 'message_information_event.dart';
import 'message_information_state.dart';

/// BLoC for managing message information state
///
/// This BLoC manages the message information state and handles:
/// - Initialization with parent message
/// - Fetching message receipts for group messages
/// - Creating receipts from parent message for user messages
/// - Real-time receipt updates via SDK listeners
///
/// The BLoC registers listeners for:
/// - CometChatMessageEvents: onMessagesRead, onMessagesDelivered
///
/// **Requirements: 1.1, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 5.1, 5.2, 5.3, 5.4, 5.5**
class MessageInformationBloc
    extends Bloc<MessageInformationEvent, MessageInformationState> {
  // Use cases
  final FetchMessageReceiptsUseCase fetchMessageReceiptsUseCase;

  // SDK listener keys - unique per instance to prevent conflicts
  late final String _uiMessageListenerKey;
  late final String _uiGroupListenerKey;

  // Parent message for filtering incoming receipts
  BaseMessage? _parentMessage;

  // User/Group context for receipt matching
  User? _user;
  Group? _group;

  /// Helper to get initialized service locator
  static MessageInformationServiceLocator _getServiceLocator() {
    if (!MessageInformationServiceLocator.instance.isInitialized) {
      MessageInformationServiceLocator.instance.setup();
    }
    return MessageInformationServiceLocator.instance;
  }

  /// Creates a MessageInformationBloc.
  ///
  /// [fetchMessageReceiptsUseCase] is optional -
  /// if not provided, it will be automatically initialized from the default
  /// service locator.
  MessageInformationBloc({
    FetchMessageReceiptsUseCase? fetchMessageReceiptsUseCase,
  })  : fetchMessageReceiptsUseCase = fetchMessageReceiptsUseCase ??
            _getServiceLocator().fetchMessageReceiptsUseCase,
        super(const MessageInformationState()) {
    // Register event handlers
    on<InitializeMessageInformation>(_onInitialize);
    on<FetchMessageReceipts>(_onFetchReceipts);
    on<ReceiptRead>(_onReceiptRead);
    on<ReceiptDelivered>(_onReceiptDelivered);

    // Generate unique listener keys using timestamp and hashCode
    // This ensures uniqueness across multiple BLoC instances
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _uiMessageListenerKey = 'message_info_ui_message_${timestamp}_$hashCode';
    _uiGroupListenerKey = 'message_info_ui_group_${timestamp}_$hashCode';

    // Register SDK listeners
    _registerSDKListeners();
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  /// Initialize the message information with parent message
  ///
  /// For user messages: Creates a receipt from parent message delivery data
  /// For group messages: Fetches receipts from SDK
  ///
  /// **Requirements: 2.1, 2.2, 2.5**
  Future<void> _onInitialize(
    InitializeMessageInformation event,
    Emitter<MessageInformationState> emit,
  ) async {
    emit(state.copyWith(status: MessageInformationStatus.loading));

    final parentMessage = event.parentMessage;
    _parentMessage = parentMessage;

    // Determine user/group context based on receiver type
    User? user;
    Group? group;

    if (parentMessage.receiver is Group) {
      group = parentMessage.receiver as Group;
    } else {
      user = parentMessage.receiver as User;
    }

    _user = user;
    _group = group;

    if (user != null) {
      // User conversation: Create receipt from parent message delivery data
      // **Requirement 2.1**
      final receipt = MessageReceipt(
        messageId: parentMessage.id,
        sender: user,
        receiverType: parentMessage.receiverType,
        receiverId: parentMessage.receiverUid,
        timestamp: parentMessage.sentAt ?? DateTime.now(),
        receiptType: '',
        deliveredAt: parentMessage.deliveredAt,
        readAt: parentMessage.readAt,
      );

      emit(state.copyWith(
        status: MessageInformationStatus.loaded,
        parentMessage: parentMessage,
        receipts: [receipt],
        user: user,
      ));
    } else if (group != null) {
      // Group conversation: Fetch receipts from SDK
      // **Requirement 2.2**
      emit(state.copyWith(
        parentMessage: parentMessage,
        group: group,
      ));

      // Dispatch fetch event with sender UID for exclusion
      add(FetchMessageReceipts(
        messageId: parentMessage.id,
        senderUid: parentMessage.sender?.uid,
      ));
    }
  }

  /// Fetch message receipts for group messages
  ///
  /// Excludes the sender from the receipt list
  ///
  /// **Requirements: 2.2, 2.3, 2.4, 2.5**
  Future<void> _onFetchReceipts(
    FetchMessageReceipts event,
    Emitter<MessageInformationState> emit,
  ) async {
    // Emit loading state if not already loading
    if (state.status != MessageInformationStatus.loading) {
      emit(state.copyWith(status: MessageInformationStatus.loading));
    }

    final result = await fetchMessageReceiptsUseCase(event.messageId);

    if (result is Success<List<MessageReceipt>>) {
      // Filter out sender from receipt list
      // **Requirement 2.3**
      final receipts = result.data
          .where((receipt) => receipt.sender.uid != event.senderUid)
          .toList();

      emit(state.copyWith(
        status: MessageInformationStatus.loaded,
        receipts: receipts,
      ));
    } else if (result is Failure) {
      // **Requirement 2.4**
      emit(state.copyWith(
        status: MessageInformationStatus.error,
        errorMessage: result.message,
      ));
    }
  }

  /// Handle read receipt event
  ///
  /// Updates the receipt list when a read receipt is received
  ///
  /// **Requirements: 3.1, 3.4, 3.5**
  void _onReceiptRead(
    ReceiptRead event,
    Emitter<MessageInformationState> emit,
  ) {
    final receipt = event.receipt;

    if (!_isForSameMessage(receipt)) return;

    final updatedReceipts = _updateReceiptList(
      state.receipts,
      receipt,
      isRead: true,
    );

    emit(state.copyWith(receipts: updatedReceipts));
  }

  /// Handle delivered receipt event
  ///
  /// Updates the receipt list when a delivered receipt is received
  ///
  /// **Requirements: 3.2, 3.4, 3.5**
  void _onReceiptDelivered(
    ReceiptDelivered event,
    Emitter<MessageInformationState> emit,
  ) {
    final receipt = event.receipt;

    if (!_isForSameMessage(receipt)) return;

    final updatedReceipts = _updateReceiptList(
      state.receipts,
      receipt,
      isRead: false,
    );

    emit(state.copyWith(receipts: updatedReceipts));
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Check if the receipt is for the same message being displayed
  ///
  /// For user conversations: Match by receiver type (user) and sender UID
  /// For group conversations: Match by receiver type (group) and group GUID
  ///
  /// **Requirements: 3.4, 3.5**
  bool _isForSameMessage(MessageReceipt receipt) {
    // Must have a parent message to compare against
    if (_parentMessage == null) return false;

    if (_group != null) {
      // Group conversation: Match by receiver type and group GUID
      return receipt.receiverType == ReceiverTypeConstants.group &&
          receipt.receiverId == _group!.guid;
    } else if (_user != null) {
      // User conversation: Match by receiver type and sender UID
      return receipt.receiverType == ReceiverTypeConstants.user &&
          receipt.sender.uid == _user!.uid;
    }
    return false;
  }

  /// Update the receipt list with a new receipt
  ///
  /// For user conversations: Updates the single receipt entry
  /// For group conversations: Matches by sender UID and updates or adds
  ///
  /// **Requirements: 3.1, 3.2, 3.3, 3.4, 3.5**
  /// Creates a new [MessageReceipt] with updated deliveredAt/readAt values.
  /// Avoids mutating the original receipt (fields may be final).
  MessageReceipt _copyReceiptWith(
    MessageReceipt original, {
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    return MessageReceipt(
      messageId: original.messageId,
      sender: original.sender,
      receiverType: original.receiverType,
      receiverId: original.receiverId,
      timestamp: original.timestamp,
      receiptType: original.receiptType,
      deliveredAt: deliveredAt ?? original.deliveredAt,
      readAt: readAt ?? original.readAt,
    );
  }

  List<MessageReceipt> _updateReceiptList(
    List<MessageReceipt> currentReceipts,
    MessageReceipt newReceipt, {
    required bool isRead,
  }) {
    // Create a mutable copy of the list
    final updatedReceipts = List<MessageReceipt>.from(currentReceipts);

    if (updatedReceipts.isEmpty) {
      // No existing receipts - add the new one
      // Set deliveredAt to readAt if this is a read receipt and deliveredAt is null
      final receipt = isRead
          ? _copyReceiptWith(
              newReceipt,
              deliveredAt: newReceipt.deliveredAt ?? newReceipt.readAt,
            )
          : newReceipt;
      updatedReceipts.add(receipt);
      return updatedReceipts;
    }

    if (_user != null) {
      // User conversation: Update the single receipt entry
      // **Requirement 3.4**
      final existing = updatedReceipts[0];
      if (isRead) {
        updatedReceipts[0] = _copyReceiptWith(
          existing,
          deliveredAt: existing.deliveredAt ?? newReceipt.readAt,
          readAt: newReceipt.readAt,
        );
      } else {
        updatedReceipts[0] = _copyReceiptWith(
          existing,
          deliveredAt: newReceipt.deliveredAt,
        );
      }
    } else {
      // Group conversation: Match by sender UID
      // **Requirement 3.5**
      final existingIndex = updatedReceipts.indexWhere(
        (r) => r.sender.uid == newReceipt.sender.uid,
      );

      if (existingIndex != -1) {
        // Update existing receipt
        final existing = updatedReceipts[existingIndex];
        if (isRead) {
          updatedReceipts[existingIndex] = _copyReceiptWith(
            existing,
            deliveredAt: existing.deliveredAt ?? newReceipt.readAt,
            readAt: newReceipt.readAt,
          );
        } else {
          updatedReceipts[existingIndex] = _copyReceiptWith(
            existing,
            deliveredAt: newReceipt.deliveredAt,
          );
        }
      } else {
        // Add new receipt
        // **Requirement 3.3**
        final receipt = isRead
            ? _copyReceiptWith(
                newReceipt,
                deliveredAt: newReceipt.deliveredAt ?? newReceipt.readAt,
              )
            : newReceipt;
        updatedReceipts.add(receipt);
      }
    }

    return updatedReceipts;
  }

  // ============================================================
  // SDK LISTENER REGISTRATION
  // ============================================================

  /// Register all CometChat SDK listeners for real-time updates
  ///
  /// **Requirements: 5.1, 5.2, 5.3, 5.4**
  void _registerSDKListeners() {
    // Register UI message event listener for read/delivered receipts
    // **Requirements: 5.1, 5.2**
    CometChatMessageEvents.addMessagesListener(
      _uiMessageListenerKey,
      _MessageInformationUIMessageListener(
        onMessagesReadCallback: _handleMessagesRead,
        onMessagesDeliveredCallback: _handleMessagesDelivered,
      ),
    );

    // Register UI group event listener for potential group-related updates
    // **Requirement: 5.3**
    CometChatGroupEvents.addGroupsListener(
      _uiGroupListenerKey,
      _MessageInformationUIGroupListener(),
    );
  }

  // ============================================================
  // SDK LISTENER CALLBACKS
  // ============================================================

  /// Handle read receipt from SDK
  void _handleMessagesRead(MessageReceipt receipt) {
    if (isClosed) return;
    add(ReceiptRead(receipt));
  }

  /// Handle delivered receipt from SDK
  void _handleMessagesDelivered(MessageReceipt receipt) {
    if (isClosed) return;
    add(ReceiptDelivered(receipt));
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  /// Clean up resources when BLoC is closed
  ///
  /// Removes all SDK listeners to prevent memory leaks
  ///
  /// **Requirements: 1.4, 5.5**
  @override
  Future<void> close() {
    // Remove all SDK listeners to prevent memory leaks
    CometChatMessageEvents.removeMessagesListener(_uiMessageListenerKey);
    CometChatGroupEvents.removeGroupsListener(_uiGroupListenerKey);
    return super.close();
  }
}

// ============================================================
// LISTENER CLASSES
// ============================================================

/// UI Message event listener for CometChatMessageEvents
///
/// Handles:
/// - onMessagesRead (update receipt with read timestamp)
/// - onMessagesDelivered (update receipt with delivered timestamp)
///
/// **Requirements: 5.1, 5.2**
class _MessageInformationUIMessageListener
    with CometChatMessageEventListener {
  final void Function(MessageReceipt) onMessagesReadCallback;
  final void Function(MessageReceipt) onMessagesDeliveredCallback;

  _MessageInformationUIMessageListener({
    required this.onMessagesReadCallback,
    required this.onMessagesDeliveredCallback,
  });

  @override
  void onMessagesRead(MessageReceipt messageReceipt) {
    onMessagesReadCallback(messageReceipt);
  }

  @override
  void onMessagesDelivered(MessageReceipt messageReceipt) {
    onMessagesDeliveredCallback(messageReceipt);
  }
}

/// UI Group event listener for CometChatGroupEvents
///
/// Currently empty - reserved for potential group-related updates
/// that may affect the message information in the future.
///
/// **Requirement: 5.3**
class _MessageInformationUIGroupListener with CometChatGroupEventListener {}
