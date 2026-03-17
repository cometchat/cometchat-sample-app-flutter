import 'dart:async';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CometChatCallLogsController
    extends CometChatListController<CallLog, String>
    with ConnectionListener, WidgetsBindingObserver {
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

  final String _connectionListenerId =
      'callLogs_connection_${DateTime.now().millisecondsSinceEpoch}';

  Timer? _retryTimer;

  @override
  void onInit() {
    CometChat.addConnectionListener(_connectionListenerId, this);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.addObserver(this);
    }
    super.onInit();
    _initializeLoggedInUser();
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.removeObserver(this);
    }
    CometChat.removeConnectionListener(_connectionListenerId);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && hasError && !isLoading) {
      resetCallLogs();
    }
  }

  @override
  void onConnected() {
    if (hasError) {
      resetCallLogs();
    } else if (!isLoading) {
      list = [];
      request = callLogsBuilderProtocol.getRequest();
      loadMoreElements();
    }
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
          onEmpty?.call();
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
          onLoad?.call(list);
        }
        update();
      }, onError: (CometChatCallsException e) {
        onError?.call(e);
        hasError = true;
        isLoading = false;
        if (kDebugMode) {
          debugPrint("Error -> ${e.details}");
        }
        if (onError != null) {
          onError!(e);
        } else {
          error = e;
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

  resetCallLogs({int retryCount = 0}) {
    _retryTimer?.cancel();
    // reset values
    list.clear();
    groupedEntries.clear();
    error = null;
    hasError = false;
    hasMoreItems = true;
    isLoading = true;
    request = callLogsBuilderProtocol.getRequest();
    update();
    loadMoreElements().then((_) {
      if (hasError && retryCount < 3) {
        _retryTimer = Timer(const Duration(seconds: 2), () {
          if (hasError) {
            resetCallLogs(retryCount: retryCount + 1);
          }
        });
      }
    });
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
