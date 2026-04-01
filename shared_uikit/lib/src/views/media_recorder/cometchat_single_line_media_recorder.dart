import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

/// Style class for [CometChatSingleLineMediaRecorder]
class CometChatSingleLineMediaRecorderStyle {
  const CometChatSingleLineMediaRecorderStyle({
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.deleteIconColor,
    this.recordingIndicatorColor,
    this.waveformColor,
    this.waveformInactiveColor,
    this.timerTextStyle,
    this.timerTextColor,
    this.pauseIconColor,
    this.playIconColor,
    this.micIconColor,
    this.sendButtonBackgroundColor,
    this.sendButtonIconColor,
    this.sendButtonBorderRadius,
  });

  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final Color? deleteIconColor;
  final Color? recordingIndicatorColor;
  final Color? waveformColor;
  final Color? waveformInactiveColor;
  final TextStyle? timerTextStyle;
  final Color? timerTextColor;
  final Color? pauseIconColor;
  final Color? playIconColor;
  final Color? micIconColor;
  final Color? sendButtonBackgroundColor;
  final Color? sendButtonIconColor;
  final BorderRadiusGeometry? sendButtonBorderRadius;

  CometChatSingleLineMediaRecorderStyle copyWith({
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    Color? deleteIconColor,
    Color? recordingIndicatorColor,
    Color? waveformColor,
    Color? waveformInactiveColor,
    TextStyle? timerTextStyle,
    Color? timerTextColor,
    Color? pauseIconColor,
    Color? playIconColor,
    Color? micIconColor,
    Color? sendButtonBackgroundColor,
    Color? sendButtonIconColor,
    BorderRadiusGeometry? sendButtonBorderRadius,
  }) {
    return CometChatSingleLineMediaRecorderStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      deleteIconColor: deleteIconColor ?? this.deleteIconColor,
      recordingIndicatorColor: recordingIndicatorColor ?? this.recordingIndicatorColor,
      waveformColor: waveformColor ?? this.waveformColor,
      waveformInactiveColor: waveformInactiveColor ?? this.waveformInactiveColor,
      timerTextStyle: timerTextStyle ?? this.timerTextStyle,
      timerTextColor: timerTextColor ?? this.timerTextColor,
      pauseIconColor: pauseIconColor ?? this.pauseIconColor,
      playIconColor: playIconColor ?? this.playIconColor,
      micIconColor: micIconColor ?? this.micIconColor,
      sendButtonBackgroundColor: sendButtonBackgroundColor ?? this.sendButtonBackgroundColor,
      sendButtonIconColor: sendButtonIconColor ?? this.sendButtonIconColor,
      sendButtonBorderRadius: sendButtonBorderRadius ?? this.sendButtonBorderRadius,
    );
  }

  CometChatSingleLineMediaRecorderStyle merge(CometChatSingleLineMediaRecorderStyle? style) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      borderRadius: style.borderRadius,
      border: style.border,
      deleteIconColor: style.deleteIconColor,
      recordingIndicatorColor: style.recordingIndicatorColor,
      waveformColor: style.waveformColor,
      waveformInactiveColor: style.waveformInactiveColor,
      timerTextStyle: style.timerTextStyle,
      timerTextColor: style.timerTextColor,
      pauseIconColor: style.pauseIconColor,
      playIconColor: style.playIconColor,
      micIconColor: style.micIconColor,
      sendButtonBackgroundColor: style.sendButtonBackgroundColor,
      sendButtonIconColor: style.sendButtonIconColor,
      sendButtonBorderRadius: style.sendButtonBorderRadius,
    );
  }
}

