import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'messages_screen.dart';
import 'join_protected_group_screen.dart';

/// Contacts / New Chat picker — two tabs: Users and Groups.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onUserTap(BuildContext ctx, User user) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'messages'),
        builder: (_) => MessagesScreen(user: user),
      ),
    );
  }

  void _onGroupTap(BuildContext ctx, Group group) {
    if (!group.hasJoined && group.type == GroupTypeConstants.password) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JoinProtectedGroupScreen(group: group),
        ),
      );
      return;
    }
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'messages'),
        builder: (_) => MessagesScreen(group: group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    return CometChatListBase(
      title: cc.Translations.of(context).newChat,
      showBackButton: true,
      onBack: () => Navigator.pop(context),
      style: ListBaseStyle(
        background: colorPalette.background1,
        titleStyle: TextStyle(
          color: colorPalette.textPrimary,
          fontSize: typography.heading1?.bold?.fontSize,
          fontWeight: typography.heading1?.bold?.fontWeight,
          fontFamily: typography.heading1?.bold?.fontFamily,
        ),
        backIconTint: colorPalette.iconPrimary,
      ),
      hideSearch: true,
      container: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(spacing.padding2 ?? 0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: colorPalette.background3,
                borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: colorPalette.background1,
                  borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                ),
                labelStyle: TextStyle(
                  color: colorPalette.textPrimary,
                  fontSize: typography.heading4?.medium?.fontSize,
                  fontWeight: typography.heading4?.medium?.fontWeight,
                  fontFamily: typography.heading4?.medium?.fontFamily,
                ),
                unselectedLabelStyle: TextStyle(
                  color: colorPalette.textSecondary,
                  fontSize: typography.heading4?.medium?.fontSize,
                  fontWeight: typography.heading4?.medium?.fontWeight,
                  fontFamily: typography.heading4?.medium?.fontFamily,
                ),
                tabs: [
                  Tab(text: cc.Translations.of(context).users),
                  Tab(text: cc.Translations.of(context).groups),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CometChatUsers(
                  hideAppbar: true,
                  onItemTap: (ctx, user) => _onUserTap(ctx, user),
                ),
                CometChatGroups(
                  hideAppbar: true,
                  onItemTap: (ctx, group) => _onGroupTap(ctx, group),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
