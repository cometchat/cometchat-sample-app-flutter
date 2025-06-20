import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart' as cc;
import 'package:get/get.dart';

///[CometChatCallLogs] is a component that displays a list of callLogs with the help of [CometChatListBase] and [CometChatListItem]
///fetched callLogs are listed down in order of recent activity
///callLogs are fetched using [CallLogsBuilderProtocol] and [CallLogRequestBuilder]
///```dart
/// CometChatCallLogs(
///  listItemView: (CallLog callLog, BuildContext context) {
///  return ListTile(
///  title: Text(callLog.receiver.name),
///  subtitle: Text(callLog.receiver.uid),
///  trailing: Icon(Icons.call),
///  );
///  },
///  );
///  ```

class CometChatCallLogs extends StatefulWidget {
  const CometChatCallLogs({
    Key? key,
    this.listItemView,
    this.subTitleView,
    this.backButton,
    this.emptyStateView,
    this.errorStateView,
    this.loadingStateView,
    this.onItemClick,
    this.onError,
    this.onBack,
    this.trailingView,
    this.callLogsBuilderProtocol,
    this.datePattern,
    this.dateSeparatorPattern,
    this.callLogsStyle,
    this.callLogsRequestBuilder,
    this.outgoingCallConfiguration,
    this.audioCallIcon,
    this.videoCallIcon,
    this.incomingCallIcon,
    this.outgoingCallIcon,
    this.missedCallIcon,
    this.hideAppbar = false,
    this.appBarOptions,
    this.onCallLogIconClicked,
    this.onItemLongPress,
    this.addOptions,
    this.setOptions,
    this.onEmpty,
    this.onLoad,
    this.leadingStateView,
    this.titleView,
    this.showBackButton,
  }) : super(key: key);

  ///[listItemView] set custom view for each callLog
  final Widget? Function(CallLog callLog, BuildContext context)? listItemView;

  ///[subTitleView] set custom sub title view for each callLog
  final Widget? Function(CallLog callLog, BuildContext context)? subTitleView;

  ///[backButton] returns back button
  final Widget? backButton;

  ///[emptyStateView]  returns view fow empty state
  final WidgetBuilder? emptyStateView;

  ///[errorStateView] returns view fow error state
  final WidgetBuilder? errorStateView;

  ///[loadingStateView] returns view fow loading state
  final WidgetBuilder? loadingStateView;

  ///[onItemClick] callback triggered on clicking of the callLog item
  final Function(CallLog callLog)? onItemClick;

  ///[onError] callback triggered in case any error happens when fetching callLogs
  final OnError? onError;

  ///[onBack] callback triggered on closing this screen
  final VoidCallback? onBack;

  ///[trailingView] a custom widget for the tail section of the callLog list item
  final Function(BuildContext context, CallLog callLog)? trailingView;

  ///[callLogsBuilderProtocol] set custom call Log request builder protocol
  final CallLogsBuilderProtocol? callLogsBuilderProtocol;

  ///[callLogRequestBuilder] set custom conversations request builder
  final CallLogRequestBuilder? callLogsRequestBuilder;

  ///[datePattern] custom date pattern visible in callLogs
  final String? datePattern;

  ///[dateSeparatorPattern] pattern for  date separator
  final String? dateSeparatorPattern;

  ///[callLogsStyle] style for every call logs
  final CometChatCallLogsStyle? callLogsStyle;

  ///[incomingCallIcon] custom incoming call icon
  final Widget? incomingCallIcon;

  ///[outgoingCallIcon] custom outgoing call icon
  final Widget? outgoingCallIcon;

  ///[missedCallIcon] custom missed call icon
  final Widget? missedCallIcon;

  ///[audioCallIcon] custom audio call icon
  final Widget? audioCallIcon;

  ///[videoCallIcon] custom video call icon
  final Widget? videoCallIcon;

  ///[outgoingCallConfiguration] is a object of [OutgoingCallConfiguration] which sets the configuration for outgoing call
  final CometChatOutgoingCallConfiguration? outgoingCallConfiguration;

  ///[hideAppbar] toggle visibility for app bar
  final bool? hideAppbar;

  ///[appBarOptions] list of options to be visible in app bar
  final List<Widget>? appBarOptions;

  ///[onCallLogIconClicked] callback triggered on clicking of the callLog icon audio/video icon
  final Function(CallLog callLog)? onCallLogIconClicked;

