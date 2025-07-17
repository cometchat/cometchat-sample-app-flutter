import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';

/// [CallUtils] is a utility class that contains methods to perform call related operations.
class CallUtils {
  /// Returns the call status message.
  static String getCallStatus(
      BuildContext context, BaseMessage baseMessage, User? loggedInUser) {
    String callMessageText = "";
    //check if the message is a call message and the receiver type is user
    if (baseMessage is Call &&
        baseMessage.receiverType == ReceiverTypeConstants.user) {
      Call call = baseMessage;
      User initiator = call.callInitiator as User;
      //check if the call is initiated
      if (call.callStatus == CallStatusConstants.initiated) {
        //check if the logged in user is the initiator
        if (!isLoggedInUser(initiator, loggedInUser)) {
          callMessageText = Translations.of(context).incomingCall;
        } else {
          callMessageText = Translations.of(context).outgoingCall;
        }
      } else if (call.callStatus == CallStatusConstants.ongoing) {
        callMessageText = Translations.of(context).callAccepted;
      } else if (call.callStatus == CallStatusConstants.ended) {
        callMessageText = Translations.of(context).callEnded;
      } else if (call.callStatus == CallStatusConstants.unanswered) {
        if (isLoggedInUser(initiator, loggedInUser)) {
          callMessageText = Translations.of(context).callUnanswered;
        } else {
          callMessageText = Translations.of(context).missedCall;
        }
      } else if (call.callStatus == CallStatusConstants.cancelled) {
        if (isLoggedInUser(initiator, loggedInUser)) {
          callMessageText = Translations.of(context).callCancelled;
        } else {
          callMessageText = Translations.of(context).missedCall;
        }
      } else if (call.callStatus == CallStatusConstants.rejected) {
        if (isLoggedInUser(initiator, loggedInUser)) {
          callMessageText = Translations.of(context).callRejected;
        } else {
          callMessageText = Translations.of(context).missedCall;
        }
      } else if (call.callStatus == CallStatusConstants.busy) {
        if (isLoggedInUser(initiator, loggedInUser)) {
          callMessageText = Translations.of(context).callRejected;
        } else {
          callMessageText = Translations.of(context).missedCall;
        }
      }
    }
    return " $callMessageText";
  }

  /// Returns true if the call is a video call.
  static bool isVideoCall(Call call) {
    return call.type == CallTypeConstants.videoCall;
  }

  /// Returns true if the call is initiated by the logged in user.
  static bool isLoggedInUser(User? initiator, User? loggedInUser) {
    if (initiator == null || loggedInUser == null) {
      return false;
    } else {
      return initiator.uid == loggedInUser.uid;
    }
  }

  static String getLastMessageForGroupCall(
      BaseMessage lastMessage, BuildContext context, User? loggedInUser) {
    String message = "";
    if (lastMessage.receiverType == ReceiverTypeConstants.group) {
      if (!isLoggedInUser(lastMessage.sender, loggedInUser)) {
        message =
            "${lastMessage.sender?.name} ${Translations.of(context).initiatedGroupCall}";
      } else {
        message = Translations.of(context).youInitiatedGroupCall;
      }
    }
    return message;
  }

  ///[isMissedCall] returns true if the call is missed call.
  static bool isMissedCall(Call call, User? loggedInUser) {
    if (call.receiverType == ReceiverTypeConstants.user) {
      User initiator = (call.callInitiator as User);
      if (call.callStatus == CallStatusConstants.unanswered) {
        return !isLoggedInUser(initiator, loggedInUser);
      } else if (call.callStatus == CallStatusConstants.cancelled) {
        return !isLoggedInUser(initiator, loggedInUser);
      } else if (call.callStatus == CallStatusConstants.rejected) {
        return !isLoggedInUser(initiator, loggedInUser);
      } else if (call.callStatus == CallStatusConstants.busy) {
        return !isLoggedInUser(initiator, loggedInUser);
      }
    }

    return false;
  }

  /// Returns true if the call is initiated by the logged in user.
  static bool callLogLoggedInUser(CallLog? callLog, User? loggedInUser) {
    if (callLog == null || loggedInUser == null) {
      return false;
    } else if (callLog.initiator is CallEntity ||
        (callLog.receiver is CallEntity)) {
      if (callLog.initiator is CallUser) {
        CallUser initiatorUser = callLog.initiator as CallUser;
        return initiatorUser.uid == loggedInUser.uid;
      } else if (callLog.receiver is CallUser) {
        CallUser receiverUser = callLog.receiver as CallUser;
        return receiverUser.uid == loggedInUser.uid;
      } else if (callLog.initiator is CallGroup) {
        CallUser receiverUser = callLog.receiver as CallUser;
        return receiverUser.uid == loggedInUser.uid;
      } else if (callLog.receiver is CallGroup) {
        CallUser initiatorUser = callLog.initiator as CallUser;
        return initiatorUser.uid == loggedInUser.uid;
      }
    }
    return false;
  }

