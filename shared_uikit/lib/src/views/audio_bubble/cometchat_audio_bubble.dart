import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

enum PlayStates { playing, paused, stopped, init }

///[CometChatAudioBubble] creates a widget that gives audio bubble
///
///used by default  when the category and type of [MediaMessage] is message and [MessageTypeConstants.audio] respectively
/// ```dart
///         CometChatAudioBubble(
///              audioUrl:
///                  'audio url',
///              title: 'Sample Audio',
///              subtitle: 'audio.mp3',
///              style: AudioBubbleStyle(
///              backgroundColor: Colors.white,
///              border: Border.all(color: Colors.red),
///              borderRadius: BorderRadius.circular(10),
///              playIconColor: Colors.red,
///              ),
///            );
///
/// ```
class CometChatAudioBubble extends StatefulWidget {
  const CometChatAudioBubble(
      {super.key,
      this.style,
      this.audioUrl,
      this.title,
      this.subtitle,
      this.playIcon,
      this.pauseIcon,
      this.margin,
      this.padding,
      this.height,
      this.width,
      this.alignment,
      this.fileMimeType,
      this.id,
      this.metadata});

  ///[audioUrl] if audioUrl passed then that audioUrl is used instead of file name from message Object
  final String? audioUrl;

  ///[title]  text to show in title
  final String? title;

  ///[subtitle]  text to show in subtitle
  final String? subtitle;

  ///[style]  Style component for audio Bubble
  final CometChatAudioBubbleStyle? style;

  ///[playIcon] audio play icon
  final Icon? playIcon;

  ///[pauseIcon] audio pause icon
  final Icon? pauseIcon;

  ///[height] height of the audio bubble
  final double? height;

  ///[width] width of the audio bubble
  final double? width;

  ///[padding] padding of the audio bubble
  final EdgeInsetsGeometry? padding;

  ///[margin] margin of the audio bubble
  final EdgeInsetsGeometry? margin;

  ///[alignment] of the bubble
  final BubbleAlignment? alignment;

  ///[fileMimeType] file mime type to open the file if message object is not passed
  final String? fileMimeType;

  ///[id] message object id to make file name unique
  final int? id;

  ///[metadata] metadata of the message object
  final Map<String, dynamic>? metadata;

  @override
  State<CometChatAudioBubble> createState() => _CometChatAudioBubbleState();
}

