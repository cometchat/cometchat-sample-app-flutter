import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

// ignore: must_be_immutable
///[CometChatOutgoingCall] is a widget which is used to show outgoing call screen.
///when the logged-in user calls another user
///
/// ```dart
/// CometChatOutgoingCall(
///  call: call,
///  user: user,
///  onError: (error) {
///  print("Error: $error");
///  },
///  onCancelled: (context, call) {
///  print("Decline Call");
///  },
///  declineButtonIcon: Icon(Icons.call_end),
///  style: CometChatOutgoingCallStyle(
///  backgroundColor: Colors.white,
///  titleColor: Colors.black,
///  subtitleColor: Colors.black,
///  iconColor: Colors.black,
///  ),
///  );
/// ```
///
//ignore: must_be_immutable
class CometChatOutgoingCall extends StatelessWidget {
  ///[user] is used to define the user for which this widget is rendered and call is initiated.
  final User? user;

  ///[subtitleView] is used to define the subtitle for the widget.
  final Widget? Function(BuildContext context, Call call)? subtitleView;

  ///[declineButtonIconUrl] is used to define the decline button icon url for the widget.
  final Widget? declineButtonIcon;

  ///[outgoingCallStyle] is used to set a custom outgoing call style
  final CometChatOutgoingCallStyle? outgoingCallStyle;

  ///[callSettingsBuilder] is used to set the call settings
  final CallSettingsBuilder? callSettingsBuilder;

  ///[height] is used to set the height of the widget.
  final double? height;

  ///[width] is used to set the width of the widget.
  final double? width;

  ///[avatarView] is used to define the avatar view.
  final Widget? Function(BuildContext context, Call call)? avatarView;

  ///[titleView] is used to define the title view.
  final Widget? Function(BuildContext context, Call call)? titleView;

  ///[cancelledView] is used to define the cancelled view.
  final Widget? Function(BuildContext context, Call call)? cancelledView;

  final CometChatOutgoingCallController _outgoingCallController;

