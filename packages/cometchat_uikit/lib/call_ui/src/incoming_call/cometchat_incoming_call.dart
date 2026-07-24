import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cometchat_calls_uikit.dart';
import '../../../cometchat_chat_uikit.dart';

/// [CometChatIncomingCall] is a widget which is used to display incoming call.
/// When the logged in user receives a call, this widget will be invoked.
///
/// ```dart
/// CometChatIncomingCall(
///   call: call,
///   user: user,
///   subtitle: 'Incoming Call',
///   declineButtonText: 'Decline',
///   declineButtonTextStyle: TextStyle(color: Colors.white),
///   declineButtonIconUrl: 'assets/images/decline.png',
///   declineButtonIconUrlPackage: 'assets',
///   acceptButtonText: 'Accept',
///   acceptButtonTextStyle: TextStyle(color: Colors.white),
/// );
/// ```
class CometChatIncomingCall extends StatefulWidget {
  /// [call] active Call object
  final Call call;

  /// [user] is used to set a custom user for the widget
  final User? user;

  /// [incomingCallStyle] is used to set a custom incoming call style
  final CometChatIncomingCallStyle? incomingCallStyle;

  /// [callSettingsBuilder] is used to set the session settings (V5)
  final SessionSettingsBuilder? callSettingsBuilder;

  /// [height] is used to set the height of the widget.
  final double? height;

  /// [width] is used to set the width of the widget.
  final double? width;

  /// [declineButtonText] is used to set a custom decline text
  final String? declineButtonText;

  /// [acceptButtonText] is used to set a custom accept text
  final String? acceptButtonText;

  /// [callIcon] is used to set a custom call icon
  final Widget? callIcon;

  /// [titleView] is used to define the title view.
  final Widget? Function(BuildContext context, Call call)? titleView;

  /// [subTitleView] is used to define the subtitle view.
  final Widget? Function(BuildContext context, Call call)? subTitleView;

  /// [leadingView] is used to define the leading view.
  final Widget? Function(BuildContext context, Call call)? leadingView;

  /// [itemView] is used to define the item view.
  final Widget? Function(BuildContext context, Call call)? itemView;

  /// [trailingView] is used to define the trailing view.
  final Widget? Function(BuildContext context, Call call)? trailingView;

  /// [onDecline] is called when the call is declined
  final Function(BuildContext, Call)? onDecline;

  /// [onAccept] is called when the call is accepted
  final Function(BuildContext, Call)? onAccept;

  /// [onError] is called when some error occurs
  final OnError? onError;

  /// [disableSoundForCalls] is used to define whether to disable sound for call or not.
  final bool? disableSoundForCalls;

  /// [customSoundForCalls] is used to define the custom sound for calls.
  final String? customSoundForCalls;

  /// [customSoundForCallsPackage] is used to define the custom sound for calls.
  final String? customSoundForCallsPackage;

  /// [incomingCallBloc] Optional external IncomingCallBloc instance.
  /// If provided, this bloc will be used instead of creating a new one internally.
  final IncomingCallBloc? incomingCallBloc;

  const CometChatIncomingCall({
    super.key,
    required this.call,
    this.user,
    this.onError,
    this.onDecline,
    this.onAccept,
    this.disableSoundForCalls,
    this.customSoundForCalls,
    this.customSoundForCallsPackage,
    this.incomingCallStyle,
    this.callSettingsBuilder,
    this.height,
    this.width,
    this.declineButtonText,
    this.acceptButtonText,
    this.callIcon,
    this.titleView,
    this.subTitleView,
    this.leadingView,
    this.itemView,
    this.trailingView,
    this.incomingCallBloc,
  });

  @override
  State<CometChatIncomingCall> createState() => _CometChatIncomingCallState();
}

class _CometChatIncomingCallState extends State<CometChatIncomingCall> {
  /// BLoC to manage incoming call state
  late IncomingCallBloc _incomingCallBloc;

  /// Track if bloc is external (should not be closed by this widget)
  bool _isExternalBloc = false;

  /// Flag to track if theme has been initialized
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

  /// Cached theme values
  late CometChatIncomingCallStyle _style;
  late CometChatTypography _typography;
  late CometChatColorPalette _colorPalette;
  late CometChatSpacing _spacing;

