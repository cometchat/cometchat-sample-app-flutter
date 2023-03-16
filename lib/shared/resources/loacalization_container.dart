import 'package:cometchat_flutter_sample_app/utils/animated_toggle.dart';
import 'package:cometchat_flutter_sample_app/utils/background_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_kit/flutter_chat_ui_kit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class LocalizationContainer extends StatelessWidget {
  const LocalizationContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackGroundCard(
        title: "Localize",
        description:
            "CometChatLocalize allows you to detect the language of your users based on their browser of "
            "device settings and set the language accordingly. To learn more about this component tap here . ",
        child: LocalizationView());
  }
}

class LocalizationView extends StatefulWidget {
  const LocalizationView({Key? key}) : super(key: key);

  @override
  _LocalizationViewState createState() => _LocalizationViewState();
}

class _LocalizationViewState extends State<LocalizationView> {
  String localeName = "en";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Language"),
              AnimatedToggle(
                width: 250,
                values: const ['English', 'हिंदी'],
                onToggleCallback: (value) {
                  if (value == "English") {
                    localeName = "en";
                  } else {
                    localeName = "hi";
                  }
                },
                buttonColor: const Color(0xFF0A3157),
                backgroundColor: const Color(0xFFB5C1CC),
                textColor: const Color(0xFFFFFFFF),
              ),
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
                      builder: (context) => MaterialApp(
                        debugShowCheckedModeBanner: false,
                        localizationsDelegates: const [
                          Translations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate
                        ],
                        supportedLocales: const [
                          Locale('en', ''),
                          Locale('hi', ''),
                        ],
                        locale: Locale(localeName),
                        title: 'Flutter Demo',
                        home: CometChatConversationsWithMessages(
                          conversationsConfiguration:
                              ConversationsConfiguration(
                                  backButton: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.black,
                                      ))),
                        ),
                      ),
                    ));
              })
        ],
      ),
    );
  }
}
