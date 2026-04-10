# Image Bubble BLoC Architecture

## Overview
The Image Bubble BLoC manages the state for image message bubbles, including image loading, caching, HEIC/HEIF format detection, and image display.

## Components

### Events
- **InitializeImageEvent**: Initialize bubble with image URL and metadata
- **LoadImageEvent**: Start loading the image
- **ImageLoadedEvent**: Mark image as successfully loaded
- **ImageLoadFailedEvent**: Handle image load failure
- **CacheImageEvent**: Mark image as cached
- **CheckCacheEvent**: Check if image is in cache
- **ImageClickEvent**: Handle image click (for full-screen view)

### States
- **ImageBubbleInitial**: Initial empty state
- **ImageBubbleLoaded**: Main state with image data
  - `imageUrl`: Remote image URL
  - `isLoading`: Loading state flag
  - `isLoaded`: Successfully loaded flag
  - `isCached`: Image in cache flag
  - `isHeicHeif`: HEIC/HEIF format flag
  - `imageBytes`: Raw image bytes (if loaded)
  - `decodedImage`: Decoded ui.Image (if processed)
  - `error`: Error message if any
  - `metadata`: Additional metadata

### Computed Properties
- `shouldShowPlaceholder`: Show placeholder when not loaded/loading
- `shouldShowLoader`: Show loading indicator
- `hasError`: Has error flag

## Usage Example

```dart
// Create BLoC
final bloc = ImageBubbleBloc();

// Initialize
bloc.add(InitializeImageEvent(
  imageUrl: 'https://example.com/image.jpg',
  metadata: {'width': 1920, 'height': 1080},
));

// Listen to state
BlocConsumer<ImageBubbleBloc, ImageBubbleBlocState>(
  listener: (context, state) {
    if (state.isLoaded) {
      // Image loaded, can show
    }
  },
  builder: (context, state) {
    if (state.shouldShowPlaceholder) {
      return PlaceholderWidget();
    } else if (state.shouldShowLoader) {
      return LoadingIndicator();
    } else if (state.isLoaded) {
      return CachedNetworkImage(imageUrl: state.imageUrl);
    } else if (state.hasError) {
      return ErrorWidget(error: state.error);
    }
    return SizedBox.shrink();
  },
);
```

## State Flow
1. **Initialize** → ImageBubbleLoaded with URL, detect HEIC/HEIF
2. **Check Cache** → Update isCached flag
3. **Load Image** → isLoading = true
4. **Image Loaded** → isLoading = false, isLoaded = true, imageBytes set
5. **Cache Image** → isCached = true
6. **Error** → error message set, isLoading = false

## Integration Notes
- Works with CachedNetworkImage for efficient caching
- Supports CometChatCacheManager for custom cache strategy
- HEIC/HEIF detection for special handling
- Image decoding can be done in isolate for performance
- Click event triggers full-screen image viewer
