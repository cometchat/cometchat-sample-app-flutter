import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:sample_app_push_notifications/auth/login_app_credential.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sample_app_push_notifications/prefs/shared_preferences.dart';
import 'package:sample_app_push_notifications/utils/initialize_cometchat.dart';
import 'package:sample_app_push_notifications/utils/text_constants.dart';
import 'app_credentials.dart';
import 'auth/login_sample_users.dart';
import 'dashboard.dart';

class GuardScreen extends StatefulWidget {
  const GuardScreen({Key? key}) : super(key: key);

  @override
  State<GuardScreen> createState() => _GuardScreenState();
}

class _GuardScreenState extends State<GuardScreen> {
  // bool? shouldGoToHomeScreen;

  final ValueNotifier<bool?> shouldGoToHomeScreen = ValueNotifier<bool?>(null);
  late CometChatColorPalette colorPalette;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // Initialize typography, color palette, and spacing
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    if (AppCredentials.appId.isNotEmpty &&
        AppCredentials.authKey.isNotEmpty &&
        AppCredentials.region.isNotEmpty) {
      await SharedPreferencesClass.setString(
          TextConstants.appId, AppCredentials.appId);
      await SharedPreferencesClass.setString(
          TextConstants.authKey, AppCredentials.authKey);
      await SharedPreferencesClass.setString(
          TextConstants.region, AppCredentials.region);
    }
    await init();
  }

  getCallButtonConfiguration() {
    return CallButtonsConfiguration(
        callButtonsStyle: CometChatCallButtonsStyle(
      voiceCallIconColor: colorPalette.iconPrimary,
      videoCallIconColor: colorPalette.iconPrimary,
    ));
  }

  init() async {
    bool isInitialized = await InitializeCometChat.init();
    if (isInitialized) {
      await alreadyLoggedIn(context);
    } else {
      shouldGoToHomeScreen.value = false;
    }
    debugPrint("CallingExtension enable with context called in login");
  }

  alreadyLoggedIn(context) async {
    final user = await CometChatUIKit.getLoggedInUser();
    if (user != null) {
      await CometChatUIKit.login(
        user.uid,
        onSuccess: (user) {
          shouldGoToHomeScreen.value = true;
        },
        onError: (excep) {
          if (kDebugMode) {
            debugPrint("Error while logging in: ${excep.message}");
          }
        },
      );
    } else {
      shouldGoToHomeScreen.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: shouldGoToHomeScreen,
      builder: (context, value, child) {
        if ((value != null && !value) &&
            (AppCredentials.appId.isEmpty ||
                AppCredentials.authKey.isEmpty ||
                AppCredentials.region.isEmpty)) {
          return const LoginAppCredential();
        }

        if (value == null) {
          return Material(
            color: colorPalette.background1,
            child: const SizedBox(),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                value ? const MyHomePage() : const LoginSampleUsers(),
              ),
              (route) => false,
            );
          });

          // Return an empty widget until navigation completes
          return const SizedBox();
        }
      },
    );
  }
}
