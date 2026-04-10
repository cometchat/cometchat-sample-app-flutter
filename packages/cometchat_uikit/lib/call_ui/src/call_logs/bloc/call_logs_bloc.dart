import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared_ui/src/clean_architecture/core/result.dart';
import '../../../../shared_ui/src/clean_architecture/core/constants/ui_kit_constants.dart';
import '../../../../shared_ui/src/clean_architecture/domain/events/call_events/cometchat_call_events.dart';
import '../../../../chat_ui/src/shared/list_base.dart';
import '../../call_event_service.dart';
import '../../outgoing_call/cometchat_outgoing_call.dart';
import '../../call_settings/call_navigation_context.dart';
import '../di/call_logs_service_locator.dart';
import '../data/repositories/call_logs_repository_impl.dart';
import '../domain/usecases/get_call_logs_usecase.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../domain/usecases/initiate_call_usecase.dart';
import '../domain/usecases/load_more_call_logs_usecase.dart';
import 'call_logs_event.dart';
import 'call_logs_state.dart';

/// BLoC for managing call logs list
///
/// This BLoC manages the call logs list state and handles:
/// - Loading and pagination of call logs
/// - Grouping call logs by date for display
/// - Initiating calls from call log entries
/// - O(1) lookups via session ID map
///
/// This BLoC uses the [ListBase] mixin for list management operations.
/// Developers can extend this class and override the hook methods
/// (onItemAdded, onItemRemoved, onItemUpdated, onListCleared, onListReplaced)
/// to add custom logic like sorting, filtering, or validation.
class CallLogsBloc extends Bloc<CallLogsEvent, CallLogsState>
    with ListBase<CallLog> {
  // Use cases - initialized from service locator if not provided
  final GetCallLogsUseCase getCallLogsUseCase;
  final LoadMoreCallLogsUseCase loadMoreCallLogsUseCase;
  final InitiateCallUseCase initiateCallUseCase;
  final GetLoggedInUserUseCase getLoggedInUserUseCase;

  /// Optional custom request builder provided by the widget.
  /// When set, this builder is used instead of the default one,
  /// allowing callers to configure filters (uid, guid, callCategory, etc.).
  final CallLogRequestBuilder? callLogsRequestBuilder;

  // Pagination state tracking
  bool _isLoadingMore = false;

  // Logged in user
  User? _loggedInUser;

  /// Cached auth token — no longer needed in V5, SDK handles auth internally
  // ============================================================
  // OPTIMIZATION: Map-based O(1) call log lookups by session ID
  // ============================================================
  final Map<String, int> _callLogIndexMap = {};

  /// Flag to track if map needs full rebuild (only on initial load/refresh)
  bool _mapNeedsRebuild = true;

  /// Helper to get initialized service locator
  static CallLogsServiceLocator _getServiceLocator() {
    if (!CallLogsServiceLocator.instance.isInitialized) {
      CallLogsServiceLocator.instance.setup();
    }
    return CallLogsServiceLocator.instance;
  }

  /// Creates a CallLogsBloc.
  ///
  /// All use cases are optional - if not provided, they will be automatically
  /// initialized from the default service locator. This makes it easy to extend
  /// the bloc without worrying about dependency injection.
  ///
  /// [callLogsRequestBuilder] - Optional custom request builder for filtering.
  CallLogsBloc({
    GetCallLogsUseCase? getCallLogsUseCase,
    LoadMoreCallLogsUseCase? loadMoreCallLogsUseCase,
    InitiateCallUseCase? initiateCallUseCase,
    GetLoggedInUserUseCase? getLoggedInUserUseCase,
    this.callLogsRequestBuilder,
  })  : getCallLogsUseCase =
            getCallLogsUseCase ?? _getServiceLocator().getCallLogsUseCase,
        loadMoreCallLogsUseCase = loadMoreCallLogsUseCase ??
            _getServiceLocator().loadMoreCallLogsUseCase,
        initiateCallUseCase =
            initiateCallUseCase ?? _getServiceLocator().initiateCallUseCase,
        getLoggedInUserUseCase = getLoggedInUserUseCase ??
            _getServiceLocator().getLoggedInUserUseCase,
        super(CallLogsState.initial()) {
    // Register event handlers
    on<LoadCallLogs>(_onLoadCallLogs);
    on<LoadMoreCallLogs>(_onLoadMoreCallLogs);
    on<RefreshCallLogs>(_onRefreshCallLogs);
    on<InitiateCallFromLog>(_onInitiateCallFromLog);

    // Initialize logged in user
    _initializeLoggedInUser();
  }

  /// Initialize logged in user
  Future<void> _initializeLoggedInUser() async {
    final result = await getLoggedInUserUseCase();

    if (result is Success<User?>) {
      _loggedInUser = result.data;
    }
  }

  /// Auth token handling removed in V5 — SDK handles auth internally.
  /// Keeping _ensureCallsSdkInitialized for SDK init gating.

  /// Ensure the CometChat Calls SDK is initialized.
  ///
  /// Delegates to [CallEventService.waitForCallsSdk] which is the single
  /// source of truth for Calls SDK initialization. This avoids duplicate
  /// init calls that cause race conditions and 408 errors.
  Future<void> _ensureCallsSdkInitialized() async {
    await CallEventService.instance.waitForCallsSdk();
  }

  /// Build a CallLogRequest and configure the repository.
  /// In V5, the SDK handles auth internally — no authToken needed.
  Future<void> _configureRequest({int limit = 30}) async {
    final repo = CallLogsServiceLocator.instance.repository;
    if (repo is CallLogsRepositoryImpl) {
      if (callLogsRequestBuilder != null) {
        repo.setRequest(callLogsRequestBuilder!.build());
      } else {
        final builder = CallLogRequestBuilder()
          ..limit = limit;
        repo.setRequest(builder.build());
      }
    }
  }

  // ============================================================
  // OPTIMIZATION: Map-based lookup helpers with incremental updates
  // ============================================================

  /// Full rebuild - only called on initial load or refresh
  void _rebuildIndexMap() {
    _callLogIndexMap.clear();
    for (int i = 0; i < items.length; i++) {
      final sessionId = items[i].sessionId;
      if (sessionId != null && sessionId.isNotEmpty) {
        _callLogIndexMap[sessionId] = i;
      }
    }
    _mapNeedsRebuild = false;
  }

  /// Incremental: Add single item to map at index
  void _addToIndexMap(String? sessionId, int index) {
    if (sessionId != null && sessionId.isNotEmpty) {
      _callLogIndexMap[sessionId] = index;
    }
  }

  /// Incremental: Remove single item from map
  void _removeFromIndexMap(String? sessionId) {
    if (sessionId != null && sessionId.isNotEmpty) {
      _callLogIndexMap.remove(sessionId);
    }
  }

  /// Incremental: Shift indices after removal (items after removedIndex move up)
  void _shiftIndicesAfterRemoval(int removedIndex) {
    _callLogIndexMap.updateAll((key, index) {
      return index > removedIndex ? index - 1 : index;
    });
  }

  /// O(1) call log index lookup by session ID
  int? findCallLogIndex(String? sessionId) {
    if (sessionId == null || sessionId.isEmpty) return null;
    // Lazy rebuild if needed
    if (_mapNeedsRebuild && items.isNotEmpty) {
      _rebuildIndexMap();
    }
    return _callLogIndexMap[sessionId];
  }

  /// O(1) call log lookup by session ID
  CallLog? findCallLog(String? sessionId) {
    final index = findCallLogIndex(sessionId);
    return index != null && index < items.length ? items[index] : null;
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  /// Maximum number of retry attempts when SDK fetch fails due to
  /// initialization race condition (408 / generateToken errors).
  static const int _maxRetries = 3;

  /// Delay between retries.
  static const Duration _retryDelay = Duration(seconds: 1);

  /// Load initial call logs.
  /// Ensures the Calls SDK is initialized and configures the repository
  /// with auth token before fetching.
  ///
  /// If the first fetch fails (typically because the Calls SDK hasn't
  /// finished internal initialization), retries up to [_maxRetries] times.
  Future<void> _onLoadCallLogs(
    LoadCallLogs event,
    Emitter<CallLogsState> emit,
  ) async {
    emit(state.copyWith(status: CallLogsStatus.loading));

    _isLoadingMore = false;
    _mapNeedsRebuild = true;

    // Ensure logged in user is available
    if (_loggedInUser == null) {
      final userResult = await getLoggedInUserUseCase();
      if (userResult is Success<User?>) {
        _loggedInUser = userResult.data;
      }
    }

    // Wait for the Calls SDK to be ready (initialized by CallEventService)
    await _ensureCallsSdkInitialized();

    // Configure the repository with auth token and optional custom builder
    await _configureRequest(limit: 30);

    Result<List<CallLog>> result = await getCallLogsUseCase(
      limit: 30,

    );

    // Retry logic: if the SDK fetch failed, wait and retry with a fresh request.
    for (int attempt = 1; attempt <= _maxRetries && result is Failure; attempt++) {
      debugPrint(
        'CallLogsBloc: fetch failed, retrying in '
        '${_retryDelay.inSeconds}s (attempt $attempt/$_maxRetries)',
      );

      await Future.delayed(_retryDelay);

      // Reset the request on the repository so fetchNext gets a fresh
      // CallLogRequest with a new generateToken cycle
      _resetRepositoryRequest();
      await _configureRequest(limit: 30);

      result = await getCallLogsUseCase(
        limit: 30,
  
      );
      
      debugPrint(
        'CallLogsBloc: retry attempt $attempt result: ${result is Success ? "SUCCESS" : "FAILED"}',
      );
    }

    if (result is Success<List<CallLog>>) {
      final callLogs = result.data;
      if (callLogs.isEmpty) {
        emit(state.copyWith(
          status: CallLogsStatus.empty,
          loggedInUser: _loggedInUser,
        ));
      } else {
        // Group call logs by date
        final groupedEntries = _groupCallLogsByDate(callLogs);

        replaceAll(callLogs);

        emit(state.copyWith(
          status: CallLogsStatus.loaded,
          callLogs: callLogs,
          hasMore: callLogs.length >= 30,
          loggedInUser: _loggedInUser,
          groupedEntries: groupedEntries,
        ));
      }
    } else if (result is Failure) {
      emit(state.copyWith(
        status: CallLogsStatus.error,
        errorMessage: result.message,
        loggedInUser: _loggedInUser,
      ));
    }
  }

  /// Resets the repository's current request so the next [_configureRequest]
  /// builds a fresh [CallLogRequest]. This is needed for retries because
  /// the SDK's fetchNext uses internal state from the previous request.
  void _resetRepositoryRequest() {
    final repo = CallLogsServiceLocator.instance.repository;
    if (repo is CallLogsRepositoryImpl) {
      repo.resetRequest();
    }
  }

  /// Load more call logs (pagination)
  Future<void> _onLoadMoreCallLogs(
    LoadMoreCallLogs event,
    Emitter<CallLogsState> emit,
  ) async {
    if (state.status != CallLogsStatus.loaded) return;

    if (!state.hasMore || state.isLoadingMore || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    emit(state.copyWith(isLoadingMore: true));

    final result = await loadMoreCallLogsUseCase(
      limit: 30,

      currentCallLogs: state.callLogs,
    );

    _isLoadingMore = false;

    if (result is Success<List<CallLog>>) {
      final newCallLogs = result.data;

      if (newCallLogs.isEmpty) {
        emit(state.copyWith(hasMore: false, isLoadingMore: false));
        return;
      }

      final allCallLogs = [...state.callLogs, ...newCallLogs];

      // Re-group all call logs by date
      final groupedEntries = _groupCallLogsByDate(allCallLogs);

      replaceAll(allCallLogs);

      emit(state.copyWith(
        callLogs: allCallLogs,
        hasMore: newCallLogs.length >= 30,
        isLoadingMore: false,
        groupedEntries: groupedEntries,
      ));
    } else if (result is Failure) {
      emit(state.copyWith(
        status: CallLogsStatus.error,
        errorMessage: result.message,
        isLoadingMore: false,
      ));
    }
  }

  /// Refresh call logs list
  Future<void> _onRefreshCallLogs(
    RefreshCallLogs event,
    Emitter<CallLogsState> emit,
  ) async {
    // Reset repository request so it's re-built on next load
    _resetRepositoryRequest();
    add(const LoadCallLogs());
  }

  /// Initiate a call from a call log entry
  Future<void> _onInitiateCallFromLog(
    InitiateCallFromLog event,
    Emitter<CallLogsState> emit,
  ) async {
    final callLog = event.callLog;
    final context = event.context;

    // Determine receiver ID and type from call log
    final String receiverId;
    final String receiverType;
    final String callType;

    // Get the receiver - if logged in user initiated the call, receiver is the other party
    // Otherwise, receiver is the initiator
    // CallLog.initiator and CallLog.receiver are CallEntity types
    // Need to cast to CallUser or CallGroup to access uid/guid
    if (_isLoggedInUserInitiator(callLog)) {
      // User initiated the original call, so call the receiver
      if (callLog.receiver is CallUser) {
        receiverId = (callLog.receiver as CallUser).uid ?? '';
        receiverType = CometChatReceiverType.user;
      } else if (callLog.receiver is CallGroup) {
        receiverId = (callLog.receiver as CallGroup).guid ?? '';
        receiverType = CometChatReceiverType.group;
      } else {
        return; // Unknown receiver type
      }
    } else {
      // User received the original call, so call the initiator
      if (callLog.initiator is CallUser) {
        receiverId = (callLog.initiator as CallUser).uid ?? '';
        receiverType = CometChatReceiverType.user;
      } else if (callLog.initiator is CallGroup) {
        receiverId = (callLog.initiator as CallGroup).guid ?? '';
        receiverType = CometChatReceiverType.group;
      } else {
        return; // Unknown initiator type
      }
    }

    // Determine call type from the original call
    callType = callLog.type ?? CometChatCallType.audio;

    if (receiverId.isEmpty) {
      return;
    }

    // Create call object
    final call = Call(
      receiverUid: receiverId,
      receiverType: receiverType,
      type: callType,
    );

    final result = await initiateCallUseCase(call);

    if (result is Success<Call>) {
      // Navigate to outgoing call screen
      _navigateToOutgoingCall(context, result.data);
    } else if (result is Failure) {
      // Error handling - could emit error state or show snackbar
      emit(state.copyWith(
        errorMessage: result.message,
      ));
    }
  }

  /// Check if logged in user is the initiator of the call
  bool _isLoggedInUserInitiator(CallLog callLog) {
    if (_loggedInUser == null) return false;
    
    if (callLog.initiator is CallUser) {
      return (callLog.initiator as CallUser).uid == _loggedInUser!.uid;
    }
    return false;
  }

  /// Navigate to outgoing call screen
  void _navigateToOutgoingCall(BuildContext context, Call call) {
    // Fire the outgoing call event
    call.category = MessageCategoryConstants.call;
    CometChatCallEvents.ccOutgoingCall(call);

    // Get the user from the call log for display
    User? user;
    if (call.receiverType == CometChatReceiverType.user) {
      user = User(
        uid: call.receiverUid,
        name: call.receiverUid, // Name will be fetched by the outgoing call screen
      );
    }

    // Navigate to outgoing call screen using the navigation context
    final navigatorContext = CallNavigationContext.navigatorKey.currentContext;
    if (navigatorContext != null) {
      Navigator.push(
        navigatorContext,
        MaterialPageRoute(
          builder: (context) => CometChatOutgoingCall(
            call: call,
            user: user,
          ),
        ),
      );
    } else {
      // Fallback to provided context
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CometChatOutgoingCall(
            call: call,
            user: user,
          ),
        ),
      );
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Group call logs by date for display
  Map<String, List<CallLog>> _groupCallLogsByDate(List<CallLog> callLogs) {
    final Map<String, List<CallLog>> grouped = {};

    for (final callLog in callLogs) {
      final initiatedAt = callLog.initiatedAt;
      if (initiatedAt == null) continue;

      // Convert timestamp to date string
      final date = DateTime.fromMillisecondsSinceEpoch(initiatedAt * 1000);
      final dateKey = _getDateKey(date);

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(callLog);
    }

    return grouped;
  }

  /// Get date key for grouping (Today, Yesterday, or date string)
  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final callDate = DateTime(date.year, date.month, date.day);

    if (callDate == today) {
      return 'Today';
    } else if (callDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format as "MMM dd, yyyy"
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  /// Get month name abbreviation
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // ============================================================
  // LISTBASE HOOK OVERRIDES (incremental map updates only)
  // State emission is handled by event handlers, not hooks
  // ============================================================

  /// Called when a call log is added to the list.
  /// Only updates the index map - state emission is in event handlers.
  @override
  void onItemAdded(CallLog item, List<CallLog> updatedList) {
    // OPTIMIZATION: Incremental map update - item added at end
    final newIndex = updatedList.length - 1;
    _addToIndexMap(item.sessionId, newIndex);
  }

  /// Called when a call log is removed from the list.
  /// Only updates the index map - state emission is in event handlers.
  @override
  void onItemRemoved(CallLog item, List<CallLog> updatedList) {
    // Get the index BEFORE removing from map (map still has old index)
    final removedIndex = _callLogIndexMap[item.sessionId];

    // Remove from map
    _removeFromIndexMap(item.sessionId);

    // Shift indices for items that were after the removed item
    if (removedIndex != null) {
      _shiftIndicesAfterRemoval(removedIndex);
    }

    if (updatedList.isEmpty) {
      _mapNeedsRebuild = true;
    }
  }

  /// Called when a call log is updated in the list.
  /// Only updates the index map if sessionId changed - state emission is in event handlers.
  @override
  void onItemUpdated(
    CallLog oldItem,
    CallLog newItem,
    List<CallLog> updatedList,
  ) {
    // OPTIMIZATION: No map update needed - index unchanged, ID unchanged
    // Only update map if sessionId changed (rare edge case)
    if (oldItem.sessionId != newItem.sessionId) {
      final index = findCallLogIndex(oldItem.sessionId);
      _removeFromIndexMap(oldItem.sessionId);
      if (index != null) {
        _addToIndexMap(newItem.sessionId, index);
      }
    }
  }

  /// Called when the call logs list is cleared.
  /// Only clears the index map - state emission is in event handlers.
  @override
  void onListCleared(List<CallLog> previousList) {
    _callLogIndexMap.clear();
    _mapNeedsRebuild = true;
  }

  /// Called when the entire call logs list is replaced.
  /// Rebuilds the index map - state emission is in event handlers.
  @override
  void onListReplaced(
    List<CallLog> previousList,
    List<CallLog> newList,
  ) {
    if (isClosed) return;

    // Full rebuild only on list replacement (initial load, refresh, pagination)
    // This is O(n) but only happens on major list changes, not individual updates
    _rebuildIndexMap();
  }

  @override
  Future<void> close() {
    // Clear index map
    _callLogIndexMap.clear();

    // Reset pagination state
    _isLoadingMore = false;

    return super.close();
  }
}
