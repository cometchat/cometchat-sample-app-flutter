import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;

import 'cometchat_contacts_controller.dart';

class CometChatContacts extends StatefulWidget {
  const CometChatContacts({
    super.key,
  });

  @override
  State<CometChatContacts> createState() => _CometChatContactsState();
}

class _CometChatContactsState extends State<CometChatContacts>
    with SingleTickerProviderStateMixin {
  late CometChatContactsController cometChatStartConversationController;
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  @override
  void initState() {
    super.initState();
    cometChatStartConversationController = CometChatContactsController();
    cometChatStartConversationController.tabController =
        TabController(length: 2, vsync: this);
    cometChatStartConversationController.tabController.addListener(
        cometChatStartConversationController.tabControllerListener);
  }

  @override
  void didChangeDependencies() {
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    typography = CometChatThemeHelper.getTypography(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    cometChatStartConversationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: cometChatStartConversationController,
        builder: (CometChatContactsController value) {
          value.context = context;
          return CometChatListBase(
            title: cc.Translations.of(context).newChat,
            showBackButton: true,
            onBack: () {
              Navigator.pop(context);
            },
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
                  padding: EdgeInsets.all(
                    spacing.padding2 ?? 0,
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: colorPalette.background3,
                      border: Border.all(
                        color: colorPalette.borderLight ?? Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(
                        spacing.radiusMax ?? 0,
                      ),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          spacing.radius6 ?? 0,
                        ), // Creates border
                        color: colorPalette.background1,
                        border: Border.all(
                          color: colorPalette.borderLight ?? Colors.transparent,
                        ),
                      ),
                      controller: value.tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: TextStyle(
                        color: colorPalette.iconHighlight,
                        fontSize: typography.button?.bold?.fontSize,
                        fontWeight: typography.heading1?.bold?.fontWeight,
                        fontFamily: typography.heading1?.bold?.fontFamily,
                      ),
                      unselectedLabelStyle: TextStyle(
                        color: colorPalette.textSecondary,
                        fontSize: typography.button?.bold?.fontSize,
                        fontWeight: typography.heading1?.bold?.fontWeight,
                        fontFamily: typography.heading1?.bold?.fontFamily,
                      ),
                      tabs: [
                        Tab(
                          text: cc.Translations.of(context).users,
                        ),
                        Tab(
                          text: cc.Translations.of(context).groups,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: value.currentView[value.tabController.index],
                ),
              ],
            ),
          );
        });
  }
}
