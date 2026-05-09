import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:ai_sample_app/screens/ai_messages_screen.dart';
import 'package:ai_sample_app/screens/login_screen.dart';

/// Home screen for the AI sample app.
/// Shows only AI agents using CometChatUsers filtered by AIConstants.aiRole.
class AiAgentsScreen extends StatefulWidget {
  const AiAgentsScreen({super.key});

  @override
  State<AiAgentsScreen> createState() => _AiAgentsScreenState();
}

class _AiAgentsScreenState extends State<AiAgentsScreen> {
  late CometChatColorPalette _colorPalette;
  late CometChatTypography _typography;
  late CometChatSpacing _spacing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    _typography = CometChatThemeHelper.getTypography(context);
    _spacing = CometChatThemeHelper.getSpacing(context);
  }

  @override
  Widget build(BuildContext context) {
    return CometChatUsers(
      title: cc.Translations.of(context).agents,
      showBackButton: false,
      usersRequestBuilder: UsersRequestBuilder()
        ..roles = [AIConstants.aiRole],
      onItemTap: (ctx, user) {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => AiMessagesScreen(user: user),
          ),
        );
      },
      appBarOptions: (context) => [
        _buildProfileMenu(),
      ],
    );
  }

  Widget _buildProfileMenu() {
    final loggedInUser = CometChatUIKit.loggedInUser;

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_spacing.radius2 ?? 8),
        side: BorderSide(
          color: _colorPalette.borderLight ?? Colors.transparent,
          width: 1,
        ),
      ),
      color: _colorPalette.background1,
      elevation: 4,
      menuPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      icon: Padding(
        padding: EdgeInsets.only(
          left: _spacing.padding3 ?? 0,
          right: _spacing.padding4 ?? 0,
        ),
        child: CometChatAvatar(
          width: 40,
          height: 40,
          image: loggedInUser?.avatar ?? '',
          name: loggedInUser?.name ?? '',
        ),
      ),
      onSelected: (value) async {
        if (value == '/logout') {
          await CometChatUIKit.logout(
            onSuccess: (_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            onError: (e) {
              debugPrint('Logout error: ${e.message}');
            },
          );
        }
      },
      position: PopupMenuPosition.under,
      enableFeedback: false,
      itemBuilder: (BuildContext bc) => [
        PopupMenuItem(
          height: 44,
          padding: EdgeInsets.all(_spacing.padding4 ?? 16),
          enabled: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: _spacing.padding2 ?? 8),
                child: Icon(
                  Icons.account_circle_outlined,
                  color: _colorPalette.iconSecondary,
                  size: 24,
                ),
              ),
              Text(
                loggedInUser?.name ?? '',
                style: TextStyle(
                  fontSize: _typography.body?.regular?.fontSize,
                  fontFamily: _typography.body?.regular?.fontFamily,
                  fontWeight: _typography.body?.regular?.fontWeight,
                  color: _colorPalette.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          height: 44,
          padding: EdgeInsets.all(_spacing.padding4 ?? 16),
          value: '/logout',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: _spacing.padding2 ?? 8),
                child: Icon(
                  Icons.logout,
                  color: _colorPalette.error,
                  size: 24,
                ),
              ),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: _typography.body?.regular?.fontSize,
                  fontFamily: _typography.body?.regular?.fontFamily,
                  fontWeight: _typography.body?.regular?.fontWeight,
                  color: _colorPalette.error,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          height: 44,
          padding: EdgeInsets.all(_spacing.padding4 ?? 16),
          enabled: false,
          child: Text(
            'v6.0.0-beta3',
            style: TextStyle(
              fontSize: _typography.caption1?.regular?.fontSize,
              fontFamily: _typography.caption1?.regular?.fontFamily,
              fontWeight: _typography.caption1?.regular?.fontWeight,
              color: _colorPalette.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}
