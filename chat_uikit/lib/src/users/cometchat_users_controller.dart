import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../cometchat_chat_uikit.dart';

///[CometChatUsersController] is the view model for [CometChatUsers]
class CometChatUsersController
    extends CometChatSearchListController<User, String>
    with
        CometChatSelectable,
        UserListener,
        CometChatUserEventListener,
        ConnectionListener,
        WidgetsBindingObserver {
  //--------------------Constructor-----------------------
  CometChatUsersController({
    required this.usersBuilderProtocol,
    SelectionMode? mode,
    super.onError,
    this.usersStatusVisibility = true,
    super.onEmpty,
    super.onLoad,
  }) : super(builderProtocol: usersBuilderProtocol) {
    selectionMode = mode ?? SelectionMode.none;
    dateStamp = DateTime.now().microsecondsSinceEpoch.toString();
    userListenerID = "${dateStamp}user_listener";
    _uiUserListener = "${dateStamp}UI_user_listener";
  }

  //-------------------------Variable Declaration-----------------------------
  late UsersBuilderProtocol usersBuilderProtocol;
  late String dateStamp;
  late String userListenerID;
  late String _uiUserListener;
  bool? usersStatusVisibility;

  CometChatColorPalette? colorPalette;
  CometChatSpacing? spacing;
  CometChatTypography? typography;

  /// Cancellable retry timer for connection recovery
  Timer? _retryTimer;

  //-------------------------LifeCycle Methods-----------------------------
  @override
  void onInit() {
    CometChat.addUserListener(userListenerID, this);
    CometChatUserEvents.addUsersListener(_uiUserListener, this);
    CometChat.addConnectionListener(userListenerID, this);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.addObserver(this);
    }
    super.onInit();
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.removeObserver(this);
    }
    CometChat.removeUserListener(userListenerID);
    CometChatUserEvents.removeUsersListener(_uiUserListener);
    CometChat.removeConnectionListener(userListenerID);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && hasError && !isLoading) {
      resetUsers();
    }
  }

  //-------------------------Parent List overriding Methods-----------------------------
  @override
  bool match(User elementA, User elementB) {
    return elementA.uid == elementB.uid;
  }

  @override
  String getKey(User element) {
    return element.uid;
  }

  //------------------------SDK User Event Listeners------------------------------
  @override
  void onUserOffline(User user) {
    updateElement(user);
  }

  @override
  void onUserOnline(User user) {
    updateElement(user);
  }

  //------------------------UI User Event Listeners-----------------------------
  @override
  void ccUserBlocked(User user) {
    updateElement(user);
  }

  @override
  void ccUserUnblocked(User user) {
    updateElement(user);
  }

  @override
  void onConnected() {
    if (hasError) {
      resetUsers();
    } else if (!isLoading) {
      request = usersBuilderProtocol.getRequest();
      list = [];
      loadMoreElements();
    }
  }

  bool hideUserPresence(User user) {
    return usersStatusVisibility == false || !userIsNotBlocked(user);
  }

  bool userIsNotBlocked(User user) {
    return user.blockedByMe != true && user.hasBlockedMe != true;
  }

  void clearSelection() {
    selectionMap.clear();
    update();
  }

  dynamic resetUsers({int retryCount = 0}) {
    _retryTimer?.cancel();
    // reset values
    list.clear();
    error = null;
    hasError = false;
    hasMoreItems = true;
    isFetching = false;
    isLoading = true;
    request = usersBuilderProtocol.getRequest();
    update();
    loadMoreElements().then((_) {
      if (hasError && retryCount < 3) {
        _retryTimer = Timer(const Duration(seconds: 2), () {
          if (hasError) {
            resetUsers(retryCount: retryCount + 1);
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
    if (options.isEmpty) {
      return;
    }
    RelativeRect? position = WidgetPositionUtil.getWidgetPosition(
      context,
      widgetKey,
    );
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
          child: GetMenuView(option: option),
        );
      }).toList(),
    ).then((selectedOption) {
      if (selectedOption != null) {
        selectedOption.onClick?.call();
      }
    });
  }
}
