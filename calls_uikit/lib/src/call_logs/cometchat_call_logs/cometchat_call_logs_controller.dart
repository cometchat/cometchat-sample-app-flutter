import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CometChatCallLogsController
    extends CometChatListController<CallLog, String> {
  CometChatCallLogsController({
    required this.callLogsBuilderProtocol,
    this.outgoingCallConfiguration,
    OnError? onError,
    OnLoad<CallLog>? onLoad,
    OnEmpty? onEmpty,
  }) : super(callLogsBuilderProtocol.getRequest(), onError: onError, onLoad: onLoad, onEmpty: onEmpty,);

  late CallLogsBuilderProtocol callLogsBuilderProtocol;

  CometChatOutgoingCallConfiguration? outgoingCallConfiguration;

  User? loggedInUser;
  String? authToken;

  CallLog? lastElement;

  Map<String, List<CallLog>> groupedEntries = {};

  CometChatColorPalette? colorPalette;
  CometChatSpacing? spacing;
  CometChatTypography? typography;

  // TODO: Implement the retry logic later.
  // Retry configuration
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
                .containsKey(CallLogsUtils.storeValueInMapTime(date!))) {
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
    return element.mid!;
  }

  @override
  bool match(CallLog elementA, CallLog elementB) {
    return elementA.sessionId == elementB.sessionId;
  }

  // Initiate Call
  void initiateCallWorkflowUser(CallLog callLog, BuildContext context) {
    Call call = Call(
      receiverUid: CallLogsUtils.returnReceiverId(loggedInUser, callLog),
      receiverType: ReceiverTypeConstants.user,
      type: callLog.type ?? CallTypeConstants.audioCall,
    );

    User receiverUser = User(
      uid: CallLogsUtils.returnReceiverId(loggedInUser, callLog),
      name: CallLogsUtils.receiverName(loggedInUser, callLog),
      avatar: CallLogsUtils.receiverAvatar(loggedInUser, callLog),
    );

    CometChatUIKitCalls.initiateCall(call, onSuccess: (Call returnedCall) {
      returnedCall.category = MessageCategoryConstants.call;
      CometChatCallEvents.ccOutgoingCall(returnedCall);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CometChatOutgoingCall(
              user: receiverUser,
              call: returnedCall,
              subtitleView: outgoingCallConfiguration?.subtitleView,
              declineButtonIcon: outgoingCallConfiguration?.declineButtonIcon,
              onCancelled: outgoingCallConfiguration?.onCancelled,
              disableSoundForCalls:
              outgoingCallConfiguration?.disableSoundForCalls,
              customSoundForCalls:
              outgoingCallConfiguration?.customSoundForCalls,
              customSoundForCallsPackage:
              outgoingCallConfiguration?.customSoundForCallsPackage,
              onError: outgoingCallConfiguration?.onError,
              outgoingCallStyle: outgoingCallConfiguration?.outgoingCallStyle,
              callSettingsBuilder:
              outgoingCallConfiguration?.callSettingsBuilder,
              height: outgoingCallConfiguration?.height,
              width: outgoingCallConfiguration?.width,
              titleView: outgoingCallConfiguration?.titleView,
              avatarView: outgoingCallConfiguration?.avatarView,
              cancelledView: outgoingCallConfiguration?.cancelledView,
            ),
          ));
    }, onError: (CometChatException e) {
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
  void initiateCall(CallLog callLog, BuildContext context) {
    if (CallLogsUtils.isUser(callLog)) {
      initiateCallWorkflowUser(callLog, context);
    }
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

  // Function to show pop-up menu on long press
  void showPopupMenu(
      BuildContext context,
      List<CometChatOption> options,
      GlobalKey widgetKey,
      ) {
    if(options.isEmpty) {
      return;
    }
    RelativeRect? position = WidgetPositionUtil.getWidgetPosition(context, widgetKey);
    showMenu(
      context: context,
      position: position ?? const RelativeRect.fromLTRB(0, 0, 0, 0),
      shadowColor: colorPalette?.background1 ?? Colors.transparent,
      color: colorPalette?.transparent ?? Colors.transparent,
      menuPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spacing?.radius2 ?? 0),
        side: BorderSide(
          color: colorPalette?.borderLight ?? Colors.transparent,
          width: 1,
        ),
      ),
      items: options.map((CometChatOption option) {
        return CustomPopupMenuItem<CometChatOption>(
            value: option,
            child: GetMenuView(
              option: option,
            ));
      }).toList(),
    ).then((selectedOption) {
      if (selectedOption != null) {
        selectedOption.onClick?.call();
      }
    });
  }
}