  @override
  void initState() {
    super.initState();

    // Use external bloc if provided, otherwise create a new one
    if (widget.incomingCallBloc != null) {
      _incomingCallBloc = widget.incomingCallBloc!;
      _isExternalBloc = true;
    } else {
      _incomingCallBloc = IncomingCallBloc(
        call: widget.call,
        user: widget.user,
        callSettingsBuilder: widget.callSettingsBuilder,
        onDecline: widget.onDecline,
        onAccept: widget.onAccept,
        disableSoundForCalls: widget.disableSoundForCalls,
        customSoundForCalls: widget.customSoundForCalls,
        customSoundForCallsPackage: widget.customSoundForCallsPackage,
        errorCallback: widget.onError,
      );
      _isExternalBloc = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize theme once to avoid expensive lookups during rebuilds
    // But re-initialize when brightness changes (dark mode toggle)
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged =
        _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (_themeInitialized && !brightnessChanged) return;
    _cachedBrightness = currentBrightness;
    _themeInitialized = true;

    _typography = CometChatThemeHelper.getTypography(context);
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    _spacing = CometChatThemeHelper.getSpacing(context);
    _style = CometChatThemeHelper.getTheme<CometChatIncomingCallStyle>(
      context: context,
      defaultTheme: CometChatIncomingCallStyle.of,
    ).merge(widget.incomingCallStyle);
  }

  @override
  void dispose() {
    // Only close the bloc if we created it internally
    if (!_isExternalBloc) {
      _incomingCallBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
      child: BlocProvider.value(
        value: _incomingCallBloc,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // Use custom itemView if provided
    if (widget.itemView != null) {
      return widget.itemView!(context, widget.call)!;
    }

    return Container(
      height: widget.height,
      width: widget.width,
      padding: EdgeInsets.all(_spacing.padding5 ?? 0),
      decoration: BoxDecoration(
        color: _style.backgroundColor ?? _colorPalette.background3,
        border:
            _style.border ??
            Border.all(
              width: 1,
              color: _colorPalette.borderLight ?? Colors.transparent,
            ),
        borderRadius:
            _style.borderRadius ?? BorderRadius.circular(_spacing.radius3 ?? 0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10182808),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x10182814),
            offset: Offset(0, 12),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: BlocConsumer<IncomingCallBloc, IncomingCallState>(
        // Only rebuild on status changes to optimize performance
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.isDisabled != current.isDisabled,
        listener: _handleStateChanges,
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: _spacing.padding4 ?? 0),
                child: ListTile(
                  horizontalTitleGap: 0,
                  contentPadding: EdgeInsets.zero,
                  minLeadingWidth: 0,
                  minVerticalPadding: 0,
                  minTileHeight: 0,
                  leading: _getLeadingView(context),
                  title: _getTitleView(context),
                  subtitle: _getSubTitleView(context),
                  trailing: _getTrailingView(context),
                ),
              ),
              _buildActionButtons(context, state),
            ],
          );
        },
      ),
    );
  }

  /// Handle state changes for side effects
  void _handleStateChanges(BuildContext context, IncomingCallState state) {
    // Handle error state by showing snackbar if no custom error handler
    if (state.status == IncomingCallStatus.error &&
        state.errorMessage != null &&
        widget.onError == null) {
      _showErrorSnackbar(context, state.errorMessage!);
    }
  }

  /// Show error snackbar
  void _showErrorSnackbar(BuildContext context, String message) {
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
  }

  /// Build action buttons (Decline and Accept)
  Widget _buildActionButtons(BuildContext context, IncomingCallState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Decline button
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: _spacing.padding2 ?? 0),
            child: TextButton(
              onPressed: () {
                _incomingCallBloc.add(const RejectCall());
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  _style.declineButtonColor ?? _colorPalette.error,
                ),
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: _colorPalette.borderDark ?? Colors.transparent,
                    width: 1,
                  ),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    side: BorderSide(
                      color: _colorPalette.borderDark ?? Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(_spacing.radius2 ?? 0),
                    ),
                  ),
                ),
              ),
              child: Text(
                widget.declineButtonText ?? Translations.of(context).decline,
                style:
                    TextStyle(
                          fontSize: _typography.button?.medium?.fontSize,
                          fontWeight: _typography.button?.medium?.fontWeight,
                          fontFamily: _typography.button?.medium?.fontFamily,
                          color:
                              _style.declineTextColor ??
                              _colorPalette.buttonIconColor,
                        )
                        .merge(_style.declineTextStyle)
                        .copyWith(color: _style.declineTextColor),
              ),
            ),
          ),
        ),
        // Accept button
        Expanded(
          child: TextButton(
            onPressed: state.isDisabled
                ? null
                : () {
                    _incomingCallBloc.add(const AcceptCall());
                  },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                _style.acceptButtonColor ?? _colorPalette.success,
              ),
              side: WidgetStateProperty.all(
                BorderSide(
                  color: _colorPalette.borderDark ?? Colors.transparent,
                  width: 1,
                ),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                    color: _colorPalette.borderDark ?? Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(_spacing.radius2 ?? 0),
                  ),
                ),
              ),
            ),
            child: Text(
              widget.acceptButtonText ?? Translations.of(context).accept,
              style:
                  TextStyle(
                        fontSize: _typography.button?.medium?.fontSize,
                        fontWeight: _typography.button?.medium?.fontWeight,
                        fontFamily: _typography.button?.medium?.fontFamily,
                        color:
                            _style.acceptTextColor ??
                            _colorPalette.buttonIconColor,
                      )
                      .merge(_style.acceptTextStyle)
                      .copyWith(color: _style.acceptTextColor),
            ),
          ),
        ),
      ],
    );
  }

  /// Leading view
  Widget? _getLeadingView(BuildContext context) {
    if (widget.leadingView != null) {
      return widget.leadingView!(context, widget.call);
    }
    return null;
  }

  /// Title view
  Widget _getTitleView(BuildContext context) {
    if (widget.titleView != null) {
      return widget.titleView!(context, widget.call)!;
    }
    return Text(
      widget.user?.name ?? '',
      style: TextStyle(
        fontSize: _typography.heading1?.bold?.fontSize,
        fontWeight: _typography.heading1?.bold?.fontWeight,
        fontFamily: _typography.heading1?.bold?.fontFamily,
        color: _style.titleColor ?? _colorPalette.textPrimary,
      ).merge(_style.titleTextStyle).copyWith(color: _style.titleColor),
    );
  }

  /// Subtitle view
  Widget _getSubTitleView(BuildContext context) {
    if (widget.subTitleView != null) {
      return widget.subTitleView!(context, widget.call)!;
    }
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: _spacing.padding ?? 0),
          child:
              widget.callIcon ??
              Icon(
                Icons.call,
                color: _style.callIconColor ?? _colorPalette.iconSecondary,
                size: 16,
              ),
        ),
        Text(
          _incomingCallBloc.getSubtitle(context),
          style:
              TextStyle(
                    fontSize: _typography.body?.regular?.fontSize,
                    fontWeight: _typography.body?.regular?.fontWeight,
                    fontFamily: _typography.body?.regular?.fontFamily,
                    color: _style.subtitleColor ?? _colorPalette.textSecondary,
                  )
                  .merge(_style.subtitleTextStyle)
                  .copyWith(color: _style.subtitleColor),
        ),
      ],
    );
  }

  /// Trailing view
  Widget _getTrailingView(BuildContext context) {
    if (widget.trailingView != null) {
      return widget.trailingView!(context, widget.call)!;
    }
    return CometChatAvatar(
      height: 48,
      width: 48,
      image: widget.user?.avatar,
      name: widget.user?.name,
      style: CometChatAvatarStyle(
        placeHolderTextStyle: TextStyle(
          fontSize: _typography.heading1?.bold?.fontSize,
          fontWeight: _typography.heading1?.bold?.fontWeight,
          fontFamily: _typography.heading1?.bold?.fontFamily,
        ).merge(_style.avatarStyle?.placeHolderTextStyle),
        backgroundColor: _style.avatarStyle?.backgroundColor,
        placeHolderTextColor: _style.avatarStyle?.placeHolderTextColor,
        borderRadius: _style.avatarStyle?.borderRadius,
        border: _style.avatarStyle?.border,
      ),
    );
  }
}
