import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart' as kit;

/// [CometChatOngoingCall] is a widget that displays the ongoing call screen.
///
/// ```dart
/// CometChatOngoingCall(
///  callSettingsBuilder: CallSettingsBuilder(),
///  sessionId: "SESSION_ID",
///  callWorkFlow: CallWorkFlow.directCalling,
///  );
///
class CometChatOngoingCall extends StatelessWidget {
  CometChatOngoingCall(
      {Key? key,
      required CallSettingsBuilder callSettingsBuilder,
      required String sessionId,
      CallWorkFlow? callWorkFlow,
      OnError? onError})
      : _ongoingCallController = CometChatOngoingCallController(
            callSettingsBuilder: callSettingsBuilder,
            sessionId: sessionId,
            callWorkFlow: callWorkFlow,
            errorHandler: onError),
        super(key: key);

  final CometChatOngoingCallController _ongoingCallController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: GetBuilder(
          init: _ongoingCallController,
          global: false,
          dispose: (GetBuilderState<CometChatOngoingCallController> state) =>
              state.controller?.onClose(),
          builder: (CometChatOngoingCallController viewModel) {
            viewModel.context = context;
            return SafeArea(
              child: viewModel.callingWidget ??
                  Material(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: Colors.black),
                      child: Center(
                          child: Text(
                        kit.Translations.of(context).connecting,
                        style: const TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
            );
          }),
    );
  }
}
