import 'dart:io' show Platform;

import '../../../cometchat_uikit_shared.dart';

///[SoundManager] is an utility component that provides an audio player
class SoundManager {
  ///[SoundManager] is a singleton class so use this to initialize the instance of this class.
  static final SoundManager _instance = SoundManager._internal();

  ///This method is used to get the instance of this class.
  factory SoundManager() => _instance;

  SoundManager._internal();

  void play(
      {required Sound sound,
        String? customSound,
        String? packageName, // Use it only when using other plugin
        bool? isLooping = false,
      }) async {
    String soundPath = "";

    if (customSound != null && customSound.isNotEmpty) {
      soundPath = customSound;

      if (Platform.isAndroid && packageName != null && packageName.isNotEmpty) {
        soundPath = soundPath;
      }
    } else {
      soundPath = _getDefaultSoundPath(sound);
      packageName ??= UIConstants.packageName;
      if (Platform.isAndroid) {
        soundPath = "packages/$packageName/$soundPath";
      }
    }
    await UIConstants.channel.invokeMethod("playCustomSound",
        {'assetAudioPath': soundPath, 'package': packageName, 'isLooping': isLooping});
  }

  void stop() async {
    await UIConstants.channel.invokeMethod("stopPlayer", {});
  }

  String _getDefaultSoundPath(Sound sound) {
    String soundType = "assets/beep.mp3";
    switch (sound) {
      case Sound.incomingMessage:
        soundType = "assets/sound/incoming_message.wav";
        break;
      case Sound.outgoingMessage:
        soundType = "assets/sound/outgoing_message.wav";
        break;
      case Sound.incomingMessageFromOther:
        soundType = "assets/sound/incoming_message.wav";
        break;
      case Sound.outgoingCall:
        soundType = "assets/sound/outgoing_call.wav";
        break;
      case Sound.incomingCall:
        soundType = "assets/sound/incoming_call.wav";
        break;
      default:
        soundType = "assets/beep.mp3";
        break;
    }

    return soundType;
  }
}

enum Sound {
  incomingMessage,
  outgoingMessage,
  incomingMessageFromOther,
  outgoingCall,
  incomingCall
}