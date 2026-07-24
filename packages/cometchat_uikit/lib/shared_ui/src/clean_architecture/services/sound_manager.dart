import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../cometchat_uikit_shared.dart' show UIConstants;
import '../core/utils/platform_utils/platform_file_utils.dart' as platform;

///[SoundManager] is an utility component that provides an audio player
class SoundManager {
  ///[SoundManager] is a singleton class so use this to initialize the instance of this class.
  static final SoundManager _instance = SoundManager._internal();

  ///This method is used to get the instance of this class.
  factory SoundManager() => _instance;

  SoundManager._internal();

  void play({
    required Sound sound,
    String? customSound,
    String? packageName, // Use it only when using other plugin
    bool? isLooping = false,
  }) async {
    // Sound playback uses native MethodChannel — not available on web
    if (kIsWeb) return;

    String soundPath = "";

    if (customSound != null && customSound.isNotEmpty) {
      soundPath = customSound;

      if (platform.platformIsAndroid() &&
          packageName != null &&
          packageName.isNotEmpty) {
        soundPath = soundPath;
      }
    } else {
      soundPath = _getDefaultSoundPath(sound);
      packageName ??= UIConstants.packageName;
      if (platform.platformIsAndroid()) {
        soundPath = "packages/$packageName/$soundPath";
      }
    }
    try {
      await UIConstants.channel.invokeMethod("playCustomSound", {
        'assetAudioPath': soundPath,
        'package': packageName,
        'isLooping': isLooping,
      });
    } catch (e) {
      if (e.toString().contains('AUDIO_FOCUS_FAILED')) {
        debugPrint('Audio focus not available. Notification sound skipped.');
      } else {
        debugPrint('Error playing sound: $e');
      }
    }
  }

  void stop() async {
    if (kIsWeb) return;
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
    }

    return soundType;
  }
}

enum Sound {
  incomingMessage,
  outgoingMessage,
  incomingMessageFromOther,
  outgoingCall,
  incomingCall,
}
