import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:get/get.dart';

/// [CometChatCallButtonsController] is the view model class for [CometChatCallButtons]
class CometChatCallButtonsController extends GetxController
    with CometChatCallEventListener, CallListener {
  ///[user] is a object of User which is used to initiate call.
  final User? user;

  ///[group] is a object of Group which is used to initiate call.
  final Group? group;

  ///[outgoingCallConfiguration] is a object of [OutgoingCallConfiguration] which sets the configuration for outgoing call
  final CometChatOutgoingCallConfiguration? outgoingCallConfiguration;

  ///[callSettingsBuilder] is used to configure the meet settings builder
  final CallSettingsBuilder Function(
      User? user, Group? group, bool? isAudioOnly)? callSettingsBuilder;

  ///[_listenerId] is a unique identifier for the listener of call events.
  late String _listenerId;

  late String receiverType;
  late String receiverId;

  bool disabled = false;

  ///[onError] is a function which will called when some error occurs.
  final OnError? onError;

  ///[_loggedInUser] is a object of User which contains the details of logged-in user.
  late User? _loggedInUser;

  /// [CometChatCallButtonsController] constructor requires [user], [group] and [onError] while initializing.
  CometChatCallButtonsController({
    this.user,
    this.group,
    this.onError,
    this.outgoingCallConfiguration,
    this.callSettingsBuilder,
  }) {
    setUser(user);
    setGroup(group);
    initializeDependencies();
  }

  @override
  void onInit() {
    _listenerId =
        "callButtons${DateTime.now().microsecondsSinceEpoch.toString()}";
    addCallListener();
    super.onInit();
  }

  @override
  void onClose() {
    removeCallListener();
    super.onClose();
  }

  initializeDependencies() async {
    _loggedInUser = await CometChatUIKit.getLoggedInUser();
  }

  void setUser(User? user) {
    if (user != null) {
      receiverType = ReceiverTypeConstants.user;
      receiverId = user.uid;
    }
  }

  void setGroup(Group? group) {
    if (group != null) {
      receiverType = ReceiverTypeConstants.group;
      receiverId = group.guid;
    }
  }

  void addCallListener() {
    CometChat.addCallListener(_listenerId, this);
    CometChatCallEvents.addCallEventsListener(_listenerId, this);
  }

  void removeCallListener() {
    CometChat.removeCallListener(_listenerId);
    CometChatCallEvents.removeCallEventsListener(_listenerId);
  }

  @override
  void ccCallRejected(Call call) {
    disabled = false;
    update();
  }

  @override
  void ccCallEnded(Call call) {
    disabled = false;
    update();
  }

  @override
  void onOutgoingCallRejected(Call call) {
    disabled = false;
    update();
  }

  @override
  void onCallEndedMessageReceived(Call call) {
    disabled = false;
    update();
  }

  void initiateMeetWorkflow(String callType, context) {
    CallSettingsBuilder defaultCallSettingsBuilder;
    bool isAudioOnly = callType == CallTypeConstants.audioCall;
    if (callSettingsBuilder != null) {
      defaultCallSettingsBuilder =
          callSettingsBuilder!(user, group, isAudioOnly);
    } else if (outgoingCallConfiguration != null &&
        outgoingCallConfiguration?.callSettingsBuilder != null) {
      defaultCallSettingsBuilder =
          outgoingCallConfiguration!.callSettingsBuilder!;
    } else {
      defaultCallSettingsBuilder = (CallSettingsBuilder()
        ..enableDefaultLayout = true
        ..setAudioOnlyCall = isAudioOnly
        ..startWithVideoMuted = false
        ..startWithAudioMuted = false);
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CometChatOngoingCall(
            callSettingsBuilder: defaultCallSettingsBuilder,
            sessionId: receiverId,
            callWorkFlow: CallWorkFlow.directCalling,
            onError: onError,
          ),
        ));
    if (kDebugMode) {
      debugPrint('expecting to have navigated to CometChatOngoingCall screen');
    }
    Map<String, dynamic> customData = <String, dynamic>{};
    try {
      customData["callType"] = callType;
      customData["sessionID"] = receiverId;
    } catch (e) {
      if (kDebugMode) {
        print('error in parsing customData');
      }
    }
    CustomMessage customMessage = CustomMessage(
        receiverUid: receiverId,
        receiverType: ReceiverTypeConstants.group,
        type: MessageTypeConstants.meeting,
        customData: customData);
    customMessage.receiver = group;
    customMessage.sentAt = DateTime.now();
    customMessage.muid = DateTime.now().microsecondsSinceEpoch.toString();
    customMessage.category = MessageCategoryConstants.custom;
    customMessage.sender = _loggedInUser;
    customMessage.updateConversation = true;

    Map<String, dynamic>? metadata = {};
    try {
      metadata = customMessage.metadata;
      if (metadata == null) {
        metadata = {};
        metadata[UpdateSettingsConstant.incrementUnreadCount] = true;
      } else {
        metadata[UpdateSettingsConstant.incrementUnreadCount] = true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('error in parsing metadata');
      }
    }
    customMessage.metadata = metadata;
    CometChatUIKit.sendCustomMessage(customMessage,
        onSuccess: (CustomMessage directCallMessage) {
      CometChatMessageEvents.ccMessageSent(
          directCallMessage, MessageStatus.sent);
      disabled = false;
      update();
    }, onError: (CometChatException e) {
      if (customMessage.metadata != null) {
        customMessage.metadata!["error"] = e;
      } else {
        customMessage.metadata = {"error": e};
      }
      CometChatMessageEvents.ccMessageSent(customMessage, MessageStatus.error);
      disabled = false;
      update();
    });
  }

  void initiateCallWorkflow(String callType, context) {
    Call call = Call(
      receiverUid: receiverId,
      receiverType: ReceiverTypeConstants.user,
      type: callType,
    );

    CallSettingsBuilder defaultCallSettingsBuilder;
    bool isAudioOnly = callType == CallTypeConstants.audioCall;
    if (callSettingsBuilder != null) {
      defaultCallSettingsBuilder =
          callSettingsBuilder!(user, group, isAudioOnly);
    } else if (outgoingCallConfiguration != null &&
        outgoingCallConfiguration?.callSettingsBuilder != null) {
      defaultCallSettingsBuilder =
          outgoingCallConfiguration!.callSettingsBuilder!;
    } else {
      defaultCallSettingsBuilder = (CallSettingsBuilder()
        ..enableDefaultLayout = true
        ..setAudioOnlyCall = isAudioOnly
        ..startWithAudioMuted = false);
    }

    CometChatUIKitCalls.initiateCall(call, onSuccess: (Call returnedCall) {
      disabled = false;
      update();
      returnedCall.category = MessageCategoryConstants.call;
      CometChatCallEvents.ccOutgoingCall(returnedCall);
      FocusManager.instance.primaryFocus?.unfocus();
      if (CallNavigationContext.navigatorKey.currentContext?.mounted ?? false) {
        Future.delayed((const Duration(milliseconds: 300)), () {
          if (CallNavigationContext.navigatorKey.currentContext != null &&
              CallNavigationContext.navigatorKey.currentContext!.mounted) {
            Navigator.push(
                CallNavigationContext.navigatorKey.currentContext!,
                MaterialPageRoute(
                  builder: (context) => CometChatOutgoingCall(
                    call: returnedCall,
                    user: user,
                    subtitleView: outgoingCallConfiguration?.subtitleView,
                    declineButtonIcon:
                        outgoingCallConfiguration?.declineButtonIcon,
                    onCancelled: outgoingCallConfiguration?.onCancelled,
                    disableSoundForCalls:
                        outgoingCallConfiguration?.disableSoundForCalls,
                    customSoundForCalls:
                        outgoingCallConfiguration?.customSoundForCalls,
                    customSoundForCallsPackage:
                        outgoingCallConfiguration?.customSoundForCallsPackage,
                    onError: outgoingCallConfiguration?.onError,
                    outgoingCallStyle: outgoingCallConfiguration?.outgoingCallStyle,
                    callSettingsBuilder: defaultCallSettingsBuilder,
                    height: outgoingCallConfiguration?.height,
                    width: outgoingCallConfiguration?.width,
                    avatarView: outgoingCallConfiguration?.avatarView,
                    titleView: outgoingCallConfiguration?.titleView,
                    cancelledView: outgoingCallConfiguration?.cancelledView,
                  ),
                ));
          } else {
            debugPrint(
                "Context is not mounted while performing Delayed Navigation");
          }
        });
      } else {
        debugPrint("Context is not mounted while performing Delay");
      }
    }, onError: (CometChatException e) {
      disabled = false;
      update();
      try {
        if (onError != null) {
          onError!(e);
        }
      } catch (err) {
        debugPrint('Error in initiating call: ${e.message}');
      }
    });
  }

  /// [initiateCall] is a method which is used to initiate call.
  void initiateCall(String callType, context) {
    disabled = true;
    update();
    if (receiverType == ReceiverTypeConstants.group) {
      initiateMeetWorkflow(callType, context);
    } else {
      initiateCallWorkflow(callType, context);
    }
  }
}
