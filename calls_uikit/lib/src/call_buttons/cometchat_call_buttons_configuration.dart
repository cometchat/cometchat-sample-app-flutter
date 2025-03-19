import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';


///[CallButtonsConfiguration] is a data class that has configuration properties
///
/// ```dart
/// CallButtonsConfiguration(
///  callButtonsStyle: CometChatCallButtonsStyle(),
///  onError: (error) {
///  // Handle error
///  },
///  outgoingCallConfiguration: CometChatOutgoingCallConfiguration(),
///  hideVideoCall: false,
/// );
///
class CallButtonsConfiguration {
  CallButtonsConfiguration({
    this.callButtonsStyle,
    this.onError,
    this.outgoingCallConfiguration,
    this.hideVideoCallButton,
    this.hideVoiceCallButton,
    this.voiceCallIcon,
    this.videoCallIcon,
    this.callSettingsBuilder,
  });

  ///[callButtonsStyle] is a object of [CometChatCallButtonsStyle] which sets the style for the call buttons
  final CometChatCallButtonsStyle? callButtonsStyle;

  ///[onError] is a callback which gets called when there is an error in call
  final OnError? onError;

  ///[outgoingCallConfiguration] is a object of [OutgoingCallConfiguration] which sets the configuration for outgoing call
  final CometChatOutgoingCallConfiguration? outgoingCallConfiguration;

  ///[hideVoiceCallButton] is a bool which hides the voice call icon
  final bool? hideVoiceCallButton;

  ///[hideVideoCallButton] is a bool which hides the video call icon
  final bool? hideVideoCallButton;

  ///[voiceCallIcon] is a Widget which sets the icon for the voice call
  final Widget? voiceCallIcon;

  ///[videoCallIcon] is a Widget which sets the icon for the video call
  final Widget? videoCallIcon;

  ///[callSettingsBuilder] is used to configure the meet settings builder
  final CallSettingsBuilder Function(
      User? user, Group? group, bool? isAudioOnly)? callSettingsBuilder;
}
