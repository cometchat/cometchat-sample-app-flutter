import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:sample_app/auth/login_app_credential.dart';
import 'package:sample_app/utils/show_snackBar.dart';

import '../dashboard.dart';
import '../models/user_model.dart';
import '../services/api_services.dart';
import '../utils/constant_utisl.dart';

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
      backgroundColor: colorPalette.background2,
      body: GestureDetector(
        onTap: () {
          removeFocus(context, _focusNode);
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: spacing.padding10 ?? 40,
            left: spacing.padding4 ?? 16,
            right: spacing.padding4 ?? 16,
            bottom: spacing.padding5 ?? 20, // Adjust for keyboard visibility
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
                            "Log In",
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
                          "Choose a Sample User",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: colorPalette.textPrimary,
                            fontSize: typography.body?.medium?.fontSize,
                            fontFamily: typography.body?.medium?.fontFamily,
                            fontWeight: typography.body?.medium?.fontWeight,
                          ),
                        ),
                      ),
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
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.all(
                                      spacing.padding2 ?? 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorPalette.background1,
                                      borderRadius: BorderRadius.circular(
                                        spacing.radius2 ?? 8,
                                      ),
                                    ),
                                  );
                                },
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: spacing.padding2 ?? 8,
                                  mainAxisSpacing: spacing.padding2 ?? 8,
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}, login using UID',
                                style: TextStyle(
                                  color: colorPalette.textPrimary,
                                  fontSize: typography.body?.bold?.fontSize,
                                  fontFamily: typography.body?.bold?.fontFamily,
                                  fontWeight: typography.body?.bold?.fontWeight,
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        removeFocus(context, _focusNode);
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
                                                  : colorPalette.background1,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                spacing.radius2 ?? 8,
                                              ),
                                              border: Border.all(
                                                color: (selectedUser ==
                                                        users[index])
                                                    ? (colorPalette
                                                            .borderHighlight ??
                                                        Colors.transparent)
                                                    : (colorPalette
                                                            .borderLight ??
                                                        Colors.transparent),
                                                width: 1,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                spacing.padding1 ?? 4,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom:
                                                          spacing.padding2 ?? 8,
                                                    ),
                                                    child: CometChatAvatar(
                                                      name:
                                                          users[index].username,
                                                      image:
                                                          users[index].imageURL,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      users[index].username,
                                                      textAlign:
                                                          TextAlign.center,
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
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                        top: spacing.padding1 ??
                                                            4,
                                                      ),
                                                      child: Text(
                                                        users[index].userId,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
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
                                                    padding: EdgeInsets.all(
                                                      spacing.padding ?? 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: colorPalette
                                                          .iconHighlight,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                          spacing.radius2 ?? 8,
                                                        ),
                                                        topRight:
                                                            Radius.circular(
                                                          spacing.radius2 ?? 8,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.check,
                                                        color:
                                                            colorPalette.white,
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
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: spacing.padding1 ?? 8,
                                    mainAxisSpacing: spacing.padding1 ?? 8,
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: spacing.padding2 ?? 4,
                          bottom: spacing.padding5 ?? 20,
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
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.padding2 ?? 4,
                              ),
                              child: Text(
                                "Or",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorPalette.textTertiary,
                                  fontSize: typography.body?.medium?.fontSize,
                                  fontFamily:
                                      typography.body?.medium?.fontFamily,
                                  fontWeight:
                                      typography.body?.medium?.fontWeight,
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
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: spacing.padding1 ?? 4,
                        ),
                        child: Text(
                          "Enter UID",
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
                        controller: uidController,
                        focusNode: _focusNode,
                        keyboardAppearance:
                            CometChatThemeHelper.getBrightness(context),
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
                          hintText: "Enter UID",
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
              // const Spacer(),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.padding5 ?? 20),
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedUserNotifier.value == null &&
                            uidController.text.isEmpty) {
                          showSnackBar(context, "Please enter a valid UID",
                              typography, colorPalette);
                          return;
                        }
                        if (selectedUserNotifier.value != null &&
                            selectedUserNotifier.value!.userId.isNotEmpty) {
                          loginUser(
                              selectedUserNotifier.value!.userId, context);
                        } else if (uidController.text.isNotEmpty) {
                          loginUser(uidController.text, context);
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
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colorPalette.white ?? Colors.white),
                                ),
                              )
                            : Text(
                                "Continue",
                                style: TextStyle(
                                  color: colorPalette.buttonIconColor,
                                  fontSize: typography.button?.medium?.fontSize,
                                  fontFamily:
                                      typography.button?.medium?.fontFamily,
                                  fontWeight:
                                      typography.button?.medium?.fontWeight,
                                ),
                              ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: spacing.padding1 ?? 4,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          removeFocus(context, _focusNode);
                          uidController.clear();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginAppCredential(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Change ",
                                style: TextStyle(
                                  color: colorPalette.textSecondary,
                                  fontSize:
                                      typography.caption1?.medium?.fontSize,
                                  fontFamily:
                                      typography.caption1?.medium?.fontFamily,
                                  fontWeight:
                                      typography.caption1?.medium?.fontWeight,
                                ),
                              ),
                              TextSpan(
                                text: "App Credentials",
                                style: TextStyle(
                                  color: colorPalette.textHighlight,
                                  fontSize:
                                      typography.caption1?.medium?.fontSize,
                                  fontFamily:
                                      typography.caption1?.medium?.fontFamily,
                                  fontWeight:
                                      typography.caption1?.medium?.fontWeight,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