class _CometChatAudioBubbleState extends State<CometChatAudioBubble>
    with TickerProviderStateMixin {
  bool isInitializing = false;
  PlayStates playerStatus = PlayStates.init;
  VideoPlayerController? _controller;

  final Random random = Random();
  final double barWidth = 2.0;
  final double minHeight = 2.0;
  final double maxHeight = 16.0;
  List<double> barHeights = [];
  Timer? timer;
  bool isAnimating = false;

  final double _millisecondsInHrs = 3600000;
  int delayer = 1;

  double progress = 0.0;

  Ticker? _ticker;

  bool isFileDownloading = false;
  bool isFileExists = false;
  String? localPath;

  Duration? totalDuration;
  late int tag;

  @override
  void initState() {
    super.initState();
    tag = widget.id ?? DateTime.now().millisecondsSinceEpoch;
    setupEventStream();
    fileExists();
  }

  Future<void> initializeController() async {
    try {
      if (_controller == null) {
        isInitializing = true;
        if (mounted) {
          setState(() {});
        }

        if (localPath != null && localPath?.isNotEmpty == true) {
          if(Platform.isIOS) {
            await setAudioSessionToSpeaker();
          }
          _controller = VideoPlayerController.file(File(localPath!),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
        } else if (widget.audioUrl != null &&
            widget.audioUrl?.isNotEmpty == true) {
          if(Platform.isIOS) {
            await resetAudioSession();
          }
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(widget.audioUrl!),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
        }

        if (_controller != null) {
          await _controller!.initialize(); // Initialize the controller.

          totalDuration = _controller!.value.duration;

          _controller!.addListener(() {
            if (mounted) {
              setState(() {});
            }
            if (_controller!.value.isCompleted) {
              stopAudio(); // Handle when audio finishes playing.
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing controller: $e");
    } finally {
      isInitializing = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  String fileName = '';

  fileExists() async {
    if (widget.id != null) {
      fileName += '${widget.id}';
    }
    if (widget.title != null) {
      if (fileName.isNotEmpty) {
        fileName += '_';
      }
      fileName += widget.title!;
    }
    final localPath = FileUtils.getLocalFilePath(widget.metadata) ?? '';
    if (FileUtils.isLocalFileAvailable(localPath)) {
      this.localPath = localPath;
      isFileExists = true;
    } else {
      String? path = await BubbleUtils.isFileDownloaded(fileName);

      if (path == null) {
        isFileExists = false;
      } else {
        isFileExists = true;
      }
    }

    if (mounted) {
      setState(() {});
    }
    initializeController();
  }

  late CometChatAudioBubbleStyle audioBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;
  late List<Widget> audioBars;
  late bool usedByMediaRecorder;

  int getBarCount() {
    return usedByMediaRecorder ? 130 : 43;
  }

  setAudioBarHeights() {
    audioBars = List.generate(
      getBarCount(),
      (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.only(right: 2.69),
          width: barWidth,
          height: randomHeight(),
          decoration: BoxDecoration(
            color: audioBubbleStyle.audioBarColor ??
                (widget.alignment == BubbleAlignment.right
                    ? colorPalette.white
                    : colorPalette.primary),
            borderRadius: BorderRadius.circular(spacing.radiusMax ?? 0),
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    audioBubbleStyle = CometChatThemeHelper.getTheme<CometChatAudioBubbleStyle>(
            context: context, defaultTheme: CometChatAudioBubbleStyle.of)
        .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    if (widget.metadata != null &&
        widget.metadata!.containsKey(AudioBubbleConstants.usedByMediaRecorder)) {
      usedByMediaRecorder = widget.metadata![AudioBubbleConstants.usedByMediaRecorder] ?? false;
    } else {
      usedByMediaRecorder = false;
    }
    setAudioBarHeights();
    super.didChangeDependencies();
  }

  double randomHeight() {
    return minHeight + random.nextDouble() * (maxHeight - minHeight);
  }

  void toggleAnimation(bool isPlaying) {
    if (isAnimating && !isPlaying) {
      timer?.cancel();
      isAnimating = false;
      setState(() {});
      return;
    }
    if (!isAnimating && isPlaying) {
      timer?.cancel();
      timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          barHeights = List.generate(getBarCount(), (index) => randomHeight());
        });
      });
      isAnimating = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cleanUpAsync();

    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }

    try {
      timer?.cancel();
    } catch (e) {
      debugPrint('Error canceling timer: $e');
    } finally {
      timer = null;
    }

    if (_ticker != null && _ticker!.isActive) {
      try {
        _ticker?.stop(canceled: true);
        _ticker?.dispose();
      } catch (e) {
        debugPrint('Error disposing _ticker: $e');
      } finally {
        _ticker = null;
      }
    }
    closeEventStream();
    super.dispose();
  }

  void _cleanUpAsync() async {
    if (localPath != null && Platform.isIOS) {
      await resetAudioSession();
    }
  }

  void playAudio() {
    if (_controller != null && _controller!.value.isInitialized) {
      AudioBubbleStream().controller.sink.add(
          AudioBubbleEvents(id: tag, action: AudioBubbleActions.pausePlayer));
      playerStatus = PlayStates.playing;
      _controller!.play();
      toggleAnimation(true);
      setState(() {});
    }
  }

  pauseAudio() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller?.pause();
      playerStatus = PlayStates.paused;
      toggleAnimation(false);
      setState(() {});
    }
  }

  stopAudio() async {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller?.pause();
      await _controller?.seekTo(Duration.zero);
      playerStatus = PlayStates.stopped;
      toggleAnimation(false);
    }

    setState(() {});
  }

  double getBarSpace() {
    double width = (widget.width ?? 265) - 6;
    double factor = widget.alignment == BubbleAlignment.right ||
            (widget.alignment == BubbleAlignment.left && isFileExists)
        ? 0.775
        : 0.6;
    return width * factor;
  }

  @override
  Widget build(BuildContext context) {
    if (playerStatus != PlayStates.playing && isAnimating) {
      toggleAnimation(false);
    }

    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      padding: widget.padding ??
          EdgeInsets.only(
              left: spacing.padding2 ?? 0,
              top: spacing.padding2 ?? 0,
              right: widget.alignment == BubbleAlignment.right ||
                      (widget.alignment == BubbleAlignment.left && isFileExists)
                  ? spacing.padding2 ?? 0
                  : 0,
              bottom: 0),
      decoration: BoxDecoration(
        color: audioBubbleStyle.backgroundColor ?? colorPalette.transparent,
        border: audioBubbleStyle.border,
        borderRadius: audioBubbleStyle.borderRadius ??
            BorderRadius.circular(spacing.radius3 ?? 0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              if (!isFileExists) {
                debugPrint("File not downloaded. Playback disabled.");
                return;
              }
              if (playerStatus == PlayStates.playing) {
                pauseAudio();
              } else {
                playAudio();
              }
            },
            child: isInitializing
                ? Padding(
                    padding: EdgeInsets.all(spacing.padding1 ?? 0),
                    child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: audioBubbleStyle.backgroundColor ??
                              colorPalette.extendedPrimary200,
                          strokeWidth: 3,
                        )),
                  )
                : CircleAvatar(
                    backgroundColor: audioBubbleStyle.playIconBackgroundColor ??
                        colorPalette.white,
                    child: playerStatus == PlayStates.playing
                        ? widget.pauseIcon ??
                            Icon(Icons.pause,
                                size: 32,
                                color: audioBubbleStyle.playIconColor ??
                                    colorPalette.primary)
                        : widget.playIcon ??
                            Icon(Icons.play_arrow_rounded,
                                size: 32,
                                color: audioBubbleStyle.playIconColor ??
                                    colorPalette.primary),
                  ),
          ),
          // Bar visualization
          Padding(
            padding: EdgeInsets.only(left: spacing.padding3 ?? 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.padding ?? 0),
                  child: SizedBox(
                    height: 20,
                    width: getBarSpace(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: playerStatus == PlayStates.playing
                            ? List.generate(
                                getBarCount(),
                                (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    margin: const EdgeInsets.only(right: 2.69),
                                    width: barWidth,
                                    height: randomHeight(),
                                    decoration: BoxDecoration(
                                      color: audioBubbleStyle.audioBarColor ??
                                          (widget.alignment ==
                                                  BubbleAlignment.right
                                              ? colorPalette.white
                                              : colorPalette.primary),
                                      borderRadius: BorderRadius.circular(
                                          spacing.radiusMax ?? 0),
                                    ),
                                  );
                                },
                              )
                            : audioBars,
                      ),
                    ),
                  ),
                ),
                Text(
                  '${formatDuration(_controller?.value.position ?? Duration.zero)}/'
                  '${formatDuration(totalDuration ?? Duration.zero)}',
                  style: TextStyle(
                    color: audioBubbleStyle.durationTextColor ??
                        (widget.alignment == BubbleAlignment.right
                            ? colorPalette.white
                            : colorPalette.neutral600),
                    fontWeight: typography.caption2?.regular?.fontWeight,
                    fontSize: typography.caption2?.regular?.fontSize,
                    fontFamily: typography.caption2?.regular?.fontFamily,
                  )
                      .merge(
                        audioBubbleStyle.durationTextStyle,
                      )
                      .copyWith(color: audioBubbleStyle.durationTextColor),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: spacing.padding ?? 0),
            child: widget.alignment == BubbleAlignment.left && !isFileExists
                ? SizedBox(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isFileDownloading)
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              value: progress,
                              backgroundColor: colorPalette.extendedPrimary200,
                              color: colorPalette.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        IconButton(
                          onPressed: () async {
                            if (widget.audioUrl != null) {
                              isFileDownloading = true;
                              setState(() {});
                              _startTicker();
                              try {
                                String? path = await BubbleUtils.downloadFile(
                                    widget.audioUrl!, fileName);
                                if (path == null) {
                                  isFileExists = false;
                                } else {
                                  isFileExists = true;
                                }
                              } catch (e) {
                                debugPrint("Error downloading file: $e");
                                isFileExists = false;
                              } finally {
                                _ticker?.stop();
                                _ticker?.dispose();
                                isFileDownloading = false;
                                setState(() {});
                              }
                            }
                          },
                          icon: Image.asset(
                            isFileDownloading
                                ? AssetConstants.close
                                : AssetConstants.download,
                            height: isFileDownloading ? 15 : 24,
                            width: isFileDownloading ? 15 : 24,
                            package: UIConstants.packageName,
                            color: getDownloadButtonColor(
                                context, audioBubbleStyle, colorPalette),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          )
        ],
      ),
    );
  }

  Color? getDownloadButtonColor(
      BuildContext context,
      CometChatAudioBubbleStyle audioBubbleStyle,
      CometChatColorPalette colorPalette) {
    return audioBubbleStyle.downloadIconColor ??
        (widget.alignment == BubbleAlignment.right
            ? colorPalette.white
            : colorPalette.primary);
  }

  openFile() async {
    if (isFileExists) {
      String filePath = '${BubbleUtils.fileDownloadPath}/$fileName';
      MethodChannel channel = const MethodChannel('cometchat_uikit_shared');

      try {
        debugPrint("Opening Path = $filePath");
        final result = await channel.invokeMethod('open_file',
            {'file_path': filePath, 'file_type': widget.fileMimeType});
        debugPrint(result);
      } catch (e) {
        debugPrint('$e');
        debugPrint("Could not open file");
      }
    }
  }

  void _startTicker() {
    _ticker = createTicker((elapsed) {
      setState(() {
        if (elapsed.inHours == delayer) {
          delayer++;
        }
        progress = elapsed.inMilliseconds / (_millisecondsInHrs * delayer);
      });
    });
    _ticker?.start();
  }

  String formatDuration(Duration duration) {
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  late StreamSubscription<AudioBubbleEvents> streamSubscription;

  void setupEventStream() {
    streamSubscription =
        AudioBubbleStream().stream.asBroadcastStream().listen((event) {
      if (event.id != tag && event.action == AudioBubbleActions.pausePlayer) {
        pauseAudio();
      }
    });
  }

  void closeEventStream() {
    streamSubscription.cancel();
  }

  Future<void> setAudioSessionToSpeaker() async {
    MethodChannel channel = const MethodChannel('cometchat_uikit_shared');
    try {
      await channel.invokeMethod('setAudioSessionToSpeaker');
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> resetAudioSession() async {
    MethodChannel channel = const MethodChannel('cometchat_uikit_shared');
    try {
      await channel.invokeMethod('resetAudioSession');
    } catch (e) {
      debugPrint('$e');
    }
  }
}
