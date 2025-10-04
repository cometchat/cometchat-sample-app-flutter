import 'dart:developer' as developer;
import 'dart:io';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_app_push_notifications/contacts/cometchat_contacts.dart';
import 'package:sample_app_push_notifications/create_group/cometchat_create_group.dart';
import 'package:sample_app_push_notifications/notifications/services/android_notification_service/voip_notification_handler.dart';
import 'package:sample_app_push_notifications/utils/join_protected_group_util.dart';
import 'package:sample_app_push_notifications/utils/page_manager.dart';
import 'call_log_details/cometchat_call_log_details.dart';
import 'notifications/services/android_notification_service/local_notification_handler.dart';
import 'notifications/services/android_notification_service/notification_launch_handler.dart';
import 'notifications/services/iOS_notification_service/apns_services.dart';
import 'notifications/services/android_notification_service/firebase_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:sample_app_push_notifications/utils/bool_singleton.dart';
import '../guard_screen.dart';
import 'notifications/services/cometchat_service/cometchat_services.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyPageView();
  }
}

class MyPageView extends StatefulWidget {
  const MyPageView({super.key});

  @override
  State<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView>
    with
        WidgetsBindingObserver,
        CometChatUIEventListener,
        CallListener,
        CometChatCallEventListener {
  final FirebaseService notificationService = FirebaseService();
  final APNSService apnsServices = APNSService();
  late PageManager _pageController;
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  late String _dateString;

  Future<void>? _permissionsFuture;

  String conversationEventListenerId = "CWMConversationListener";
  final String _listenerId = "callingEventListener";

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    BoolSingleton().loadFromPrefs();
    _pageController = Get.find<PageManager>();

    _dateString = DateTime.now().millisecondsSinceEpoch.toString();

    CometChatUIEvents.addUiListener(
        _dateString + conversationEventListenerId, this);
    CometChat.addCallListener(_dateString + _listenerId, this);
    CometChatCallEvents.addCallEventsListener(_dateString + _listenerId, this);
    super.initState();
    if (Platform.isAndroid) {
      notificationService.init(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        VoipNotificationHandler.handleNativeCallIntent(context);
      });
    } else {
      apnsServices.init(context);
    }

