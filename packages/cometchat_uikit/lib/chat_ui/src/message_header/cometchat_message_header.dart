import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cometchat_chat_uikit.dart';
import '../../../cometchat_chat_uikit.dart' as cc;
import '../../../call_ui/src/call_buttons/cometchat_call_buttons.dart';
import 'bloc/message_header_bloc.dart';
import 'bloc/message_header_event.dart';
import 'bloc/message_header_state.dart';
import 'package:intl/intl.dart';

/// [CometChatMessageHeader] is a widget which shows [user]/[group] details using [CometChatListItem]
/// if its being shown for an [User] then the name of the user will be in the [CometChatListItem.title] of [CometChatListItem] and their online/offline status will be in the [subtitleView]
/// if its being shown for an [Group] then the name of the group will be in the [CometChatListItem.title] of [CometChatListItem] and their member count will be in the [subtitleView]
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
    this.hideNewChatButton,
    this.hideChatHistoryButton,
    this.chatHistoryButtonClick,
    this.newChatButtonClick,
    this.newChatIcon,
    this.chatHistoryIcon,
  }) : assert(
         user != null || group != null,
         "One of user or group should be passed",
       ),
       assert(
         user == null || group == null,
         "Only one of user or group should be passed",
       );

  /// [backButton] used to set back button widget
  final WidgetBuilder? backButton;

  /// [subtitleView] to set subtitle view
  final Widget? Function(Group? group, User? user, BuildContext context)?
  subtitleView;

  /// set [User] object, one is mandatory either [user] or [group]
  final User? user;

  /// set [Group] object, one is mandatory either [user] or [group]
  final Group? group;

  /// [listItemView] set custom view for listItem
  final Widget Function(Group? group, User? user, BuildContext context)?
  listItemView;

  /// [CometChatMessageHeaderStyle] set styling props for message header
  final CometChatMessageHeaderStyle? messageHeaderStyle;

  /// [showBackButton] toggle visibility for back button
  final bool? showBackButton;

  /// [listItemStyle] style for every list item
  final ListItemStyle? listItemStyle;

  /// [trailingView] set appbar options
  final List<Widget>? Function(User? user, Group? group, BuildContext context)?
  trailingView;

  /// [onBack] callback triggered on closing this screen
  final VoidCallback? onBack;

  /// [avatarHeight] set height for avatar
  final double? avatarHeight;

  /// [avatarWidth] set width for avatar
  final double? avatarWidth;

  /// [height] set height for message header
  final double? height;

  /// [padding] set padding for message header
  final EdgeInsetsGeometry? padding;

  /// [hideVideoCallButton] is a [bool] that can be used to hide/display video call button
  final bool? hideVideoCallButton;

  /// [hideVoiceCallButton] is a [bool] that can be used to hide/display voice call button
  final bool? hideVoiceCallButton;

  /// [leadingStateView] to set leading View
  final Widget? Function(Group? group, User? user, BuildContext context)?
  leadingStateView;

  /// [titleView] to set to set titleView view
  final Widget? Function(Group? group, User? user, BuildContext context)?
  titleView;

  /// [auxiliaryButtonView] to set auxiliary view
  final Widget? Function(Group? group, User? user, BuildContext context)?
  auxiliaryButtonView;

  /// [usersStatusVisibility] controls visibility of status indicator shown if a user is online
  final bool? usersStatusVisibility;

  /// [dateTimeFormatterCallback] is a callback that can be used to format the date and time
  final DateTimeFormatterCallback? dateTimeFormatterCallback;

  /// [hideChatHistoryButton] is a [bool] that can be used to hide/display chat history button
  final bool? hideChatHistoryButton;

  /// [hideNewChatButton] is a [bool] that can be used to hide/display chat button button
  final bool? hideNewChatButton;

  /// [newChatButtonClick] callback triggered on new chat button click
  final VoidCallback? newChatButtonClick;

  /// [chatHistoryButtonClick] callback triggered on chat history button click
  final VoidCallback? chatHistoryButtonClick;

  /// [newChatIcon] provides new chat icon
  final IconData? newChatIcon;

  /// [chatHistoryIcon] provides chat history icon
  final IconData? chatHistoryIcon;

  @override
  State<CometChatMessageHeader> createState() => _CometChatMessageHeaderState();

  @override
  Size get preferredSize {
    return Size.fromHeight(height ?? 65);
  }
}

