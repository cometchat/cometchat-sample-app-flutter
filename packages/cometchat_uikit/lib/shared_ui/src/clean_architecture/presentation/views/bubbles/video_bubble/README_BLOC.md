# Video Bubble BLoC Architecture

## Overview
The Video Bubble BLoC manages the state for video message bubbles, including thumbnail loading, video player state, and video playback controls.

## Components

### Events
- **InitializeVideoEvent**: Initialize bubble with video URL, thumbnail, and metadata
- **LoadThumbnailEvent**: Start loading thumbnail image
- **ThumbnailLoadedEvent**: Mark thumbnail as successfully loaded
- **ThumbnailLoadFailedEvent**: Handle thumbnail load failure
- **VideoClickEvent**: Handle video click (opens player)
- **PlayVideoEvent**: Start video playback
- **PauseVideoEvent**: Pause video playback

### States
- **VideoBubbleInitial**: Initial empty state
- **VideoBubbleLoaded**: Main state with video data
  - `videoUrl`: Remote video URL
  - `thumbnailUrl`: Thumbnail image URL
  - `isThumbnailLoading`: Thumbnail loading flag
  - `isThumbnailLoaded`: Thumbnail loaded flag
  - `isPlaying`: Video playback state
  - `error`: Error message if any
  - `metadata`: Additional metadata

### Computed Properties
- `shouldShowPlayButton`: Show play button when not playing
- `shouldShowLoader`: Show loading indicator
- `hasError`: Has error flag
- `hasVideo`: Valid video URL exists

## Usage Example

```dart
// Create BLoC
final bloc = VideoBubbleBloc();

// Initialize
bloc.add(InitializeVideoEvent(
  videoUrl: 'https://example.com/video.mp4',
  thumbnailUrl: 'https://example.com/thumb.jpg',
  metadata: {'duration': 120},
));

// Listen to state
BlocConsumer<VideoBubbleBloc, VideoBubbleBlocState>(
  listener: (context, state) {
    if (state.isPlaying) {
      // Open video player
    }
  },
  builder: (context, state) {
    return Stack(
      children: [
        // Thumbnail
        if (state.isThumbnailLoaded)
          Image.network(state.thumbnailUrl!),
        
        // Play button
        if (state.shouldShowPlayButton)
          IconButton(
            icon: Icon(Icons.play_circle),
            onPressed: () => context.read<VideoBubbleBloc>()
              .add(VideoClickEvent()),
          ),
        
        // Loading
        if (state.shouldShowLoader)
          CircularProgressIndicator(),
      ],
    );
  },
);
```

## State Flow
1. **Initialize** → VideoBubbleLoaded with URLs and metadata
2. **Load Thumbnail** → isThumbnailLoading = true
3. **Thumbnail Loaded** → isThumbnailLoading = false, isThumbnailLoaded = true
4. **Video Click** → Opens video player
5. **Play** → isPlaying = true
6. **Pause** → isPlaying = false
7. **Error** → error message set, loading = false

## Integration Notes
- Thumbnail loading uses Image.network with retry logic
- Video playback delegates to platform video player
- Play button overlays thumbnail
- Supports custom play icon
- Click event opens full-screen video player
- Can show video duration from metadata
