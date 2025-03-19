import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// [CometChatCallButtons] is a button widget with voice and video call icons.
///
/// ```dart
/// CometChatCallButtons(
///   user: User(),
///   group: Group(),
/// );
/// ```
class CometChatCallButtons extends StatelessWidget {
  CometChatCallButtons({
    Key? key,
    this.user,
    this.group,
    this.callButtonsStyle,
    OnError? onError,
    this.hideVideoCallButton,
    this.hideVoiceCallButton,
    this.voiceCallIcon,
    this.videoCallIcon,
    this.outgoingCallConfiguration,
    this.callSettingsBuilder,
  })  : _callButtonsController = CometChatCallButtonsController(
            user: user,
            group: group,
            onError: onError,
            outgoingCallConfiguration: outgoingCallConfiguration,
            callSettingsBuilder: callSettingsBuilder),
        super(key: key);

  ///[user] is a object of [User] for which call is to be initiated
  final User? user;

  ///[group] is a object of [Group] for which call is to be initiated
  final Group? group;

  ///[callButtonsStyle] is a object of [CometChatCallButtonsStyle] which sets the style for the call buttons
  final CometChatCallButtonsStyle? callButtonsStyle;

  ///[hideVoiceCallButton] is a bool which hides the voice call icon
  final bool? hideVoiceCallButton;

  ///[hideVideoCallButton] is a bool which hides the video call icon
  final bool? hideVideoCallButton;

  ///[voiceCallIcon] is a Widget which sets the icon for the voice call
  final Widget? voiceCallIcon;

  ///[videoCallIcon] is a Widget which sets the icon for the video call
  final Widget? videoCallIcon;

  ///[outgoingCallConfiguration] is a object of [OutgoingCallConfiguration] which sets the configuration for outgoing call
  final CometChatOutgoingCallConfiguration? outgoingCallConfiguration;

  ///[callSettingsBuilder] is used to configure the meet settings builder
  final CallSettingsBuilder Function(
      User? user, Group? group, bool? isAudioOnly)? callSettingsBuilder;

  ///[_callButtonsController] is an instance of [CometChatCallButtonsController] the view model of this widget
  final CometChatCallButtonsController _callButtonsController;

  @override
  Widget build(BuildContext context) {
    final style =
        CometChatThemeHelper.getTheme<CometChatCallButtonsStyle>(
                context: context, defaultTheme: CometChatCallButtonsStyle.of)
            .merge(callButtonsStyle);
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    return Material(
      color: colorPalette.transparent ?? Colors.transparent,
      child: GetBuilder(
        init: _callButtonsController,
        global: false,
        dispose: (GetBuilderState<CometChatCallButtonsController> state) =>
            state.controller?.onClose(),
        builder: (CometChatCallButtonsController viewModel) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hideVoiceCallButton != true)
                IconButton(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          style.voiceCallButtonBorderRadius ??
                              BorderRadius.circular(0),
                      side: style.voiceCallButtonBorder ??
                          BorderSide.none,
                    ),
                    backgroundColor: style.voiceCallButtonColor,
                  ),
                  onPressed: () {
                    if (!viewModel.disabled) {
                      viewModel.initiateCall(
                          CallTypeConstants.audioCall, context);
                    }
                  },
                  icon: voiceCallIcon ??
                      Icon(
                        Icons.call_outlined,
                        size: 24,
                        color: style.voiceCallIconColor ??
                            colorPalette.iconPrimary,
                      ),
                ),
              if (hideVideoCallButton != true)
                IconButton(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          style.videoCallButtonBorderRadius ??
                              BorderRadius.circular(0),
                      side: style.videoCallButtonBorder ??
                          BorderSide.none,
                    ),
                    backgroundColor: style.videoCallButtonColor,
                  ),
                  onPressed: () {
                    if (viewModel.disabled == false) {
                      viewModel.initiateCall(
                          CallTypeConstants.videoCall, context);
                    }
                  },
                  icon: videoCallIcon ??
                      SvgPicture.asset(
                        SvgAssetConstants.videoCall,
                        height: 24,
                        width: 24,
                        color: style.videoCallIconColor ??
                            colorPalette.iconPrimary,
                        package: UIConstants.packageName,
                      ),
                ),
            ],
          );
        },
      ),
    );
  }
}
