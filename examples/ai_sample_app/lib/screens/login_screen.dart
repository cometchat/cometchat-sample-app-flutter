import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import '../models/user_model.dart';
import '../services/api_services.dart';
import '../utils/ui_utils.dart';
import 'ai_agents_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late CometChatColorPalette colorPalette;
  late CometChatTypography typography;
  late CometChatSpacing spacing;

  Future<List<SampleUserModel>>? _futureUsers;
  final TextEditingController _uidController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<SampleUserModel?> _selectedUserNotifier =
      ValueNotifier<SampleUserModel?>(null);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureUsers = ApiServices.fetchUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    typography = CometChatThemeHelper.getTypography(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  @override
  void dispose() {
    _selectedUserNotifier.dispose();
    _uidController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loginUser(String userId) async {
    setState(() => _isLoading = true);

    try {
      User? existingUser = await CometChat.getLoggedInUser();
      if (existingUser != null && existingUser.uid != userId) {
        await CometChat.logout(
          onSuccess: (_) => debugPrint("Logout Successful"),
          onError: (_) => debugPrint("Logout failed"),
        );
      } else if (existingUser != null && existingUser.uid == userId) {
        _navigateToHome();
        return;
      }

      await CometChatUIKit.login(userId, onSuccess: (User loggedInUser) async {
        debugPrint("Login Successful: $loggedInUser");
        if (mounted) _navigateToHome();
      }, onError: (CometChatException e) {
        debugPrint("Login failed: ${e.message}");
        if (mounted) {
          setState(() => _isLoading = false);
          showErrorSnackBar(context, "Unable to login.", typography, colorPalette);
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorSnackBar(context, "Unable to login.", typography, colorPalette);
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AiAgentsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPalette.background2,
      body: GestureDetector(
        onTap: () => removeFocus(context, _focusNode),
        child: Padding(
          padding: EdgeInsets.only(
            top: spacing.padding10 ?? 40,
            left: spacing.padding4 ?? 16,
            right: spacing.padding4 ?? 16,
            bottom: spacing.padding5 ?? 20,
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
                        padding: EdgeInsets.only(top: spacing.padding10 ?? 40),
                        child: Image.asset(
                          'assets/cometchat_logo_with_text.png',
                          color: colorPalette.textPrimary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: spacing.padding10 ?? 40),
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
                      _buildUserGrid(),
                      _buildOrDivider(),
                      _buildUidField(),
                    ],
                  ),
                ),
              ),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserGrid() {
    return FutureBuilder<List<SampleUserModel>>(
      future: _futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CometChatShimmerEffect(
            colorPalette: colorPalette,
            child: GridView.builder(
              itemCount: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(spacing.padding2 ?? 8),
                  decoration: BoxDecoration(
                    color: colorPalette.background1,
                    borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                  ),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
        }

        final users = snapshot.data ?? [];
        return ValueListenableBuilder<SampleUserModel?>(
          valueListenable: _selectedUserNotifier,
          builder: (context, selectedUser, _) {
            return GridView.builder(
              itemCount: users.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = selectedUser == user;
                return GestureDetector(
                  onTap: () {
                    removeFocus(context, _focusNode);
                    _selectedUserNotifier.value = user;
                  },
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorPalette.extendedPrimary50
                              : colorPalette.background1,
                          borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
                          border: Border.all(
                            color: isSelected
                                ? (colorPalette.borderHighlight ?? Colors.transparent)
                                : (colorPalette.borderLight ?? Colors.transparent),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(spacing.padding1 ?? 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: spacing.padding2 ?? 8),
                                child: CometChatAvatar(
                                  name: user.username,
                                  image: user.imageURL,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  user.username,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colorPalette.textPrimary,
                                    fontSize: typography.body?.medium?.fontSize,
                                    fontFamily: typography.body?.medium?.fontFamily,
                                    fontWeight: typography.body?.medium?.fontWeight,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: spacing.padding1 ?? 4),
                                  child: Text(
                                    user.userId,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: colorPalette.textSecondary,
                                      fontSize: typography.caption1?.regular?.fontSize,
                                      fontFamily: typography.caption1?.regular?.fontFamily,
                                      fontWeight: typography.caption1?.regular?.fontWeight,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(spacing.padding ?? 8),
                            decoration: BoxDecoration(
                              color: colorPalette.iconHighlight,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(spacing.radius2 ?? 8),
                                topRight: Radius.circular(spacing.radius2 ?? 8),
                              ),
                            ),
                            child: Center(
                              child: Icon(Icons.check, color: colorPalette.white, size: 15),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: spacing.padding1 ?? 8,
                mainAxisSpacing: spacing.padding1 ?? 8,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrDivider() {
    return Padding(
      padding: EdgeInsets.only(
        top: spacing.padding2 ?? 4,
        bottom: spacing.padding5 ?? 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Divider(color: colorPalette.borderDefault, thickness: 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.padding2 ?? 4),
            child: Text(
              "Or",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorPalette.textTertiary,
                fontSize: typography.body?.medium?.fontSize,
                fontFamily: typography.body?.medium?.fontFamily,
                fontWeight: typography.body?.medium?.fontWeight,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: colorPalette.borderDefault, thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildUidField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: spacing.padding1 ?? 4),
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
          controller: _uidController,
          focusNode: _focusNode,
          keyboardAppearance: CometChatThemeHelper.getBrightness(context),
          onChanged: (value) {
            if (value.isNotEmpty) _selectedUserNotifier.value = null;
          },
          style: TextStyle(
            color: colorPalette.textPrimary,
            fontSize: typography.body?.regular?.fontSize,
            fontFamily: typography.body?.regular?.fontFamily,
            fontWeight: typography.body?.regular?.fontWeight,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: spacing.padding2 ?? 0,
              horizontal: spacing.padding2 ?? 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(spacing.radius2 ?? 0),
              borderSide: BorderSide(
                width: 2,
                color: colorPalette.borderLight ?? Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(spacing.radius2 ?? 0),
              borderSide: BorderSide(
                width: 2,
                color: colorPalette.borderLight ?? Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(spacing.radius2 ?? 0),
              borderSide: BorderSide(
                width: 2,
                color: colorPalette.borderLight ?? Colors.transparent,
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
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.padding5 ?? 20),
      child: ElevatedButton(
        onPressed: () {
          removeFocus(context, _focusNode);
          if (_selectedUserNotifier.value == null && _uidController.text.isEmpty) {
            showErrorSnackBar(context, "Please enter a valid UID", typography, colorPalette);
            return;
          }
          if (_selectedUserNotifier.value != null &&
              _selectedUserNotifier.value!.userId.isNotEmpty) {
            _loginUser(_selectedUserNotifier.value!.userId);
          } else if (_uidController.text.isNotEmpty) {
            _loginUser(_uidController.text);
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colorPalette.primary),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
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
          child: _isLoading
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
                    fontFamily: typography.button?.medium?.fontFamily,
                    fontWeight: typography.button?.medium?.fontWeight,
                  ),
                ),
        ),
      ),
    );
  }
}