/// [CometChatSingleLineMediaRecorder] is an inline media recorder widget
/// that replaces the compose box when recording voice messages.
///
/// It displays:
/// - Recording state: Delete | Red dot | Animated Waveform | Timer | Pause | Send
/// - Paused state: Delete | Play | Static Waveform | Frozen Timer | Mic | Send
class CometChatSingleLineMediaRecorder extends StatefulWidget {
  const CometChatSingleLineMediaRecorder({
    super.key,
    this.onSubmit,
    this.onClose,
    this.style,
    this.deleteIcon,
    this.pauseIcon,
    this.playIcon,
    this.micIcon,
    this.sendIcon,
  });

  /// Callback when recording is submitted with file path and waveform data
  final Function(BuildContext, String, List<double>)? onSubmit;

  /// Callback when recording is cancelled/deleted
  final Function()? onClose;

  /// Style for the recorder
  final CometChatSingleLineMediaRecorderStyle? style;

  /// Custom delete icon
  final Widget? deleteIcon;

  /// Custom pause icon
  final Widget? pauseIcon;

  /// Custom play/resume icon
  final Widget? playIcon;

  /// Custom mic icon (shown in paused state)
  final Widget? micIcon;

  /// Custom send icon
  final Widget? sendIcon;

  @override
  State<CometChatSingleLineMediaRecorder> createState() =>
      _CometChatSingleLineMediaRecorderState();
}