  ///[onItemLongPress] callback triggered on long pressing of the callLog item
  final Function(CallLog callLog)? onItemLongPress;

  ///[onLoad] callback triggered when list is fetched and load
  final OnLoad<CallLog>? onLoad;

  ///[onEmpty] callback triggered when the list is empty
  final OnEmpty? onEmpty;

  ///[setOptions] sets List of actions available on the long press of list item
  final List<CometChatOption>? Function(CallLog callLog,
      CometChatCallLogsController controller, BuildContext context)? setOptions;

  ///[addOptions] adds into the current List of actions available on the long press of list item
  final List<CometChatOption>? Function(CallLog callLog,
      CometChatCallLogsController controller, BuildContext context)? addOptions;

  ///[leadingStateView] to set leading view for each callLog
  final Widget? Function(BuildContext, CallLog)? leadingStateView;

  ///[titleView] to set title view for each callLog
  final Widget? Function(BuildContext, CallLog)? titleView;

  ///[showBackButton] switch on/off back button
  final bool? showBackButton;

  @override
  State<CometChatCallLogs> createState() => _CometChatCallLogsState();
}

class _CometChatCallLogsState extends State<CometChatCallLogs> {
  CometChatCallLogsController? _callLogsController;

  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  late CometChatCallLogsStyle style;
  late CometChatAvatarStyle avatarStyle;
  late CometChatDateStyle dateStyle;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    String? userAuthToken = await CometChatUIKitCalls.getUserAuthToken();
    _callLogsController = CometChatCallLogsController(
      callLogsBuilderProtocol: widget.callLogsBuilderProtocol ??
          UICallLogsBuilder(
              widget.callLogsRequestBuilder ?? CallLogRequestBuilder()
                ..authToken = userAuthToken
                ..callCategory = CometChatCallsConstants.callCategoryCall),
      onError: widget.onError,
      outgoingCallConfiguration: widget.outgoingCallConfiguration,
      onEmpty: widget.onEmpty,
      onLoad: widget.onLoad,
    );
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize typography, color palette, and spacing
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    style = CometChatThemeHelper.getTheme<CometChatCallLogsStyle>(
            context: context, defaultTheme: CometChatCallLogsStyle.of)
        .merge(widget.callLogsStyle);

    avatarStyle = CometChatThemeHelper.getTheme<CometChatAvatarStyle>(
            context: context, defaultTheme: CometChatAvatarStyle.of)
        .merge(style.avatarStyle);

