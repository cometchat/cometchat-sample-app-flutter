import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cometchat_calls_uikit.dart';
import '../../../../cometchat_chat_uikit.dart' as cc;
import '../../../../cometchat_chat_uikit.dart';

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
    super.key,
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
    this.callLogsBloc,
  });

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

  ///[callLogsRequestBuilder] set custom conversations request builder
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

  ///[outgoingCallConfiguration] is a object of [CometChatOutgoingCallConfiguration] which sets the configuration for outgoing call
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
  final List<CometChatOption>? Function(
    CallLog callLog,
    CallLogsBloc bloc,
    BuildContext context,
  )?
  setOptions;

  ///[addOptions] adds into the current List of actions available on the long press of list item
  final List<CometChatOption>? Function(
    CallLog callLog,
    CallLogsBloc bloc,
    BuildContext context,
  )?
  addOptions;

  ///[leadingStateView] to set leading view for each callLog
  final Widget? Function(BuildContext, CallLog)? leadingStateView;

  ///[titleView] to set title view for each callLog
  final Widget? Function(BuildContext, CallLog)? titleView;

  ///[showBackButton] switch on/off back button
  final bool? showBackButton;

  ///[callLogsBloc] Optional external CallLogsBloc instance.
  ///If provided, this bloc will be used instead of creating a new one internally.
  ///This allows for custom bloc implementations with overridden hooks.
  final CallLogsBloc? callLogsBloc;

  @override
  State<CometChatCallLogs> createState() => _CometChatCallLogsState();
}

class _CometChatCallLogsState extends State<CometChatCallLogs> {
  /// BLoC to manage call logs state
  late CallLogsBloc _callLogsBloc;

  /// Track if bloc is external (should not be closed by this widget)
  bool _isExternalBloc = false;

