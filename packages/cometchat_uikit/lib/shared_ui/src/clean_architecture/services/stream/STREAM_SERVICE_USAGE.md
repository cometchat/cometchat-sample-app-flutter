# Stream Playback Service - Usage Guide

## Overview
The Stream Playback Service provides a clean architecture implementation for audio/video streaming with full playback control capabilities using `video_player` package.

## Features
- ✅ Play audio/video from URL (network or local files)
- ✅ Play/Pause/Stop/Resume controls
- ✅ Seek to specific position
- ✅ Real-time playback status updates
- ✅ Duration and position tracking
- ✅ Buffering status monitoring
- ✅ Multiple concurrent streams support
- ✅ Automatic resource cleanup

## Architecture

```
Domain Layer:
├── StreamEntity - Represents a stream (id, url, status, duration, position)
├── StreamRepository - Abstract contract
└── Use Cases - PlayStream, PauseStream, StopStream, etc.

Data Layer:
└── StreamRemoteDataSourceImpl - VideoPlayerController wrapper
    ├── Manages multiple stream controllers
    ├── Emits real-time status updates
    └── Handles lifecycle and cleanup
```

## Usage Examples

### 1. Basic Stream Playback

```dart
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

class AudioPlayerWidget extends StatefulWidget {
  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final ServiceLocator _serviceLocator = ServiceLocator();
  late PlayStreamUseCase _playStreamUseCase;
  late StopStreamUseCase _stopStreamUseCase;
  
  String streamId = 'audio_stream_1';
  String audioUrl = 'https://example.com/audio.mp3';
  
  @override
  void initState() {
    super.initState();
    _serviceLocator.initialize();
    _playStreamUseCase = _serviceLocator.getPlayStreamUseCase();
    _stopStreamUseCase = _serviceLocator.getStopStreamUseCase();
  }
  
  Future<void> playStream() async {
    final result = await _playStreamUseCase.call(
      url: audioUrl,
      streamId: streamId,
    );
    
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (stream) => print('Playing: ${stream.name}'),
    );
  }
  
  Future<void> stopStream() async {
    final result = await _stopStreamUseCase.call(streamId: streamId);
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (_) => print('Stream stopped'),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: playStream,
          child: Text('Play'),
        ),
        ElevatedButton(
          onPressed: stopStream,
          child: Text('Stop'),
        ),
      ],
    );
  }
}
```

### 2. Stream with Status Updates

```dart
class StreamPlayerWithStatus extends StatefulWidget {
  @override
  _StreamPlayerWithStatusState createState() => _StreamPlayerWithStatusState();
}

class _StreamPlayerWithStatusState extends State<StreamPlayerWithStatus> {
  final ServiceLocator _serviceLocator = ServiceLocator();
  StreamSubscription? _statusSubscription;
  
  String streamId = 'music_stream';
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _serviceLocator.initialize();
    _setupStatusListener();
  }
  
  void _setupStatusListener() {
    final getStatusStreamUseCase = _serviceLocator.getGetStreamStatusStreamUseCase();
    
    final result = getStatusStreamUseCase.call(streamId: streamId);
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (statusStream) {
        _statusSubscription = statusStream.listen((status) {
          setState(() {
            isPlaying = status.isPlaying;
            position = status.position;
            duration = status.duration;
          });
          
          if (status.isCompleted) {
            print('Playback completed!');
          }
        });
      },
    );
  }
  
  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Position: ${_formatDuration(position)}'),
        Text('Duration: ${_formatDuration(duration)}'),
        Slider(
          value: position.inMilliseconds.toDouble(),
          max: duration.inMilliseconds.toDouble(),
          onChanged: (value) {
            final seekUseCase = _serviceLocator.getSeekToPositionUseCase();
            seekUseCase.call(
              streamId: streamId,
              position: Duration(milliseconds: value.toInt()),
            );
          },
        ),
        Text(isPlaying ? 'Playing' : 'Paused'),
      ],
    );
  }
  
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}';
  }
}
```

### 3. Pause and Resume

```dart
Future<void> handlePauseResume() async {
  final pauseUseCase = _serviceLocator.getPauseStreamUseCase();
  final resumeUseCase = _serviceLocator.getResumeStreamUseCase();
  
  if (isPlaying) {
    // Pause the stream
    final result = await pauseUseCase.call(streamId: streamId);
    result.fold(
      (failure) => print('Pause failed: ${failure.message}'),
      (_) => print('Stream paused'),
    );
  } else {
    // Resume the stream
    final result = await resumeUseCase.call(streamId: streamId);
    result.fold(
      (failure) => print('Resume failed: ${failure.message}'),
      (_) => print('Stream resumed'),
    );
  }
}
```

### 4. Get Stream Duration (Before Playing)

```dart
Future<void> checkDuration() async {
  final getDurationUseCase = _serviceLocator.getGetStreamDurationUseCase();
  
  final result = await getDurationUseCase.call(
    url: 'https://example.com/audio.mp3',
  );
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (duration) => print('Stream duration: ${duration.inSeconds}s'),
  );
}
```

### 5. Multiple Concurrent Streams

