import 'package:flutter/material.dart';

import '../../../cometchat_chat_uikit.dart';

///[CometChatUsersController] is the view model for [CometChatUsers]
class CometChatUsersController
    extends CometChatSearchListController<User, String>
    with
        CometChatSelectable,
        UserListener,
        CometChatUserEventListener,
        ConnectionListener {
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

  // TODO: Implement the retry logic later.
  // Retry configuration
  final int maxRetries = 3;
  final Duration retryDelay = const Duration(seconds: 3);
  int _currentRetryCount = 0;

  CometChatColorPalette? colorPalette;
  CometChatSpacing? spacing;
  CometChatTypography? typography;

  //-------------------------LifeCycle Methods-----------------------------
  @override
  void onInit() {
    CometChat.addUserListener(userListenerID, this);
    CometChatUserEvents.addUsersListener(_uiUserListener, this);
    CometChat.addConnectionListener(userListenerID, this);
    super.onInit();
  }

  @override
  void onClose() {
    CometChat.removeUserListener(userListenerID);
    CometChatUserEvents.removeUsersListener(_uiUserListener);
    CometChat.removeConnectionListener(userListenerID);
    super.onClose();
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
    if (!isLoading) {
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

  // TODO: Implement the retry logic later.
  // Method to load groups
  void retryUsers() async {
    try {
      request = usersBuilderProtocol.getRequest();
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
        retryUsers();
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
