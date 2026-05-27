import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:sample_app_push_notifications/auth/login_app_credential.dart';
import 'package:sample_app_push_notifications/utils/show_snackBar.dart';

import '../dashboard.dart';
import '../models/user_model.dart';
import '../services/api_services.dart';
import '../utils/constant_utils.dart';

class LoginSampleUsers extends StatefulWidget {
  const LoginSampleUsers({super.key});

  @override
  State<LoginSampleUsers> createState() => _LoginSampleUsersState();
}

class _LoginSampleUsersState extends State<LoginSampleUsers> {
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  Future<List<MaterialButtonUserModel>>? _futureUsers;

  TextEditingController uidController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  final ValueNotifier<MaterialButtonUserModel?> selectedUserNotifier =
      ValueNotifier<MaterialButtonUserModel?>(null);

  String userId = "";

  @override
  void initState() {
    super.initState();
    _futureUsers = ApiServices.fetchUsers();
  }

  bool isLoading = false;

  @override
  void dispose() {
    selectedUserNotifier.dispose();
    uidController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    typography = CometChatThemeHelper.getTypography(context);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  //Login User function must pass userid and authkey should be used only while developing
  loginUser(String userId, context) async {
    User? user = await CometChat.getLoggedInUser();

    setState(() {
      isLoading = true; // Start loading
    });

    try {
      if (user != null) {
        if (user.uid == userId) {
          // User is already logged in, no need to do anything
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MyHomePage(),
            ),
          );
          return;
        } else {
          // Logging out the current user if it's different
          await CometChat.logout(
            onSuccess: (_) {
              debugPrint("Logout Successful");
            },
            onError: (_) {
              debugPrint("Logout failed");
            },
          );
        }
      }

      // Proceed to login if necessary
      await CometChatUIKit.login(userId, onSuccess: (User loggedInUser) {
        debugPrint("Login Successful from UI : $loggedInUser");
        setState(() {
          isLoading = false; // Stop loading on success
        });
        user = loggedInUser;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MyHomePage()));
      }, onError: (CometChatException e) {
        debugPrint("Login failed with exception:  ${e.message}");
        setState(() {
          isLoading = false; // Stop loading on error
        });
        showSnackBar(context, "Unable to login.", typography, colorPalette);
      });
    } catch (_) {
      // Handle any exceptions that occur outside the CometChat calls
      setState(() {
        isLoading = false; // Stop loading in case of an exception
      });
      debugPrint("Error while logging out");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorPalette.background2,
      body: GestureDetector(
        onTap: () {
          removeFocus(context, _focusNode);
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // CometChat logo at the top center
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Center(
                          child: Image.asset(
                            'assets/cometchat_logo_with_text.png',
                            color: colorPalette.textPrimary,
                          ),
                        ),
                      ),
                      // Card with border and shadow wrapping all elements
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
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
                                "Sign in to cometchat",
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
                            // Subtitle
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 16,
                              ),
                              child: Center(
                                child: Text(
                                  "Using our sample users",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colorPalette.textSecondary,
                                    fontSize:
                                    typography.body?.medium?.fontSize,
                                    fontFamily:
                                    typography.body?.medium?.fontFamily,
                                    fontWeight:
                                    typography.body?.medium?.fontWeight,
                                  ),
                                ),
                              ),
                            ),
                            // User grid
                            FutureBuilder(
                              future: _futureUsers,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<MaterialButtonUserModel>>
                                  snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CometChatShimmerEffect(
                                    colorPalette: colorPalette,
                                    child: GridView.builder(
                                      itemCount: 6,
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: colorPalette.background1,
                                            borderRadius:
                                            BorderRadius.circular(
                                              spacing.radius2 ?? 8,
                                            ),
                                          ),
                                        );
                                      },
                                      gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error}, login using UID',
                                      style: TextStyle(
                                        color: colorPalette.textPrimary,
                                        fontSize:
                                        typography.body?.bold?.fontSize,
                                        fontFamily:
                                        typography.body?.bold?.fontFamily,
                                        fontWeight:
                                        typography.body?.bold?.fontWeight,
                                      ),
                                    ),
                                  );
                                } else {
                                  final List<MaterialButtonUserModel> users =
                                      snapshot.data ?? [];
                                  return ValueListenableBuilder(
                                    valueListenable: selectedUserNotifier,
                                    builder: (context, selectedUser, _) {
                                      return GridView.builder(
                                        itemCount: users.length,
                                        shrinkWrap: true,
                                        physics:
                                        const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              removeFocus(
                                                  context, _focusNode);
                                              selectedUserNotifier.value =
                                              users[index];
                                            },
                                            child: Stack(
                                              fit: StackFit.passthrough,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: (selectedUser ==
                                                        users[index])
                                                        ? colorPalette
                                                        .extendedPrimary50
                                                        : colorPalette
                                                        .background1,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      spacing.radius2 ?? 8,
                                                    ),
                                                    border: Border.all(
                                                      color: (selectedUser ==
                                                          users[index])
                                                          ? (colorPalette
                                                          .borderHighlight ??
                                                          Colors
                                                              .transparent)
                                                          : (colorPalette
                                                          .borderLight ??
                                                          Colors
                                                              .transparent),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        4),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              bottom: 4),
                                                          child:
                                                          CometChatAvatar(
                                                            name: users[index]
                                                                .username,
                                                            image:
                                                            users[index]
                                                                .imageURL,
                                                          ),
                                                        ),
                                                        Text(
                                                          users[index]
                                                              .username,
                                                          textAlign:
                                                          TextAlign
                                                              .center,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            color: colorPalette
                                                                .textPrimary,
                                                            fontSize: typography
                                                                .body
                                                                ?.medium
                                                                ?.fontSize,
                                                            fontFamily: typography
                                                                .body
                                                                ?.medium
                                                                ?.fontFamily,
                                                            fontWeight: typography
                                                                .body
                                                                ?.medium
                                                                ?.fontWeight,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              top: 2),
                                                          child: FittedBox(
                                                            fit: BoxFit.scaleDown,
                                                            child: Text(
                                                              users[index]
                                                                  .userId,
                                                              textAlign:
                                                              TextAlign
                                                                  .center,
                                                              maxLines: 1,
                                                              style:
                                                              TextStyle(
                                                                color: colorPalette
                                                                    .textSecondary,
                                                                fontSize: typography
                                                                    .caption1
                                                                    ?.regular
                                                                    ?.fontSize,
                                                                fontFamily: typography
                                                                    .caption1
                                                                    ?.regular
                                                                    ?.fontFamily,
                                                                fontWeight: typography
                                                                    .caption1
                                                                    ?.regular
                                                                    ?.fontWeight,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                (selectedUser == users[index])
                                                    ? Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    padding:
                                                    EdgeInsets.all(
                                                      spacing.padding ??
                                                          8,
                                                    ),
                                                    decoration:
                                                    BoxDecoration(
                                                      color: colorPalette
                                                          .iconHighlight,
                                                      borderRadius:
                                                      BorderRadius
                                                          .only(
                                                        bottomLeft:
                                                        Radius
                                                            .circular(
                                                          spacing.radius2 ??
                                                              8,
                                                        ),
                                                        topRight: Radius
                                                            .circular(
                                                          spacing.radius2 ??
                                                              8,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.check,
                                                        color:
                                                        colorPalette
                                                            .white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          );
                                        },
                                        gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                          childAspectRatio: 0.82,
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                            // "Or" divider
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 16,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: colorPalette.borderDefault,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      "Or",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colorPalette.textTertiary,
                                        fontSize: typography
                                            .body?.medium?.fontSize,
                                        fontFamily: typography
                                            .body?.medium?.fontFamily,
                                        fontWeight: typography
                                            .body?.medium?.fontWeight,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: colorPalette.borderDefault,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // "UID" label
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "UID",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: colorPalette.textPrimary,
                                  fontSize:
                                  typography.caption1?.medium?.fontSize,
                                  fontFamily: typography
                                      .caption1?.medium?.fontFamily,
                                  fontWeight: typography
                                      .caption1?.medium?.fontWeight,
                                ),
                              ),
                            ),
                            // Input field with 40px height, grey fill, no border
                            SizedBox(
                              height: 40,
                              child: TextFormField(
                                controller: uidController,
                                focusNode: _focusNode,
                                keyboardAppearance:
                                CometChatThemeHelper.getBrightness(
                                    context),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    selectedUserNotifier.value = null;
                                  }
                                },
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
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
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
                                  hintText: "Enter UID",
                                  hintStyle: TextStyle(
                                    color: colorPalette.textTertiary,
                                    fontSize:
                                    typography.body?.regular?.fontSize,
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
                            // Continue button with 40px height
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: SizedBox(
                                height: 40,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (selectedUserNotifier.value == null &&
                                        uidController.text.isEmpty) {
                                      showSnackBar(
                                          context,
                                          "Please enter a valid UID",
                                          typography,
                                          colorPalette);
                                      return;
                                    }
                                    if (selectedUserNotifier.value != null &&
                                        selectedUserNotifier
                                            .value!.userId.isNotEmpty) {
                                      loginUser(
                                          selectedUserNotifier.value!.userId,
                                          context);
                                    } else if (uidController
                                        .text.isNotEmpty) {
                                      loginUser(
                                          uidController.text, context);
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
                                      const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                    ),
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child:
                                    CircularProgressIndicator(
                                      valueColor:
                                      AlwaysStoppedAnimation<
                                          Color>(
                                        colorPalette.white ??
                                            Colors.white,
                                      ),
                                    ),
                                  )
                                      : Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: colorPalette
                                          .buttonIconColor,
                                      fontSize: typography.button
                                          ?.medium?.fontSize,
                                      fontFamily: typography.button
                                          ?.medium?.fontFamily,
                                      fontWeight: typography.button
                                          ?.medium?.fontWeight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // "Don't have an UID? App Credentials" text
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    removeFocus(context, _focusNode);
                                    uidController.clear();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginAppCredential(),
                                      ),
                                    );
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Don't have an UID? ",
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
                                          text: "App Credentials",
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
