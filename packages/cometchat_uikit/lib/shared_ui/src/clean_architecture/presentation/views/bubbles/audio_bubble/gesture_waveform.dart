import 'package:flutter/material.dart';
import 'audio_waveform_painter.dart';
import 'waveform_utils.dart';

/// Widget that wraps waveform visualization with gesture detection for seeking.
/// Uses a cached painter to avoid unnecessary repaints during parent rebuilds.
class GestureWaveform extends StatefulWidget {
  final List<double> amplitudes;
  final double progress;
  final Color playedColor;
  final Color unplayedColor;
  final double barWidth;
  final double barSpacing;
  final double height;
  final double? width;
  final void Function(double progress)? onSeek;
  final bool enabled;
  final int? expectedBarCount;

  const GestureWaveform({
    super.key,
    required this.amplitudes,
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
    this.barWidth = 3.0,
    this.barSpacing = 2.0,
    this.height = 24.0,
    this.width,
    this.onSeek,
    this.enabled = true,
    this.expectedBarCount,
  });

  @override
  State<GestureWaveform> createState() => _GestureWaveformState();
}

class _GestureWaveformState extends State<GestureWaveform> {
  late List<double> _normalizedAmplitudes;
  late double _requestedWidth;
  AudioWaveformPainter? _cachedPainter;

  @override
  void initState() {
    super.initState();
    _updateAmplitudes();
  }

  @override
  void didUpdateWidget(GestureWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recalculate amplitudes if they actually changed
    if (!_listEquals(oldWidget.amplitudes, widget.amplitudes) ||
        oldWidget.expectedBarCount != widget.expectedBarCount) {
      _updateAmplitudes();
      _cachedPainter = null; // force new painter
    }
    // Invalidate painter cache if visual properties changed
    if (oldWidget.progress != widget.progress ||
        oldWidget.playedColor != widget.playedColor ||
        oldWidget.unplayedColor != widget.unplayedColor ||
        oldWidget.barWidth != widget.barWidth ||
        oldWidget.barSpacing != widget.barSpacing ||
        oldWidget.height != widget.height ||
        oldWidget.width != widget.width) {
      _cachedPainter = null;
    }
  }

  void _updateAmplitudes() {
    final targetBarCount = widget.expectedBarCount ?? widget.amplitudes.length;
    _normalizedAmplitudes = widget.amplitudes.length == targetBarCount
        ? widget.amplitudes
        : WaveformUtils.ensureBarCount(widget.amplitudes, targetBarCount);
    _requestedWidth =
        widget.width ?? _normalizedAmplitudes.length * (widget.barWidth + widget.barSpacing);
  }

  bool _listEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  AudioWaveformPainter _getPainter() {
    return _cachedPainter ??= AudioWaveformPainter(
      amplitudes: _normalizedAmplitudes,
      progress: widget.progress,
      playedColor: widget.playedColor,
      unplayedColor: widget.unplayedColor,
      barWidth: widget.barWidth,
      barSpacing: widget.barSpacing,
      maxBarHeight: widget.height,
      minBarHeight: widget.height * 0.2,
      availableWidth: null,
    );
  }

  void _handleSeek(Offset localPosition) {
    if (widget.onSeek == null) return;
    final box = context.findRenderObject() as RenderBox?;
    final w = box?.size.width ?? _requestedWidth;
    final p = (localPosition.dx / w).clamp(0.0, 1.0);
    widget.onSeek!(p);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled && widget.onSeek != null
          ? (details) => _handleSeek(details.localPosition)
          : null,
      onHorizontalDragUpdate: widget.enabled && widget.onSeek != null
          ? (details) => _handleSeek(details.localPosition)
          : null,
      child: SizedBox(
        width: _requestedWidth,
        height: widget.height,
        child: CustomPaint(
          size: Size(_requestedWidth, widget.height),
          painter: _getPainter(),
        ),
      ),
    );
  }
}
