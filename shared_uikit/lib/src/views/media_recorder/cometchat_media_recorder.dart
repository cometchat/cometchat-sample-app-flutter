import 'dart:async';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/src/views/media_recorder/_microphone_visualizer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///[CometChatMediaRecorder] is a class that allows users to record audio  messages.
///It has a start button to start recording, a stop button to stop recording, a play button to play the recorded message, a pause button to pause the recorded message, a submit button to submit the recorded message and a close button to close the media recorder.
///
/// ```dart
/// CometChatMediaRecorder(
///  },
///  onClose: () {
///  print("Closed");
///  },
///  mediaRecorderStyle: MediaRecorderStyle(
///  backgroundColor: Colors.white,
///  border: Border.all(color: Colors.red),
///  borderRadius: BorderRadius.circular(10),
///  startButtonBackgroundColor: Colors.blue,
///  stopButtonBackgroundColor: Colors.red,
///  pauseButtonBackgroundColor: Colors.green,
///  ),
///  );
///  ```
///
class CometChatMediaRecorder extends StatefulWidget {
  const CometChatMediaRecorder(
      {super.key,
      this.onSubmit,
      this.onClose,
      this.style,
      this.padding,
      this.startButtonIcon,
      this.pauseButtonIcon,
      this.deleteButtonIcon,
      this.stopButtonIcon,
      this.sendButtonIcon
      });

  ///[onSubmit] provides callback to the submit Icon/widget
  final Function(BuildContext, String)? onSubmit;

  ///[onClose] provides callback to the close Icon/widget
  final Function? onClose;

  ///[mediaRecorderStyle] provides style to the media recorder
  final CometChatMediaRecorderStyle? style;

  ///[padding] provides padding to the media recorder
  final EdgeInsetsGeometry? padding;

  ///[startButtonIcon] defines the icon of the start button.
  final Widget? startButtonIcon;

  ///[pauseButtonIcon] defines the icon of the pause button.
  final Widget? pauseButtonIcon;

  ///[deleteButtonIcon] defines the icon of the delete button.
  final Widget? deleteButtonIcon;

  ///[stopButtonIcon] defines the icon of the stop button.
  final Widget? stopButtonIcon;

  ///[sendButtonIcon] defines the icon of the send button.
  final Widget? sendButtonIcon;

  @override
  State<CometChatMediaRecorder> createState() => _CometChatMediaRecorderState();
}

