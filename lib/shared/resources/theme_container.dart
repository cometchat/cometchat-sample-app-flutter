import 'package:cometchat_flutter_sample_app/utils/animated_toggle.dart';
import 'package:cometchat_flutter_sample_app/utils/background_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;

class ThemeContainer extends StatelessWidget {
  const ThemeContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackGroundCard(
        title: "Theme",
        description:
            "CometChatTheme is a style applied to every component and every view in the activity or component in the UI kit",
        child: ThemeView());
  }
}

class ThemeView extends StatefulWidget {
  const ThemeView({Key? key}) : super(key: key);

  @override
  _ThemeViewState createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeView> {
  final CometChatTheme _customTheme = CometChatTheme(
      palette: const Palette(
        backGroundColor: PaletteModel(dark: Colors.black, light: Colors.black),
        primary: PaletteModel(dark: Colors.green, light: Colors.green),
        secondary: PaletteModel(dark: Colors.grey, light: Colors.black),
        accent: PaletteModel(dark: Colors.green, light: Colors.green),
        success: PaletteModel(dark: Colors.green, light: Colors.green),
        error: PaletteModel(dark: Colors.red, light: Colors.red),
      ),
      typography: cc.Typography.fromDefault());

  CometChatTheme _theme = cometChatTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Theme"),
              AnimatedToggle(
                  values: const ["Default", "Custom"],
                  onToggleCallback: (value) {
                    if (value == "Custom") {
                      _theme = _customTheme;
                    } else {
                      _theme = cometChatTheme;
                    }
                  },
                  width: 250)
            ],
          ),
          MaterialButton(
              child: const Text(
                "Launch",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CometChatConversationsWithMessages(
                        theme: _theme,
                      ),
                    ));
              })
        ],
      ),
    );
  }
}
