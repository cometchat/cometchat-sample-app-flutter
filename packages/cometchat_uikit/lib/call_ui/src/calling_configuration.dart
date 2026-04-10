import 'call_buttons/cometchat_call_buttons_configuration.dart';
import 'incoming_call/cometchat_incoming_call_configuration.dart';
import 'outgoing_call/cometchat_outgoing_call_configuration.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;

class CallingConfiguration {
  CallingConfiguration({
    this.outgoingCallConfiguration,
    this.incomingCallConfiguration,
    this.callButtonsConfiguration,
    this.groupSessionSettingsBuilder,
  });

  ///[outgoingCallConfiguration] is a object of [OutgoingCallConfiguration] which sets the configuration for outgoing call
  final CometChatOutgoingCallConfiguration? outgoingCallConfiguration;

  ///[incomingCallConfiguration] is a object of [CometChatIncomingCallConfiguration] which sets the configuration for incoming call
  final CometChatIncomingCallConfiguration? incomingCallConfiguration;

  ///[callButtonsConfiguration] is a object of [CallButtonsConfiguration] which sets the configuration for call buttons
  final CallButtonsConfiguration? callButtonsConfiguration;

  ///[groupSessionSettingsBuilder] is used to configure the meet session settings
  final SessionSettingsBuilder? groupSessionSettingsBuilder;
}
