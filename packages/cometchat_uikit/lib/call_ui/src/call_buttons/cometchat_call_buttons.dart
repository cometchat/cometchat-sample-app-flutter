import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../cometchat_calls_uikit.dart';
import '../../../cometchat_chat_uikit.dart';

/// [CometChatCallButtons] is a button widget with voice and video call icons.
///
/// This widget uses BLoC pattern for state management and supports both
/// user (direct call) and group (meeting) receivers.
///
/// ```dart
/// CometChatCallButtons(
///   user: User(),
///   group: Group(),
/// );
/// ```
class CometChatCallButtons extends StatefulWidget {
  const CometChatCallButtons({
    Key? key,
    this.user,
    this.group,
    this.callButtonsStyle,
    this.onError,
    this.hideVideoCallButton,
    this.hideVoiceCallButton,
    this.voiceCallIcon,
    this.videoCallIcon,
    this.outgoingCallConfiguration,
    this.callSettingsBuilder,
    this.callButtonsBloc,
  }) : super(key: key);

  final User? user;
  final Group? group;
  final CometChatCallButtonsStyle? callButtonsStyle;
  final OnError? onError;
  final bool? hideVoiceCallButton;
  final bool? hideVideoCallButton;
  final Widget? voiceCallIcon;
  final Widget? videoCallIcon;
  final CometChatOutgoingCallConfiguration? outgoingCallConfiguration;
  final SessionSettingsBuilder Function(
      User? user, Group? group, bool? isAudioOnly)? callSettingsBuilder;
  final CallButtonsBloc? callButtonsBloc;

  @override
  State<CometChatCallButtons> createState() => _CometChatCallButtonsState();
}


class _CometChatCallButtonsState extends State<CometChatCallButtons> {
  late CallButtonsBloc _callButtonsBloc;
  bool _isExternalBloc = false;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;
  late CometChatCallButtonsStyle _style;
  late CometChatColorPalette _colorPalette;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
  }

  void _initializeBloc() {
    if (widget.callButtonsBloc != null) {
      _callButtonsBloc = widget.callButtonsBloc!;
      _isExternalBloc = true;
    } else {
      _callButtonsBloc = CallButtonsBloc(
        user: widget.user,
        group: widget.group,
        outgoingCallConfiguration: widget.outgoingCallConfiguration,
        callSettingsBuilder: widget.callSettingsBuilder,
        errorCallback: widget.onError,
      );
      _isExternalBloc = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (_themeInitialized && !brightnessChanged) return;
    _cachedBrightness = currentBrightness;
    _themeInitialized = true;
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    _style = CometChatThemeHelper.getTheme<CometChatCallButtonsStyle>(
            context: context, defaultTheme: CometChatCallButtonsStyle.of)
        .merge(widget.callButtonsStyle);
  }

  @override
  void didUpdateWidget(CometChatCallButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.callButtonsStyle != oldWidget.callButtonsStyle &&
        widget.callButtonsStyle != null) {
      _style = CometChatThemeHelper.getTheme<CometChatCallButtonsStyle>(
              context: context, defaultTheme: CometChatCallButtonsStyle.of)
          .merge(widget.callButtonsStyle);
    }
    if (widget.callButtonsBloc != oldWidget.callButtonsBloc) {
      if (!_isExternalBloc) {
        _callButtonsBloc.close();
      }
      _initializeBloc();
    }
  }

  @override
  void dispose() {
    if (!_isExternalBloc) {
      _callButtonsBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _colorPalette.transparent ?? Colors.transparent,
      child: BlocProvider.value(
        value: _callButtonsBloc,
        child: BlocBuilder<CallButtonsBloc, CallButtonsState>(
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                if (widget.hideVoiceCallButton != true)
                  _buildVoiceCallButton(state),
                if (widget.hideVideoCallButton != true)
                  _buildVideoCallButton(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVoiceCallButton(CallButtonsState state) {
    final hasBorder = _style.voiceCallButtonBorder != null &&
        _style.voiceCallButtonBorder != BorderSide.none;
    return IconButton(
      tooltip: 'Voice call',
      padding: hasBorder
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
          : const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius:
              _style.voiceCallButtonBorderRadius ?? BorderRadius.circular(0),
          side: _style.voiceCallButtonBorder ?? BorderSide.none,
        ),
        backgroundColor: _style.voiceCallButtonColor,
      ),
      onPressed: state.isDisabled
          ? null
          : () => _callButtonsBloc.add(const InitiateVoiceCall()),
      icon: widget.voiceCallIcon ??
          Icon(
            Icons.call_outlined,
            size: 24,
            color: _style.voiceCallIconColor ?? _colorPalette.iconPrimary,
          ),
    );
  }

  Widget _buildVideoCallButton(CallButtonsState state) {
    final hasBorder = _style.videoCallButtonBorder != null &&
        _style.videoCallButtonBorder != BorderSide.none;
    return IconButton(
      tooltip: 'Video call',
      padding: hasBorder
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
          : const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius:
              _style.videoCallButtonBorderRadius ?? BorderRadius.circular(0),
          side: _style.videoCallButtonBorder ?? BorderSide.none,
        ),
        backgroundColor: _style.videoCallButtonColor,
      ),
      onPressed: state.isDisabled
          ? null
          : () => _callButtonsBloc.add(const InitiateVideoCall()),
      icon: widget.videoCallIcon ??
          SvgPicture.asset(
            SvgAssetConstants.videoCall,
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              _style.videoCallIconColor ??
                  _colorPalette.iconPrimary ??
                  Colors.black,
              BlendMode.srcIn,
            ),
            package: UIConstants.packageName,
          ),
    );
  }
}
