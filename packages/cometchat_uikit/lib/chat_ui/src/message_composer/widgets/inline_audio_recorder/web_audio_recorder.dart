// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:web_audio' as web_audio;
import 'package:flutter/foundation.dart';

/// Web-based audio recorder using the browser's MediaRecorder API directly.
///
/// This avoids the `record` package entirely on web, eliminating the
/// `record_linux` / `record_platform_interface` version mismatch issues.
/// Uses `dart:html` + `dart:js` for browser API access (compatible with Flutter 3.38.x).
class WebAudioRecorder {
  static final WebAudioRecorder _instance = WebAudioRecorder._internal();
  factory WebAudioRecorder() => _instance;
  WebAudioRecorder._internal();

  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  // Web Audio API for amplitude metering
  web_audio.AudioContext? _audioContext;
  web_audio.AnalyserNode? _analyserNode;
  final List<html.Blob> _chunks = [];
  String? _recordedBlobUrl;
  Uint8List? _recordedBytes;
  bool _isRecording = false;
  bool _isPaused = false;

  /// Stream controller for amplitude updates
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();
  Timer? _amplitudeTimer;

  /// Stream of amplitude values (0.0 to 1.0) during recording
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// Whether recording is currently active
  bool get isRecording => _isRecording;

  /// Start recording audio
  /// Returns true if recording started successfully
  Future<bool> startRecording() async {
    try {
      // Request microphone access
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'audio': true,
        'video': false,
      });

      if (_mediaStream == null) {
        debugPrint('[WebAudioRecorder] Failed to get media stream');
        return false;
      }

      // Set up AudioContext + AnalyserNode for amplitude metering
      try {
        _audioContext = web_audio.AudioContext();
        _analyserNode = _audioContext!.createAnalyser();
        _analyserNode!.fftSize = 256;

        // Create media stream source and connect to analyser
        final source = _audioContext!.createMediaStreamSource(_mediaStream!);
        source.connectNode(_analyserNode!);
      } catch (e) {
        debugPrint('[WebAudioRecorder] Could not set up amplitude metering: $e');
        // Continue without amplitude — recording still works
        _audioContext = null;
        _analyserNode = null;
      }

      // Create MediaRecorder
      _chunks.clear();
      _recordedBlobUrl = null;
      _recordedBytes = null;

      // Try opus first, fall back to webm
      final mimeType = html.MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
          ? 'audio/webm;codecs=opus'
          : 'audio/webm';

      _mediaRecorder = html.MediaRecorder(_mediaStream!, {'mimeType': mimeType});

      // Listen for data chunks
      _mediaRecorder!.addEventListener('dataavailable', (html.Event event) {
        final blobEvent = event as html.BlobEvent;
        final data = blobEvent.data;
        if (data != null && data.size > 0) {
          _chunks.add(data);
        }
      });

      // Start recording with 250ms timeslice for regular data events
      _mediaRecorder!.start(250);
      _isRecording = true;
      _isPaused = false;

      // Start amplitude polling
      _startAmplitudePolling();

