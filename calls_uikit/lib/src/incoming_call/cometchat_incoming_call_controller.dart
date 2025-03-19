import 'package:flutter/foundation.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart' as kit;

/// [CometChatIncomingCallController] is the view model class for [CometChatIncomingCall]
class CometChatIncomingCallController extends GetxController with CallListener {
  late BuildContext context;

  late String _listenerId;

  ///[onDecline] is called when the call is declined
  final Function(BuildContext, Call)? onDecline;

  ///[onAccept] is called when the call is accepted
  final Function(BuildContext, Call)? onAccept;

  ///[disableSoundForCalls] is used to define whether to disable sound for call or not.
  final bool? disableSoundForCalls;

  ///[customSoundForCalls] is used to define the custom sound for calls.
  final String? customSoundForCalls;

  ///[customSoundForCallsPackage] is used to define the custom sound for calls.
  final String? customSoundForCallsPackage;

  ///[callSettingsBuilder] is used to set the call settings
  final CallSettingsBuilder? callSettingsBuilder;

  final Call activeCall;

  ///[onError] is called when some error occurs
  final OnError? onError;

  CometChatIncomingCallController(
      {this.onDecline,
      this.onAccept,
      required this.activeCall,
      this.onError,
      this.disableSoundForCalls,
      this.customSoundForCalls,
      this.customSoundForCallsPackage,
      this.callSettingsBuilder});
  bool disabled = false;

  CallStateController? _callStateController;

  @override
  void onInit() {
    super.onInit();
    _callStateController = CallStateController.instance;
    _callStateController?.setActiveIncomingValue(true);
    _listenerId =
        "incomingCall_${DateTime.now().microsecondsSinceEpoch.toString()}";
    CometChat.addCallListener(_listenerId, this);
    if (disableSoundForCalls != true) {
      playIncomingSound();
    }
  }

  @override
  void onClose() {
    _callStateController?.setActiveIncomingValue(false);
    CometChat.removeCallListener(_listenerId);
    if (disableSoundForCalls != true) {
      stopSound();
    }
    super.onClose();
  }

  playIncomingSound() {
    try {
      CometChatUIKit.soundManager.play(
          sound: Sound.incomingCall,
          packageName: customSoundForCallsPackage ?? UIConstants.packageName,
          customSound: customSoundForCalls);
      developer.log('sound playing');
    } catch (_) {
      developer.log("Sound not played");
    }
  }

  stopSound() {
    try {
      CometChatUIKit.soundManager.stop();
    } catch (_) {
      developer.log('failed to stop sound player');
    }
  }

  ///[acceptCall] is the method to accept a call.
  acceptCall(BuildContext context, CometChatColorPalette colorPalette,
      CometChatTypography typography) {
    //executing custom onAccept method
    disabled = true;
    try {
      if (onAccept != null) {
        onAccept!(context, activeCall);
      }
    } on CometChatException catch (error) {
      if (onError != null) {
        onError!(error);
      } else {
        _showError(context, error, colorPalette, typography);
      }
    }

    String? sessionId = activeCall.sessionId;
    if (sessionId == null) {
      return;
    }
    CometChat.acceptCall(sessionId, onSuccess: (Call call) async {
      IncomingCallOverlay.dismiss();
      CometChatCallEvents.ccCallAccepted(call);
      bool? isAudioOnly;

      if (call.type == CallTypeConstants.audioCall) {
        isAudioOnly = true;
      }

      CallSettingsBuilder defaultCallSettingsBuilder = (CallSettingsBuilder()
        ..enableDefaultLayout = true
        ..setAudioOnlyCall = isAudioOnly);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CometChatOngoingCall(
              callSettingsBuilder:
                  callSettingsBuilder ?? defaultCallSettingsBuilder,
              sessionId: sessionId,
              callWorkFlow: CallWorkFlow.defaultCalling,
            ),
          ));

      if (kDebugMode) {
        debugPrint('call has been accepted successfully');
      }
    }, onError: (CometChatException e) {
      disabled = false;
      if (onError != null) {
        onError!(e);
      } else {
        _showError(
          context,
          e,
          colorPalette,
          typography,
        );
      }
      if (kDebugMode) {
        debugPrint('call could not be accepted ${e.message}');
      }
    });
  }

  void rejectCall(context, CometChatColorPalette colorPalette,
      CometChatTypography typography) {
    //executing custom onDecline method
    try {
      if (onDecline != null) {
        onDecline!(context, activeCall);
      }
    } on CometChatException catch (error) {
      if (onError != null) {
        onError!(error);
      } else {
        _showError(context, error, colorPalette, typography);
      }
    }

    if (activeCall.sessionId != null) {
      developer.log("trying to reject call ");
      CometChatUIKitCalls.rejectCall(
          activeCall.sessionId!, CallStatusConstants.rejected,
          onSuccess: (Call call) {
        call.category = MessageCategoryConstants.call;
        CometChatCallEvents.ccCallRejected(call);
        developer.log('incoming call was cancelled');

        // rejectCall.setValue(call);
        IncomingCallOverlay.dismiss();
      }, onError: (e) {
        developer.log("Unable to end call from incoming call screen");
        try {
          if (onError != null) {
            onError!(e);
          }
        } catch (err) {
          if (kDebugMode) {
            debugPrint('Error in rejecting call: ${e.message}');
          }
        }
        _handleCallRejection(null);
      });
    }
  }

  void _handleCallRejection(Call? call) {
    if (call != null) {
      call.category = MessageCategoryConstants.call;
      CometChatCallEvents.ccCallEnded(call);
    }
    IncomingCallOverlay.dismiss();
  }

  @override
  void onIncomingCallCancelled(Call call) {
    IncomingCallOverlay.dismiss();
  }

  void _showError(context, CometChatException e,
      CometChatColorPalette colorPalette, CometChatTypography typography) {
    try {
      var snackBar = SnackBar(
        backgroundColor: colorPalette.error,
        content: Text(
          kit.Translations.of(context).somethingWentWrongError,
          style: TextStyle(
            color: colorPalette.white,
            fontSize: typography.button?.medium?.fontSize,
            fontWeight: typography.button?.medium?.fontWeight,
            fontFamily: typography.button?.medium?.fontFamily,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error while displaying snackBar: $e");
      }
    }
  }

  String getSubtitle(BuildContext context) {
    return activeCall.type == CallTypeConstants.audioCall
        ? kit.Translations.of(context).incomingAudioCall
        : kit.Translations.of(context).incomingVideoCall;
  }
}
