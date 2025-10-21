import 'dart:io';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:flutter/material.dart';
import 'package:ai_sample_app/utils/page_manager.dart';
import 'dart:async';
import '../guard_screen.dart';

class CometChatAIAssistantChat extends StatefulWidget {
  const CometChatAIAssistantChat({super.key});

  @override
  State<CometChatAIAssistantChat> createState() => _CometChatAIAssistantChatState();
}

class _CometChatAIAssistantChatState extends State<CometChatAIAssistantChat> {
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  bool isLogoutLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    typography = CometChatThemeHelper.getTypography(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  Future<bool> isConnectedToNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    UsersRequestBuilder customUserRequestBuilder = UsersRequestBuilder()
      ..roles = [AIConstants.aiRole];

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
              cc.Translations.of(context).noInternetConnection,
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
        debugPrint("Logout failed: $e");
        var snackBar = SnackBar(
          backgroundColor: colorPalette.error,
          content: Text(
            cc.Translations.of(context).logoutFailedTryAgain,
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

    return CometChatUsers(
      title: cc.Translations.of(context).agents,
      usersStyle: CometChatUsersStyle(
        titleTextStyle: TextStyle(
          fontSize: typography.heading1?.bold?.fontSize,
          fontFamily: typography.heading1?.bold?.fontFamily,
          fontWeight: typography.heading1?.bold?.fontWeight,
          color: colorPalette.textPrimary,
        )
      ),
      appBarOptions: (context) {
        return [
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
                  value: '/name',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: spacing.padding2 ?? 0),
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
                          fontFamily: typography.body?.regular?.fontFamily,
                          fontWeight: typography.body?.regular?.fontWeight,
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
                        padding: EdgeInsets.only(right: spacing.padding2 ?? 0),
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
                          fontFamily: typography.body?.regular?.fontFamily,
                          fontWeight: typography.body?.regular?.fontWeight,
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
                          color: colorPalette.borderLight ?? Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(spacing.padding4 ?? 0),
                      child: Text(
                        "V5.2.1",
                        style: TextStyle(
                          fontSize: typography.body?.regular?.fontSize,
                          fontFamily: typography.body?.regular?.fontFamily,
                          fontWeight: typography.body?.regular?.fontWeight,
                          color: colorPalette.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
          ),
        ];
      },
      showBackButton: false,
      usersRequestBuilder: customUserRequestBuilder,
      onItemTap: (context, user) {
        PageManager().navigateToMessages(
          context: context,
          user: user,
        );
      },
    );
  }
}