class _CometChatMediaRecorderState extends State<CometChatMediaRecorder> {
  String? path;
  bool _isRecording = false;
  bool _isAudioRecordingCompleted = false;
  late Timer _timer;
  // bool _isPlaying = false;
  bool _hasRecordingStarted =false;

  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    startRecording();
  }

  @override
  void dispose() {
    _stopTimer();
    releaseAudioRecorderResources();
    deleteFile();
    super.dispose();
  }

  late CometChatMediaRecorderStyle mediaRecorderStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;

  @override
  void didChangeDependencies() {
    mediaRecorderStyle =
        CometChatThemeHelper.getTheme<CometChatMediaRecorderStyle>(
            context: context, defaultTheme: CometChatMediaRecorderStyle.of)
            .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: widget.padding ?? EdgeInsets.only(
          bottom: spacing.padding5 ?? 0, top: spacing.padding3 ?? 0),
      decoration: BoxDecoration(
        color: mediaRecorderStyle.backgroundColor ?? colorPalette.background1,
        border: mediaRecorderStyle.border,
        borderRadius: mediaRecorderStyle.borderRadius ?? BorderRadius.only(
            topLeft: Radius.circular(
                spacing.radius6 ??
                0),
            topRight: Radius.circular( spacing.radius6 ??
                0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.padding5 ?? 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: spacing.padding5 ?? 0),
              child: _isAudioRecordingCompleted
                  ? CometChatAudioBubble(
                      metadata: {AudioBubbleConstants.localPath: path,AudioBubbleConstants.usedByMediaRecorder:true},
                      alignment: BubbleAlignment.right,
                      width: MediaQuery.of(context).size.width-40,
                      padding: EdgeInsets.all(spacing.padding2 ?? 0),
                      style: CometChatAudioBubbleStyle(
                        playIconColor: mediaRecorderStyle.playButtonIconColor,
                        backgroundColor: colorPalette.primary,
                        borderRadius:
                            BorderRadius.circular(spacing.radius3 ?? 0),
                      ).merge(mediaRecorderStyle.audioBubbleStyle),
                    )
                  : getAudioAnimation(mediaRecorderStyle, colorPalette, typography, spacing),
            ),
            _getActionItems(mediaRecorderStyle,colorPalette, spacing)
          ],
        ),
      ),
    );
  }

  Widget _getActionItems(CometChatMediaRecorderStyle mediaRecorderStyle,
      CometChatColorPalette colorPalette, CometChatSpacing spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if(_isAudioRecordingCompleted || _hasRecordingStarted)  buttonWrapper(
            IconButton(
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                icon: widget.deleteButtonIcon ??
                    Image.asset(
                      AssetConstants.delete48px,
                      package: UIConstants.packageName,
                      color: mediaRecorderStyle.deleteButtonIconColor ??
                          colorPalette.iconSecondary,
                    ),
                onPressed: () async {
                  //exit media recorder
                  _stopTimer();
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    deleteFile();
                    Navigator.pop(context);
                  }
                }),
            24,
            colorPalette,
            spacing,
          mediaRecorderStyle.deleteButtonBackgroundColor,
          mediaRecorderStyle.deleteButtonBorderRadius,
          mediaRecorderStyle.deleteButtonBorder
        ),
        //-----show add to chat bottom sheet-----
              Padding(padding: EdgeInsets.symmetric(horizontal: spacing.padding5 ?? 0),
              child: _isAudioRecordingCompleted
                  ? _getSendButton(mediaRecorderStyle,colorPalette, spacing)
                  : getRecordButtons(mediaRecorderStyle, colorPalette, spacing),
              ),
        //-----show auxiliary buttons -----
       if(_isAudioRecordingCompleted || _hasRecordingStarted) buttonWrapper(
            _isAudioRecordingCompleted
                ? _getStartButton(mediaRecorderStyle, colorPalette, spacing)
                : _getStopButton(mediaRecorderStyle, colorPalette, spacing),
            24,
            colorPalette,
            spacing,
           _isAudioRecordingCompleted? mediaRecorderStyle.startButtonBackgroundColor : mediaRecorderStyle.stopButtonBackgroundColor,
            _isAudioRecordingCompleted? mediaRecorderStyle.startButtonBorderRadius : mediaRecorderStyle.stopButtonBorderRadius,
            _isAudioRecordingCompleted? mediaRecorderStyle.startButtonBorder : mediaRecorderStyle.stopButtonBorder
       )
      ],
    );
  }

  Widget buttonWrapper(Widget child, double size,
      CometChatColorPalette colorPalette, CometChatSpacing spacing, Color? backgroundColor, BorderRadiusGeometry? borderRadius, BoxBorder? border) {
    return Container(
      padding: EdgeInsets.all(spacing.padding2 ?? 0),
      decoration: BoxDecoration(
          color: backgroundColor ?? colorPalette.background1,
          border: border ?? Border.all(
              color: colorPalette.borderLight ?? Colors.transparent, width: 1),
          borderRadius: borderRadius ?? BorderRadius.circular(spacing.radiusMax ?? 0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff1018280F).withOpacity(.06),
              blurRadius: 4,
              spreadRadius: -2,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: const Color(0xff1018280F).withOpacity(.1),
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            )
          ]),
      child: SizedBox(height: size, width: size, child: child),
    );
  }

  Widget _getSendButton(CometChatMediaRecorderStyle mediaRecorderStyle,
      CometChatColorPalette colorPalette, CometChatSpacing spacing) {
    return buttonWrapper(IconButton(
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints(),
      splashRadius: 32,
      icon: widget.sendButtonIcon ??
          Image.asset(
            AssetConstants.mediaRecorderSendIcon,
            package: UIConstants.packageName,
            color: mediaRecorderStyle.sendButtonIconColor,
          ),
      onPressed: () {
        if (_isAudioRecordingCompleted) {
              if (widget.onSubmit != null && path != null && path!.isNotEmpty) {
                widget.onSubmit!(context, path!);
              }
              setState(() {
                path = null;
              });
              Navigator.pop(context);
            }
      },
    ), 32, colorPalette, spacing, mediaRecorderStyle.sendButtonBackgroundColor, mediaRecorderStyle.sendButtonBorderRadius, mediaRecorderStyle.sendButtonBorder);
  }

  Widget getAudioAnimation(CometChatMediaRecorderStyle mediaRecorderStyle,
      CometChatColorPalette colorPalette,
      CometChatTypography typography, CometChatSpacing spacing) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 120,
          width: 120,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _isRecording
                  ? MicrophoneVisualizer(
                      isAnimating: _isRecording,
                      startSize: 80,
                      endSize: 120,
                      color:  mediaRecorderStyle.recordIndicatorBackgroundColor?.withOpacity(.05) ?? colorPalette.extendedPrimary50,
                      borderRadius: mediaRecorderStyle.recordIndicatorBorderRadius ?? BorderRadius.circular(spacing.radiusMax ?? 0),
                    )
                  : const SizedBox(),
              _isRecording
                  ? MicrophoneVisualizer(
                      isAnimating: _isRecording,
                      startSize: 80,
                      endSize: 100,
                      color: mediaRecorderStyle.recordIndicatorBackgroundColor?.withOpacity(.1) ?? colorPalette.extendedPrimary100,
                      borderRadius: mediaRecorderStyle.recordIndicatorBorderRadius ?? BorderRadius.circular(spacing.radiusMax ?? 0),
                    )
                  : const SizedBox(),
              Container(
                padding: EdgeInsets.all(spacing.padding4 ?? 0),
                decoration: BoxDecoration(
                  color:   (_hasRecordingStarted
                      ? mediaRecorderStyle.recordIndicatorBackgroundColor ?? colorPalette.iconHighlight
                      : mediaRecorderStyle.recordIndicatorBackgroundColor?.withOpacity(.2) ?? colorPalette.extendedPrimary200),
                  borderRadius: mediaRecorderStyle.recordIndicatorBorderRadius ?? BorderRadius.circular(spacing.radiusMax ?? 0),
                  border: mediaRecorderStyle.recordIndicatorBorder
                ),
                child: Image.asset(
                  AssetConstants.mic96px,
                  package: UIConstants.packageName,
                  color: mediaRecorderStyle.recordIndicatorIconColor ??
                      colorPalette.white,
                  height: 48,
                  width: 48,
                ),
              ),
            ],
          ),
        ),
        _hasRecordingStarted?
        Text(
          _formatElapsedTime(_elapsedTime),
          style: TextStyle(
            color: mediaRecorderStyle.textColor ?? mediaRecorderStyle.textStyle?.color ?? colorPalette.textPrimary,
            fontSize: mediaRecorderStyle.textStyle?.fontSize ?? typography.heading4?.regular?.fontSize,
            fontWeight: mediaRecorderStyle.textStyle?.fontWeight ?? typography.heading4?.regular?.fontWeight,
            fontFamily: mediaRecorderStyle.textStyle?.fontFamily ?? typography.heading4?.regular?.fontFamily,
          ),
        )
        : const SizedBox(height: 19,),
      ],
    );
  }

  Widget _getStopButton(CometChatMediaRecorderStyle mediaRecorderStyle,
      CometChatColorPalette colorPalette, CometChatSpacing spacing) {
    return IconButton(
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(),
        icon: widget.stopButtonIcon ??
            Image.asset(
              AssetConstants.stop48px,
              package: UIConstants.packageName,
              color: mediaRecorderStyle.stopButtonIconColor ??
                  colorPalette.iconSecondary,
            ),
        onPressed: stopRecording);
  }

  Widget getRecordButtons(CometChatMediaRecorderStyle mediaRecorderStyle,
      CometChatColorPalette colorPalette, CometChatSpacing spacing) {
    return buttonWrapper(_isRecording
        ? _getPauseButton(mediaRecorderStyle,colorPalette, spacing)
        : _getStartButton(mediaRecorderStyle,colorPalette, spacing), 32, colorPalette, spacing,
        _isRecording? mediaRecorderStyle.pauseButtonBackgroundColor : mediaRecorderStyle.startButtonBackgroundColor,
        _isRecording? mediaRecorderStyle.pauseButtonBorderRadius : mediaRecorderStyle.startButtonBorderRadius,
        _isRecording? mediaRecorderStyle.pauseButtonBorder : mediaRecorderStyle.startButtonBorder);
  }

  Widget _getStartButton(CometChatMediaRecorderStyle mediaRecorderStyle,
      CometChatColorPalette colorPalette, CometChatSpacing spacing) {
    return IconButton(
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(),
        icon: widget.startButtonIcon ??
            Image.asset(
              AssetConstants.mic96px,
              package: UIConstants.packageName,
              color: mediaRecorderStyle.startButtonIconColor ??
                  (_isAudioRecordingCompleted? colorPalette.iconSecondary : colorPalette.error),
            ),
        onPressed: startRecording);
  }

  void startRecording() async {
    stopAudioPlaybackBeforeRecording();
    if (_isRecording ||
        path != null ||
        _isAudioRecordingCompleted) {
      try {
        UIConstants.channel.invokeMethod("releaseAudioRecorderResources");
      } catch (e) {
        if (kDebugMode) {
          print('Failed to release audio recorder resources: $e');
        }
      }
    }
    //start recording
    bool result = await UIConstants.channel.invokeMethod("startRecordingAudio");
    if (result) {
      _startTimer();
      setState(() {
        _isAudioRecordingCompleted = false;
        _isRecording = true;
        _hasRecordingStarted = true;
      });
    }
  }

  void stopAudioPlaybackBeforeRecording() {
    AudioBubbleStream().controller.sink.add(
      AudioBubbleEvents(id: DateTime.now().millisecondsSinceEpoch, action: AudioBubbleActions.stopPlayer),
    );
  }

  void stopRecording() async {
    //exit media recorder
    String? filePath =
        await UIConstants.channel.invokeMethod("stopRecordingAudio");
    _stopTimer();
    setState(() {
      _isRecording = false;
      _isAudioRecordingCompleted = true;
      _hasRecordingStarted =false;
      path = filePath;
      _elapsedTime = Duration.zero;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime += const Duration(seconds: 1);
      if ((_elapsedTime).inSeconds == 1200) {
        stopRecording();
      } else {
        setState(() {});
      }
    });
  }

  void _stopTimer() {
    try {
      if (mounted && _timer.isActive) {
        _timer.cancel();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("error in stopping timer $e");
      }
    }
  }

  Widget _getPauseButton(CometChatMediaRecorderStyle mediaRecorderStyle,
      CometChatColorPalette colorPalette, CometChatSpacing spacing) {
    return IconButton(
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(),
        icon: widget.pauseButtonIcon ??
            Image.asset(
              AssetConstants.pause72px,
              package: UIConstants.packageName,
              color: mediaRecorderStyle.pauseButtonIconColor ??
                  colorPalette.error,
            ),
        onPressed: () {
          pauseAudioRecorder();

          if (mounted) {
            setState(() {
              _isRecording = false;
            });
          }
        });
  }

  void pauseAudioRecorder() {
    //pause playing recorded audio
    if(_isRecording){
      UIConstants.channel.invokeMethod("pauseRecordingAudio");
      _timer.cancel();
    }
  }

  void deleteFile() {
    try {
      if (path != null && path!.isNotEmpty) {
        UIConstants.channel.invokeMethod("deleteFile", {"filePath": path});
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("error in deleting file $e");
      }
    }
  }

  ///[_formatElapsedTime] is used to format the elapsed time in the format of HH:MM:SS
  String _formatElapsedTime(Duration duration) {
    if (duration.inMinutes >= 1) {
      return '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '00:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  void releaseAudioRecorderResources() {
    if (_isRecording) {
      try {
        UIConstants.channel.invokeMethod("releaseAudioRecorderResources");
      } catch (e) {
        if (kDebugMode) {
          debugPrint("error in releasing audio recorder resources $e");
        }
      }
    }
  }
}
