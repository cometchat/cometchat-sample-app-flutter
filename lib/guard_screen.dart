import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_flutter_sample_app/app_constants.dart';
import 'package:cometchat_flutter_sample_app/dashboard.dart';
import 'package:cometchat_flutter_sample_app/login.dart';
import 'package:cometchat_flutter_sample_app/utils/demo_meta_info_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class GuardScreen extends StatefulWidget {
  const GuardScreen({Key? key}) : super(key: key);

  @override
  State<GuardScreen> createState() => _GuardScreenState();
}

class _GuardScreenState extends State<GuardScreen> {
  bool? shouldGoToHomeScreen = false;

  @override
  void initState() {
    makeUISettings();
    super.initState();
  }

  makeUISettings() {
    UIKitSettings uiKitSettings = (UIKitSettingsBuilder()
      ..subscriptionType = CometChatSubscriptionType.allUsers
      ..region = AppConstants.region
      ..autoEstablishSocketConnection = true
      ..appId = AppConstants.appId
      ..authKey = AppConstants.authKey
      ..callingExtension = CometChatCallingExtension()
      ..extensions = CometChatUIKitChatExtensions.getDefaultExtensions()
      ..aiFeature = [
        AISmartRepliesExtension(),
        AIConversationStarterExtension(),
        AIAssistBotExtension(),
        AIConversationSummaryExtension()
      ])
        .build();

    CometChatUIKit.init(
      uiKitSettings: uiKitSettings,
      onSuccess: (successMessage) async {
        alreadyLoggedIn(context);
        try {
          CometChat.setDemoMetaInfo(jsonObject: {
            "name": DemoMetaInfoConstants.name,
            "type": DemoMetaInfoConstants.type,
            "version": DemoMetaInfoConstants.version,
            "bundle": DemoMetaInfoConstants.bundle,
            "platform": DemoMetaInfoConstants.platform,
          });
        } catch (e) {
          if (kDebugMode) {
            debugPrint("setDemoMetaInfo ended with error");
          }
        }
      },
    );
  }

  alreadyLoggedIn(context) async {
      final user = await CometChatUIKit.getLoggedInUser();
      if (user != null) {
        await CometChatUIKit.login(
          user.uid,
          onSuccess: (user) {
            setState(() {
              shouldGoToHomeScreen = true;
            });
          },
          onError: (excep) {
           if(kDebugMode) {
             print("Error while logging in: ${excep.message}");
           }
          },
        );
      } else {
      setState(() {
        shouldGoToHomeScreen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  (shouldGoToHomeScreen != null && shouldGoToHomeScreen!) ? const Dashboard() : const Login();
  }
}