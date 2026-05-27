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
        child: Stack(
          children: [
            // Background pattern image
            Positioned.fill(
              child: Image.asset(
                'assets/auth_background.png',
                fit: BoxFit.cover,
              ),
            ),
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.padding5 ?? 20,
                    vertical: spacing.padding5 ?? 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CometChat logo at the top center
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: spacing.padding5 ?? 20,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/cometchat_logo_with_text.png',
                            color: colorPalette.textPrimary,
                          ),
                        ),
                      ),
                      // Fix 1: Card with border and shadow wrapping all elements
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.padding4 ?? 16,
                          vertical: spacing.padding6 ?? 24,
                        ),
                        decoration: BoxDecoration(
                          color: colorPalette.background1,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(16, 24, 40, 0.08),
                              blurRadius: 16,
                              offset: Offset(0, 12),
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: Color.fromRGBO(16, 24, 40, 0.03),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Center(
                              child: Text(
                                "App Credentials",
                                style: TextStyle(
                                  color: colorPalette.textPrimary,
                                  fontSize:
                                  typography.heading2?.bold?.fontSize,
                                  fontFamily:
                                  typography.heading2?.bold?.fontFamily,
                                  fontWeight:
                                  typography.heading2?.bold?.fontWeight,
                                ),
                              ),
                            ),
                            // Region label
                            Padding(
                              padding: EdgeInsets.only(
                                top: spacing.padding5 ?? 20,
                                bottom: spacing.padding2 ?? 8,
                              ),
                              child: Text(
                                "Region",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: colorPalette.textPrimary,
                                  fontSize:
                                  typography.body?.medium?.fontSize,
                                  fontFamily:
                                  typography.body?.medium?.fontFamily,
                                  fontWeight:
                                  typography.body?.medium?.fontWeight,
                                ),
                              ),
                            ),
                            // Fix 2: Region tabs with 14-16px icon size and 40px height
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: regions.map((region) {
                                int index = regions.indexOf(region);
                                return Expanded(
                                  child: Padding(
                                    padding: (index != regions.length - 1)
                                        ? EdgeInsets.only(
                                      right: spacing.padding2 ?? 8,
                                    )
                                        : EdgeInsets.zero,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_focusNodeAuthKey.hasFocus) {
                                            removeFocus(
                                                context, _focusNodeAuthKey);
                                          } else {
                                            removeFocus(
                                                context, _focusNodeAppID);
                                          }
                                          selectedRegion = region;
                                        });
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: (selectedRegion == region)
                                              ? colorPalette
                                              .extendedPrimary50
                                              : colorPalette.background1,
                                          borderRadius:
                                          BorderRadius.circular(
                                            spacing.radius2 ?? 8,
                                          ),
                                          border: Border.all(
                                            color: (selectedRegion ==
                                                region)
                                                ? (colorPalette
                                                .borderHighlight ??
                                                Colors.transparent)
                                                : (colorPalette
                                                .borderLight ??
                                                Colors.transparent),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              region.path ?? "",
                                              width: 18,
                                              height: 18,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 4,
                                              ),
                                              child: Text(
                                                region.region ?? "",
                                                overflow:
                                                TextOverflow.ellipsis,
                                                textAlign:
                                                TextAlign.start,
                                                style: TextStyle(
                                                  color: colorPalette
                                                      .textSecondary,
                                                  fontSize: typography
                                                      .button
                                                      ?.medium
                                                      ?.fontSize,
                                                  fontFamily: typography
                                                      .button
                                                      ?.medium
                                                      ?.fontFamily,
                                                  fontWeight: typography
                                                      .button
                                                      ?.medium
                                                      ?.fontWeight,
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
                            // App ID label
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
                                  fontSize: typography
                                      .caption1?.medium?.fontSize,
                                  fontFamily: typography
                                      .caption1?.medium?.fontFamily,
                                  fontWeight: typography
                                      .caption1?.medium?.fontWeight,
                                ),
                              ),
                            ),
                            // Fix 3: Input field with 40px height and proper styling
                            SizedBox(
                              height: 40,
                              child: TextFormField(
                                controller: appIdController,
                                focusNode: _focusNodeAppID,
                                keyboardAppearance:
                                CometChatThemeHelper.getBrightness(
                                    context),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "";
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  color: colorPalette.textPrimary,
                                  fontSize:
                                  typography.body?.regular?.fontSize,
                                  fontFamily:
                                  typography.body?.regular?.fontFamily,
                                  fontWeight:
                                  typography.body?.regular?.fontWeight,
                                ),
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                    fontSize: 0,
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: spacing.padding2 ?? 8,
                                    horizontal: spacing.padding3 ?? 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      spacing.radius2 ?? 8,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      spacing.radius2 ?? 8,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      spacing.radius2 ?? 8,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Enter the App ID",
                                  hintStyle: TextStyle(
                                    color: colorPalette.textTertiary,
                                    fontSize: typography
                                        .body?.regular?.fontSize,
                                    fontFamily: typography
                                        .body?.regular?.fontFamily,
                                    fontWeight: typography
                                        .body?.regular?.fontWeight,
                                  ),
                                  filled: true,
                                  fillColor: colorPalette.background2,
                                ),
                              ),
                            ),
                            // Auth Key label
                            Padding(
                              padding: EdgeInsets.only(
                                top: spacing.padding5 ?? 20,
                                bottom: spacing.padding1 ?? 4,
                              ),
                              child: Text(
                                "Auth Key",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: colorPalette.textPrimary,
                                  fontSize: typography
                                      .caption1?.medium?.fontSize,
                                  fontFamily: typography
                                      .caption1?.medium?.fontFamily,
                                  fontWeight: typography
                                      .caption1?.medium?.fontWeight,
                                ),
                              ),
                            ),
                            // Fix 3: Auth Key input field with 40px height
                            SizedBox(
                              height: 40,
                              child: TextFormField(
                                controller: authKeyController,
                                focusNode: _focusNodeAuthKey,
                                keyboardAppearance:
                                CometChatThemeHelper.getBrightness(
                                    context),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "";
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  color: colorPalette.textPrimary,
                                  fontSize:
                                  typography.body?.regular?.fontSize,
                                  fontFamily:
                                  typography.body?.regular?.fontFamily,
                                  fontWeight:
                                  typography.body?.regular?.fontWeight,
                                ),
                                decoration: InputDecoration(
                                  errorStyle: const TextStyle(
                                    fontSize: 0,
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: spacing.padding2 ?? 8,
                                    horizontal: spacing.padding3 ?? 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      spacing.radius2 ?? 8,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      spacing.radius2 ?? 8,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      spacing.radius2 ?? 8,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Enter the Auth Key",
                                  hintStyle: TextStyle(
                                    color: colorPalette.textTertiary,
                                    fontSize: typography
                                        .body?.regular?.fontSize,
                                    fontFamily: typography
                                        .body?.regular?.fontFamily,
                                    fontWeight: typography
                                        .body?.regular?.fontWeight,
                                  ),
                                  filled: true,
                                  fillColor: colorPalette.background2,
                                ),
                              ),
                            ),
                            // Fix 5: Continue button with 40px height
                            Padding(
                              padding: EdgeInsets.only(
                                top: spacing.padding7 ?? 32,
                              ),
                              child: SizedBox(
                                height: 40,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_focusNodeAuthKey.hasFocus) {
                                      removeFocus(
                                          context, _focusNodeAuthKey);
                                    } else {
                                      removeFocus(
                                          context, _focusNodeAppID);
                                    }
                                    if (selectedRegion == null ||
                                        appIdController.text.isEmpty ||
                                        authKeyController.text.isEmpty) {
                                      showSnackBar(
                                          context,
                                          "Please fill all the fields",
                                          typography,
                                          colorPalette);
                                      return;
                                    }
                                    if ((selectedRegion != null) &&
                                        appIdController.text.isNotEmpty &&
                                        authKeyController
                                            .text.isNotEmpty) {
                                      AppCredentials.setRegion(
                                          selectedRegion?.region ?? "");
                                      AppCredentials.setAppId(
                                          appIdController.text);
                                      AppCredentials.setAuthKey(
                                          authKeyController.text);
                                      Future.delayed(
                                          const Duration(
                                              milliseconds: 500), () {
                                        init();
                                      });
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                    WidgetStateProperty.all(
                                      colorPalette.primary,
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                          spacing.radius2 ?? 8,
                                        ),
                                      ),
                                    ),
                                    elevation:
                                    WidgetStateProperty.all(0),
                                    padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                        horizontal:
                                        spacing.padding5 ?? 20,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(
                                      color:
                                      colorPalette.buttonIconColor,
                                      fontSize: typography
                                          .button?.medium?.fontSize,
                                      fontFamily: typography
                                          .button?.medium?.fontFamily,
                                      fontWeight: typography
                                          .button?.medium?.fontWeight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // "Don't have an app credentials? UID" text
                            Padding(
                              padding: EdgeInsets.only(
                                top: spacing.padding4 ?? 16,
                              ),
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_focusNodeAuthKey.hasFocus) {
                                      removeFocus(
                                          context, _focusNodeAuthKey);
                                    } else {
                                      removeFocus(
                                          context, _focusNodeAppID);
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginSampleUsers(),
                                      ),
                                    );
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                          "Don't have an app credentials? ",
                                          style: TextStyle(
                                            color: colorPalette
                                                .textSecondary,
                                            fontSize: typography.caption1
                                                ?.medium?.fontSize,
                                            fontFamily: typography
                                                .caption1
                                                ?.medium
                                                ?.fontFamily,
                                            fontWeight: typography
                                                .caption1
                                                ?.medium
                                                ?.fontWeight,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "UID",
                                          style: TextStyle(
                                            color: colorPalette
                                                .textHighlight,
                                            fontSize: typography.caption1
                                                ?.medium?.fontSize,
                                            fontFamily: typography
                                                .caption1
                                                ?.medium
                                                ?.fontFamily,
                                            fontWeight: typography
                                                .caption1
                                                ?.medium
                                                ?.fontWeight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