    dateStyle = CometChatThemeHelper.getTheme<CometChatDateStyle>(
            context: context, defaultTheme: CometChatDateStyle.of)
        .merge(style.dateStyle);
  }

  @override
  Widget build(BuildContext context) {
    return (_callLogsController == null)
        ? Scaffold(
            backgroundColor: colorPalette.background1,
          )
        : CometChatListBase(
            title: cc.Translations.of(context).calls,
            hideSearch: true,
            backIcon: widget.backButton,
            onBack: widget.onBack,
            hideAppBar: widget.hideAppbar,
            showBackButton: widget.showBackButton,
            menuOptions: [
              if (widget.appBarOptions != null &&
                  widget.appBarOptions!.isNotEmpty)
                ...widget.appBarOptions!,
            ],
            style: ListBaseStyle(
              background: style.backgroundColor ?? colorPalette.background1,
              titleStyle: TextStyle(
                color: style.titleTextColor ?? colorPalette.textPrimary,
                fontSize: typography.heading1?.bold?.fontSize,
                fontWeight: typography.heading1?.bold?.fontWeight,
                fontFamily: typography.heading1?.bold?.fontFamily,
              )
                  .merge(
                    style.titleTextStyle,
                  )
                  .copyWith(
                    color: style.titleTextColor,
                  ),
              backIconTint: style.backIconColor ?? colorPalette.iconPrimary,
              border: style.border,
              borderRadius: style.borderRadius,
            ),
            container: Column(
              children: [
                Divider(
                  color: style.separatorColor ?? colorPalette.borderLight,
                  height: style.separatorHeight ?? 1,
                ),
                Expanded(
                  child: GetBuilder(
                    init: _callLogsController,
                    builder: (CometChatCallLogsController value) {
                      value.colorPalette = colorPalette;
                      value.spacing = spacing;
                      value.typography = typography;
                      if (value.hasError == true) {
                        if (widget.errorStateView != null) {
                          return widget.errorStateView!(context);
                        }
                        return _showErrorView(context, value);
                      } else if (value.isLoading == true &&
                          value.list.isEmpty) {
                        return _getLoadingIndicator(context);
                      } else if (value.list.isEmpty) {
                        return _emptyView(context);
                      } else {
                        List<GlobalKey> tileKeys = List.generate(
                            value.list.length, (index) => GlobalKey());
                        return ListView.builder(
                          itemCount: value.hasMoreItems
                              ? value.list.length + 1
                              : value.list.length,
                          itemBuilder: (context, index) {
                            if (index >= value.list.length) {
                              value.loadMoreElements();
                              return _getLoadingIndicator(
                                context,
                              );
                            }
                            final log = value.list[index];
                            if (widget.listItemView != null) {
                              return widget.listItemView!(log, context);
                            } else {
                              return GestureDetector(
                                key: tileKeys[index],
                                onTap: () {
                                  if (widget.onItemClick != null) {
                                    widget.onItemClick!(log);
                                  }
                                },
                                onLongPress: () {
                                  if (widget.onItemLongPress != null) {
                                    widget.onItemLongPress!(log);
                                  } else {
                                    List<CometChatOption>? options;

                                    if (widget.setOptions != null) {
                                      options = widget.setOptions!(
                                        log,
                                        value,
                                        context,
                                      );
                                    } else {
                                      if (widget.addOptions != null) {
                                        options = widget.addOptions!(
                                          log,
                                          value,
                                          context,
                                        );
                                      }
                                    }
                                    value.showPopupMenu(
                                      context,
                                      options ?? [],
                                      tileKeys[index],
                                    );
                                  }
                                },
                                child: CometChatListItem(
                                  hideSeparator: true,
                                  avatarURL: CallLogsUtils.receiverAvatar(
                                    value.loggedInUser!,
                                    log,
                                  ),
                                  avatarName: CallLogsUtils.receiverName(
                                    value.loggedInUser!,
                                    log,
                                  ),
                                  title: CallLogsUtils.receiverName(
                                    value.loggedInUser!,
                                    log,
                                  ),
                                  style: ListItemStyle(
                                    background: colorPalette.transparent,
                                    titleStyle: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize:
                                          typography.heading4?.medium?.fontSize,
                                      fontWeight: typography
                                          .heading4?.medium?.fontWeight,
                                      fontFamily: typography
                                          .heading4?.medium?.fontFamily,
                                      color: style.itemTitleTextColor ??
                                          CallUtils.getCallStatusColor(
                                            log,
                                            value.loggedInUser,
                                            colorPalette,
                                          ),
                                    )
                                        .merge(
                                          style.itemTitleTextStyle,
                                        )
                                        .copyWith(
                                          color: style.itemTitleTextColor,
                                        ),
                                    padding: EdgeInsets.only(
                                      left: spacing.padding4 ?? 0,
                                      right: spacing.padding4 ?? 0,
                                      top: spacing.padding3 ?? 0,
                                      bottom: spacing.padding3 ?? 0,
                                    ),
                                  ),
                                  subtitleView: _getSubTitleView(
                                    value,
                                    log,
                                    context,
                                  ),
                                  tailView: _getTailView(
                                    context,
                                    value,
                                    log,
                                  ),
                                  avatarStyle: avatarStyle,
                                  leadingStateView:
                                      _getLeadingView(value, log, context),
                                  titleView: _getTitleView(value, log, context),
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
  }

  // tail widget
  Widget _getTailView(BuildContext context, CometChatCallLogsController value,
      CallLog callLog) {
    if (widget.trailingView != null) {
      return widget.trailingView!(context, callLog);
    } else {
      IconData iconData = (callLog.type == CallTypeConstants.audioCall)
          ? Icons.call_outlined
          : Icons.videocam_outlined;

      Widget? icon = (callLog.type == CallTypeConstants.audioCall)
          ? widget.audioCallIcon
          : widget.videoCallIcon;

      Color? iconColor = (callLog.type == CallTypeConstants.audioCall)
          ? style.audioCallIconColor
          : style.videoCallIconColor;

      return SizedBox(
        width: 24,
        height: 24,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (widget.onCallLogIconClicked != null) {
              widget.onCallLogIconClicked!(callLog);
            } else if (CallLogsUtils.isUser(callLog)) {
              value.initiateCall(
                callLog,
                context,
              );
            }
          },
          icon: icon ??
              Icon(
                iconData,
                size: 24,
                color: iconColor ?? colorPalette.iconPrimary,
              ),
        ),
      );
    }
  }

  // Sub title widget
  _getSubTitleView(CometChatCallLogsController value, CallLog callLog,
      BuildContext context) {
    if (widget.subTitleView != null) {
      return widget.subTitleView!(callLog, context);
    } else {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: spacing.padding1 ?? 4,
            ),
            child: CallUtils.getCallIcon(
              context,
              callLog,
              value.loggedInUser,
              colorPalette,
              typography,
              spacing,
              style,
              incomingCallIcon: widget.incomingCallIcon,
              missedCallIcon: widget.missedCallIcon,
              outgoingCallIcon: widget.outgoingCallIcon,
            ),
          ),
          Expanded(
            child: CallLogsUtils.getTime(
              context,
              callLog.initiatedAt,
              colorPalette,
              typography,
              spacing,
              style,
              dateStyle,
              datePattern: widget.datePattern,
            ),
          ),
        ],
      );
    }
  }

  // leading view widget
  _getLeadingView(CometChatCallLogsController value, CallLog callLog,
      BuildContext context) {
    if (widget.leadingStateView != null) {
      return widget.leadingStateView!(context, callLog);
    }
  }

  // title view widget
  _getTitleView(CometChatCallLogsController value, CallLog callLog,
      BuildContext context) {
    if (widget.titleView != null) {
      return widget.titleView!(context, callLog);
    }
  }

  // Loading View
  Widget _getLoadingIndicator(BuildContext context) {
    if (widget.loadingStateView != null) {
      return widget.loadingStateView!(context);
    } else {
      return CometChatShimmerEffect(
        colorPalette: colorPalette,
        child: ListView.builder(
          itemCount: 30,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.padding4 ?? 0,
                vertical: spacing.padding3 ?? 0,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: spacing.padding3 ?? 0,
                    ),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title shimmer bar
                      Container(
                        height: 22.0,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(
                            spacing.radius2 ?? 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Subtitle shimmer bar
                      Container(
                        height: 12.0,
                        width: MediaQuery.of(context).size.width * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(
                            spacing.radius2 ?? 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(
                      right: spacing.padding3 ?? 0,
                    ),
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(
                            spacing.radius2 ?? 8,
                          )),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  // Empty Widget
  Widget _emptyView(BuildContext context) {
    if (widget.emptyStateView != null) {
      return widget.emptyStateView!(context);
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.call,
              color: colorPalette.neutral300,
              size: 100,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: spacing.padding5 ?? 20,
                bottom: spacing.padding ?? 2,
              ),
              child: Text(
                cc.Translations.of(context).noCallLogsYet,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: style.emptyStateTextColor ?? colorPalette.textPrimary,
                  fontSize: typography.heading3?.bold?.fontSize,
                  fontWeight: typography.heading3?.bold?.fontWeight,
                  fontFamily: typography.heading3?.bold?.fontFamily,
                )
                    .merge(style.emptyStateTextStyle)
                    .copyWith(color: style.emptyStateTextColor),
              ),
            ),
            Text(
              cc.Translations.of(context).makeOrReceiveCalls,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: style.emptyStateSubTitleTextColor ??
                    colorPalette.textSecondary,
                fontSize: typography.heading3?.regular?.fontSize,
                fontWeight: typography.heading3?.regular?.fontWeight,
                fontFamily: typography.heading3?.regular?.fontFamily,
              )
                  .merge(
                    style.emptyStateSubTitleTextStyle,
                  )
                  .copyWith(
                    color: style.emptyStateSubTitleTextColor,
                  ),
            ),
          ],
        ),
      );
    }
  }

  Widget _showErrorView(
    BuildContext context,
    CometChatCallLogsController controller,
  ) {
    return UIStateUtils.getDefaultErrorStateView(
      context,
      colorPalette,
      typography,
      spacing,
      () {
        controller.retryGroups();
      },
      errorStateTextColor: style.errorStateTextColor,
      errorStateTextStyle: style.errorStateTextStyle,
      errorStateSubtitleColor: style.errorStateSubTitleTextColor,
      errorStateSubtitleStyle: style.errorStateSubTitleTextStyle,
      buttonBackgroundColor: style.retryButtonBackgroundColor,
      buttonBorderRadius: style.retryButtonBorderRadius,
      buttonBorderSide: style.retryButtonBorder,
      buttonTextColor: style.retryButtonTextColor,
      buttonTextStyle: style.retryButtonTextStyle,
    );
  }
}
