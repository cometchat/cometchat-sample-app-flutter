import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Utility class for generating audio waveform data
class WaveformUtils {
  static const MethodChannel _channel = MethodChannel('cometchat_chat_uikit');

  /// Fast waveform extraction that samples raw bytes at evenly-spaced offsets.
  /// Doesn't decode audio — just reads byte amplitudes from the file.
  /// Returns in <50ms even for hour-long files.
  /// On web, returns a generated placeholder since local file access is unavailable.
  static Future<List<double>> extractWaveformFast(
    String filePath, {
    int barCount = 40,
  }) async {
    // On web, no local file access — use URL-based placeholder
    if (kIsWeb) {
      return generateWaveform(filePath, barCount: barCount);
    }
    return _extractWaveformFastNative(filePath, barCount: barCount);
  }

  /// Native-only implementation that reads file bytes directly.
  static Future<List<double>> _extractWaveformFastNative(
    String filePath, {
    int barCount = 40,
  }) async {
    try {
      // Use platform channel to read file bytes for waveform extraction
      final result = await _channel.invokeMethod('extractWaveformFast', {
        'filePath': filePath,
        'barCount': barCount,
      });
      if (result is List && result.isNotEmpty) {
        return result
            .map((e) => (e as num).toDouble().clamp(0.15, 1.0))
            .toList();
      }
      return generatePlaceholder(barCount: barCount);
    } catch (e) {
      return generatePlaceholder(barCount: barCount);
    }
  }

  /// Extract real waveform amplitudes from an audio file using native code.
  /// Accurate but slow for long files. Use [extractWaveformFast] for instant results.
  /// On web, falls back to generated placeholder.
  static Future<List<double>> extractWaveformFromFile(
    String filePath, {
    int barCount = 40,
  }) async {
    if (kIsWeb) {
      return generateWaveform(filePath, barCount: barCount);
    }
    try {
      final result = await _channel.invokeMethod('extractWaveformFromFile', {
        'filePath': filePath,
        'sampleCount': barCount,
      });

      if (result is List && result.isNotEmpty) {
        final amplitudes = result.map((e) => (e as num).toDouble()).toList();
        return _normalizeToBarCount(amplitudes, barCount);
      }
      return generatePlaceholder(barCount: barCount);
    } catch (e) {
      return generatePlaceholder(barCount: barCount);
    }
  }

  /// Ensure a list has exactly [targetCount] elements
  static List<double> ensureBarCount(List<double> amplitudes, int targetCount) {
    if (amplitudes.length == targetCount) return amplitudes;
    return _normalizeToBarCount(amplitudes, targetCount);
  }

  /// Normalize amplitude list to exactly [targetCount] samples
  static List<double> _normalizeToBarCount(
    List<double> amplitudes,
    int targetCount,
  ) {
    if (amplitudes.length == targetCount) return amplitudes;
    if (amplitudes.isEmpty) {
      return generatePlaceholder(barCount: targetCount);
    }

    final result = <double>[];
    for (int i = 0; i < targetCount; i++) {
      final sourceIndex = (i * amplitudes.length / targetCount);
      final lowerIndex = sourceIndex.floor().clamp(0, amplitudes.length - 1);
      final upperIndex = (lowerIndex + 1).clamp(0, amplitudes.length - 1);
      final fraction = sourceIndex - lowerIndex;
      final value =
          amplitudes[lowerIndex] * (1 - fraction) +
          amplitudes[upperIndex] * fraction;
      result.add(value.clamp(0.15, 1.0));
    }
    return result;
  }

  /// Generate deterministic waveform amplitudes based on audio URL.
  /// Consistent across rebuilds without actual audio analysis.
  static List<double> generateWaveform(String audioUrl, {int barCount = 40}) {
    final seed = audioUrl.hashCode;
    final random = Random(seed);
    return List.generate(barCount, (index) {
      final baseAmplitude = 0.3 + random.nextDouble() * 0.7;
      final variation = sin(index * 0.5) * 0.2;
      return (baseAmplitude + variation).clamp(0.15, 1.0);
    });
  }

  /// Generate placeholder waveform (random bars) for initial state
  static List<double> generatePlaceholder({int barCount = 40}) {
    final random = Random();
    return List.generate(barCount, (_) => 0.15 + random.nextDouble() * 0.7);
  }
}
