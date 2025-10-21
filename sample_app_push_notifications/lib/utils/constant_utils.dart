import 'package:flutter/cupertino.dart';

removeFocus(context, FocusNode focusNode) {
  if (focusNode.hasFocus) {
    focusNode.unfocus();
  } else {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}


// Tab Constants
class TabConstants {
  static List<String> tabs = ["chats", "calls", "users", "groups"];
}