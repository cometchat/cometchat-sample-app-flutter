import 'package:flutter/material.dart';

/// CustomPainter that draws audio waveform bars with played/unplayed colors
class AudioWaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final double progress; // 0.0 - 1.0 (played portion)
  final Color playedColor;
  final Color unplayedColor;
  final double barWidth;
  final double barSpacing;
  final double maxBarHeight;
  final double minBarHeight;
  final double borderRadius;
  final double? availableWidth;

  AudioWaveformPainter({
    required this.amplitudes,
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
    this.barWidth = 3.0,
    this.barSpacing = 2.0,
    this.maxBarHeight = 20.0,
    this.minBarHeight = 4.0,
    this.borderRadius = 2.0,
    this.availableWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final barCount = amplitudes.length;

    // Calculate bar dimensions based on available width
    final effectiveWidth = availableWidth ?? size.width;
    final totalBarWidth = effectiveWidth / barCount;
    // Use 60% of slot width for bar, rest for spacing
    final effectiveBarWidth = (totalBarWidth * 0.6).clamp(2.0, 6.0);

    final playedBarCount = (progress * barCount).floor();

    for (int i = 0; i < barCount; i++) {
      final amplitude = amplitudes[i];
      final barHeight =
          minBarHeight + (amplitude * (maxBarHeight - minBarHeight));

      // Center bars vertically
      final top = (size.height - barHeight) / 2;
      // Center bar within its slot
      final slotStart = i * totalBarWidth;
      final left = slotStart + (totalBarWidth - effectiveBarWidth) / 2;

      final isPlayed = i < playedBarCount;
      final paint = Paint()
        ..color = isPlayed ? playedColor : unplayedColor
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, effectiveBarWidth, barHeight),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(AudioWaveformPainter oldDelegate) {
    if (oldDelegate.progress != progress ||
        oldDelegate.playedColor != playedColor ||
        oldDelegate.unplayedColor != unplayedColor ||
        oldDelegate.availableWidth != availableWidth) {
      return true;
    }
    if (oldDelegate.amplitudes.length != amplitudes.length) return true;
    for (int i = 0; i < amplitudes.length; i++) {
      if (oldDelegate.amplitudes[i] != amplitudes[i]) return true;
    }
    return false;
  }
}