      debugPrint('[WebAudioRecorder] Recording started (mimeType: $mimeType)');
      return true;
    } catch (e) {
      debugPrint('[WebAudioRecorder] Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording and return the recorded audio as bytes
  Future<RecordingResult?> stopRecording() async {
    if (_mediaRecorder == null) return null;

    try {
      _stopAmplitudePolling();

      // Create a completer to wait for the final data
      final completer = Completer<void>();

      _mediaRecorder!.addEventListener('stop', (html.Event event) {
        if (!completer.isCompleted) completer.complete();
      });

      _mediaRecorder!.stop();
      _isRecording = false;
      _isPaused = false;

      // Wait for onstop event (ensures all data chunks are collected)
      await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      );

      if (_chunks.isEmpty) {
        debugPrint('[WebAudioRecorder] No audio chunks recorded');
        return null;
      }

      // Create blob from chunks
      final blob = html.Blob(_chunks, _mediaRecorder!.mimeType);

      // Create blob URL
      _recordedBlobUrl = html.Url.createObjectUrlFromBlob(blob);
      debugPrint(
          '[WebAudioRecorder] Recording stopped, blob size: ${blob.size}, url: $_recordedBlobUrl');

      // Read blob as bytes for upload
      Uint8List? bytes;
      try {
        final reader = html.FileReader();
        final readCompleter = Completer<Uint8List>();

        reader.onLoadEnd.listen((_) {
          final result = reader.result;
          if (result != null && result is ByteBuffer) {
            readCompleter.complete(result.asUint8List());
          } else if (result != null && result is Uint8List) {
            readCompleter.complete(result);
          } else {
            readCompleter.completeError('FileReader result is null or unexpected type');
          }
        });

        reader.onError.listen((_) {
          if (!readCompleter.isCompleted) {
            readCompleter.completeError('FileReader error');
          }
        });

        reader.readAsArrayBuffer(blob);
        bytes = await readCompleter.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () => Uint8List(0),
        );

        if (bytes.isNotEmpty) {
          debugPrint('[WebAudioRecorder] Read ${bytes.length} bytes from blob');
        }
      } catch (e) {
        debugPrint('[WebAudioRecorder] Could not read blob bytes: $e');
      }

      _recordedBytes = bytes;

      // Clean up media stream tracks
      _stopMediaStream();

      return RecordingResult(path: _recordedBlobUrl!, bytes: bytes);
    } catch (e) {
      debugPrint('[WebAudioRecorder] Error stopping recording: $e');
      return null;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    if (_mediaRecorder == null || !_isRecording) return;
    try {
      _mediaRecorder!.pause();
      _isPaused = true;
      _stopAmplitudePolling();
      debugPrint('[WebAudioRecorder] Recording paused');
    } catch (e) {
      debugPrint('[WebAudioRecorder] Error pausing: $e');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    if (_mediaRecorder == null || !_isPaused) return;
    try {
      _mediaRecorder!.resume();
      _isPaused = false;
      _startAmplitudePolling();
      debugPrint('[WebAudioRecorder] Recording resumed');
    } catch (e) {
      debugPrint('[WebAudioRecorder] Error resuming: $e');
    }
  }

  /// Release all resources
  Future<void> dispose() async {
    _stopAmplitudePolling();

    if (_mediaRecorder != null) {
      try {
        if (_isRecording || _isPaused) {
          _mediaRecorder!.stop();
        }
      } catch (_) {}
    }

    _stopMediaStream();
    _closeAudioContext();

    _mediaRecorder = null;
    _isRecording = false;
    _isPaused = false;
    _chunks.clear();

    // Close the amplitude stream controller to prevent memory leaks
    _amplitudeController.close();

    // Revoke blob URL to free memory
    if (_recordedBlobUrl != null) {
      try {
        html.Url.revokeObjectUrl(_recordedBlobUrl!);
      } catch (_) {}
      _recordedBlobUrl = null;
    }
    _recordedBytes = null;
  }

  /// Get the last recorded blob URL
  String? get recordedBlobUrl => _recordedBlobUrl;

  /// Get the last recorded bytes (populated after stopRecording)
  Uint8List? get recordedBytes => _recordedBytes;

  void _stopMediaStream() {
    if (_mediaStream != null) {
      final tracks = _mediaStream!.getTracks();
      for (final track in tracks) {
        track.stop();
      }
      _mediaStream = null;
    }
  }

  void _closeAudioContext() {
    if (_audioContext != null) {
      try {
        _audioContext!.close();
      } catch (_) {}
      _audioContext = null;
      _analyserNode = null;
    }
  }

  void _startAmplitudePolling() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (_analyserNode == null || !_isRecording || _isPaused) return;
        try {
          final bufferLength = _analyserNode!.frequencyBinCount ?? 128;
          final dataArray = Uint8List(bufferLength);
          _analyserNode!.getByteTimeDomainData(dataArray);

          // Calculate RMS amplitude from time domain data
          double sum = 0;
          for (int i = 0; i < bufferLength; i++) {
            final sample = (dataArray[i] - 128) / 128.0;
            sum += sample * sample;
          }
          final rms = (sum / bufferLength);
          // Normalize to 0.0-1.0 range with some amplification
          final normalized = (rms * 4.0).clamp(0.0, 1.0);

          if (!_amplitudeController.isClosed) {
            _amplitudeController.add(normalized);
          }
        } catch (_) {}
      },
    );
  }

  void _stopAmplitudePolling() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
  }
}

/// Result of a recording session
class RecordingResult {
  /// On web: blob URL. On native: file path.
  final String path;

  /// Raw bytes of the recording (populated on web after reading blob)
  final Uint8List? bytes;

  RecordingResult({required this.path, this.bytes});
}
