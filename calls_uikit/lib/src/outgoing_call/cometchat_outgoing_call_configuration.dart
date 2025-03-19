import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';

///[CometChatOutgoingCallConfiguration] is a data class that has configuration properties for  [CometChatOutgoingCallScreen]
///
/// ```dart
/// CometChatOutgoingCallConfiguration(
/// theme: cometChatTheme,
/// subtitle: 'Calling',
/// declineButtonText: 'Decline',
/// declineButtonIconUrl: 'https://example.com/decline.png',
/// declineButtonIconUrlPackage: 'assets',
/// cardStyle: CardStyle( ),
/// buttonStyle: kit.ButtonStyle(
/// backgroundColor: Colors.red,
/// ),
/// onDecline: (context, call) {
/// print('Call Declined');
/// },
/// disableSoundForCalls: true,
/// customSoundForCalls: 'custom_sound_for_calls',
/// customSoundForCallsPackage: 'assets',
/// );
/// ```
///
class CometChatOutgoingCallConfiguration {
  CometChatOutgoingCallConfiguration({
    this.subtitleView,
    this.onCancelled,
    this.disableSoundForCalls,
    this.customSoundForCalls,
    this.customSoundForCallsPackage,
    this.onError,
    this.outgoingCallStyle,
    this.callSettingsBuilder,
    this.width,
    this.height,
    this.declineButtonIcon,
    this.avatarView,
    this.titleView,
    this.cancelledView,
  });

  ///[subtitleView] is used to define the subtitle for the widget.
  final Widget? Function(BuildContext, Call)? subtitleView;

  ///[onCancelled] is used to define the callback for the widget when decline call button is tapped.
  final Function(BuildContext, Call)? onCancelled;

  ///[disableSoundForCalls] is used to define whether to disable sound for call or not.
  final bool? disableSoundForCalls;

  ///[customSoundForCalls] is used to define the custom sound for calls.
  final String? customSoundForCalls;

  ///[customSoundForCallsPackage] is used to define the custom sound for calls.
  final String? customSoundForCallsPackage;

  ///[onError] is called when some error occurs
  final OnError? onError;

  ///[outgoingCallStyle] is used to set a custom incoming call style
  final CometChatOutgoingCallStyle? outgoingCallStyle;

  ///[callSettingsBuilder] is used to set the call settings
  final CallSettingsBuilder? callSettingsBuilder;

  ///[height] is used to set the height of the widget.
  final double? height;

  ///[width] is used to set the width of the widget.
  final double? width;

  ///[declineButtonIcon] is used to define the decline button icon for the widget.
  final Widget? declineButtonIcon;

  ///[avatarView] is used to define the avatar view.
  final Widget? Function(BuildContext, Call)? avatarView;

  ///[titleView] is used to define the avatar view.
  final Widget? Function(BuildContext, Call)? titleView;

  ///[cancelledView] is used to define the cancelled view.
  final Widget? Function(BuildContext, Call)? cancelledView;
}