    handleNotificationTap(context);
  }

  handleNotificationTap(context) {
    // Delay slightly to ensure context and Navigator are ready
    Future.delayed(const Duration(milliseconds: 300), () {
      final response = NotificationLaunchHandler.pendingNotificationResponse;
      if (response != null) {
        NotificationLaunchHandler.pendingNotificationResponse = null;

        LocalNotificationService.handleNotificationTap(
          response,
          isTerminatedState: true,
        );
      }
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (BoolSingleton().value == true) {
        IncomingCallOverlay.dismiss();
        BoolSingleton().value = false;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CometChatUIEvents.removeUiListener(
        _dateString + conversationEventListenerId);
    CometChat.removeCallListener(_dateString + _listenerId);
    CometChatCallEvents.removeCallEventsListener(_dateString + _listenerId);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    typography = CometChatThemeHelper.getTypography(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    _pageController
        .setKeyboardVisible(_pageController.isKeyboardVisible(context));
    _checkPermissions();
  }

  void _onItemTapped(int index) {
    _pageController.setSelectedIndex(index);
  }

  ///[onIncomingCallReceived] method is used to handle incoming call events.
  @override
  void onIncomingCallReceived(Call call) {
    User? user;
    if (call.callInitiator is User) {
      user = call.callInitiator as User;
    }

    if(user != null && user.uid == CometChatUIKit.loggedInUser?.uid){
      return;
    }
    final callStateController = CallStateController.instance;
    if (callStateController.isActiveCall.value == true) {
      IncomingCallOverlay.dismiss();
      if (call.sessionId != null) {
        rejectIncomingCall(call);
      }
      return;
    } else if (callStateController.isActiveOutgoingCall.value == true) {
      IncomingCallOverlay.dismiss();
      return;
    } else if (callStateController.isActiveIncomingCall.value == true) {
      IncomingCallOverlay.dismiss();
      return;
    }
  }

  Future<void> _checkPermissions() {
    // If already running, return the same future
    if (_permissionsFuture != null) return _permissionsFuture!;

    final completer = Completer<void>();
    _permissionsFuture = completer.future;

    () async {
      try {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.notification,
          Permission.microphone,
          Permission.camera,
        ].request();
      } catch (e) {
        debugPrint('Permission request error: $e');
      } finally {
        completer.complete();
        _permissionsFuture = null;
      }
    }();

    return _permissionsFuture!;
  }

  bool isLogoutLoading = false;

  Future<bool> isConnectedToNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    setState(() {
      isLogoutLoading = true;
    });

    final connected = await isConnectedToNetwork();

    if (!connected) {
      setState(() {
        isLogoutLoading = false;
      });
      var snackBar = SnackBar(
        backgroundColor: colorPalette.error,
        content: Text(
          "No internet connection",
          style: TextStyle(
            color: colorPalette.white,
            fontSize: typography.button?.medium?.fontSize,
            fontWeight: typography.button?.medium?.fontWeight,
            fontFamily: typography.button?.medium?.fontFamily,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    try {
      PNRegistry.unregisterPNService();
      await CometChatUIKit.logout(
        onSuccess: (p0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const GuardScreen(),
            ),
          );
        },
      );
    } catch (e) {
      // Handle any errors here
      print("Logout failed: $e");
      var snackBar = SnackBar(
        backgroundColor: colorPalette.error,
        content: Text(
          "Logout failed. Try again.",
          style: TextStyle(
            color: colorPalette.white,
            fontSize: typography.button?.medium?.fontSize,
            fontWeight: typography.button?.medium?.fontWeight,
            fontFamily: typography.button?.medium?.fontFamily,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        isLogoutLoading = false;
      });
    }
  }

  openCreateConversation(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CometChatContacts();
        },
      ),
    );
  }

  @override
  void openChat(
    User? user,
    Group? group,
  ) {
    _pageController.navigateToMessages(
      context: context,
      user: user,
      group: group,
    );
  }

  List<Widget> _getPages(context) {
    return [
      (_pageController.selectedIndex == 0)
          ? CometChatConversations(
              showBackButton: false,
              appBarOptions: [
                PopupMenuButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(spacing.radius2 ?? 0),
                    side: BorderSide(
                      color: colorPalette.borderLight ?? Colors.transparent,
                      width: 1,
                    ),
                  ),
                  color: colorPalette.background1,
                  elevation: 4,
                  menuPadding: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  icon: Padding(
                    padding: EdgeInsets.only(
                      left: spacing.padding3 ?? 0,
                      right: spacing.padding4 ?? 0,
                    ),
                    child: CometChatAvatar(
                      width: 40,
                      height: 40,
                      image: CometChatUIKit.loggedInUser?.avatar,
                      name: CometChatUIKit.loggedInUser?.name,
                    ),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case '/Create':
                        openCreateConversation(context);
                        break;
                      case '/logout':
                        logout();
                        break;
                      case '/name':
                        break;
                      case '/version':
                        break;
                    }
                  },
                  position: PopupMenuPosition.under,
                  enableFeedback: false,
                  itemBuilder: (BuildContext bc) {
                    return [
                      PopupMenuItem(
                        height: 44,
                        padding: EdgeInsets.all(spacing.padding4 ?? 0),
                        value: '/Create',
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: spacing.padding2 ?? 0),
                              child: Icon(
                                Icons.add_comment_outlined,
                                color: colorPalette.iconSecondary,
                                size: 24,
                              ),
                            ),
                            Text(
                              "Create Conversation",
                              style: TextStyle(
                                fontSize: typography.body?.regular?.fontSize,
                                fontFamily:
                                    typography.body?.regular?.fontFamily,
                                fontWeight:
                                    typography.body?.regular?.fontWeight,
                                color: colorPalette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        height: 44,
                        padding: EdgeInsets.all(spacing.padding4 ?? 0),
                        value: '/name',
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: spacing.padding2 ?? 0),
                              child: Icon(
                                Icons.account_circle_outlined,
                                color: colorPalette.iconSecondary,
                                size: 24,
                              ),
                            ),
                            Text(
                              CometChatUIKit.loggedInUser?.name ?? "",
                              style: TextStyle(
                                fontSize: typography.body?.regular?.fontSize,
                                fontFamily:
                                    typography.body?.regular?.fontFamily,
                                fontWeight:
                                    typography.body?.regular?.fontWeight,
                                color: colorPalette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        height: 44,
                        padding: EdgeInsets.all(spacing.padding4 ?? 0),
                        value: '/logout',
                        enabled: !isLogoutLoading,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(right: spacing.padding2 ?? 0),
                              child: Icon(
                                Icons.logout,
                                color: colorPalette.error,
                                size: 24,
                              ),
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: typography.body?.regular?.fontSize,
                                fontFamily:
                                    typography.body?.regular?.fontFamily,
                                fontWeight:
                                    typography.body?.regular?.fontWeight,
                                color: colorPalette.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        enabled: false,
                        height: 44,
                        padding: EdgeInsets.zero,
                        value: '/version',
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorPalette.borderLight ??
                                    Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(spacing.padding4 ?? 0),
                            child: Text(
                              "v5.1.1",
                              style: TextStyle(
                                fontSize: typography.body?.regular?.fontSize,
                                fontFamily:
                                    typography.body?.regular?.fontFamily,
                                fontWeight:
                                    typography.body?.regular?.fontWeight,
                                color: colorPalette.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                ),
              ],
              onItemTap: (conversation) {
                User? user;
                Group? group;
                if (conversation.conversationWith is User) {
                  user = conversation.conversationWith as User;
                } else {
                  group = conversation.conversationWith as Group;
                }
                _pageController.navigateToMessages(
                  context: context,
                  user: user,
                  group: group,
                );
              },
            )
          : SizedBox.shrink(),
      (_pageController.selectedIndex == 1)
          ? CometChatCallLogs(
              onItemClick: (callLog) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CometChatCallLogDetails(
                        callLog: callLog,
                      );
                    },
                  ),
                );
              },
            )
          : SizedBox.shrink(),
      (_pageController.selectedIndex == 2)
          ? CometChatUsers(
              showBackButton: false,
              onBack: () {},
              onItemTap: (context, user) {
                _pageController.navigateToMessages(
                  context: context,
                  user: user,
                );
              },
            )
          : SizedBox.shrink(),
      (_pageController.selectedIndex == 3)
          ? CometChatGroups(
              appBarOptions: (context) {
                return [
                  IconButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      showCreateGroup(
                        context: context,
                        colorPalette: colorPalette,
                        typography: typography,
                        spacing: spacing,
                      );
                    },
                    icon: Icon(
                      Icons.group_add,
                      color: colorPalette.iconHighlight,
                    ),
                  ),
                ];
              },
              showBackButton: false,
              onItemTap: (context, group) {
                FocusManager.instance.primaryFocus?.unfocus();
                JoinProtectedGroupUtils.onGroupItemTap(
                    context,
                    group,
                    colorPalette,
                    typography,
                    spacing,
                    _pageController.selectedIndex);
              },
            )
          : SizedBox.shrink(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (_pageController.keyboardVisible &&
            _pageController.navigateToMessageScreen) {
          return const SizedBox();
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: colorPalette.background1,
          body: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: IndexedStack(
              index: _pageController.selectedIndex,
              // controller: _pageController.pageController,
              // physics: const NeverScrollableScrollPhysics(),
              // onPageChanged: (index) {
              //   _pageController.setSelectedIndex(index);
              // },
              children: _getPages(context),
            ),
          ),
          bottomNavigationBar: Obx(
            () {
              return Container(
                padding: EdgeInsets.symmetric(vertical: spacing.padding ?? 0),
                decoration: BoxDecoration(
                  color: colorPalette.background1,
                  border: Border(
                    top: BorderSide(
                      color: colorPalette.borderLight ?? Colors.transparent,
                      width: 1,
                    ),
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashFactory:
                        NoSplash.splashFactory, // Remove ripple effect
                    highlightColor:
                        Colors.transparent, // Disable highlight feedback
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _pageController.selectedIndex,
                    elevation: 0,
                    onTap: _onItemTapped,
                    selectedItemColor: colorPalette.primary,
                    showUnselectedLabels: false,
                    unselectedItemColor: colorPalette.textSecondary,
                    selectedLabelStyle: TextStyle(
                      color: colorPalette.primary,
                      fontSize: typography.caption1?.medium?.fontSize,
                      fontFamily: typography.caption1?.medium?.fontFamily,
                      fontWeight: typography.caption1?.medium?.fontWeight,
                    ),
                    unselectedLabelStyle: TextStyle(
                      color: colorPalette.textSecondary,
                      fontSize: typography.caption1?.regular?.fontSize,
                      fontFamily: typography.caption1?.regular?.fontFamily,
                      fontWeight: typography.caption1?.regular?.fontWeight,
                    ),
                    iconSize: 32,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: colorPalette.background1,
                    enableFeedback: false,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.chat_outlined,
                          color: colorPalette.iconSecondary,
                        ),
                        activeIcon: Icon(
                          Icons.chat_rounded,
                          color: colorPalette.primary,
                        ),
                        label: 'Chats',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.call_outlined,
                          color: colorPalette.iconSecondary,
                        ),
                        activeIcon: Icon(
                          Icons.call_rounded,
                          color: colorPalette.primary,
                        ),
                        label: 'Calls',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline_rounded,
                            color: colorPalette.iconSecondary),
                        activeIcon: Icon(
                          Icons.person_rounded,
                          color: colorPalette.primary,
                        ),
                        label: 'Users',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.people_alt_outlined,
                          color: colorPalette.iconSecondary,
                        ),
                        activeIcon: Icon(
                          Icons.people_alt_rounded,
                          color: colorPalette.primary,
                        ),
                        label: 'Groups',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  rejectIncomingCall(Call call) {
    CometChatUIKitCalls.rejectCall(call.sessionId!, CallStatusConstants.busy,
        onSuccess: (Call call) {
      call.category = MessageCategoryConstants.call;
      CometChatCallEvents.ccCallRejected(call);
      developer.log('incoming call was cancelled');
    }, onError: (e) {
      developer.log("Unable to end call from incoming call screen");
    });
  }
}
