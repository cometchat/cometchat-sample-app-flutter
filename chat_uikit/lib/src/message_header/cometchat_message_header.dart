import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../cometchat_chat_uikit.dart';
import '../../../cometchat_chat_uikit.dart' as cc;

///[CometChatMessageHeader] is a widget which shows [user]/[group] details using [CometChatListItem]
///if its being shown for an [User] then the name of the user will be in the [title] of [CometChatListItem] and their online/offline status will be in the [subtitleView]
///if its being shown for an [Group] then the name of the group will be in the [title] of [CometChatListItem] and their member count will be in the [subtitleView]
///
/// ```dart
/// CometChatMessageHeader(
///   user: <user>,
///   messageHeaderStyle: MessageHeaderStyle(),
/// );
///
/// ```
/// For Group
/// ```dart
/// CometChatMessageHeader(
///   group: <group>,
///  messageHeaderStyle: MessageHeaderStyle(),
/// );
///
/// ```
class CometChatMessageHeader extends StatefulWidget
    implements PreferredSizeWidget {
  const CometChatMessageHeader({
    super.key,
    this.backButton,
    this.messageHeaderStyle,
    this.group,
    this.user,
    this.trailingView,
    this.listItemView,
    this.showBackButton = true,
    this.subtitleView,
    this.listItemStyle,
    this.onBack,
    this.avatarHeight,
    this.avatarWidth,
    this.height,
    this.padding,
    this.hideVideoCallButton,
    this.hideVoiceCallButton,
    this.titleView,
    this.leadingStateView,
    this.auxiliaryButtonView,
    this.usersStatusVisibility = true,
    this.dateTimeFormatterCallback,
  })  : assert(user != null || group != null,
            "One of user or group should be passed"),
        assert(user == null || group == null,
            "Only one of user or group should be passed");

  ///[backButton] used to set back button widget
  final WidgetBuilder? backButton;

  ///[subtitleView] to set subtitle view
  /// ```dart
  /// CometChatMessageHeader(
  ///    group: group,
  ///    subtitleView: (Group? group, User? user,BuildContext context) {
  ///                                 return Text("${group?.guid}");
  ///        },
  ///   )
  ///   ```
  final Widget? Function(Group? group, User? user, BuildContext context)?
      subtitleView;

  /// set [User] object, one is mandatory either [user] or [group]
  final User? user;

  ///set [Group] object, one is mandatory either [user] or [group]
  final Group? group;

  ///[listItemView] set custom view for listItem
  final Widget Function(Group? group, User? user, BuildContext context)?
      listItemView;

  ///[CometChatMessageHeaderStyle] set styling props for message header
  ///
  /// ```dart
  ///CometChatMessageHeader(
  ///   group: group,
  ///   messageHeaderStyle: _headerStyle,
  ///   subtitleView: (Group? group, User? user,BuildContext context) {
  ///       return Text("${group?.guid}");
  ///       },
  /// ),
  /// ```
  final CometChatMessageHeaderStyle? messageHeaderStyle;

  ///[showBackButton] toggle visibility for back button
  final bool? showBackButton;

  ///[listItemStyle] style for every list item
  final ListItemStyle? listItemStyle;

  ///[trailingView] set appbar options
  ///
  /// ```dart
  ///CometChatMessageHeader(
  /// 	 group: group,
  ///    appBarOptions: [
  ///
  ///       (User? user, Group? group,BuildContext context) {
  ///            return Icon(Icons.group);
  ///              },
  ///
  ///      (User? user, Group? group,BuildContext context) {
  ///                     return Icon(Icons.info);
  ///                     }
  ///         ],
  ///  ),
  ///  ```
  final List<Widget>? Function(User? user, Group? group, BuildContext context)?
      trailingView;

  ///[onBack] callback triggered on closing this screen
  final VoidCallback? onBack;

  ///[avatarHeight] set height for avatar
  final double? avatarHeight;

  ///[avatarWidth] set width for avatar
  final double? avatarWidth;

  ///[height] set height for message header
  final double? height;

  ///[padding] set padding for message header
  final EdgeInsetsGeometry? padding;

  ///[hideVideoCallButton] is a [bool] that can be used to hide/display video call button
  final bool? hideVideoCallButton;

  ///[hideVoiceCallButton] is a [bool] that can be used to hide/display voice call button
  final bool? hideVoiceCallButton;

  ///[leadingStateView] to set leading View
  final Widget? Function(Group? group, User? user, BuildContext context)?
      leadingStateView;

  ///[titleView] to set to set titleView view
  final Widget? Function(Group? group, User? user, BuildContext context)?
      titleView;

  ///[auxiliaryButtonView] to set auxiliary view
  final Widget? Function(Group? group, User? user, BuildContext context)?
      auxiliaryButtonView;

  ///[usersStatusVisibility] controls visibility of status indicator shown if a user is online
  final bool? usersStatusVisibility;

  /// [dateTimeFormatterCallback] is a callback that can be used to format the date and time
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  @override
  State<CometChatMessageHeader> createState() => _CometChatMessageHeaderState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize {
    return Size.fromHeight(height ?? 65);
  }
}

