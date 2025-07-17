import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../messages/messages.dart';

class PageManager extends GetxController {
  // Private constructor for singleton
  PageManager._internal();

  // Singleton instance
  static final PageManager _instance = PageManager._internal();

  // Factory constructor to return the same instance
  factory PageManager() {
    return _instance;
  }

  // Variables
  final RxInt _selectedIndex = 0.obs;
  final RxBool _keyboardVisible = false.obs;
  final RxBool _navigateToMessageScreen = false.obs;
  final PageController _pageController = PageController();

  // Getters
  int get selectedIndex => _selectedIndex.value;
  bool get keyboardVisible => _keyboardVisible.value;
  bool get navigateToMessageScreen => _navigateToMessageScreen.value;
  PageController get pageController => _pageController;

  // Keyboard visibility check
  bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  // Setters
  void setSelectedIndex(int index) {
    _selectedIndex.value = index;
    update();
  }

  void setKeyboardVisible(bool value) {
    _keyboardVisible.value = value;
    update();
  }

  void setNavigateToMessageScreen(bool value) {
    _navigateToMessageScreen.value = value;
    update();
  }

  // Navigation to the messages screen
  void navigateToMessages({
    required BuildContext context,
    User? user,
    Group? group,
  }) async {
    final ccColor = CometChatThemeHelper.getColorPalette(context);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if (isKeyboardOpen) {
      await Future.delayed(const Duration(milliseconds: 50));
      // Close the keyboard
      FocusScope.of(context).unfocus();

      // Wait for the keyboard to close and layout to settle
      await Future.delayed(const Duration(milliseconds: 400));
      await WidgetsBinding.instance.endOfFrame;

      // Optional: wait slightly longer for Android keyboards
      await Future.delayed(const Duration(milliseconds: 50));
    }
    setNavigateToMessageScreen(true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              backgroundColor: ccColor.background1,
              body: MessagesSample(
                user: user,
                group: group,
              ),
            );
          },
        ),
      ).then((value) {
        setNavigateToMessageScreen(false);
      });
  }
}
