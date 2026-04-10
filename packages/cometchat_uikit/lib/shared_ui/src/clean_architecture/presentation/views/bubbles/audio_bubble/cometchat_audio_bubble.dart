import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import "../../../../clean_architecture.dart";
import 'package:flutter/scheduler.dart';

import 'cometchat_audio_bubble_controller.dart';

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
      this.metadata,
      this.colorPalette,
      this.spacing,
      this.typography});

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

  /// [colorPalette] optional pre-cached color palette to avoid expensive lookups during keyboard animation
  final CometChatColorPalette? colorPalette;

  /// [spacing] optional pre-cached spacing to avoid expensive lookups during keyboard animation
  final CometChatSpacing? spacing;

  /// [typography] optional pre-cached typography to avoid expensive lookups during keyboard animation
  final CometChatTypography? typography;

  @override
  State<CometChatAudioBubble> createState() => _CometChatAudioBubbleState();
}

class _CometChatAudioBubbleState extends State<CometChatAudioBubble>
    with TickerProviderStateMixin {
  AudioBubbleState? _audioState;
  StreamSubscription<AudioStateUpdate>? _audioStateSubscription;
  StreamSubscription<AudioBubbleEvents>? _eventSubscription;

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
  String fileName = '';
  late int tag;

  @override
  void initState() {
    super.initState();
    tag = widget.id ?? DateTime.now().millisecondsSinceEpoch;
    _setupAudioState();
    _setupEventStreams();
    _checkFileExists();
  }

  void _setupAudioState() {
    final path = FileUtils.getLocalFilePath(widget.metadata) ?? '';
    _audioState = AudioStateManager().getAudioState(tag, widget.audioUrl, path);

    _audioStateSubscription = _audioState!.stateStream.listen((update) {
      if (mounted && update.id == tag) {
        setState(() {
          _updateAnimationBasedOnPlayState(update.playState);
        });
      }
    });
  }

  void _setupEventStreams() {
    _eventSubscription = AudioBubbleStream().stream.asBroadcastStream().listen((event) {
      if (event.id != tag && event.action == AudioBubbleActions.pausePlayer) {
        _audioState?.pauseAudio();
      } else if (event.action == AudioBubbleActions.stopPlayer) {
        _audioState?.stopAudio();
      }
    });
  }

  void _updateAnimationBasedOnPlayState(PlayStates playState) {
    bool shouldAnimate = playState == PlayStates.playing;
    if (isAnimating != shouldAnimate) {
      toggleAnimation(shouldAnimate);
    }
  }

  Future<void> _checkFileExists() async {
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

    // Update audio state with the local path if found
    _audioState = AudioStateManager().getAudioState(tag, widget.audioUrl, localPath);
    _audioState!.initializeController();
  }

  late CometChatAudioBubbleStyle audioBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;
  late List<Widget> audioBars;
  late bool usedByMediaRecorder;
  bool _themeInitialized = false;
  Brightness? _cachedBrightness;

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
    // Only initialize theme once to avoid expensive lookups during keyboard animation
    final currentBrightness = MediaQuery.platformBrightnessOf(context);
    final brightnessChanged = _cachedBrightness != null && _cachedBrightness != currentBrightness;
    if (!_themeInitialized || brightnessChanged) {
      _cachedBrightness = currentBrightness;
      audioBubbleStyle = CometChatThemeHelper.getTheme<CometChatAudioBubbleStyle>(
              context: context, defaultTheme: CometChatAudioBubbleStyle.of)
          .merge(widget.style);
      // Use passed values OR fallback to lookup (for standalone usage)
      colorPalette = widget.colorPalette ?? CometChatThemeHelper.getColorPalette(context);
      spacing = widget.spacing ?? CometChatThemeHelper.getSpacing(context);
      typography = widget.typography ?? CometChatThemeHelper.getTypography(context);
      if (widget.metadata != null &&
          widget.metadata!.containsKey(AudioBubbleConstants.usedByMediaRecorder)) {
        usedByMediaRecorder = widget.metadata![AudioBubbleConstants.usedByMediaRecorder] ?? false;
      } else {
        usedByMediaRecorder = false;
      }
      setAudioBarHeights();
      _themeInitialized = true;
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(CometChatAudioBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update style if it changed
    if (widget.style != oldWidget.style) {
      audioBubbleStyle = CometChatThemeHelper.getTheme<CometChatAudioBubbleStyle>(
              context: context, defaultTheme: CometChatAudioBubbleStyle.of)
          .merge(widget.style);
      setAudioBarHeights();
    }
    // Update cached theme values if they changed
    if (widget.colorPalette != oldWidget.colorPalette && widget.colorPalette != null) {
      colorPalette = widget.colorPalette!;
    }
    if (widget.spacing != oldWidget.spacing && widget.spacing != null) {
      spacing = widget.spacing!;
    }
    if (widget.typography != oldWidget.typography && widget.typography != null) {
      typography = widget.typography!;
    }
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
    _audioStateSubscription?.cancel();
    _eventSubscription?.cancel();

    // Don't remove audio state here - it should persist while scrolling
    // The message list will call AudioStateManager().clearAll() when disposed

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

    super.dispose();
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
    final isInitializing = _audioState?.isInitializing ?? false;
    final playState = _audioState?.playState ?? PlayStates.init;
    final currentPosition = _audioState?.currentPosition ?? Duration.zero;
    final totalDuration = _audioState?.totalDuration ?? Duration.zero;

    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      padding: widget.padding ?? EdgeInsets.all(spacing.padding1 ?? 0),
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
              if (playState == PlayStates.playing) {
                await _audioState?.pauseAudio();
                AudioBubbleStream().controller.sink.add(
                    AudioBubbleEvents(id: tag, action: AudioBubbleActions.pausePlayer));
              } else {
                await _audioState?.playAudio();
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
                    child: playState == PlayStates.playing
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: spacing.padding3 ?? 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.padding ?? 0),
                    child: SizedBox(
                      height: 20,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        children: playState == PlayStates.playing
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
                  '${formatDuration(currentPosition)}/'
                  '${formatDuration(totalDuration)}',
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
}