  /// [getStatus] return call status
  static String getStatus(
      BuildContext? context, CallLog? callLog, User? loggedInUser) {
    String callMessageText = "";

    if (callLog == null || loggedInUser == null) {
      return "";
    }

    if (context == null) {
      return "";
    }

    //check if the call is initiated
    if (callLog.status == CallStatusConstants.initiated) {
      //check if the logged in user is the initiator
      if (!callLogLoggedInUser(callLog, loggedInUser)) {
        callMessageText = Translations.of(context).incomingCall;
      } else {
        callMessageText = Translations.of(context).outgoingCall;
      }
    } else if (callLog.status == CallStatusConstants.ongoing) {
      if (callLogLoggedInUser(callLog, loggedInUser)) {
        callMessageText = Translations.of(context).ongoingCall;
      } else {
        callMessageText = Translations.of(context).ongoingCall;
      }
    } else if (callLog.status == CallStatusConstants.ended) {
      if (callLogLoggedInUser(callLog, loggedInUser)) {
        callMessageText = Translations.of(context).outgoingCall;
      } else {
        callMessageText = Translations.of(context).incomingCall;
      }
    } else if (callLog.status == CallStatusConstants.unanswered) {
      if (callLogLoggedInUser(callLog, loggedInUser)) {
        callMessageText = Translations.of(context).unansweredCall;
      } else {
        callMessageText = Translations.of(context).missedCall;
      }
    } else if (callLog.status == CallStatusConstants.cancelled) {
      if (callLogLoggedInUser(callLog, loggedInUser)) {
        callMessageText = Translations.of(context).cancelledCall;
      } else {
        callMessageText = Translations.of(context).missedCall;
      }
    } else if (callLog.status == CallStatusConstants.rejected) {
      if (callLogLoggedInUser(callLog, loggedInUser)) {
        callMessageText = Translations.of(context).rejectedCall;
      } else {
        callMessageText = Translations.of(context).missedCall;
      }
    } else if (callLog.status == CallStatusConstants.busy) {
      if (callLogLoggedInUser(callLog, loggedInUser)) {
        callMessageText = Translations.of(context).unansweredCall;
      } else {
        callMessageText = Translations.of(context).missedCall;
      }
    }
    return " $callMessageText";
  }

  /// [getCallIcon] Return call status icon
  static Widget getCallIcon(
    BuildContext context,
    CallLog callLog,
    User? loggedInUser,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
    CometChatCallLogsStyle style, {
    Widget? incomingCallIcon,
    Widget? outgoingCallIcon,
    Widget? missedCallIcon,
  }) {
    bool isInitiatedByUser = callLogLoggedInUser(callLog, loggedInUser);
    isAudioCall(callLog);

    // Define default icons if not provided
    Widget incoming = incomingCallIcon ??
        Icon(
          Icons.call_received_outlined,
          color: style.incomingCallIconColor ?? colorPalette.success,
          size: 16,
        );

    Widget outgoing = outgoingCallIcon ??
        Icon(
          Icons.call_made_outlined,
          color: style.outgoingCallIconColor ?? colorPalette.success,
          size: 16,
        );

    Widget missed = missedCallIcon ??
        Icon(
          Icons.call_missed_outgoing_rounded,
          color: style.missedCallIconColor ?? colorPalette.error,
          size: 16,
        );

    // Helper function to select icon based on initiator and call type
    Widget selectIcon(bool isInitiatedByUser) {
      return isInitiatedByUser ? outgoing : incoming;
    }

    // Switch on call status to determine the appropriate icon
    switch (callLog.status) {
      case CallStatusConstants.initiated:
      case CallStatusConstants.ongoing:
      case CallStatusConstants.ended:
        return selectIcon(isInitiatedByUser);

      case CallStatusConstants.unanswered:
      case CallStatusConstants.cancelled:
      case CallStatusConstants.rejected:
      case CallStatusConstants.busy:
        return isInitiatedByUser ? outgoing : missed;

      default:
        return const SizedBox(); // Return empty widget for unknown statuses
    }
  }

