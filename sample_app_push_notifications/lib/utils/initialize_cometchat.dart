import 'dart:async';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/foundation.dart';

import '../app_credentials.dart';
import '../demo_meta_info_constants.dart';

class InitializeCometChat {
  static Future<bool> init() async {
    final completer = Completer<bool>();

    UIKitSettings uiKitSettings = (UIKitSettingsBuilder()
      ..subscriptionType = CometChatSubscriptionType.allUsers
      ..region = AppCredentials.region
      ..autoEstablishSocketConnection = true
      ..appId = AppCredentials.appId
      ..authKey = AppCredentials.authKey
      ..callingExtension = CometChatCallingExtension()
      ..extensions = CometChatUIKitChatExtensions.getDefaultExtensions()
      ..aiFeature = CometChatUIKitChatAIFeatures.getDefaultAiFeatures())
        .build();

    CometChatUIKit.init(
      uiKitSettings: uiKitSettings,
      onSuccess: (successMessage) async {
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
            debugPrint("setDemoMetaInfo ended with error: $e");
          }
        }
        completer.complete(true);
      },
      onError: (e) {
        if (kDebugMode) {
          debugPrint("CometChatUIKit.init failed: $e");
        }
        completer.complete(false);
      },
    );

    debugPrint("CallingExtension enable with context called in login");

    return completer.future;
  }
}
