import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cometchat_calls_uikit.dart';
import '../../../cometchat_chat_uikit.dart';

/// [CometChatOngoingCall] is a widget that displays the ongoing call screen.
///
/// ```dart
/// CometChatOngoingCall(
///   sessionSettingsBuilder: SessionSettingsBuilder(),
///   sessionId: "SESSION_ID",
///   callWorkFlow: CallWorkFlow.directCalling,
/// );
/// ```
class CometChatOngoingCall extends StatefulWidget {
  /// Session settings builder (V5)
  final SessionSettingsBuilder sessionSettingsBuilder;

  /// Session ID for the call
  final String sessionId;

  /// Call workflow type (directCalling or defaultCalling)
  final CallWorkFlow? callWorkFlow;

  /// Error callback
  final OnError? onError;

  /// Optional external BLoC for testing/injection
  final OngoingCallBloc? bloc;

  const CometChatOngoingCall({
    super.key,
    required this.sessionSettingsBuilder,
    required this.sessionId,
    this.callWorkFlow,
    this.onError,
    this.bloc,
  });

  @override
  State<CometChatOngoingCall> createState() => _CometChatOngoingCallState();
}

class _CometChatOngoingCallState extends State<CometChatOngoingCall> {
  late OngoingCallBloc _bloc;
  bool _isExternalBloc = false;

  @override
  void initState() {
    super.initState();
    _isExternalBloc = widget.bloc != null;
    _bloc =
        widget.bloc ??
        OngoingCallBloc(
          sessionSettingsBuilder: widget.sessionSettingsBuilder,
          sessionId: widget.sessionId,
          callWorkFlow: widget.callWorkFlow,
          errorCallback: widget.onError,
        );
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
    return BlocProvider<OngoingCallBloc>.value(
      value: _bloc,
      child: PopScope(
        canPop: false,
        child: BlocBuilder<OngoingCallBloc, OngoingCallState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.callingWidget != current.callingWidget,
          builder: (context, state) {
            if (state.status == OngoingCallStatus.error) {
              // Dismiss after a brief delay to show the error
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (CallScreenOverlay.isShowing) {
                  CallScreenOverlay.dismiss();
                } else if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              });
              return Material(
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Center(
                    child: Text(
                      state.errorMessage ?? 'Something went wrong',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            }

            // On Android the Calls SDK renders its own native UI outside
            // Flutter's widget tree. Return a transparent widget so the
            // native layer shows through. Skip the loading screen entirely.
            if (state.callingWidget == null &&
                !kIsWeb &&
                defaultTargetPlatform == TargetPlatform.android) {
              return const SizedBox.shrink();
            }

            return state.callingWidget ??
                Material(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.black),
                    child: Center(
                      child: Text(
                        Translations.of(context).connecting,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
          },
        ),
      ),
    );
  }
}
