import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class CometChatCallLogHistoryController
    extends CometChatListController<CallLog, String> {
  CometChatCallLogHistoryController({required this.callLogsBuilderProtocol})
      : super(callLogsBuilderProtocol.getRequest());

  late CallLogsBuilderProtocol callLogsBuilderProtocol;

  User? loggedInUser;
  String? authToken;

  List<CallLog> sortedCallLogsList = [];

  CallLog? lastElement;

  Map<String, List<CallLog>> groupedEntries = {};

  final int maxRetries = 3;
  final Duration retryDelay = const Duration(seconds: 3);
  int _currentRetryCount = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeLoggedInUser();
  }

  _initializeLoggedInUser() async {
    loggedInUser = await CometChat.getLoggedInUser();
    update();
  }

  @override
  loadMoreElements({bool Function(CallLog element)? isIncluded}) async {
    isLoading = true;
    loggedInUser ??= await CometChat.getLoggedInUser();
    try {
      await request.fetchNext(onSuccess: (List<CallLog> fetchedList) {
        if (fetchedList.isEmpty) {
          isLoading = false;
          hasMoreItems = false;
        } else {
          isLoading = false;
          hasMoreItems = true;
          for (var element in fetchedList) {
            final date = element.initiatedAt;
            if (!groupedEntries
                .containsKey(CallLogsUtils.storeValueInMapTime(date))) {
              groupedEntries[CallLogsUtils.storeValueInMapTime(date)] = [];
            }
            groupedEntries[CallLogsUtils.storeValueInMapTime(date)]!
                .add(element);
            if (isIncluded != null && isIncluded(element) == true) {
              list.add(element);
            } else {
              list.add(element);
            }
          }
        }
        update();
      }, onError: (CometChatCallsException e) {
        if (kDebugMode) {
          debugPrint("Error -> ${e.details}");
        }
        if (onError != null) {
          onError!(e);
        } else {
          error = e;
          hasError = true;
        }

        update();
      });
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint("Error in Catch  -> $e");
      }
      error = CometChatCallsException("ERR", s.toString(), "Error");
      hasError = true;
      isLoading = false;
      hasMoreItems = false;
      update();
    }
  }

  @override
  String getKey(CallLog element) {
    return element.mid ?? "";
  }

  @override
  bool match(CallLog elementA, CallLog elementB) {
    return elementA.sessionId == elementB.sessionId;
  }

  String getDate(
    int? epochTimestampInSeconds,
  ) {
    String formattedDate = "";
    if (epochTimestampInSeconds == null) {
      return formattedDate;
    }
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(epochTimestampInSeconds * 1000);

    return formattedDate = DateFormat('d MMMM, h:mm a').format(dateTime);
  }

  static User? getUser(CallLog callLog) {
    User? user;
    if (CallLogsUtils.isUser(callLog)) {
      user = User(
        name: CallLogsUtils.receiverName(CometChatUIKit.loggedInUser, callLog),
        avatar:
            CallLogsUtils.receiverAvatar(CometChatUIKit.loggedInUser, callLog),
        uid: CallLogsUtils.returnReceiverId(
            CometChatUIKit.loggedInUser, callLog),
      );
    }
    return user;
  }

  /// [getCallType] Return call status as a string
  String getCallType(
    context,
    CallLog callLog,
    User? loggedInUser,
  ) {
    bool isInitiatedByUser =
        CallUtils.callLogLoggedInUser(callLog, loggedInUser);

    // Determine the call type based on the call log status
    switch (callLog.status) {
      case CallStatusConstants.initiated:
      case CallStatusConstants.ongoing:
      case CallStatusConstants.ended:
        return isInitiatedByUser ? "Outgoing" : "Incoming";

      case CallStatusConstants.unanswered:
      case CallStatusConstants.cancelled:
      case CallStatusConstants.rejected:
      case CallStatusConstants.busy:
        return isInitiatedByUser ? "Outgoing" : "Missed";

      default:
        return "Unknown"; // Return "Unknown" for unknown statuses
    }
  }

  String convertDuration(String? duration) {
    if (duration == null) {
      return "";
    }
    // Split the input string by ":"
    final parts = duration.split(':');
    if (parts.length != 3) {
      return "Invalid format"; // Return an error message if the format is unexpected
    }

    // Parse hours, minutes, and seconds
    int hours = int.parse(parts[0].trim());
    int minutes = int.parse(parts[1].trim());

    // Convert hours and minutes to a string format
    // Only include hours if they are greater than 0
    String formatted = '';
    if (hours > 0) {
      formatted = '$hours: ${minutes} m'; // If there are hours, show them
    } else {
      formatted = '$minutes m'; // Only show minutes if there are no hours
    }

    return formatted;
  }

  // TODO: Implement the retry logic later.
  // Method to load groups
  void retryGroups() async {
    try {
      request = callLogsBuilderProtocol.getRequest();
      list = [];
      isLoading = true;
      await loadMoreElements();
      isLoading = false;
      _currentRetryCount = 0; // Reset retries on success
    } catch (e) {
      isLoading = false;
      _handleError(e);
    }
  }

  // TODO: Implement the retry logic later.
  // Retry logic on error
  void _handleError(dynamic error) {
    if (_currentRetryCount < maxRetries) {
      _currentRetryCount++;
      Future.delayed(retryDelay, () {
        retryGroups();
      });
    } else {
      if (onError != null) {
        onError!(error);
      }
    }
  }
}
