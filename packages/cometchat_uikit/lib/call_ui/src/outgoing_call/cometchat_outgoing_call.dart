import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cometchat_calls_uikit.dart';
import '../../../cometchat_chat_uikit.dart';

/// [CometChatOutgoingCall] is a widget which is used to show outgoing call screen
/// when the logged-in user calls another user.
///
/// ```dart
/// CometChatOutgoingCall(
///   call: call,
///   user: user,
///   onError: (error) {
///     print("Error: $error");
///   },
///   onCancelled: (context, call) {
///     print("Decline Call");
///   },
///   declineButtonIcon: Icon(Icons.call_end),
///   style: CometChatOutgoingCallStyle(
///     backgroundColor: Colors.white,
///     titleColor: Colors.black,
///     subtitleColor: Colors.black,
///     iconColor: Colors.black,
///   ),
/// );
/// ```
class CometChatOutgoingCall extends StatefulWidget {
  /// The active outgoing call
  final Call call;

  /// User being called (optional, for display purposes)
  final User? user;

  /// Subtitle view builder
  final Widget? Function(BuildContext context, Call call)? subtitleView;

  /// Custom decline button icon
  final Widget? declineButtonIcon;

  /// Custom outgoing call style
  final CometChatOutgoingCallStyle? outgoingCallStyle;

  /// Custom session settings builder (V5)
  final SessionSettingsBuilder? sessionSettingsBuilder;

  /// Widget height
  final double? height;

  /// Widget width
  final double? width;

  /// Avatar view builder
  final Widget? Function(BuildContext context, Call call)? avatarView;

  /// Title view builder
  final Widget? Function(BuildContext context, Call call)? titleView;

  /// Cancelled view builder (bottom action button)
  final Widget? Function(BuildContext context, Call call)? cancelledView;

  /// Error callback
  final OnError? onError;

  /// Callback when call is cancelled
  final Function(BuildContext context, Call call)? onCancelled;

  /// Whether to disable sound for calls
  final bool? disableSoundForCalls;

  /// Custom sound asset for calls
  final String? customSoundForCalls;

  /// Package name for custom sound asset
  final String? customSoundForCallsPackage;

  /// Optional external BLoC for testing/injection
  final OutgoingCallBloc? bloc;

  const CometChatOutgoingCall({
    super.key,
    required this.call,
    this.user,
    this.onError,
    this.onCancelled,
    this.subtitleView,
    this.disableSoundForCalls,
    this.customSoundForCalls,
    this.customSoundForCallsPackage,
    this.declineButtonIcon,
    this.outgoingCallStyle,
    this.sessionSettingsBuilder,
    this.width,
    this.height,
    this.avatarView,
    this.titleView,
    this.cancelledView,
    this.bloc,
  });

  @override
  State<CometChatOutgoingCall> createState() => _CometChatOutgoingCallState();
}

class _CometChatOutgoingCallState extends State<CometChatOutgoingCall> {
  late OutgoingCallBloc _bloc;
  bool _isExternalBloc = false;

  // Cached theme values
  late CometChatColorPalette _colorPalette;
  late CometChatSpacing _spacing;
  late CometChatTypography _typography;
  late CometChatOutgoingCallStyle _style;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  @override
  void initState() {
    super.initState();
    _isExternalBloc = widget.bloc != null;
    _bloc =
        widget.bloc ??
        OutgoingCallBloc(
          call: widget.call,
          user: widget.user,
          callSettingsBuilder: widget.sessionSettingsBuilder,
          onCancelledCallTap: widget.onCancelled,
          disableSoundForCalls: widget.disableSoundForCalls,
          customSoundForCalls: widget.customSoundForCalls,
          customSoundForCallsPackage: widget.customSoundForCallsPackage,
          errorCallback: widget.onError,
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged =
        _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      _colorPalette = CometChatThemeHelper.getColorPalette(context);
      _spacing = CometChatThemeHelper.getSpacing(context);
      _typography = CometChatThemeHelper.getTypography(context);
      _style = CometChatThemeHelper.getTheme<CometChatOutgoingCallStyle>(
        context: context,
        defaultTheme: CometChatOutgoingCallStyle.of,
      ).merge(widget.outgoingCallStyle);
      _themeInitialized = true;
    }
  }