class _CometChatMessageHeaderState extends State<CometChatMessageHeader> {
  late MessageHeaderBloc _bloc;
  late CometChatMessageHeaderStyle headerStyle;
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  late CometChatStatusIndicatorStyle statusIndicatorStyle;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;
  double _cachedWidth = 300; // Cached to avoid MediaQuery in build()

  @override
  void initState() {
    super.initState();
    _bloc = MessageHeaderBloc(
      usersStatusVisibility: widget.usersStatusVisibility ?? true,
    );

    // Set initial user or group
    if (widget.user != null) {
      _bloc.add(SetUser(widget.user!));
    } else if (widget.group != null) {
      _bloc.add(SetGroup(widget.group!));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize theme once to avoid expensive lookups during keyboard animation
    // But re-initialize when brightness changes (dark mode toggle)
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged =
        _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (_themeInitialized && !brightnessChanged) return;
    _cachedBrightness = currentBrightness;
    _themeInitialized = true;

    // Cache width to avoid MediaQuery in build()
    _cachedWidth = MediaQuery.sizeOf(context).width;

    headerStyle = CometChatThemeHelper.getTheme<CometChatMessageHeaderStyle>(
      context: context,
      defaultTheme: CometChatMessageHeaderStyle.of,
    ).merge(widget.messageHeaderStyle);
    statusIndicatorStyle =
        CometChatThemeHelper.getTheme<CometChatStatusIndicatorStyle>(
          context: context,
          defaultTheme: CometChatStatusIndicatorStyle.of,
        ).merge(headerStyle.statusIndicatorStyle);
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  @override
  void didUpdateWidget(CometChatMessageHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update bloc if user/group changed
    if (widget.user != oldWidget.user && widget.user != null) {
      _bloc.add(SetUser(widget.user!));
    } else if (widget.group != oldWidget.group && widget.group != null) {
      _bloc.add(SetGroup(widget.group!));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: SafeArea(
        child: Container(
          height: widget.height,
          width: _cachedWidth,
          padding:
              widget.padding ?? EdgeInsets.only(left: spacing.padding4 ?? 0),
          decoration: BoxDecoration(
            color: headerStyle.backgroundColor ?? colorPalette.background1,
            border: headerStyle.border,
            borderRadius: headerStyle.borderRadius ?? BorderRadius.circular(0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getBackButtonView(context, headerStyle, colorPalette),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: spacing.padding4 ?? 0),
                  child: _getBody(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Back Button view
  Widget _getBackButtonView(
    BuildContext context,
    CometChatMessageHeaderStyle style,
    CometChatColorPalette colorPalette,
  ) {
    if (widget.showBackButton == true) {
      if (widget.backButton != null) {
        return widget.backButton!(context);
      }
      Widget leading;
      leading = GestureDetector(
        onTap:
            widget.onBack ??
            () {
              Navigator.pop(context);
            },
        child:
            style.backIcon ??
            Image.asset(
              AssetConstants.back,
              package: UIConstants.packageName,
              color: style.backIconColor ?? colorPalette.iconPrimary,
            ),
      );

      return leading;
    } else {
      return const SizedBox(height: 0, width: 0);
    }
  }

  // Body / Title view using BLoC
  Widget _getBody(BuildContext context) {
    return BlocBuilder<MessageHeaderBloc, MessageHeaderState>(
      builder: (context, state) {
        // Handle initial/loading state - use widget's user/group directly
        // until the BLoC state is populated
        if (state.status == MessageHeaderStatus.initial ||
            state.status == MessageHeaderStatus.loading) {
          // Use widget's user/group as fallback during initial load
          if (widget.user == null && widget.group == null) {
            return const SizedBox.shrink();
          }
          // Create a temporary state with widget data
          final tempState = MessageHeaderState(
            status: MessageHeaderStatus.loaded,
            user: widget.user,
            group: widget.group,
            memberCount: widget.group?.membersCount ?? 0,
          );
          return _getListItem(context, tempState);
        }
        return _getListItem(context, state);
      },
    );
  }

  // typing indicator view
  Widget _getTypingIndicator(
    BuildContext context,
    MessageHeaderState state,
    TextStyle? typingIndicatorTextStyle,
    CometChatTypography typography,
    Color? color,
  ) {
    String text;
    if (state.user != null) {
      text = cc.Translations.of(context).typing;
    } else {
      text =
          "${state.typingUser?.name ?? ''}: ${cc.Translations.of(context).typing}";
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
    MessageHeaderState state,
    CometChatMessageHeaderStyle style,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
  ) {
    Widget? subtitle;
    final subtitleStyle = TextStyle(
      color:
          style.subtitleTextColor ??
          style.subtitleTextStyle?.color ??
          colorPalette.textSecondary,
      fontSize:
          style.subtitleTextStyle?.fontSize ??
          typography.caption1?.regular?.fontSize,
      fontFamily:
          style.subtitleTextStyle?.fontFamily ??
          typography.caption1?.regular?.fontFamily,
      fontWeight:
          style.subtitleTextStyle?.fontWeight ??
          typography.caption1?.regular?.fontWeight,
    );

    if (state.isTyping && state.userIsNotBlocked) {
      subtitle = _getTypingIndicator(
        context,
        state,
        style.typingIndicatorTextStyle,
        typography,
        colorPalette.primary,
      );
    } else if (widget.subtitleView != null) {
      subtitle = widget.subtitleView!(state.group, state.user, context);
    } else if (state.user != null) {
      if (widget.usersStatusVisibility == true && state.userIsNotBlocked) {
        final statusText = state.isUserOnline
            ? cc.Translations.of(context).online
            : _getUserActivityStatus(context, state);
        // Wrap in LayoutBuilder so the marquee is constrained to the
        // available width and does not overflow into trailing widgets.
        subtitle = LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: CometChatMarquee(
                velocity: 30,
                text: statusText,
                style: subtitleStyle,
              ),
            );
          },
        );
      } else {
        subtitle = null;
      }
    } else {
      subtitle = Text(
        '${state.memberCount} ${state.memberCount == 1 ? cc.Translations.of(context).member : cc.Translations.of(context).members}',
        style: subtitleStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return subtitle;
  }

  // title view
  Widget? _getTitleView(BuildContext context, MessageHeaderState state) {
    if (widget.titleView != null) {
      return widget.titleView!(state.group, state.user, context);
    }
    return null;
  }

  // leading view
  Widget? _getLeadingView(BuildContext context, MessageHeaderState state) {
    if (widget.leadingStateView != null) {
      return widget.leadingStateView!(state.group, state.user, context);
    }
    return null;
  }

  // auxiliary header view
  Widget? _getAuxiliaryButtonView(
    BuildContext context,
    MessageHeaderState state,
    CometChatMessageHeaderStyle style,
    CometChatColorPalette colorPalette,
    CometChatTypography typography,
    CometChatSpacing spacing,
  ) {
    if (widget.auxiliaryButtonView != null) {
      return widget.auxiliaryButtonView!(state.group, state.user, context);
    } else {
      if (state.isUserAgentic) {
        return null;
      }
      return _buildCallButtons(style);
    }
  }

  // trailing view
  List<Widget>? _getTrailingView(
    BuildContext context,
    MessageHeaderState state,
    CometChatMessageHeaderStyle style,
  ) {
    if (widget.trailingView != null) {
      return widget.trailingView!(state.user, state.group, context);
    }
    return null;
  }

  Widget _getListItem(BuildContext context, MessageHeaderState state) {
    if (widget.listItemView != null) {
      return widget.listItemView!(widget.group, widget.user, context);
    }

    // Safety check - if both user and group are null, show empty widget
    if (state.user == null && state.group == null) {
      return const SizedBox.shrink();
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

    if (state.user != null) {
      avatarName = state.user?.name;
      avatarUrl = state.user?.avatar;
      title = state.user?.name;
    } else {
      avatarName = state.group?.name;
      avatarUrl = state.group?.icon;
      title = state.group?.name;
    }

    StatusIndicatorUtils util =
        StatusIndicatorUtils.getStatusIndicatorFromParams(
          context: context,
          user: state.user,
          group: state.group,
          privateGroupIcon: headerStyle.privateGroupBadgeIcon,
          protectedGroupIcon: headerStyle.passwordProtectedGroupBadgeIcon,
          onlineStatusIndicatorColor:
              statusIndicatorStyle.backgroundColor ??
              headerStyle.onlineStatusColor ??
              colorPalette.success,
          usersStatusVisibility: !_hideUserPresence(state),
          privateGroupIconBackground: headerStyle.privateGroupBadgeIconColor,
          protectedGroupIconBackground:
              headerStyle.passwordProtectedGroupBadgeIconColor,
        );

    statusIndicatorColor = util.statusIndicatorColor;
    List<Widget>? tailWidgetList = [];
    icon = util.icon;
    leadingStateView = _getLeadingView(context, state);
    titleView = _getTitleView(context, state);
    subtitleView = _getSubtitleView(
      context,
      state,
      headerStyle,
      colorPalette,
      typography,
    );

    auxiliaryHeaderMenu = _getAuxiliaryButtonView(
      context,
      state,
      headerStyle,
      colorPalette,
      typography,
      spacing,
    );
    if (auxiliaryHeaderMenu != null) {
      tailWidgetList.add(auxiliaryHeaderMenu);
    }

    if (widget.trailingView != null) {
      var temp = _getTrailingView(context, state, headerStyle);

      if (temp != null) {
        tailWidgetList.addAll(temp);
      }
    }

    if (state.isUserAgentic) {
      tailWidgetList.addAll(_getAgenticButtons());
    }

    if (tailWidgetList.isNotEmpty) {
      tailView = Padding(
        padding: EdgeInsets.only(
          left: spacing.padding3 ?? 0,
          top: spacing.padding2 ?? 0,
          bottom: spacing.padding2 ?? 0,
        ),
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
          backgroundColor: widget.group != null
              ? headerStyle.groupIconBackgroundColor
              : null,
        ).merge(headerStyle.avatarStyle),
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
        style:
            widget.listItemStyle ??
            ListItemStyle(
              background: Colors.transparent,
              height: 56,
              titleStyle: TextStyle(
                fontSize:
                    headerStyle.titleTextStyle?.fontSize ??
                    typography.heading4?.medium?.fontSize,
                fontWeight:
                    headerStyle.titleTextStyle?.fontWeight ??
                    typography.heading4?.medium?.fontWeight,
                fontFamily:
                    headerStyle.titleTextStyle?.fontFamily ??
                    typography.heading4?.medium?.fontFamily,
                color:
                    headerStyle.titleTextColor ??
                    headerStyle.titleTextStyle?.color ??
                    colorPalette.textPrimary,
                overflow: TextOverflow.ellipsis,
              ),
            ),
      ),
    );
  }

  Widget _buildTightIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(
        width: 30,
        height: 30,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  List<Widget> _getAgenticButtons() {
    return [
      if (!(widget.hideNewChatButton ?? false))
        _buildTightIconButton(
          color:
              headerStyle.newChatIconColor ??
              colorPalette.iconSecondary ??
              Colors.transparent,
          icon: widget.newChatIcon ?? Icons.add,
          onPressed:
              widget.newChatButtonClick ??
              () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
          padding: EdgeInsets.only(right: spacing.padding2 ?? 0),
        ),
      if (!(widget.hideChatHistoryButton ?? false))
        _buildTightIconButton(
          color:
              headerStyle.chatHistoryIconColor ??
              colorPalette.iconSecondary ??
              Colors.transparent,
          icon: widget.chatHistoryIcon ?? Icons.history,
          onPressed:
              widget.chatHistoryButtonClick ??
              () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
          padding: EdgeInsets.only(right: spacing.padding4 ?? 0),
        ),
    ];
  }

  bool _hideUserPresence(MessageHeaderState state) {
    return state.user != null &&
        (widget.usersStatusVisibility == false || !state.userIsNotBlocked);
  }

  Widget? _buildCallButtons(CometChatMessageHeaderStyle style) {
    if (CometChatUIKit.authenticationSettings?.enableCalls != true) {
      return null;
    }

    final callingConfig =
        CometChatUIKit.authenticationSettings?.callingConfiguration;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CometChatCallButtons(
          user: widget.user,
          group: widget.group,
          callButtonsStyle:
              (callingConfig?.callButtonsConfiguration?.callButtonsStyle ??
                      const CometChatCallButtonsStyle())
                  .merge(style.callButtonsStyle),
          onError: callingConfig?.callButtonsConfiguration?.onError,
          hideVoiceCallButton:
              widget.hideVoiceCallButton ??
              callingConfig?.callButtonsConfiguration?.hideVoiceCallButton,
          hideVideoCallButton:
              widget.hideVideoCallButton ??
              callingConfig?.callButtonsConfiguration?.hideVideoCallButton,
          voiceCallIcon: callingConfig?.callButtonsConfiguration?.voiceCallIcon,
          videoCallIcon: callingConfig?.callButtonsConfiguration?.videoCallIcon,
          outgoingCallConfiguration:
              callingConfig
                  ?.callButtonsConfiguration
                  ?.outgoingCallConfiguration ??
              callingConfig?.outgoingCallConfiguration,
          callSettingsBuilder:
              callingConfig?.callButtonsConfiguration?.callSettingsBuilder,
        ),
      ],
    );
  }

  String _getUserActivityStatus(
    BuildContext context,
    MessageHeaderState state,
  ) {
    if (state.user == null) {
      return "";
    }
    if (state.user?.lastActiveAt == null) {
      return cc.Translations.of(context).offline;
    }
    return _getLastSeenText(state.user!.lastActiveAt!, context);
  }

  String _getLastSeenText(DateTime lastActiveAt, BuildContext context) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastActiveAt);

    if (difference.inMinutes <= 1) {
      return _getMinute(lastActiveAt, context);
    } else if (difference.inMinutes < 60) {
      return _getMinutes(difference, lastActiveAt, context);
    } else if (difference.inHours < 2) {
      return _getHour(difference, lastActiveAt, context);
    } else if (difference.inHours < 24) {
      int diffInHours = difference.inHours;
      return _getHours(difference, diffInHours, lastActiveAt, context);
    } else {
      return _getFormattedDateWithTime(lastActiveAt, context);
    }
  }

  String _getMinute(DateTime date, BuildContext context) {
    if (widget.dateTimeFormatterCallback?.minute(date.millisecondsSinceEpoch) !=
        null) {
      return widget.dateTimeFormatterCallback?.minute(
            date.millisecondsSinceEpoch,
          ) ??
          "${cc.Translations.of(context).lastSeen} 1 ${cc.Translations.of(context).minuteAgo}";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.minute(date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} 1 ${cc.Translations.of(context).minuteAgo}";
    }
  }

  String _getMinutes(Duration difference, DateTime date, BuildContext context) {
    int diffInMinutes = difference.inMinutes;
    if (widget.dateTimeFormatterCallback?.minutes(
          diffInMinutes,
          date.millisecondsSinceEpoch,
        ) !=
        null) {
      return widget.dateTimeFormatterCallback?.minutes(
            diffInMinutes,
            date.millisecondsSinceEpoch,
          ) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inMinutes} ${cc.Translations.of(context).minutesAgo}";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.minutes(diffInMinutes, date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inMinutes} ${cc.Translations.of(context).minutesAgo}";
    }
  }

  String _getHour(Duration difference, DateTime date, BuildContext context) {
    if (widget.dateTimeFormatterCallback?.hour(date.millisecondsSinceEpoch) !=
        null) {
      return widget.dateTimeFormatterCallback?.hour(
            date.millisecondsSinceEpoch,
          ) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inHours} ${cc.Translations.of(context).hourAgo}";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.hour(date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inHours} ${cc.Translations.of(context).hourAgo}";
    }
  }

  String _getHours(
    Duration difference,
    int diffInHours,
    DateTime date,
    BuildContext context,
  ) {
    if (widget.dateTimeFormatterCallback?.hours(
          diffInHours,
          date.millisecondsSinceEpoch,
        ) !=
        null) {
      return widget.dateTimeFormatterCallback?.hours(
            diffInHours,
            date.millisecondsSinceEpoch,
          ) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inHours} ${cc.Translations.of(context).hoursAgo}";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.hours(diffInHours, date.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} ${difference.inHours} ${cc.Translations.of(context).hoursAgo}";
    }
  }

  String _getFormattedDateWithTime(
    DateTime lastActiveAt,
    BuildContext context,
  ) {
    final now = DateTime.now();
    final isSameYear = now.year == lastActiveAt.year;

    String datePattern = isSameYear ? 'dd MMM' : 'dd MMM yyyy';
    String formattedDate = DateFormat(datePattern).format(lastActiveAt);
    String formattedTime = DateFormat.jm().format(lastActiveAt);

    if (widget.dateTimeFormatterCallback?.otherDays(
          lastActiveAt.millisecondsSinceEpoch,
        ) !=
        null) {
      return widget.dateTimeFormatterCallback?.otherDays(
            lastActiveAt.millisecondsSinceEpoch,
          ) ??
          "${cc.Translations.of(context).lastSeen} $formattedDate ${cc.Translations.of(context).at} $formattedTime";
    } else {
      return CometChatUIKit.authenticationSettings?.dateTimeFormatterCallback
              ?.otherDays(lastActiveAt.millisecondsSinceEpoch) ??
          "${cc.Translations.of(context).lastSeen} $formattedDate ${cc.Translations.of(context).at} $formattedTime";
    }
  }
}
