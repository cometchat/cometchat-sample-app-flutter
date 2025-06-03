import 'dart:async';
import 'dart:io';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sample_app_push_notifications/demo_meta_info_constants.dart';

import '../../../app_credentials.dart';
import '../../../dashboard.dart';
import '../../../guard_screen.dart';




class CometChatService {

  static final CometChatService _singleton = CometChatService._internal();

  factory CometChatService() {
    return _singleton;
  }

  CometChatService._internal();

  Future<bool> isAlreadyLoggedIn() async {
    User? user = await CometChatUIKit.getLoggedInUser(
      onSuccess: (user) => user,
      onError: (e) {
        debugPrint("Error while checking logged in user $e");
      },
    );
    debugPrint("Logged in user: ${user?.name}");

    return user != null;
  }



  @Deprecated('This method is deprecated please use PNRegistry.registerPNService() instead')
  static Future<void> registerToken(String token, String type) async {
    final Map<String, dynamic> body = type == 'apns'
        ? {"apnsToken": token}
        : type == 'voip'
        ? {"voipToken": token}
        : {'fcmToken': token};

    CometChat.callExtension('push-notification', 'POST', '/v2/tokens', body,
        onSuccess: (message) {
          debugPrint("Registered successfully: ${message.toString()}");
          return true;
        }, onError: (CometChatException e) {
          debugPrint("Registration failed with exception: ${e.message}");
          return false;
        });
  }

  Future<bool> logout(BuildContext context) async {
    showLoadingIndicatorDialog(context);
    await PNRegistry.unregisterPNService();
    CometChat.removeCallListener("CometChatService_CallListener");
    await CometChat.logout(
      onSuccess: (message) {
        if(Platform.isAndroid) {
          FirebaseMessaging.instance.deleteToken();
        }
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const GuardScreen(),
        ));
      },
      onError: (error) {
        Navigator.of(context).pop();
        debugPrint("Error while logout ${error.message}");
      },
    );
    return true;
  }

  login(String uid,BuildContext context) async {
    showLoadingIndicatorDialog(context);
    User? user = await CometChatUIKit.getLoggedInUser();
    try {
      if (user != null) {
        await PNRegistry.unregisterPNService();
        await CometChatUIKit.logout(onSuccess: (_) {
        }, onError: (_) {});
      }
    } catch (_) {}
    user = await CometChatUIKit.login(uid,onSuccess: (user) {
    },);
    if(context.mounted) {
      Navigator.of(context).pop();
      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const MyHomePage()));
      }
    }
  }

  init() async {
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
            debugPrint("setDemoMetaInfo ended with error");
          }
        }
      },
    );
    debugPrint("CallingExtension enable with context called in login");
  }
}

extension PNRegistry on CometChatService {
  static Future<String?> registerPNService(String token,bool isFcm, bool isVoip) async{
    return await CometChatNotifications.registerPushToken(
      getPushPlatform(isFcm, isVoip),
      providerId: getProviderId(isFcm),
      fcmToken: isFcm? token:null,
      deviceToken: !isFcm && !isVoip ? token : null,
      voipToken: !isFcm && isVoip ? token : null,
      onSuccess: (response) {
        debugPrint("registerPushToken:success ${response.toString()}");
      },
      onError: (e) {
        debugPrint("registerPushToken:error ${e.toString()}");
      },
    );
  }

  static Future<String?> unregisterPNService() async{
    return await CometChatNotifications.unregisterPushToken(onSuccess: (response) {
      debugPrint("Token has been unregistered successfully => ${response.toString()}");
    },
        onError: (e) {
          debugPrint("unregisterPushToken:error ${e.toString()}");
        }
    );
  }

  static String getProviderId(bool isFcm) {
    return  isFcm ? AppCredentials.fcmProviderId: AppCredentials.apnProviderId;
  }

  static PushPlatforms getPushPlatform(bool isFcm, bool isVoip) {
    return  isFcm ?( Platform.isAndroid ? PushPlatforms.FCM_FLUTTER_ANDROID:PushPlatforms.FCM_FLUTTER_IOS) : (isVoip? PushPlatforms.APNS_FLUTTER_VOIP:PushPlatforms.APNS_FLUTTER_DEVICE);
  }
}