  CometChatOutgoingCall({
    Key? key,
    required Call call,
    this.user,
    OnError? onError,
    Function(BuildContext context, Call call)? onCancelled,
    this.subtitleView,
    bool? disableSoundForCalls,
    String? customSoundForCalls,
    String? customSoundForCallsPackage,
    this.declineButtonIcon,
    this.outgoingCallStyle,
    this.callSettingsBuilder,
    this.width,
    this.height,
    this.avatarView,
    this.titleView,
    this.cancelledView,
  })  : _outgoingCallController = CometChatOutgoingCallController(
          activeCall: call,
          disableSoundForCalls: disableSoundForCalls,
          customSoundForCalls: customSoundForCalls,
          customSoundForCallsPackage: customSoundForCallsPackage,
          onError: onError,
          onCancelledCallTap: onCancelled,
          callSettingsBuilder: callSettingsBuilder,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = CometChatThemeHelper.getTheme<CometChatOutgoingCallStyle>(
            context: context, defaultTheme: CometChatOutgoingCallStyle.of)
        .merge(outgoingCallStyle);
    final typography = CometChatThemeHelper.getTypography(context);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Translations.of(context).popScreenDisabled,
              style: TextStyle(
                color: colorPalette.white,
                fontSize: typography.button?.medium?.fontSize,
                fontWeight: typography.button?.medium?.fontWeight,
                fontFamily: typography.button?.medium?.fontFamily,
              ),
            ),
            backgroundColor: colorPalette.error,
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: colorPalette.transparent,
        body: Container(
          height: height ?? double.infinity,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: style.backgroundColor ?? colorPalette.background1,
            border: style.border,
            borderRadius: style.borderRadius,
          ),
          child: GetBuilder(
            init: _outgoingCallController,
            global: false,
            dispose: (GetBuilderState<CometChatOutgoingCallController> state) =>
                state.controller?.onClose(),
            builder: (CometChatOutgoingCallController viewModel) {
              viewModel.context = context;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.padding5 ?? 0,
                  vertical: spacing.padding5 ?? 0,
                ),
                child: CometChatCard(
                  title: user?.name,
                  avatarName: user?.name,
                  avatarUrl: user?.avatar,
                  titleView: _getTitleView(context, viewModel.activeCall),
                  avatarHeight: 120,
                  avatarWidth: 120,
                  titlePadding: EdgeInsets.only(
                    bottom: spacing.padding2 ?? 0,
                  ),
                  subtitleView: _getSubtitleView(context, viewModel.activeCall,
                      spacing, typography, colorPalette, style),
                  avatarView: _getAvatarView(context, viewModel.activeCall),
                  cardStyle: CardStyle(
                    titleStyle: TextStyle(
                      fontSize: typography.heading1?.bold?.fontSize,
                      fontWeight: typography.heading1?.bold?.fontWeight,
                      fontFamily: typography.heading1?.bold?.fontFamily,
                      color: style.titleColor ?? colorPalette.textPrimary,
                    )
                        .merge(
                          style.titleTextStyle,
                        )
                        .copyWith(
                          color: style.titleColor,
                        ),
                    avatarStyle: CometChatAvatarStyle(
                      placeHolderTextStyle: TextStyle(
                        fontSize: typography.heading1?.bold?.fontSize,
                        fontWeight: typography.heading1?.bold?.fontWeight,
                        fontFamily: typography.heading1?.bold?.fontFamily,
                      ).merge(
                        style.avatarStyle?.placeHolderTextStyle,
                      ),
                      backgroundColor: style.avatarStyle?.backgroundColor,
                      placeHolderTextColor:
                          style.avatarStyle?.placeHolderTextColor,
                      borderRadius: style.avatarStyle?.borderRadius,
                      border: style.avatarStyle?.border,
                    ),
                  ),
                  bottomView: _getCancelledView(
                    context,
                    viewModel.activeCall,
                    spacing,
                    typography,
                    colorPalette,
                    style,
                    viewModel,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getSubtitleView(
      BuildContext context,
      Call call,
      CometChatSpacing spacing,
      CometChatTypography typography,
      CometChatColorPalette colorPalette,
      CometChatOutgoingCallStyle outgoingCallStyle) {
    if (subtitleView != null) {
      return subtitleView!(context, call)!;
    } else {
      return Padding(
        padding: EdgeInsets.only(
          bottom: spacing.padding10 ?? 0,
        ),
        child: Text(
          Translations.of(context).calling,
          style: TextStyle(
            fontSize: typography.body?.regular?.fontSize,
            fontWeight: typography.body?.regular?.fontWeight,
            fontFamily: typography.body?.regular?.fontFamily,
            color:
                outgoingCallStyle.subtitleColor ?? colorPalette.textSecondary,
          )
              .merge(
                outgoingCallStyle.subtitleTextStyle,
              )
              .copyWith(
                color: outgoingCallStyle.subtitleColor,
              ),
        ),
      );
    }
  }

  Widget? _getAvatarView(BuildContext context, Call call) {
    if (avatarView != null) {
      return avatarView!(context, call);
    } else {
      return null;
    }
  }

  Widget? _getTitleView(BuildContext context, Call call) {
    if (titleView != null) {
      return titleView!(context, call);
    } else {
      return null;
    }
  }

  Widget? _getCancelledView(
      BuildContext context,
      Call call,
      CometChatSpacing spacing,
      CometChatTypography typography,
      CometChatColorPalette colorPalette,
      CometChatOutgoingCallStyle outgoingCallStyle,
      CometChatOutgoingCallController viewModel) {
    if (cancelledView != null) {
      return cancelledView!(context, call);
    } else {
      return Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: outgoingCallStyle.declineButtonColor ?? colorPalette.error,
          borderRadius: outgoingCallStyle.declineButtonBorderRadius ??
              BorderRadius.circular(spacing.radiusMax ?? 0),
        ),
        child: IconButton(
          onPressed: () {
            viewModel.rejectCall(context, colorPalette, typography);
          },
          icon: declineButtonIcon ??
              Icon(
                Icons.call_end,
                size: 32,
                color: outgoingCallStyle.iconColor ?? colorPalette.white,
              ),
        ),
      );
    }
  }
}