  /// [getCallStatusColor] returns call status color
  static Color getCallStatusColor(
    CallLog callLog,
    User? loggedInUser,
    CometChatColorPalette colorPalette,
  ) {
    bool isInitiatedByUser = callLogLoggedInUser(callLog, loggedInUser);

    switch (callLog.status) {
      case CallStatusConstants.initiated:
        return colorPalette.textPrimary ??
            Colors.transparent; // Incoming or outgoing call

      case CallStatusConstants.ongoing:
        return colorPalette.textPrimary ?? Colors.transparent; // Ongoing call

      case CallStatusConstants.ended:
        return colorPalette.textPrimary ??
            Colors.transparent; // Outgoing or incoming call

      case CallStatusConstants.unanswered:
        return isInitiatedByUser
            ? colorPalette.textPrimary ??
                Colors.transparent // Unanswered call by user
            : colorPalette.error ?? Colors.transparent; // Missed call

      case CallStatusConstants.cancelled:
      case CallStatusConstants.rejected:
        return isInitiatedByUser
            ? colorPalette.textPrimary ??
                Colors.transparent // User cancelled/rejected
            : colorPalette.error ?? Colors.transparent; // Missed call

      case CallStatusConstants.busy:
        return colorPalette.textPrimary ??
            Colors.transparent; // Unanswered call

      default:
        return colorPalette.error ??
            Colors.transparent; // Unknown or missed call
    }
  }

  static bool isAudioCall(CallLog callLog) {
    return callLog.type == CallTypeConstants.audioCall;
  }

  static bool isCallInitiatedByMe(Call call) {
    if (call.callInitiator is User) {
      User initiator = call.callInitiator as User;
      return initiator.uid == CometChatUIKit.loggedInUser?.uid;
    }
    return false;
  }

  static String getCallIconByStatus(
      BuildContext context, BaseMessage baseMessage, User? loggedInUser, bool isAudio) {
    String callIcon = "";
    //check if the message is a call message and the receiver type is user
    if (baseMessage is Call &&
        baseMessage.receiverType == ReceiverTypeConstants.user) {
      Call call = baseMessage;
      User initiator = call.callInitiator as User;
      //check if the call is initiated
      if (call.callStatus == CallStatusConstants.initiated) {
        //check if the logged in user is the initiator
        if (!isLoggedInUser(initiator, loggedInUser)) {
          callIcon = isAudio? AssetConstants.incomingAudioCallNoFill : AssetConstants.incomingVideoCallNoFill;
        } else {
          callIcon = isAudio? AssetConstants.outgoingAudioCallNoFill : AssetConstants.outgoingVideoCallNoFill;
        }
      }else if(!isLoggedInUser(initiator, loggedInUser) && ( call.callStatus == CallStatusConstants.cancelled || call.callStatus == CallStatusConstants.unanswered || call.callStatus == CallStatusConstants.busy)){
        callIcon = isAudio? AssetConstants.audioMissed : AssetConstants.videoMissed;
      } else {
        callIcon = isAudio? AssetConstants.callNoFill : AssetConstants.videocamNoFill;
      }
    }
    return callIcon;
  }

  static Color getCallTextColor(
      BuildContext context, BaseMessage baseMessage, User? loggedInUser, CometChatColorPalette colorPalette) {
    Color callTextColor = colorPalette.textSecondary ?? Colors.transparent;
    if (baseMessage is Call &&
        baseMessage.receiverType == ReceiverTypeConstants.user) {
      Call call = baseMessage;
      User initiator = call.callInitiator as User;

      if (!isLoggedInUser(initiator, loggedInUser) &&
          (
              call.callStatus == CallStatusConstants.cancelled ||
              call.callStatus == CallStatusConstants.unanswered ||
              call.callStatus == CallStatusConstants.busy)) {
        callTextColor = colorPalette.error ?? Colors.transparent;
      }
    }
    return callTextColor;
  }
  static Color getCallIconColor(
      BuildContext context, BaseMessage baseMessage, User? loggedInUser, CometChatColorPalette colorPalette) {
    Color callTextColor = colorPalette.iconSecondary ?? Colors.transparent;
    if (baseMessage is Call &&
        baseMessage.receiverType == ReceiverTypeConstants.user) {
      Call call = baseMessage;
      User initiator = call.callInitiator as User;

      if (!isLoggedInUser(initiator, loggedInUser) &&
          (call.callStatus == CallStatusConstants.ended ||
              call.callStatus == CallStatusConstants.cancelled ||
              call.callStatus == CallStatusConstants.unanswered ||
              call.callStatus == CallStatusConstants.busy)) {
        callTextColor = colorPalette.error ?? Colors.transparent;
      }
    }
    return callTextColor;
  }
}