class _CometChatSingleLineMediaRecorderState
    extends State<CometChatSingleLineMediaRecorder> {
  /// Whether recording is currently active
  bool _isRecording = false;
  
  /// Whether recording has been started at least once (used to show UI elements)
  bool _hasRecordingStarted = false;
  
  /// Whether we are playing back the recorded audio
  bool _isPlayingBack = false;
  
  /// The recorded audio file path (set when recording is stopped for playback)
  String? _recordedFilePath;
  
  /// Timer for elapsed time
  Timer? _timer;
  
  /// Elapsed recording time
  Duration _elapsedTime = Duration.zero;
  
  /// Saved elapsed time when stopped for playback
  Duration _savedElapsedTime = Duration.zero;
  
  /// Tag for the audio playback state
  int? _playbackAudioTag;
  
  /// Audio state for playback
  AudioBubbleState? _audioState;
  
  /// Subscription to audio state updates
  StreamSubscription<AudioStateUpdate>? _audioStateSubscription;
  
  /// Current playback position
  Duration _playbackPosition = Duration.zero;
  
  /// Total duration of the recorded audio
  Duration _playbackDuration = Duration.zero;

  // Real-time waveform data from the native audio intensity event channel
  static const EventChannel _audioIntensityChannel =
      EventChannel("cometchat_uikit_shared_audio_intensity");
  StreamSubscription<dynamic>? _audioIntensitySubscription;

  /// Rolling buffer of amplitude samples that fills the waveform area.
  /// Each value is normalized 0.0 – 1.0.
  final List<double> _amplitudeSamples = [];

  /// Frozen snapshot of the waveform captured at the moment recording stops
  /// for playback. Resampled to exactly [_maxBarCount] bars so it fills the
  /// entire waveform area during playback.
  List<double> _playbackWaveformSnapshot = [];

  /// How many bars fit in the available width (calculated in LayoutBuilder).
  int _maxBarCount = 0;

  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;
  late CometChatTypography typography;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _stopTimer();
    _stopAudioIntensityListener();
    _audioStateSubscription?.cancel();
    _stopAudioPlayback();
    _releaseResources();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    typography = CometChatThemeHelper.getTypography(context);
    super.didChangeDependencies();
  }

  // ---------------------------------------------------------------------------
  // Real-time audio intensity listener (drives waveform while recording)
  // ---------------------------------------------------------------------------

  void _startAudioIntensityListener() {
    _stopAudioIntensityListener();
    _audioIntensitySubscription =
        _audioIntensityChannel.receiveBroadcastStream().listen((event) {
      if (!mounted || !_isRecording) return;
      if (event is double) {
        setState(() {
          _amplitudeSamples.add(event.clamp(0.0, 1.0));
          // Keep the buffer trimmed to the visible bar count
          if (_maxBarCount > 0 && _amplitudeSamples.length > _maxBarCount) {
            _amplitudeSamples.removeRange(
                0, _amplitudeSamples.length - _maxBarCount);
          }
        });
      }
    });
  }

  void _stopAudioIntensityListener() {
    _audioIntensitySubscription?.cancel();
    _audioIntensitySubscription = null;
  }


  // ---------------------------------------------------------------------------
  // Waveform snapshot for playback
  // ---------------------------------------------------------------------------

  /// Resample [_amplitudeSamples] into exactly [targetCount] bars so the
  /// waveform fills the entire width during playback.
  List<double> _resampleWaveform(int targetCount) {
    if (_amplitudeSamples.isEmpty || targetCount <= 0) {
      return List.filled(targetCount > 0 ? targetCount : 1, 0.0);
    }
    if (_amplitudeSamples.length == targetCount) {
      return List<double>.from(_amplitudeSamples);
    }

    final result = <double>[];
    final ratio = _amplitudeSamples.length / targetCount;
    for (int i = 0; i < targetCount; i++) {
      final start = (i * ratio).floor();
      final end = ((i + 1) * ratio).ceil().clamp(0, _amplitudeSamples.length);
      double sum = 0;
      int count = 0;
      for (int j = start; j < end; j++) {
        sum += _amplitudeSamples[j];
        count++;
      }
      result.add(count > 0 ? sum / count : 0.0);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Audio playback helpers
  // ---------------------------------------------------------------------------

  void _stopAudioPlayback() {
    _audioStateSubscription?.cancel();
    _audioStateSubscription = null;

    if (_playbackAudioTag != null) {
      _audioState?.stopAudio();
      AudioStateManager().removeAudioState(_playbackAudioTag!);
      _playbackAudioTag = null;
      _audioState = null;
    }

    _playbackPosition = Duration.zero;
    _playbackDuration = Duration.zero;

    AudioBubbleStream().controller.sink.add(
      AudioBubbleEvents(
        id: DateTime.now().millisecondsSinceEpoch,
        action: AudioBubbleActions.stopPlayer,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Recording lifecycle
  // ---------------------------------------------------------------------------

  void _startRecording() async {
    _stopAudioPlayback();

    if (_isRecording) {
      try {
        await UIConstants.channel.invokeMethod("releaseAudioRecorderResources");
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to release audio recorder resources: $e');
        }
      }
    }

    bool result = await UIConstants.channel.invokeMethod("startRecordingAudio");
    if (result && mounted) {
      _startTimer();
      _startAudioIntensityListener();
      setState(() {
        _isRecording = true;
        _hasRecordingStarted = true;
      });
    }
  }

  void _pauseRecording() {
    if (_isRecording) {
      UIConstants.channel.invokeMethod("pauseRecordingAudio");
      _stopTimer();
      _stopAudioIntensityListener();
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  void _resumeRecording() async {
    if (!_isRecording && _hasRecordingStarted) {
      if (_isPlayingBack) {
        _stopAudioPlayback();
        _isPlayingBack = false;
        _recordedFilePath = null;
        _playbackWaveformSnapshot = [];
      }

      bool result =
          await UIConstants.channel.invokeMethod("startRecordingAudio");
      if (result && mounted) {
        _startTimer();
        _startAudioIntensityListener();
        setState(() {
          _isRecording = true;
        });
      }
    }
  }

  void _playRecordedAudio() async {
    if (_isPlayingBack) {
      if (_audioState?.playState == PlayStates.playing) {
        await _audioState?.pauseAudio();
      } else {
        await _audioState?.playAudio();
      }
      return;
    }

    String? filePath =
        await UIConstants.channel.invokeMethod("stopRecordingAudio");

    if (filePath != null && filePath.isNotEmpty && mounted) {
      _recordedFilePath = filePath;
      _savedElapsedTime = _elapsedTime;

      // Snapshot the recorded waveform, resampled to fill the full width
      _playbackWaveformSnapshot = _resampleWaveform(
          _maxBarCount > 0 ? _maxBarCount : _amplitudeSamples.length);

      final audioTag = DateTime.now().millisecondsSinceEpoch;
      _playbackAudioTag = audioTag;
      _audioState =
          AudioStateManager().getAudioState(audioTag, null, filePath);

      _audioStateSubscription?.cancel();
      _audioStateSubscription = _audioState!.stateStream.listen((update) {
        if (mounted && update.id == audioTag) {
          setState(() {
            _playbackPosition = update.currentPosition;
            if (update.totalDuration != null) {
              _playbackDuration = update.totalDuration!;
            }

            if (update.playState == PlayStates.stopped) {
              _playbackPosition = Duration.zero;
            }
          });
        }
      });

      setState(() {
        _isPlayingBack = true;
        _hasRecordingStarted = false;
        _playbackPosition = Duration.zero;
      });

      await _audioState!.initializeController();
      await _audioState!.playAudio();
    }
  }

  void _stopAndSend() async {
    _stopTimer();
    _stopAudioIntensityListener();
    _stopAudioPlayback();

    String? filePath;

    if (_recordedFilePath != null && _recordedFilePath!.isNotEmpty) {
      filePath = _recordedFilePath;
    } else {
      filePath = await UIConstants.channel.invokeMethod("stopRecordingAudio");
    }

    if (filePath != null && filePath.isNotEmpty && widget.onSubmit != null) {
      // Build the final waveform: use the playback snapshot if available,
      // otherwise resample the live amplitude samples to a fixed bar count.
      final waveform = _playbackWaveformSnapshot.isNotEmpty
          ? List<double>.from(_playbackWaveformSnapshot)
          : _resampleWaveform(_maxBarCount > 0 ? _maxBarCount : _amplitudeSamples.length);
      if (mounted) {
        widget.onSubmit!(context, filePath, waveform);
      }
    }

    if (mounted) {
      setState(() {
        _isRecording = false;
        _hasRecordingStarted = false;
        _isPlayingBack = false;
        _recordedFilePath = null;
        _elapsedTime = Duration.zero;
        _savedElapsedTime = Duration.zero;
        _amplitudeSamples.clear();
        _playbackWaveformSnapshot = [];
      });
    }
  }

  void _deleteRecording() {
    _stopTimer();
    _stopAudioIntensityListener();
    _stopAudioPlayback();

    try {
      UIConstants.channel.invokeMethod("releaseAudioRecorderResources");
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error releasing resources: $e');
      }
    }

    if (_recordedFilePath != null && _recordedFilePath!.isNotEmpty) {
      try {
        UIConstants.channel
            .invokeMethod("deleteFile", {"filePath": _recordedFilePath});
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error deleting file: $e');
        }
      }
    }

    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _elapsedTime += const Duration(seconds: 1);
      if (_elapsedTime.inSeconds >= 1200) {
        _stopAndSend();
      } else {
        setState(() {});
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _releaseResources() {
    if (_isRecording || _hasRecordingStarted) {
      try {
        UIConstants.channel.invokeMethod("releaseAudioRecorderResources");
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error releasing resources: $e');
        }
      }
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get _isPaused => _hasRecordingStarted && !_isRecording;

  void _startNewRecordingAfterPlayback() async {
    _stopAudioPlayback();

    if (_recordedFilePath != null && _recordedFilePath!.isNotEmpty) {
      try {
        UIConstants.channel
            .invokeMethod("deleteFile", {"filePath": _recordedFilePath});
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error deleting file: $e');
        }
      }
    }

    _recordedFilePath = null;
    _isPlayingBack = false;
    _elapsedTime = Duration.zero;
    _savedElapsedTime = Duration.zero;
    _amplitudeSamples.clear();
    _playbackWaveformSnapshot = [];

    _startRecording();
  }


  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        widget.style ?? const CometChatSingleLineMediaRecorderStyle();

    return Container(
      decoration: BoxDecoration(
        color: effectiveStyle.backgroundColor ?? colorPalette.background2,
        borderRadius:
            effectiveStyle.borderRadius ?? BorderRadius.circular(24),
        border: effectiveStyle.border,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.padding2 ?? 8,
        vertical: spacing.padding1 ?? 4,
      ),
      child: Row(
        children: [
          _buildDeleteButton(effectiveStyle),
          SizedBox(width: spacing.margin2 ?? 8),
          (_isPaused || _isPlayingBack)
              ? _buildPlayButton(effectiveStyle)
              : _buildRecordingIndicator(effectiveStyle),
          SizedBox(width: spacing.margin2 ?? 8),
          Expanded(child: _buildWaveform(effectiveStyle)),
          SizedBox(width: spacing.margin2 ?? 8),
          _buildTimer(effectiveStyle),
          SizedBox(width: spacing.margin2 ?? 8),
          (_isPaused || _isPlayingBack)
              ? _buildMicButton(effectiveStyle)
              : _buildPauseButton(effectiveStyle),
          SizedBox(width: spacing.margin2 ?? 8),
          _buildSendButton(effectiveStyle),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(CometChatSingleLineMediaRecorderStyle style) {
    return GestureDetector(
      onTap: _deleteRecording,
      child: Container(
        height: 32,
        width: 32,
        alignment: Alignment.center,
        child: widget.deleteIcon ??
            Image.asset(
              AssetConstants.delete,
              package: UIConstants.packageName,
              height: 24,
              width: 24,
              color: style.deleteIconColor ?? colorPalette.iconSecondary,
            ),
      ),
    );
  }

  Widget _buildRecordingIndicator(
      CometChatSingleLineMediaRecorderStyle style) {
    return Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: style.recordingIndicatorColor ?? colorPalette.error,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPlayButton(CometChatSingleLineMediaRecorderStyle style) {
    final isCurrentlyPlaying =
        _isPlayingBack && _audioState?.playState == PlayStates.playing;

    return GestureDetector(
      onTap: _playRecordedAudio,
      child: Container(
        height: 24,
        width: 24,
        alignment: Alignment.center,
        child: isCurrentlyPlaying
            ? (widget.pauseIcon ??
                Image.asset(
                  AssetConstants.pause,
                  package: UIConstants.packageName,
                  height: 20,
                  width: 20,
                  color: style.pauseIconColor ?? colorPalette.primary,
                ))
            : (widget.playIcon ??
                Image.asset(
                  AssetConstants.play,
                  package: UIConstants.packageName,
                  height: 20,
                  width: 20,
                  color: style.playIconColor ?? colorPalette.primary,
                )),
      ),
    );
  }

  Widget _buildWaveform(CometChatSingleLineMediaRecorderStyle style) {
    final activeColor = style.waveformColor ?? colorPalette.primary;
    final inactiveColor =
        style.waveformInactiveColor ?? colorPalette.iconSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double barWidth = 2.0;
        const double barSpacing = 2.0;
        const double totalBarWidth = barWidth + barSpacing;
        const double maxBarHeight = 32.0;
        const double minBarHeight = 4.0;

        final int barCount = (constraints.maxWidth / totalBarWidth).floor();

        if (_maxBarCount != barCount) {
          _maxBarCount = barCount;
        }

        // --- Playback mode: show the frozen snapshot with a sweeping playhead ---
        if (_isPlayingBack || _isPaused) {
          final snapshot = _playbackWaveformSnapshot.isNotEmpty
              ? _playbackWaveformSnapshot
              : _amplitudeSamples;
          final int displayCount =
              snapshot.length.clamp(0, barCount);

          // Calculate how far the playhead has progressed (0.0 – 1.0)
          double progress = 0.0;
          if (_isPlayingBack) {
            final totalMs = _playbackDuration.inMilliseconds > 0
                ? _playbackDuration.inMilliseconds
                : _savedElapsedTime.inMilliseconds;
            if (totalMs > 0) {
              progress =
                  (_playbackPosition.inMilliseconds / totalMs).clamp(0.0, 1.0);
            }
          }

          final int playedBars = (displayCount * progress).round();

          return SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(displayCount, (index) {
                final amplitude = snapshot[index];
                // Apply sensitivity boost
                final boostedAmplitude = (amplitude * 1.5).clamp(0.0, 1.0);
                final height =
                    minBarHeight + boostedAmplitude * (maxBarHeight - minBarHeight);
                final color = index < playedBars ? activeColor : inactiveColor;

                return Container(
                  width: barWidth,
                  height: height,
                  margin: const EdgeInsets.only(right: barSpacing),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            ),
          );
        }

        // --- Recording mode: live amplitude bars growing from the right ---
        final int sampleCount = _amplitudeSamples.length;
        final int displayCount = min(barCount, max(sampleCount, 1));

        return SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(displayCount, (index) {
              final sampleIndex = sampleCount - displayCount + index;
              final amplitude =
                  (sampleIndex >= 0 && sampleIndex < sampleCount)
                      ? _amplitudeSamples[sampleIndex]
                      : 0.0;

              // Apply sensitivity boost
              final boostedAmplitude = (amplitude * 1.5).clamp(0.0, 1.0);
              final height =
                  minBarHeight + boostedAmplitude * (maxBarHeight - minBarHeight);

              return Container(
                width: barWidth,
                height: height,
                margin: const EdgeInsets.only(right: barSpacing),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildTimer(CometChatSingleLineMediaRecorderStyle style) {
    String displayTime;

    if (_isPlayingBack) {
      displayTime = _formatTime(_playbackPosition);
    } else {
      displayTime = _formatTime(_elapsedTime);
    }

    return Text(
      displayTime,
      style: TextStyle(
        color: style.timerTextColor ?? colorPalette.textPrimary,
        fontSize: typography.body?.regular?.fontSize ?? 14,
        fontWeight: typography.body?.regular?.fontWeight,
        fontFamily: typography.body?.regular?.fontFamily,
      ).merge(style.timerTextStyle),
    );
  }

  Widget _buildPauseButton(CometChatSingleLineMediaRecorderStyle style) {
    return GestureDetector(
      onTap: _pauseRecording,
      child: Container(
        height: 32,
        width: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colorPalette.borderLight ?? Colors.transparent,
            width: 1,
          ),
        ),
        child: widget.pauseIcon ??
            Image.asset(
              AssetConstants.pause,
              package: UIConstants.packageName,
              height: 20,
              width: 20,
              color: style.pauseIconColor ?? colorPalette.iconSecondary,
            ),
      ),
    );
  }

  Widget _buildMicButton(CometChatSingleLineMediaRecorderStyle style) {
    return GestureDetector(
      onTap:
          _isPlayingBack ? _startNewRecordingAfterPlayback : _resumeRecording,
      child: Container(
        height: 32,
        width: 32,
        alignment: Alignment.center,
        child: widget.micIcon ??
            Image.asset(
              AssetConstants.microphone,
              package: UIConstants.packageName,
              height: 24,
              width: 24,
              color: style.micIconColor ?? colorPalette.primary,
            ),
      ),
    );
  }

  Widget _buildSendButton(CometChatSingleLineMediaRecorderStyle style) {
    return GestureDetector(
      onTap: _stopAndSend,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: style.sendButtonBackgroundColor ?? colorPalette.primary,
          borderRadius:
              style.sendButtonBorderRadius ?? BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: widget.sendIcon ??
            Image.asset(
              AssetConstants.send,
              package: UIConstants.packageName,
              height: 20,
              width: 20,
              color: style.sendButtonIconColor ?? colorPalette.white,
            ),
      ),
    );
  }
}