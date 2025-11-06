import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sample_app_push_notifications/app_credentials.dart';
import 'package:sample_app_push_notifications/auth/login_sample_users.dart';

import '../demo_meta_info_constants.dart';
import '../models/region_model.dart';
import '../prefs/shared_preferences.dart';
import '../utils/constant_utils.dart';
import '../utils/show_snackBar.dart';
import '../utils/text_constants.dart';

class LoginAppCredential extends StatefulWidget {
  const LoginAppCredential({super.key});

  @override
  State<LoginAppCredential> createState() => _LoginAppCredentialState();
}

class _LoginAppCredentialState extends State<LoginAppCredential> {
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  TextEditingController appIdController = TextEditingController();
  TextEditingController authKeyController = TextEditingController();

  final FocusNode _focusNodeAppID = FocusNode();
  final FocusNode _focusNodeAuthKey = FocusNode();

  List<Region> regions = [
    Region()
      ..region = "US"
      ..path = "assets/us.png",
    Region()
      ..region = "EU"
      ..path = "assets/eu.png",
    Region()
      ..region = "IN"
      ..path = "assets/in.png",
  ];

  Region? selectedRegion;

  init() async {
    final region = SharedPreferencesClass.getString(TextConstants.region);
    final authKey = SharedPreferencesClass.getString(TextConstants.authKey);
    final appId = SharedPreferencesClass.getString(TextConstants.appId);
    UIKitSettings uiKitSettings = (UIKitSettingsBuilder()
      ..subscriptionType = CometChatSubscriptionType.allUsers
      ..region = region
      ..autoEstablishSocketConnection = true
      ..appId = appId
      ..authKey = authKey
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginSampleUsers(),
          ),
        );
      },
      onError: (e) {
        if (kDebugMode) {
          debugPrint(
              "CometChat initialization failed with error: ${e.message}");
        }
        showSnackBar(
            context, "CometChat init failed.", typography, colorPalette);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  @override
  void dispose() {
    authKeyController.dispose();
    appIdController.dispose();
    _focusNodeAppID.dispose();
    _focusNodeAuthKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorPalette.background2,
      body: GestureDetector(
        onTap: () {
          if (_focusNodeAuthKey.hasFocus) {
            removeFocus(context, _focusNodeAuthKey);
          } else {
            removeFocus(context, _focusNodeAppID);
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: spacing.padding10 ?? 40,
            left: spacing.padding4 ?? 16,
            right: spacing.padding4 ?? 16,
            bottom: spacing.padding4 ?? 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: spacing.padding10 ?? 40,
                        ),
                        child: Image.asset(
                          'assets/cometchat_logo_with_text.png',
                          color: colorPalette.textPrimary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: spacing.padding10 ?? 40,
                        ),
                        child: Center(
                          child: Text(
                            "App Credentials",
                            style: TextStyle(
                              color: colorPalette.textPrimary,
                              fontSize: typography.heading2?.bold?.fontSize,
                              fontFamily: typography.heading2?.bold?.fontFamily,
                              fontWeight: typography.heading2?.bold?.fontWeight,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: spacing.padding5 ?? 20,
                          bottom: spacing.padding2 ?? 4,
                        ),
                        child: Text(
                          "Region",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: colorPalette.textPrimary,
                            fontSize: typography.body?.medium?.fontSize,
                            fontFamily: typography.body?.medium?.fontFamily,
                            fontWeight: typography.body?.medium?.fontWeight,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: regions.map((region) {
                          int index = regions.indexOf(region);
                          return Expanded(
                            child: Padding(
                              padding: (index != regions.length - 1)
                                  ? EdgeInsets.only(
                                right: spacing.padding ?? 2,
                              )
                                  : const EdgeInsets.all(0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_focusNodeAuthKey.hasFocus) {
                                      removeFocus(context, _focusNodeAuthKey);
                                    } else {
                                      removeFocus(context, _focusNodeAppID);
                                    }
                                    selectedRegion =
                                        region; // Setting the selected region
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: spacing.padding2 ?? 8,
                                    horizontal: spacing.padding3 ?? 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (selectedRegion == region)
                                        ? colorPalette.extendedPrimary50
                                        : colorPalette.background1,
                                    borderRadius: BorderRadius.circular(
                                      spacing.radius2 ?? 8,
                                    ),
                                    border: Border.all(
                                      color: (selectedRegion == region)
                                          ? (colorPalette.borderHighlight ??
                                          Colors.transparent)
                                          : (colorPalette.borderLight ??
                                          Colors.transparent),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        region.path ?? "",
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: spacing.padding2 ?? 8,
                                        ),
                                        child: Text(
                                          region.region ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: colorPalette.textSecondary,
                                            fontSize: typography
                                                .button?.medium?.fontSize,
                                            fontFamily: typography
                                                .button?.medium?.fontFamily,
                                            fontWeight: typography
                                                .button?.medium?.fontWeight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: spacing.padding5 ?? 20,
                          bottom: spacing.padding1 ?? 4,
                        ),
                        child: Text(
                          "App ID",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: colorPalette.textPrimary,
                            fontSize: typography.caption1?.medium?.fontSize,
                            fontFamily: typography.caption1?.medium?.fontFamily,
                            fontWeight: typography.caption1?.medium?.fontWeight,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: appIdController,
                        keyboardAppearance:
                        CometChatThemeHelper.getBrightness(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "";
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: colorPalette.textPrimary,
                          fontSize: typography.body?.regular?.fontSize,
                          fontFamily: typography.body?.regular?.fontFamily,
                          fontWeight: typography.body?.regular?.fontWeight,
                        ),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(
                            fontSize: 0,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: spacing.padding2 ?? 0,
                            horizontal: spacing.padding2 ?? 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              spacing.radius2 ?? 0,
                            ),
                            borderSide: BorderSide(
                              width: 2,
                              color: colorPalette.borderLight ??
                                  Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              spacing.radius2 ?? 0,
                            ),
                            borderSide: BorderSide(
                              width: 2,
                              color: colorPalette.borderLight ??
                                  Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              spacing.radius2 ?? 0,
                            ),
                            borderSide: BorderSide(
                              width: 2,
                              color: colorPalette.borderLight ??
                                  Colors.transparent,
                            ),
                          ),
                          hintText: "Enter the App ID",
                          hintStyle: TextStyle(
                            color: colorPalette.textTertiary,
                            fontSize: typography.body?.regular?.fontSize,
                            fontFamily: typography.body?.regular?.fontFamily,
                            fontWeight: typography.body?.regular?.fontWeight,
                          ),
                          filled: true,
                          fillColor: colorPalette.background2,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: spacing.padding5 ?? 20,
                          bottom: spacing.padding1 ?? 4,
                        ),
                        child: Text(
                          "Enter Auth Key",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: colorPalette.textPrimary,
                            fontSize: typography.caption1?.medium?.fontSize,
                            fontFamily: typography.caption1?.medium?.fontFamily,
                            fontWeight: typography.caption1?.medium?.fontWeight,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: authKeyController,
                        keyboardAppearance: CometChatThemeHelper.getBrightness(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "";
                          }
                          return null;
                        },
                        style: TextStyle(
                          color: colorPalette.textPrimary,
                          fontSize: typography.body?.regular?.fontSize,
                          fontFamily: typography.body?.regular?.fontFamily,
                          fontWeight: typography.body?.regular?.fontWeight,
                        ),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(
                            fontSize: 0,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: spacing.padding2 ?? 0,
                            horizontal: spacing.padding2 ?? 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              spacing.radius2 ?? 0,
                            ),
                            borderSide: BorderSide(
                              width: 2,
                              color: colorPalette.borderLight ?? Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              spacing.radius2 ?? 0,
                            ),
                            borderSide: BorderSide(
                              width: 2,
                              color: colorPalette.borderLight ?? Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              spacing.radius2 ?? 0,
                            ),
                            borderSide: BorderSide(
                              width: 2,
                              color: colorPalette.borderLight ?? Colors.transparent,
                            ),
                          ),
                          hintText: "Enter the Auth Key",
                          hintStyle: TextStyle(
                            color: colorPalette.textTertiary,
                            fontSize: typography.body?.regular?.fontSize,
                            fontFamily: typography.body?.regular?.fontFamily,
                            fontWeight: typography.body?.regular?.fontWeight,
                          ),
                          filled: true,
                          fillColor: colorPalette.background2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: spacing.padding5 ?? 20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_focusNodeAuthKey.hasFocus) {
                      removeFocus(context, _focusNodeAuthKey);
                    } else {
                      removeFocus(context, _focusNodeAppID);
                    }
                    if (selectedRegion == null ||
                        appIdController.text.isEmpty ||
                        authKeyController.text.isEmpty) {
                      showSnackBar(context, "Please fill all the fields",
                          typography, colorPalette);
                      return;
                    }
                    if ((selectedRegion != null) &&
                        appIdController.text.isNotEmpty &&
                        authKeyController.text.isNotEmpty) {
                      AppCredentials.setRegion(selectedRegion?.region ?? "");
                      AppCredentials.setAppId(appIdController.text);
                      AppCredentials.setAuthKey(authKeyController.text);
                      Future.delayed(const Duration(milliseconds: 500), () {
                        init();
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      colorPalette.primary,
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          spacing.radius2 ?? 8,
                        ),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(
                        vertical: spacing.padding2 ?? 8,
                        horizontal: spacing.padding5 ?? 20,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        color: colorPalette.buttonIconColor,
                        fontSize: typography.button?.medium?.fontSize,
                        fontFamily: typography.button?.medium?.fontFamily,
                        fontWeight: typography.button?.medium?.fontWeight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}