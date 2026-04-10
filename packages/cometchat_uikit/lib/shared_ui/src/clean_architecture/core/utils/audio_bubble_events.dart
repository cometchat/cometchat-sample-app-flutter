import 'dart:async';

class AudioBubbleEvents {
  ///[id] message object id to make file name unique
  final int id;

  ///[action] action to be performed
  final AudioBubbleActions action;

  AudioBubbleEvents({required this.id, required this.action});

  @override
  String toString() {
    return 'AudioBubbleEvents{id: $id, action: $action}';
  }

}

enum AudioBubbleActions {
  pausePlayer,
  stopPlayer,
}

///[AudioBubbleStream] a singleton class to handle the audio bubble events stream
class AudioBubbleStream {
  static final AudioBubbleStream _singleton = AudioBubbleStream._internal();

  factory AudioBubbleStream() {
    return _singleton;
  }

  AudioBubbleStream._internal();

  final controller = StreamController<AudioBubbleEvents>.broadcast();

  Stream<AudioBubbleEvents> get stream => controller.stream;
}