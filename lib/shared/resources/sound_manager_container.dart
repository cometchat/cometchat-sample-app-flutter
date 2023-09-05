import 'package:cometchat_flutter_sample_app/utils/background_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class SoundManagerContainer extends StatelessWidget {
  const SoundManagerContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackGroundCard(
        title: "Sound Manager",
        description:
            "CometChatSoundManager allows you to play different types of audio which is required for incoming and outgoing events .",
        child: SoundManagerView());
  }
}

class SoundManagerView extends StatefulWidget {
  const SoundManagerView({Key? key}) : super(key: key);

  @override
  _SoundManagerViewState createState() => _SoundManagerViewState();
}

class _SoundManagerViewState extends State<SoundManagerView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("Incoming Message"),
              MaterialButton(
                color: const Color(0xffbdbdbd),
                onPressed: () {
                  CometChatUIKit.soundManager.play(
                    sound: Sound.incomingMessage,
                  );
                },
                child: const Text("Play"),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("Outgoing Message"),
              MaterialButton(
                color: const Color(0xffbdbdbd),
                onPressed: () {
                  CometChatUIKit.soundManager.play(sound: Sound.outgoingMessage);
                },
                child: const Text("Play"),
              )
            ],
          )
        ],
      ),
    );
  }
}
