import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ActionElementUtils {
  static final defaultHeader = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static Future<bool> performAction({
    BuildContext? context,
    required BaseInteractiveElement element,
    Map<String, dynamic>? body,
    WebViewStyle? style,
    required int messageId,
  }) async {
    if (element.action?.actionType == ActionTypeConstants.apiAction) {
      if (element.action == null) return false;
      APIAction apiAction = element.action! as APIAction;
      Map<String, dynamic> requestBody = body ?? {};

      http.Response? response;
      await Future.delayed(const Duration(seconds: 2));

      switch (apiAction.method.toUpperCase()) {
        case APIRequestTypeConstants.put:
          response = await NetworkUtils.put(
              apiAction.url, apiAction.headers ?? defaultHeader, requestBody);
          break;
        case APIRequestTypeConstants.post:
          response = await NetworkUtils.postData(
              apiAction.url, apiAction.headers ?? defaultHeader, requestBody);
          break;
        case APIRequestTypeConstants.delete:
          response = await NetworkUtils.delete(
              apiAction.url, apiAction.headers ?? defaultHeader, requestBody);
          break;
        case APIRequestTypeConstants.patch:
          response = await NetworkUtils.patchData(
              apiAction.url, apiAction.headers ?? defaultHeader, requestBody);
          break;
      }

      if (response != null) {
        if (response.statusCode == 200) {
          await CometChat.markAsInteracted(messageId, element.elementId,
              onSuccess: (String res) {}, onError: (CometChatException e) {});
          return true;
        } else {
          if (kDebugMode) {
            print(
                "Error in API Action ${response.statusCode} ${response.body}");
          }
          return false;
        }
      }
    } else if (element.action?.actionType ==
        ActionTypeConstants.urlNavigation) {
      URLNavigationAction apiNavigationAction =
          element.action! as URLNavigationAction;

      if (context != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CometChatWebView(
                    title: "WEB",
                    webViewUrl: apiNavigationAction.url,
                    webViewStyle: const WebViewStyle(
                    ))));
      }

      return true;
    }
    return false;
  }
}