class _CometChatMessageHeaderState extends State<CometChatMessageHeader> {
  late CometChatMessageHeaderController controller;
  late CometChatMessageHeaderStyle headerStyle;
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  late CometChatStatusIndicatorStyle statusIndicatorStyle;

  @override
  void didChangeDependencies() {
    controller = CometChatMessageHeaderController(
      userObject: widget.user,
      groupObject: widget.group,
      usersStatusVisibility: widget.usersStatusVisibility,
      dateTimeFormatterCallback: widget.dateTimeFormatterCallback,
    );
    headerStyle =
        CometChatThemeHelper.getTheme<CometChatMessageHeaderStyle>(
                context: context, defaultTheme: CometChatMessageHeaderStyle.of)
            .merge(widget.messageHeaderStyle);
    statusIndicatorStyle = CometChatThemeHelper.getTheme<CometChatStatusIndicatorStyle>(
        context: context, defaultTheme: CometChatStatusIndicatorStyle.of)
        .merge(headerStyle.statusIndicatorStyle);
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: widget.height,
        width: MediaQuery.of(context).size.width,
        padding: widget.padding ?? EdgeInsets.only(left: spacing.padding4 ?? 0),
        decoration: BoxDecoration(
            color:
                headerStyle.backgroundColor ?? colorPalette.background1,
            border: headerStyle.border,
            borderRadius:
                headerStyle.borderRadius ?? BorderRadius.circular(0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getBackButton(context, headerStyle, colorPalette),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: spacing.padding4 ?? 0),
                child: _getBody(controller, context, headerStyle,
                    colorPalette, typography, spacing),
              ),
            )
          ],
        ),
      ),
    );
  }

  // back button view
  Widget getBackButton(BuildContext context, CometChatMessageHeaderStyle style,
      CometChatColorPalette colorPalette) {
    if (widget.showBackButton == true) {
      if (widget.backButton != null) {
        return widget.backButton!(context);
      }
      Widget backIcon;
      backIcon = GestureDetector(
        onTap: widget.onBack ??
            () {
              Navigator.pop(context);
            },
        child: style.backIcon ??
            Image.asset(
              AssetConstants.back,
              package: UIConstants.packageName,
              color: style.backIconColor ?? colorPalette.iconPrimary,
            ),
      );

      return backIcon;
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
  }

  // typing indicator view
  Widget _getTypingIndicator(
      BuildContext context,
      CometChatMessageHeaderController controller,
      TextStyle? typingIndicatorTextStyle,
      CometChatTypography typography,
      Color? color) {
    String text;
    if (controller.userObject != null) {
      text = cc.Translations.of(context).typing;
    } else {
      text =
          "${controller.typingUser?.name ?? ''}: ${cc.Translations.of(context).typing}";
    }
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: typography.caption1?.regular?.fontSize,
        color: color,
        fontWeight: typography.caption1?.regular?.fontWeight,
      ).merge(typingIndicatorTextStyle),
    );
  }

  // subtitle view
  Widget? _getSubtitleView(
      BuildContext context,
      CometChatMessageHeaderController controller,
      CometChatMessageHeaderStyle style,
      CometChatColorPalette colorPalette,
      CometChatTypography typography) {
    Widget? subtitle;
    final subtitleStyle = TextStyle(
      color: style.subtitleTextColor ??
          style.subtitleTextStyle?.color ??
          colorPalette.textSecondary,
      fontSize: style.subtitleTextStyle?.fontSize ??
          typography.caption1?.regular?.fontSize,
      fontFamily: style.subtitleTextStyle?.fontFamily ??
          typography.caption1?.regular?.fontFamily,
      fontWeight: style.subtitleTextStyle?.fontWeight ??
          typography.caption1?.regular?.fontWeight,
    );

    if (controller.isTyping == true) {
      subtitle = _getTypingIndicator(context, controller,
          style.typingIndicatorTextStyle, typography, colorPalette.primary);
    } else if (widget.subtitleView != null) {
      subtitle = widget.subtitleView!(
          controller.groupObject, controller.userObject, context);
    } else if (controller.userObject != null) {
      if (controller.usersStatusVisibility == true || !controller.userIsNotBlocked(controller.userObject!)) {
        subtitle = Text(
          controller.userObject?.status == UserStatusConstants.online
              ? cc.Translations.of(context).online
              : controller.getUserActivityStatus(context),
          overflow: TextOverflow.ellipsis,
          style: subtitleStyle,
        );
      } else {
        subtitle = null;
      }
    } else {
      subtitle = Text(
        '${controller.membersCount ?? 0} ${ controller.membersCount == 1 ? cc.Translations.of(context).member : cc.Translations.of(context).members }',
        style: subtitleStyle,
      );
    }
    return subtitle;
  }

  // title view
  Widget? _getTitleView(
      BuildContext context, CometChatMessageHeaderController controller) {
    if (widget.titleView != null) {
      return widget.titleView!(
          controller.groupObject, controller.userObject, context);
    }
    return null;
  }

  // leading view
  Widget? _getLeadingView(
      BuildContext context, CometChatMessageHeaderController controller) {
    if (widget.leadingStateView != null) {
      return widget.leadingStateView!(
          controller.groupObject, controller.userObject, context);
    }
    return null;
  }

  // auxiliary header view
  Widget? _getAuxiliaryButtonView(
      BuildContext context,
      CometChatMessageHeaderController controller,
      CometChatMessageHeaderStyle style,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    if (widget.auxiliaryButtonView != null) {
      return widget.auxiliaryButtonView!(
        controller.groupObject,
        controller.userObject,
        context,
      );
    } else {
      return CometChatUIKit.getDataSource().getAuxiliaryHeaderMenu(
        context,
        widget.user,
        widget.group,
        additionalConfigurations: AdditionalConfigurations(
          callButtonsStyle: style.callButtonsStyle,
          hideVideoCallButton: widget.hideVideoCallButton,
          hideVoiceCallButton: widget.hideVoiceCallButton,
        ),
      );
    }
  }

  // trailing view
  List<Widget>? _getTrailingView(
    BuildContext context,
    CometChatMessageHeaderController controller,
    CometChatMessageHeaderStyle style,
  ) {
    if (widget.trailingView != null) {
      return widget.trailingView!(
        controller.userObject,
        controller.groupObject,
        context,
      );
    }
    return null;
  }

  // body view
  _getBody(
      CometChatMessageHeaderController controller,
      BuildContext context,
      CometChatMessageHeaderStyle style,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    return GetBuilder(
        init: controller,
        tag: controller.tag,
        dispose: (GetBuilderState<CometChatMessageHeaderController> state) =>
            Get.delete<CometChatMessageHeaderController>(
                tag: state.controller?.tag),
        builder: (CometChatMessageHeaderController value) {
          return _getListItem(
              value, context, style, colorPalette, typography, spacing);
        });
  }

  Widget _getListItem(
      CometChatMessageHeaderController controller,
      BuildContext context,
      CometChatMessageHeaderStyle style,
      CometChatColorPalette colorPalette,
      CometChatTypography typography,
      CometChatSpacing spacing) {
    if (widget.listItemView != null) {
      return widget.listItemView!(widget.group, widget.user, context);
    }

    String? avatarName;
    String? avatarUrl;
    String? title;
    Color? statusIndicatorColor;
    Widget? icon;
    Widget? leadingStateView;
    Widget? titleView;
    Widget? subtitleView;
    Widget? auxiliaryHeaderMenu;
    Widget? tailView;

    if (widget.user != null) {
      avatarName = controller.userObject?.name;
      avatarUrl = controller.userObject?.avatar;
      title = controller.userObject?.name;
    } else {
      avatarName = controller.groupObject?.name;
      avatarUrl = controller.groupObject?.icon;
      title = controller.groupObject?.name;
    }
    StatusIndicatorUtils util =
        StatusIndicatorUtils.getStatusIndicatorFromParams(
            context: context,
            user: controller.userObject,
            group: controller.groupObject,
            privateGroupIcon: style.privateGroupBadgeIcon,
            protectedGroupIcon: style.passwordProtectedGroupBadgeIcon,
            onlineStatusIndicatorColor:
                statusIndicatorStyle.backgroundColor ?? style.onlineStatusColor ?? colorPalette.success,
            usersStatusVisibility: controller.hideUserPresence(),
            privateGroupIconBackground: style.privateGroupBadgeIconColor,
            protectedGroupIconBackground:
                style.passwordProtectedGroupBadgeIconColor);

    statusIndicatorColor = util.statusIndicatorColor;
    List<Widget>? tailWidgetList = [];
    icon = util.icon;
    leadingStateView = _getLeadingView(context, controller);
    titleView = _getTitleView(context, controller);
    subtitleView =
        _getSubtitleView(context, controller, style, colorPalette, typography);

    auxiliaryHeaderMenu = _getAuxiliaryButtonView(
      context,
      controller,
      style,
      colorPalette,
      typography,
      spacing,
    );
    if (auxiliaryHeaderMenu != null) {
      tailWidgetList.add(auxiliaryHeaderMenu);
    }

    if (widget.trailingView != null) {
      var temp = _getTrailingView(context, controller, style);

      if (temp != null) {
        tailWidgetList.addAll(temp);
      }
    }

    if (tailWidgetList.isNotEmpty) {
      tailView = Padding(
        padding: EdgeInsets.only(
            left: spacing.padding3 ?? 0,
            top: spacing.padding2 ?? 0,
            bottom: spacing.padding2 ?? 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: tailWidgetList,
        ),
      );
    }

    return GestureDetector(
      onTap: () {},
      child: CometChatListItem(
        avatarName: avatarName,
        avatarURL: avatarUrl,
        avatarWidth: widget.avatarWidth ?? 40,
        avatarHeight: widget.avatarHeight ?? 40,
        title: title,
        subtitleView: subtitleView,
        titlePadding: EdgeInsets.only(left: spacing.padding2 ?? 0),
        avatarStyle: CometChatAvatarStyle(
          backgroundColor:
              widget.group != null ? style.groupIconBackgroundColor : null,
        ).merge(style.avatarStyle),
        statusIndicatorColor: statusIndicatorColor,
        statusIndicatorIcon: icon,
        statusIndicatorStyle: CometChatStatusIndicatorStyle(
          border: Border.all(
            width: spacing.spacing ?? 0,
            color: colorPalette.background1 ?? Colors.white,
          ),
          backgroundColor: colorPalette.success,
        ).merge(statusIndicatorStyle),
        hideSeparator: true,
        tailView: tailView,
        titleView: titleView,
        leadingStateView: leadingStateView,
        style: widget.listItemStyle ??
            ListItemStyle(
                background: Colors.transparent,
                height: 56,
                titleStyle: TextStyle(
                  fontSize: style.titleTextStyle?.fontSize ??
                      typography.heading4?.medium?.fontSize,
                  fontWeight: style.titleTextStyle?.fontWeight ??
                      typography.heading4?.medium?.fontWeight,
                  fontFamily: style.titleTextStyle?.fontFamily ??
                      typography.heading4?.medium?.fontFamily,
                  color: style.titleTextColor ??
                      style.titleTextStyle?.color ??
                      colorPalette.textPrimary,
                  overflow: TextOverflow.ellipsis,
                )),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(widget.height ?? 65);
}
