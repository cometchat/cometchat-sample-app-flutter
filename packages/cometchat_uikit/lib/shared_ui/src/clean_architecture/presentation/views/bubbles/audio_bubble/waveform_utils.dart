import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Utility class for generating audio waveform data
class WaveformUtils {
  static const MethodChannel _channel = MethodChannel('cometchat_chat_uikit');

  /// Fast waveform extraction that samples raw bytes at evenly-spaced offsets.
  /// Doesn't decode audio — just reads byte amplitudes from the file.
  /// Returns in <50ms even for hour-long files.
  static Future<List<double>> extractWaveformFast(String filePath,
      {int barCount = 40}) async {
    try {
      final file = File(filePath);
      final fileLength = await file.length();
      if (fileLength < barCount * 2) {
        return generatePlaceholder(barCount: barCount);
      }

      // Skip MP3/audio headers (first ~10% of file is often metadata)
      final dataStart = (fileLength * 0.05).toInt();
      final dataEnd = (fileLength * 0.95).toInt();
      final dataLength = dataEnd - dataStart;

      final raf = await file.open(mode: FileMode.read);
      final amplitudes = <double>[];
      // Size of each chunk to sample — read a small window at each offset
      const sampleWindowSize = 512;

      for (int i = 0; i < barCount; i++) {
        final offset =
            dataStart + (i * dataLength / barCount).toInt();
        await raf.setPosition(offset.clamp(0, fileLength - sampleWindowSize));
        final Uint8List bytes =
            await raf.read(min(sampleWindowSize, fileLength - offset));

        if (bytes.isEmpty) {
          amplitudes.add(0.15);
          continue;
        }

        // Calculate RMS-like amplitude from raw bytes
        double sum = 0;
        for (final b in bytes) {
          // Treat byte as signed audio sample centered at 128
          final sample = (b - 128).abs().toDouble();
          sum += sample * sample;
        }
        final rms = sqrt(sum / bytes.length) / 128.0;
        amplitudes.add(rms.clamp(0.15, 1.0));
      }

      await raf.close();
      return amplitudes;
    } catch (e) {
      return generatePlaceholder(barCount: barCount);
    }
  }

  /// Extract real waveform amplitudes from an audio file using native code.
  /// Accurate but slow for long files. Use [extractWaveformFast] for instant results.
  static Future<List<double>> extractWaveformFromFile(String filePath,
      {int barCount = 40}) async {
    try {
      final result = await _channel.invokeMethod('extractWaveformFromFile', {
        'filePath': filePath,
        'sampleCount': barCount,
      });

      if (result is List && result.isNotEmpty) {
        final amplitudes =
            result.map((e) => (e as num).toDouble()).toList();
        return _normalizeToBarCount(amplitudes, barCount);
      }
      return generatePlaceholder(barCount: barCount);
    } catch (e) {
      return generatePlaceholder(barCount: barCount);
    }
  }

  /// Ensure a list has exactly [targetCount] elements
  static List<double> ensureBarCount(
      List<double> amplitudes, int targetCount) {
    if (amplitudes.length == targetCount) return amplitudes;
    return _normalizeToBarCount(amplitudes, targetCount);
  }

  /// Normalize amplitude list to exactly [targetCount] samples
  static List<double> _normalizeToBarCount(
      List<double> amplitudes, int targetCount) {
    if (amplitudes.length == targetCount) return amplitudes;
    if (amplitudes.isEmpty) {
      return generatePlaceholder(barCount: targetCount);
    }

    final result = <double>[];
    for (int i = 0; i < targetCount; i++) {
      final sourceIndex = (i * amplitudes.length / targetCount);
      final lowerIndex =
          sourceIndex.floor().clamp(0, amplitudes.length - 1);
      final upperIndex =
          (lowerIndex + 1).clamp(0, amplitudes.length - 1);
      final fraction = sourceIndex - lowerIndex;
      final value = amplitudes[lowerIndex] * (1 - fraction) +
          amplitudes[upperIndex] * fraction;
      result.add(value.clamp(0.15, 1.0));
    }
    return result;
  }

  /// Generate deterministic waveform amplitudes based on audio URL.
  /// Consistent across rebuilds without actual audio analysis.
  static List<double> generateWaveform(String audioUrl,
      {int barCount = 40}) {
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
    return List.generate(
        barCount, (_) => 0.15 + random.nextDouble() * 0.7);
  }
}
