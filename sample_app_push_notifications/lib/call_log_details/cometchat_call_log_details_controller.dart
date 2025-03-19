import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CometChatCallLogDetailsController  {

  static String getDate(
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

  /// [getCallType] Return call status as a string
  static String getCallType(
    BuildContext context,
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

  static String convertDuration(String? duration) {
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

  static List<Widget> tabs(String title) {
    return [
      const Tab(text: 'Participants'),
      const Tab(text: 'Recording'),
      const Tab(text: 'History'),
    ];
  }

  static CallUser? getCallUser(CallLog? log) {
    CallUser? callUser;
    if (log != null && CallLogsUtils.isUser(log)) {
      callUser = CallUser(
        name: CallLogsUtils.receiverName(CometChatUIKit.loggedInUser, log),
        uid: CallLogsUtils.returnReceiverId(CometChatUIKit.loggedInUser, log),
        avatar: CallLogsUtils.receiverAvatar(CometChatUIKit.loggedInUser, log),
      );
    }
    return callUser;
  }

  static CallGroup? getCallGroup(CallLog? log) {
    CallGroup? callGroup;

    if (log != null && log.receiver != null && log.receiver is CallGroup) {
      callGroup = log.receiver as CallGroup;
    }
    return callGroup;
  }
}
