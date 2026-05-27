import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
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
      this.fileSize});

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

  ///[fileSize] file size to display before download
  final String? fileSize;

  @override
  State<CometChatAudioBubble> createState() => _CometChatAudioBubbleState();
}

class _CometChatAudioBubbleState extends State<CometChatAudioBubble>
    with TickerProviderStateMixin {
  AudioBubbleState? _audioState;
  StreamSubscription<AudioStateUpdate>? _audioStateSubscription;
  StreamSubscription<AudioBubbleEvents>? _eventSubscription;

  final double barWidth = 2.0;
  final double minHeight = 4.0;
  final double maxHeight = 28.0;

  /// Waveform amplitudes (0.0–1.0) extracted from metadata or generated
  /// deterministically from the message id.
  List<double> _waveformData = [];
  List<double> _randomWaveformData = [];
  List<double> _actualWaveformData = [];

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
    if (widget.metadata != null &&
        widget.metadata!.containsKey(AudioBubbleConstants.usedByMediaRecorder)) {
      usedByMediaRecorder = widget.metadata![AudioBubbleConstants.usedByMediaRecorder] ?? false;
    }
    _initWaveformData();
    _setupAudioState();
    _setupEventStreams();
    _checkFileExists();
  }

  /// Initialise waveform data from metadata or generate a deterministic
  /// pattern seeded from the message tag so the same message always looks
  /// the same.
  void _initWaveformData() {
    final meta = widget.metadata;
    if (meta != null && meta.containsKey('waveform') && meta['waveform'] is List) {
      _actualWaveformData = (meta['waveform'] as List)
          .map<double>((e) => (e is num ? e.toDouble() : 0.0).clamp(0.0, 1.0))
          .toList();
    }

    // Generate a deterministic random waveform from the tag for initial display
    final seededRandom = Random(tag);
    _randomWaveformData = List.generate(
      getBarCount(),
      (_) => seededRandom.nextDouble(),
    );

    // If we have actual waveform data, use it; otherwise use random
    if (_actualWaveformData.isEmpty) {
      _actualWaveformData = List.generate(
        getBarCount(),
        (_) => seededRandom.nextDouble(),
      );
    }
    
    // Initially show random waveform
    _waveformData = _randomWaveformData;
  }

  void _setupAudioState() {
    final path = FileUtils.getLocalFilePath(widget.metadata) ?? '';
    _audioState = AudioStateManager().getAudioState(tag, widget.audioUrl, path);

    _audioStateSubscription?.cancel();

    _audioStateSubscription = _audioState!.stateStream.listen((update) {
      if (mounted && update.id == tag) {
        setState(() {});
      }
    });
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void permanentCleanup() {
    _audioState?.stopAudio();
    AudioStateManager().removeAudioState(tag);
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
    String resolvedPath = localPath;
    if (FileUtils.isLocalFileAvailable(localPath)) {
      this.localPath = localPath;
      isFileExists = true;
    } else {
      String? path = await BubbleUtils.isFileDownloaded(fileName);
      if (path == null) {
        isFileExists = false;
      } else {
        isFileExists = true;
        resolvedPath = path;
      }
    }

    if (mounted) {
      setState(() {});
    }

    _audioState = AudioStateManager().getAudioState(tag, widget.audioUrl, resolvedPath);
    
    // Only initialize controller if file exists
    if (isFileExists) {
      _audioState!.initializeController();
      // Switch to actual waveform when file exists
      _waveformData = _actualWaveformData;
    }
  }

  late CometChatAudioBubbleStyle audioBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;
  bool usedByMediaRecorder = false;

  int getBarCount() {
    return usedByMediaRecorder ? 130 : 43;
  }

  /// Resample [_waveformData] to exactly [targetCount] bars.
  List<double> _resampleWaveform(int targetCount) {
    if (_waveformData.isEmpty || targetCount <= 0) {
      return List.filled(targetCount > 0 ? targetCount : 1, 0.0);
    }
    if (_waveformData.length == targetCount) return _waveformData;

    final result = <double>[];
    final ratio = _waveformData.length / targetCount;
    for (int i = 0; i < targetCount; i++) {
      final start = (i * ratio).floor();
      final end = ((i + 1) * ratio).ceil().clamp(0, _waveformData.length);
      double sum = 0;
      int count = 0;
      for (int j = start; j < end; j++) {
        sum += _waveformData[j];
        count++;
      }
      result.add(count > 0 ? sum / count : 0.0);
    }
    return result;
  }

  @override
  void didChangeDependencies() {
    audioBubbleStyle = CometChatThemeHelper.getTheme<CometChatAudioBubbleStyle>(
            context: context, defaultTheme: CometChatAudioBubbleStyle.of)
        .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    AudioStateManager().stopAllAudio();
    _audioStateSubscription?.cancel();
    _eventSubscription?.cancel();

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
    double factor = 0.775;
    return width * factor;
  }

  @override
  Widget build(BuildContext context) {
    final isInitializing = _audioState?.isInitializing ?? false;
    final playState = _audioState?.playState ?? PlayStates.init;
    final currentPosition = _audioState?.currentPosition ?? Duration.zero;
    final totalDuration = _audioState?.totalDuration ?? Duration.zero;

    // Show loader when downloading or initializing
    final showLoader = isFileDownloading || (isInitializing && isFileExists);

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
              // If file doesn't exist, download it first
              if (!isFileExists) {
                if (widget.audioUrl != null && !isFileDownloading) {
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

                      _audioState = AudioStateManager().getAudioState(
                        tag,
                        widget.audioUrl,
                        null,
                      );

                      _audioState!.updateLocalPath(path);
                      await _audioState!.initializeController();
                      
                      // Switch to actual waveform after download
                      _waveformData = _actualWaveformData;
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
                return;
              }
              
              // File exists, handle play/pause
              if (playState == PlayStates.playing) {
                await _audioState?.pauseAudio();
                AudioBubbleStream().controller.sink.add(
                    AudioBubbleEvents(id: tag, action: AudioBubbleActions.pausePlayer));
              } else {
                await _audioState?.playAudio();
              }
            },
            child: showLoader
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
          Padding(
            padding: EdgeInsets.only(left: spacing.padding3 ?? 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.padding ?? 0),
                  child: SizedBox(
                    height: 32,
                    width: getBarSpace(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double barSpacing = 2.69;
                        final double totalBarWidth = barWidth + barSpacing;
                        final int barCount =
                            (constraints.maxWidth / totalBarWidth).floor();
                        final samples = _resampleWaveform(barCount);

                        // Calculate playhead progress (0.0 – 1.0)
                        double playProgress = 0.0;
                        if (totalDuration.inMilliseconds > 0) {
                          playProgress = (currentPosition.inMilliseconds /
                                  totalDuration.inMilliseconds)
                              .clamp(0.0, 1.0);
                        }
                        final int playedBars =
                            (barCount * playProgress).round();

                        final activeColor =
                            audioBubbleStyle.audioBarColor ??
                                (widget.alignment == BubbleAlignment.right
                                    ? colorPalette.white
                                    : colorPalette.primary);
                        final inactiveColor = activeColor?.withValues(alpha: 0.35);

                        return Row(
                          children: List.generate(barCount, (index) {
                            final amplitude =
                                index < samples.length ? samples[index] : 0.0;
                            // Apply sensitivity boost - amplify the amplitude
                            final boostedAmplitude = (amplitude * 1.5).clamp(0.0, 1.0);
                            final height = minHeight +
                                boostedAmplitude * (maxHeight - minHeight);
                            final color =
                                index < playedBars ? activeColor : inactiveColor;

                            return Container(
                              margin: const EdgeInsets.only(right: barSpacing),
                              width: barWidth,
                              height: height,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(
                                    spacing.radiusMax ?? 0),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
                // Show file size if file not downloaded or controller not ready, otherwise show timestamp
                Text(
                  isFileExists && totalDuration > Duration.zero
                      ? '${formatDuration(currentPosition)}/'
                        '${formatDuration(totalDuration)}'
                      : widget.fileSize ?? '',
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
        ],
      ),
    );
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