  /// Flag to track if theme has been initialized
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  /// Cached theme values to avoid expensive lookups during rebuilds
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;
  late CometChatCallLogsStyle style;
  late CometChatAvatarStyle avatarStyle;
  late CometChatDateStyle dateStyle;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
  }

  /// Initialize the BLoC
  void _initializeBloc() {
    // Use external bloc if provided, otherwise create a new one
    if (widget.callLogsBloc != null) {
      _callLogsBloc = widget.callLogsBloc!;
      _isExternalBloc = true;
    } else {
      // Initialize service locator if not already initialized
      if (!CallLogsServiceLocator.instance.isInitialized) {
        CallLogsServiceLocator.instance.setup();
      }

      // Determine the request builder: prefer explicit callLogsRequestBuilder,
      // fall back to callLogsBuilderProtocol's internal builder
      CallLogRequestBuilder? requestBuilder = widget.callLogsRequestBuilder;
      if (requestBuilder == null && widget.callLogsBuilderProtocol != null) {
        requestBuilder = widget.callLogsBuilderProtocol!.requestBuilder;
      }

      // Create BLoC with dependencies from service locator
      _callLogsBloc = CallLogsBloc(callLogsRequestBuilder: requestBuilder);
      _isExternalBloc = false;
    }

    // Load call logs
    _callLogsBloc.add(const LoadCallLogs());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize theme once to avoid expensive lookups during keyboard animation
    // But re-initialize when brightness changes (dark mode toggle)
    final currentBrightness = CometChatThemeHelper.getBrightness(context);
    final brightnessChanged =
        _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (_themeInitialized && !brightnessChanged) return;
    _cachedBrightness = currentBrightness;
    _themeInitialized = true;

    // Initialize typography, color palette, and spacing
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    style = CometChatThemeHelper.getTheme<CometChatCallLogsStyle>(
      context: context,
      defaultTheme: CometChatCallLogsStyle.of,
    ).merge(widget.callLogsStyle);

    avatarStyle = CometChatThemeHelper.getTheme<CometChatAvatarStyle>(
      context: context,
      defaultTheme: CometChatAvatarStyle.of,
    ).merge(style.avatarStyle);

    dateStyle = CometChatThemeHelper.getTheme<CometChatDateStyle>(
      context: context,
      defaultTheme: CometChatDateStyle.of,
    ).merge(style.dateStyle);
  }

  @override
  void dispose() {
    // Only close the bloc if we created it internally
    if (!_isExternalBloc) {
      _callLogsBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _callLogsBloc,
      child: CometChatListBase(
        title: cc.Translations.of(context).calls,
        hideSearch: true,
        backIcon: widget.backButton,
        onBack: widget.onBack,
        hideAppBar: widget.hideAppbar,
        showBackButton: widget.showBackButton,
        menuOptions: [
          if (widget.appBarOptions != null && widget.appBarOptions!.isNotEmpty)
            ...widget.appBarOptions!,
        ],
        style: ListBaseStyle(
          background: style.backgroundColor ?? colorPalette.background1,
          titleStyle: TextStyle(
            color: style.titleTextColor ?? colorPalette.textPrimary,
            fontSize: typography.heading1?.bold?.fontSize,
            fontWeight: typography.heading1?.bold?.fontWeight,
            fontFamily: typography.heading1?.bold?.fontFamily,
          ).merge(style.titleTextStyle).copyWith(color: style.titleTextColor),
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
              child: BlocConsumer<CallLogsBloc, CallLogsState>(
                // Only rebuild on status changes to optimize performance
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.callLogs != current.callLogs ||
                    previous.hasMore != current.hasMore ||
                    previous.isLoadingMore != current.isLoadingMore,
                listener: (context, state) {
                  // Handle error callback
                  if (state.status == CallLogsStatus.error &&
                      widget.onError != null) {
                    widget.onError!(
                      CometChatException(
                        'CALL_LOGS_ERROR',
                        state.errorMessage ?? 'Unknown error',
                        state.errorMessage ?? 'Unknown error',
                      ),
                    );
                  }

                  // Handle empty callback
                  if (state.status == CallLogsStatus.empty &&
                      widget.onEmpty != null) {
                    widget.onEmpty!();
                  }

                  // Handle load callback
                  if (state.status == CallLogsStatus.loaded &&
                      widget.onLoad != null) {
                    widget.onLoad!(state.callLogs);
                  }
                },
                builder: (context, state) {
                  if (state.status == CallLogsStatus.error) {
                    if (widget.errorStateView != null) {
                      return widget.errorStateView!(context);
                    }
                    return _showErrorView(context);
                  } else if (state.status == CallLogsStatus.loading) {
                    return _getLoadingIndicator(context);
                  } else if (state.status == CallLogsStatus.empty) {
                    return _emptyView(context);
                  } else {
                    return _buildCallLogsList(context, state);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the call logs list
  Widget _buildCallLogsList(BuildContext context, CallLogsState state) {
    final callLogs = state.callLogs;
    final List<GlobalKey> tileKeys = List.generate(
      callLogs.length,
      (index) => GlobalKey(),
    );

    return ListView.builder(
      itemCount: state.hasMore ? callLogs.length + 1 : callLogs.length,
      itemBuilder: (context, index) {
        if (index >= callLogs.length) {
          _callLogsBloc.add(const LoadMoreCallLogs());
          return _getLoadingIndicator(context);
        }

        final log = callLogs[index];

        if (widget.listItemView != null) {
          return widget.listItemView!(log, context);
        }

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
                options = widget.setOptions!(log, _callLogsBloc, context);
              } else {
                if (widget.addOptions != null) {
                  options = widget.addOptions!(log, _callLogsBloc, context);
                }
              }
              _showPopupMenu(context, options ?? [], tileKeys[index]);
            }
          },
          child: CometChatListItem(
            hideSeparator: true,
            avatarURL: CallLogsUtils.receiverAvatar(state.loggedInUser!, log),
            avatarName: CallLogsUtils.receiverName(state.loggedInUser!, log),
            title: CallLogsUtils.receiverName(state.loggedInUser!, log),
            style: ListItemStyle(
              background: colorPalette.transparent,
              titleStyle:
                  TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: typography.heading4?.medium?.fontSize,
                        fontWeight: typography.heading4?.medium?.fontWeight,
                        fontFamily: typography.heading4?.medium?.fontFamily,
                        color:
                            style.itemTitleTextColor ??
                            CallUtils.getCallStatusColor(
                              log,
                              state.loggedInUser,
                              colorPalette,
                            ),
                      )
                      .merge(style.itemTitleTextStyle)
                      .copyWith(color: style.itemTitleTextColor),
              padding: EdgeInsets.only(
                left: spacing.padding4 ?? 0,
                right: spacing.padding4 ?? 0,
                top: spacing.padding3 ?? 0,
                bottom: spacing.padding3 ?? 0,
              ),
            ),
            subtitleView: _getSubTitleView(state, log, context),
            tailView: _getTailView(context, state, log),
            avatarStyle: avatarStyle,
            leadingStateView: _getLeadingView(state, log, context),
            titleView: _getTitleView(state, log, context),
          ),
        );
      },
    );
  }

  /// Show popup menu for options
  void _showPopupMenu(
    BuildContext context,
    List<CometChatOption> options,
    GlobalKey key,
  ) {
    if (options.isEmpty) return;

    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width,
        offset.dy,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      items: options.map((option) {
        return PopupMenuItem(
          onTap: option.onClick,
          child: Row(
            children: [
              if (option.iconWidget != null) ...[
                option.iconWidget!,
                const SizedBox(width: 8),
              ] else if (option.icon != null) ...[
                Image.network(
                  option.icon!,
                  width: 24,
                  height: 24,
                  color: option.iconTint,
                ),
                const SizedBox(width: 8),
              ],
              Text(option.title ?? '', style: option.titleStyle),
            ],
          ),
        );
      }).toList(),
    );
  }

  // tail widget
  Widget _getTailView(
    BuildContext context,
    CallLogsState state,
    CallLog callLog,
  ) {
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
              _callLogsBloc.add(
                InitiateCallFromLog(callLog: callLog, context: context),
              );
            }
          },
          icon:
              icon ??
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
  Widget _getSubTitleView(
    CallLogsState state,
    CallLog callLog,
    BuildContext context,
  ) {
    if (widget.subTitleView != null) {
      return widget.subTitleView!(callLog, context)!;
    } else {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: spacing.padding1 ?? 4),
            child: CallUtils.getCallIcon(
              context,
              callLog,
              state.loggedInUser,
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
  Widget? _getLeadingView(
    CallLogsState state,
    CallLog callLog,
    BuildContext context,
  ) {
    if (widget.leadingStateView != null) {
      return widget.leadingStateView!(context, callLog);
    }
    return null;
  }

  // title view widget
  Widget? _getTitleView(
    CallLogsState state,
    CallLog callLog,
    BuildContext context,
  ) {
    if (widget.titleView != null) {
      return widget.titleView!(context, callLog);
    }
    return null;
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
                    padding: EdgeInsets.only(right: spacing.padding3 ?? 0),
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
                        width: MediaQuery.sizeOf(context).width * 0.4,
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
                        width: MediaQuery.sizeOf(context).width * 0.2,
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
                    padding: EdgeInsets.only(right: spacing.padding3 ?? 0),
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          spacing.radius2 ?? 8,
                        ),
                      ),
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
            Icon(Icons.call, color: colorPalette.neutral300, size: 100),
            Padding(
              padding: EdgeInsets.only(
                top: spacing.padding5 ?? 20,
                bottom: spacing.padding ?? 2,
              ),
              child: Text(
                cc.Translations.of(context).noCallLogsYet,
                textAlign: TextAlign.center,
                style:
                    TextStyle(
                          color:
                              style.emptyStateTextColor ??
                              colorPalette.textPrimary,
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
              style:
                  TextStyle(
                        color:
                            style.emptyStateSubTitleTextColor ??
                            colorPalette.textSecondary,
                        fontSize: typography.heading3?.regular?.fontSize,
                        fontWeight: typography.heading3?.regular?.fontWeight,
                        fontFamily: typography.heading3?.regular?.fontFamily,
                      )
                      .merge(style.emptyStateSubTitleTextStyle)
                      .copyWith(color: style.emptyStateSubTitleTextColor),
            ),
          ],
        ),
      );
    }
  }

  Widget _showErrorView(BuildContext context) {
    return UIStateUtils.getDefaultErrorStateView(
      context,
      colorPalette,
      typography,
      spacing,
      () {
        _callLogsBloc.add(const RefreshCallLogs());
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
