import 'dart:io';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_app/contacts/cometchat_contacts.dart';
import 'package:sample_app/create_group/cometchat_create_group.dart';
import 'package:sample_app/utils/join_protected_group_util.dart';
import 'package:sample_app/utils/page_manager.dart';
import 'call_log_details/cometchat_call_log_details.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:sample_app/utils/bool_singleton.dart';
import '../guard_screen.dart';

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
  late PageManager _pageController;
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  late String _dateString;

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
    final callStateController = CallStateController.instance;
    if (callStateController.isActiveCall.value == true) {
      IncomingCallOverlay.dismiss();
      return;
    } else if (callStateController.isActiveOutgoingCall.value == true) {
      IncomingCallOverlay.dismiss();
      return;
    } else if (callStateController.isActiveIncomingCall.value == true) {
      IncomingCallOverlay.dismiss();
      return;
    }
  }

  Future<void> _checkPermissions() async {
    PermissionStatus micStatus = await Permission.microphone.status;
    PermissionStatus camStatus = await Permission.camera.status;
    PermissionStatus notifyStatus = await Permission.notification.status;

    if (micStatus.isDenied) {
      await Permission.microphone.request();
      await Future.delayed(const Duration(seconds: 1));
    }

    if (camStatus.isDenied) {
      await Permission.camera.request();
      await Future.delayed(const Duration(seconds: 1));
    }

    if (notifyStatus.isDenied) {
      await Permission.notification.request();
    }

    if (micStatus.isPermanentlyDenied ||
        camStatus.isPermanentlyDenied ||
        notifyStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  bool isLoading = false;

  Future<void> logout() async {
    setState(() {
      isLoading = true;
    });

    try {
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
    } finally {
      setState(() {
        isLoading = false;
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
                              "v5.0.2",
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
}
