# Bubble BLoC Architecture Overview

This document provides an overview of all BLoC implementations for message bubble components in the CometChat UI Kit.

## Implemented BLoCs

### 1. Audio Bubble BLoC ✅
**Location**: `lib/shared_ui/src/views/audio_bubble/audio_bubble_bloc.dart`

**State Management**: Audio playback, pause, stop, seek, and duration tracking

**Key Features**:
- Play/Pause/Stop controls
- Seek to position
- Duration tracking
- Audio state streaming
- Integration with AudioStateManager

**Status**: Fully implemented with clean architecture version

---

### 2. File Bubble BLoC ✅
**Location**: `lib/shared_ui/src/views/file_bubble/file_bubble_bloc.dart`

**State Management**: File download progress, local storage, file opening

**Key Features**:
- Download progress tracking (0.0 - 1.0)
- File existence checking
- Local path management
- Download/open controls
- Error handling

**Events**: Initialize, StartDownload, UpdateProgress, Complete, Fail, CheckFileExists, OpenFile

---

### 3. Image Bubble BLoC ✅
**Location**: `lib/shared_ui/src/views/image_bubble/image_bubble_bloc.dart`

**State Management**: Image loading, caching, HEIC/HEIF support

**Key Features**:
- Image loading states
- Cache management
- HEIC/HEIF format detection
- Image bytes/decoded image storage
- Click handling for full-screen view

**Events**: Initialize, LoadImage, ImageLoaded, ImageLoadFailed, CacheImage, CheckCache, ImageClick

---

### 4. Video Bubble BLoC ✅
**Location**: `lib/shared_ui/src/views/video_bubble/video_bubble_bloc.dart`

**State Management**: Thumbnail loading, video player state

**Key Features**:
- Thumbnail loading
- Play/Pause state
- Video player integration
- Click handling
- Error handling

**Events**: Initialize, LoadThumbnail, ThumbnailLoaded, ThumbnailLoadFailed, VideoClick, Play, Pause

---

### 5. Text Bubble BLoC ✅
**Location**: `lib/shared_ui/src/views/text_bubble/text_bubble_bloc.dart`

**State Management**: Text content and formatter application

**Key Features**:
- Text content management
- Formatter tracking (mentions, URLs, etc.)
- Format application state
- Simple, lightweight state

**Events**: InitializeText, UpdateText, ApplyFormatters

---

### 6. Stream Bubble BLoC ✅
**Location**: `lib/shared_ui/src/views/stream_bubble/stream_bubble_bloc.dart`

**State Management**: AI streaming messages, real-time updates

**Key Features**:
- Real-time content streaming
- Shimmer effect control
- Tool call tracking
- Stream completion
- Error handling
- Markdown support

**Events**: Initialize, ContentReceived, MessageStart, MessageEnd, ToolCallStart, ToolCallEnd, Error, Complete

---

## Common BLoC Patterns

### Event Structure
```dart
abstract class BubbleEvent {}

class InitializeEvent extends BubbleEvent {
  // Initialization parameters
}

class StateChangeEvent extends BubbleEvent {
  // State change data
}
```

### State Structure
```dart
abstract class BubbleBlocState {
  // Common properties
  final bool isLoading;
  final String? error;
  
  // Computed properties
  bool get hasError => error != null;
}

class BubbleInitial extends BubbleBlocState { }

class BubbleLoaded extends BubbleBlocState {
  const BubbleLoaded({...});
  
  BubbleLoaded copyWith({...}) { }
}
```

### BLoC Structure
```dart
class BubbleBloc extends Bloc<BubbleEvent, BubbleBlocState> {
  BubbleBloc() : super(const BubbleInitial()) {
    on<InitializeEvent>(_onInitialize);
    on<StateChangeEvent>(_onStateChange);
  }
  
  void _onInitialize(event, emit) { }
  void _onStateChange(event, emit) { }
  
  @override
  Future<void> close() {
    // Cleanup
    return super.close();
  }
}
```

## Usage Pattern

### 1. Create BLoC Provider
```dart
BlocProvider(
  create: (context) => BubbleBloc(),
  child: BubbleWidget(),
)
```

### 2. Dispatch Events
```dart
context.read<BubbleBloc>().add(InitializeEvent(...));
```

### 3. Listen to State
```dart
BlocConsumer<BubbleBloc, BubbleBlocState>(
  listener: (context, state) {
    // Side effects
  },
  builder: (context, state) {
    // UI rendering
  },
)
```

## Migration Guide

### From Stateful Widget to BLoC

**Before**:
```dart
class BubbleWidget extends StatefulWidget {
  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget> {
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    loadData();
  }
  
  void loadData() {
    setState(() => isLoading = true);
    // Load data
    setState(() => isLoading = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return isLoading ? Loader() : Content();
  }
}
```

**After**:
```dart
class BubbleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BubbleBloc()..add(InitializeEvent()),
      child: BlocBuilder<BubbleBloc, BubbleBlocState>(
        builder: (context, state) {
          return state.isLoading ? Loader() : Content();
        },
      ),
    );
  }
}
```

## Benefits

### 1. **Separation of Concerns**
- Business logic in BLoC
- UI in widget
- Clear boundaries

### 2. **Testability**
- Unit test BLoC independently
- Mock events and verify states
- No UI dependencies in tests

### 3. **Reusability**
- Same BLoC for different UI implementations
- Share logic across widgets
- Consistent behavior

### 4. **Maintainability**
- Single source of truth
- Predictable state changes
- Easy to debug with bloc_observer

### 5. **Scalability**
- Add new events/states easily
- Compose multiple BLoCs
- Clean architecture integration

## Testing

### Unit Test Example
```dart
blocTest<BubbleBloc, BubbleBlocState>(
  'emits loaded state when initialized',
  build: () => BubbleBloc(),
  act: (bloc) => bloc.add(InitializeEvent()),
  expect: () => [
    isA<BubbleLoaded>(),
  ],
);
```

### Widget Test Example
```dart
testWidgets('shows content when loaded', (tester) async {
  final bloc = MockBubbleBloc();
  whenListen(
    bloc,
    Stream.fromIterable([BubbleLoaded(...)]),
    initialState: BubbleInitial(),
  );
  
  await tester.pumpWidget(
    BlocProvider.value(
      value: bloc,
      child: BubbleWidget(),
    ),
  );
  
  expect(find.byType(Content), findsOneWidget);
});
```

## Next Steps

1. **Implement Views**: Update bubble widgets to use BLoCs
2. **Integration Tests**: Test BLoC + View integration
3. **Clean Architecture**: Create clean architecture versions in `/presentation` folder
4. **Use Cases**: Connect BLoCs to domain use cases
5. **Documentation**: Keep README files updated with examples

## Resources

- [flutter_bloc Package](https://pub.dev/packages/flutter_bloc)
- [BLoC Library Documentation](https://bloclibrary.dev)
- [Clean Architecture with Flutter](https://resocoder.com/flutter-clean-architecture)
- Audio Bubble Clean Architecture Example: `lib/shared_ui/src/clean_architecture/presentation/audio_bubble/`