```dart
class MultiStreamPlayer extends StatefulWidget {
  @override
  _MultiStreamPlayerState createState() => _MultiStreamPlayerState();
}

class _MultiStreamPlayerState extends State<MultiStreamPlayer> {
  final ServiceLocator _serviceLocator = ServiceLocator();
  final List<String> streamIds = ['stream_1', 'stream_2', 'stream_3'];
  
  Future<void> playMultipleStreams() async {
    final playUseCase = _serviceLocator.getPlayStreamUseCase();
    
    for (int i = 0; i < streamIds.length; i++) {
      final result = await playUseCase.call(
        url: 'https://example.com/audio_$i.mp3',
        streamId: streamIds[i],
      );
      
      result.fold(
        (failure) => print('Stream $i failed: ${failure.message}'),
        (stream) => print('Stream $i playing: ${stream.name}'),
      );
    }
  }
  
  Future<void> stopAllStreams() async {
    final stopUseCase = _serviceLocator.getStopStreamUseCase();
    
    for (final streamId in streamIds) {
      await stopUseCase.call(streamId: streamId);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: playMultipleStreams,
          child: Text('Play All'),
        ),
        ElevatedButton(
          onPressed: stopAllStreams,
          child: Text('Stop All'),
        ),
      ],
    );
  }
}
```

### 6. Local File Playback

```dart
Future<void> playLocalFile() async {
  final playUseCase = _serviceLocator.getPlayStreamUseCase();
  
  // From file path
  final result1 = await playUseCase.call(
    url: '/storage/emulated/0/Download/audio.mp3',
    streamId: 'local_stream',
  );
  
  // Or with file:// protocol
  final result2 = await playUseCase.call(
    url: 'file:///storage/emulated/0/Download/audio.mp3',
    streamId: 'local_stream_2',
  );
}
```

## Available Use Cases

### Playback Control
- `PlayStreamUseCase` - Start playing a stream
- `PauseStreamUseCase` - Pause current playback
- `ResumeStreamUseCase` - Resume paused playback
- `StopStreamUseCase` - Stop and reset playback

### Information
- `GetStreamDurationUseCase` - Get total duration of a stream
- `GetStreamCurrentPositionUseCase` - Get current playback position
- `GetStreamStatusStreamUseCase` - Subscribe to real-time status updates

### Navigation
- `SeekToPositionUseCase` - Jump to specific time position

## StreamPlaybackStatus

The status stream emits `StreamPlaybackStatus` objects with:

```dart
class StreamPlaybackStatus {
  final bool isPlaying;           // Current playback state
  final Duration position;        // Current position
  final Duration duration;        // Total duration
  final Duration bufferedPosition; // How much is buffered
  final bool isCompleted;         // Whether playback finished
}
```

## Error Handling

All use cases return `Result<T>` which can be either `Success` or `Failure`:

```dart
final result = await playStreamUseCase.call(url: url, streamId: id);

result.fold(
  (failure) {
    print('Error code: ${failure.code}');
    print('Error message: ${failure.message}');
    print('Exception: ${failure.exception}');
  },
  (stream) {
    print('Success! Stream: ${stream.name}');
  },
);
```

### Error Codes
- `STREAM_PLAY_ERROR` - Failed to start playback
- `STREAM_STOP_ERROR` - Failed to stop playback
- `STREAM_PAUSE_ERROR` - Failed to pause
- `STREAM_RESUME_ERROR` - Failed to resume
- `STREAM_SEEK_ERROR` - Failed to seek
- `STREAM_DURATION_ERROR` - Failed to get duration
- `STREAM_POSITION_ERROR` - Failed to get position

## Best Practices

1. **Always initialize ServiceLocator** before using any use cases
2. **Use unique stream IDs** for each concurrent stream
3. **Cancel subscriptions** in dispose() to prevent memory leaks
4. **Handle errors gracefully** with proper user feedback
5. **Stop streams** when done to release resources
6. **Use status streams** for UI updates instead of polling

## Implementation Details

- Uses `video_player` package (already in pubspec.yaml)
- Works for both audio and video files
- Supports network URLs and local files
- Manages multiple VideoPlayerController instances
- Automatic cleanup of disposed streams
- Real-time position updates every 100ms
- Mix with other audio enabled by default

## Testing

The service can be easily tested by mocking the repository:

```dart
class MockStreamRepository implements StreamRepository {
  @override
  Future<Result<StreamEntity>> playStream({
    required String url,
    required String streamId,
  }) async {
    return Success(StreamEntity(
      id: streamId,
      name: 'Test Stream',
      url: url,
      isPlaying: true,
      duration: Duration(seconds: 180),
      position: Duration.zero,
      createdAt: DateTime.now(),
    ));
  }
  
  // ... implement other methods
}
```

## Migration from Legacy Code

If migrating from direct VideoPlayerController usage:

**Before:**
```dart
VideoPlayerController controller = VideoPlayerController.networkUrl(Uri.parse(url));
await controller.initialize();
await controller.play();
```

**After:**
```dart
final playUseCase = ServiceLocator().getPlayStreamUseCase();
final result = await playUseCase.call(url: url, streamId: 'my_stream');
result.fold(
  (failure) => handleError(failure),
  (stream) => handleSuccess(stream),
);
```

## Support

For issues or questions about the Stream Playback Service, please refer to the clean architecture documentation or contact the development team.
