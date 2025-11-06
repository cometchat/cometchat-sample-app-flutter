import 'package:flutter/material.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:sample_app_push_notifications/prefs/shared_preferences.dart';
import 'package:flutter/services.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static const platform = MethodChannel('com.cometchat.sampleapp.call');
  String? sessionId;
  String? callType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCallData();
  }

  void _loadCallData() async {
    try {
      sessionId = SharedPreferencesClass.getString("ongoingCallSessionId");
      callType = SharedPreferencesClass.getString("ongoingCallType");

      if (sessionId != null && callType != null) {
        setState(() {
          isLoading = false;
        });
      } else {
        // If no call data found, close the activity
        await platform.invokeMethod('closeCallActivity');
      }
    } catch (e) {
      debugPrint("[CallScreen] Error loading call data: $e");
      await platform.invokeMethod('closeCallActivity');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || sessionId == null || callType == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    CallSettingsBuilder callSettingsBuilder = CallSettingsBuilder()
      ..enableDefaultLayout = true
      ..setAudioOnlyCall = callType == "audio";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Handle back button - end call and close activity
          await platform.invokeMethod('closeCallActivity');
        }
      },
      child: CometChatOngoingCall(
        callSettingsBuilder: callSettingsBuilder,
        sessionId: sessionId!,
        callWorkFlow: CallWorkFlow.defaultCalling,
      ),
    );
  }
}