  @override
  void dispose() {
    if (!_isExternalBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OutgoingCallBloc>.value(
      value: _bloc,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Translations.of(context).popScreenDisabled,
                  style: TextStyle(
                    color: _colorPalette.white,
                    fontSize: _typography.button?.medium?.fontSize,
                    fontWeight: _typography.button?.medium?.fontWeight,
                    fontFamily: _typography.button?.medium?.fontFamily,
                  ),
                ),
                backgroundColor: _colorPalette.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: _colorPalette.transparent,
          body: Container(
            height: widget.height ?? double.infinity,
            width: widget.width ?? double.infinity,
            decoration: BoxDecoration(
              color: _style.backgroundColor ?? _colorPalette.background1,
              border: _style.border,
              borderRadius: _style.borderRadius,
            ),
            child: BlocConsumer<OutgoingCallBloc, OutgoingCallState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status,
              listener: _handleStateChanges,
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _spacing.padding5 ?? 0,
                    vertical: _spacing.padding5 ?? 0,
                  ),
                  child: CometChatCard(
                    title: widget.user?.name,
                    avatarName: widget.user?.name,
                    avatarUrl: widget.user?.avatar,
                    titleView: _getTitleView(context, widget.call),
                    avatarHeight: 120,
                    avatarWidth: 120,
                    titlePadding: EdgeInsets.only(
                      bottom: _spacing.padding2 ?? 0,
                    ),
                    subtitleView: _getSubtitleView(context, widget.call),
                    avatarView: _getAvatarView(context, widget.call),
                    cardStyle: CardStyle(
                      titleStyle:
                          TextStyle(
                                fontSize: _typography.heading1?.bold?.fontSize,
                                fontWeight:
                                    _typography.heading1?.bold?.fontWeight,
                                fontFamily:
                                    _typography.heading1?.bold?.fontFamily,
                                color:
                                    _style.titleColor ??
                                    _colorPalette.textPrimary,
                              )
                              .merge(_style.titleTextStyle)
                              .copyWith(color: _style.titleColor),
                      avatarStyle: CometChatAvatarStyle(
                        placeHolderTextStyle: TextStyle(
                          fontSize: _typography.heading1?.bold?.fontSize,
                          fontWeight: _typography.heading1?.bold?.fontWeight,
                          fontFamily: _typography.heading1?.bold?.fontFamily,
                        ).merge(_style.avatarStyle?.placeHolderTextStyle),
                        backgroundColor: _style.avatarStyle?.backgroundColor,
                        placeHolderTextColor:
                            _style.avatarStyle?.placeHolderTextColor,
                        borderRadius: _style.avatarStyle?.borderRadius,
                        border: _style.avatarStyle?.border,
                      ),
                    ),
                    bottomView: _getCancelledView(context, widget.call, state),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, OutgoingCallState state) {
    if (state.status == OutgoingCallStatus.error &&
        state.errorMessage != null) {
      _showError(context, state.errorMessage!);
    }
  }

  Widget _getSubtitleView(BuildContext context, Call call) {
    if (widget.subtitleView != null) {
      return widget.subtitleView!(context, call)!;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: _spacing.padding10 ?? 0),
      child: Text(
        Translations.of(context).calling,
        style: TextStyle(
          fontSize: _typography.body?.regular?.fontSize,
          fontWeight: _typography.body?.regular?.fontWeight,
          fontFamily: _typography.body?.regular?.fontFamily,
          color: _style.subtitleColor ?? _colorPalette.textSecondary,
        ).merge(_style.subtitleTextStyle).copyWith(color: _style.subtitleColor),
      ),
    );
  }

  Widget? _getAvatarView(BuildContext context, Call call) {
    return widget.avatarView?.call(context, call);
  }

  Widget? _getTitleView(BuildContext context, Call call) {
    return widget.titleView?.call(context, call);
  }

  Widget _getCancelledView(
    BuildContext context,
    Call call,
    OutgoingCallState state,
  ) {
    if (widget.cancelledView != null) {
      return widget.cancelledView!(context, call)!;
    }
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: _style.declineButtonColor ?? _colorPalette.error,
        borderRadius:
            _style.declineButtonBorderRadius ??
            BorderRadius.circular(_spacing.radiusMax ?? 0),
      ),
      child: IconButton(
        onPressed: state.isCallRejected
            ? null
            : () => _bloc.add(const CancelCall()),
        icon:
            widget.declineButtonIcon ??
            Icon(
              Icons.call_end,
              size: 32,
              color: _style.iconColor ?? _colorPalette.white,
            ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _colorPalette.error,
          content: Text(
            Translations.of(context).somethingWentWrongError,
            style: TextStyle(
              color: _colorPalette.white,
              fontSize: _typography.button?.medium?.fontSize,
              fontWeight: _typography.button?.medium?.fontWeight,
              fontFamily: _typography.button?.medium?.fontFamily,
            ),
          ),
        ),
      );
    } catch (_) {}
  }
}
