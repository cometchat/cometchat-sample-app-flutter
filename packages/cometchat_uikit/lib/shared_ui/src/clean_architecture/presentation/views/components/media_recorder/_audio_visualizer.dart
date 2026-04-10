import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///The class [AudioVisualizer] is used to show the audio visualizer while recording audio. It is strictly for internal use only. And should be kept private.
class AudioVisualizer extends StatefulWidget {
  ///The [color] parameter is used to define the color of the audio visualizer.
  final Color color;

  const AudioVisualizer({super.key, required this.color});

  @override
  AudioVisualizerState createState() => AudioVisualizerState();
}

class AudioVisualizerState extends State<AudioVisualizer> {
  final double maxBarHeight = 40.0; // Maximum height of a bar

  final ScrollController _controller = ScrollController();
  late List<Widget> audioUnits = [];

  final EventChannel _eventChannel =
      const EventChannel("cometchat_uikit_shared_audio_intensity");

  StreamSubscription<dynamic>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        _eventChannel.receiveBroadcastStream().listen(onAudioStreamed);
    _streamSubscription?.onDone(handleDone);
  }

  void handleDone() {
    _streamSubscription?.cancel();
  }

  void onAudioStreamed(dynamic event) {
    if (event is double) {
      addAudioUnit(event);
    }
  }

  addAudioUnit(double decibel) {
    setState(() {
      audioUnits = [
        ...audioUnits,
        _buildAudioBar(maxBarHeight * (0.18 + 0.618 * decibel)),
      ];
    });
    _scrollDown();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      children: audioUnits,
      // ),
    );
  }

  Widget _buildAudioBar(double height) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 4.0,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 1.0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ));
  }
}
