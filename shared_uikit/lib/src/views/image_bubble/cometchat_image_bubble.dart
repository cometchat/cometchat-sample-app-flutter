import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'image_utility.dart'; // For any FileUtils or constants

/// Custom cache manager for CometChat images with memory optimization
class CometChatCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'cometchat_image_cache';

  static final CometChatCacheManager _instance = CometChatCacheManager._();
  static CometChatCacheManager get instance => _instance;

  CometChatCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ),
  );
}

/// Isolate function for safe image decoding with memory constraints
Future<ui.Image?> decodeImageInIsolate(Uint8List bytes) async {
  try {
    // Limit image size to prevent memory issues on iOS
    const maxWidth = 1024;
    const maxHeight = 1024;

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: maxWidth,
      targetHeight: maxHeight,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  } catch (e) {
    debugPrint("❌ Image decode error in isolate: $e");
    return null;
  }
}

/// Decode image on main thread (for iOS compatibility)
Future<ui.Image?> decodeImageOnMainThread(Uint8List bytes) async {
  try {
    const maxWidth = 1024;
    const maxHeight = 1024;

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: maxWidth,
      targetHeight: maxHeight,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  } catch (e) {
    debugPrint("❌ Image decode error on main thread: $e");
    return null;
  }
}

/// Widget that shows an image bubble with caching and isolate download support
class CometChatImageBubble extends StatefulWidget {
  final String? imageUrl;
  final CometChatImageBubbleStyle? style;
  final String? placeholderImage;
  final String? placeHolderImagePackageName;
  final Function()? onClick;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Map<String, dynamic>? metadata;

  const CometChatImageBubble({
    super.key,
    this.imageUrl,
    this.style,
    this.placeholderImage,
    this.placeHolderImagePackageName,
    this.onClick,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.metadata,
  });

  @override
  State<CometChatImageBubble> createState() => _CometChatImageBubbleState();
}

/// Image loading state
enum _ImageLoadState {
  loading,
  loaded,
  error,
}

class _CometChatImageBubbleState extends State<CometChatImageBubble> {
  bool _isHeicHeif = false; // Track if it's HEIC/HEIF format
  int _retryCount = 0; // Track automatic retry attempts
  int _imageKey = 0; // Key to force image reload
  _ImageLoadState _loadState = _ImageLoadState.loading;
  static const int _maxRetries = 3; // Maximum automatic retry attempts

  /// Resets all retry state to initial values
  void _resetRetryState() {
    _retryCount = 0;
    _imageKey = 0;
    _loadState = _ImageLoadState.loading;
  }

  late CometChatImageBubbleStyle imageBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageBubbleStyle = CometChatThemeHelper.getTheme<CometChatImageBubbleStyle>(
        context: context, defaultTheme: CometChatImageBubbleStyle.of)
        .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  @override
  void didUpdateWidget(CometChatImageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset retry state when URL changes
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resetRetryState();
      _checkImageFormat();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkImageFormat();
  }

  bool _isHeicOrHeifImage(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.heic') ||
        lowerUrl.contains('.heif') ||
        lowerUrl.endsWith('heic') ||
        lowerUrl.endsWith('heif') ||
        lowerUrl.contains('heics') ||
        lowerUrl.contains('heifs') ||
        lowerUrl.contains('image/heic') ||
        lowerUrl.contains('image/heif') ||
        lowerUrl.contains('avif') ||
        lowerUrl.endsWith('.avif') ||
        lowerUrl.contains('image/avif');
  }

  void _checkImageFormat() {
    if (widget.imageUrl != null && _isHeicOrHeifImage(widget.imageUrl!)) {
      debugPrint("⚠️ HEIC/HEIF/AVIF image detected, showing placeholder: ${widget.imageUrl}");
      setState(() {
        _isHeicHeif = true;
      });
    } else {
      setState(() {
        _isHeicHeif = false;
      });
    }
  }

  Widget _buildHeicHeifPlaceholder() {
    return Container(
      color: imageBubbleStyle.backgroundColor ?? colorPalette.background3?.withOpacity(0.5),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: colorPalette.iconSecondary ?? Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: imageBubbleStyle.backgroundColor ?? colorPalette.background3,
      alignment: Alignment.center,
      child: Image(
        fit: BoxFit.contain,
        color: colorPalette.iconTertiary,
        image: AssetImage(
          widget.placeholderImage ?? AssetConstants.imagePlaceholder,
          package: widget.placeHolderImagePackageName ?? UIConstants.packageName,
        ),
      ),
    );
  }

  /// Builds the loading indicator widget
  Widget _buildLoadingIndicator() {
    return Container(
      color: imageBubbleStyle.backgroundColor ?? colorPalette.background3,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorPalette.primary,
        strokeWidth: 2.0,
      ),
    );
  }

  /// Builds the error UI with retry button displayed after all retries are exhausted
  Widget _buildErrorUIWithRetryButton() {
    return Container(
      color: imageBubbleStyle.backgroundColor ?? colorPalette.background3?.withOpacity(0.5),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: colorPalette.error ?? Colors.red[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load',
            style: TextStyle(
              color: colorPalette.textSecondary ?? Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _onManualRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorPalette.primary,
                borderRadius: BorderRadius.circular(spacing.radius2 ?? 4),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: colorPalette.white ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles manual retry button tap, resets state and triggers reload
  void _onManualRetry() {
    debugPrint("🔄 Manual retry triggered");
    // Clear memory cache for this URL
    if (widget.imageUrl != null) {
      PaintingBinding.instance.imageCache.evict(widget.imageUrl!);
    }
    if (mounted) {
      setState(() {
        _retryCount = 0;
        _loadState = _ImageLoadState.loading;
        _imageKey++; // Force image widget to rebuild
      });
    }
  }
  
  /// Handles image load error and triggers retry if needed
  void _onImageError(Object error, StackTrace? stackTrace) {
    debugPrint("❌ Image load error (attempt ${_retryCount + 1}/$_maxRetries): $error");
    
    if (_retryCount < _maxRetries - 1) {
      // Still have retries left - schedule retry
      _retryCount++;
      debugPrint("🔄 Scheduling retry ${_retryCount}/$_maxRetries");
      
      // Clear memory cache before retry
      if (widget.imageUrl != null) {
        PaintingBinding.instance.imageCache.evict(widget.imageUrl!);
      }
      
      // Delay then retry
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _loadState = _ImageLoadState.loading;
            _imageKey++;
          });
        }
      });
    } else {
      // All retries exhausted
      debugPrint("❌ All $_maxRetries retries exhausted, showing error UI");
      if (mounted) {
        setState(() {
          _loadState = _ImageLoadState.error;
        });
      }
    }
  }
  
  /// Handles successful image load
  void _onImageLoaded() {
    if (mounted && _loadState != _ImageLoadState.loaded) {
      setState(() {
        _loadState = _ImageLoadState.loaded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isHeicHeif
          ? null
          : (widget.onClick ??
              () {
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewer(
                    imageUrl: widget.imageUrl!,
                    placeholderImage: widget.placeholderImage,
                    placeHolderImagePackageName:
                    widget.placeHolderImagePackageName,
                  ),
                ),
              );
            }
          }),
      child: Container(
        height: widget.height ?? 232,
        width: widget.width ?? 232,
        clipBehavior: Clip.hardEdge,
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          border: imageBubbleStyle.border,
          borderRadius: imageBubbleStyle.borderRadius ??
              BorderRadius.circular(spacing.radius3 ?? 0),
          color: imageBubbleStyle.backgroundColor ?? colorPalette.background3,
        ),
        child: _isHeicHeif
            ? _buildHeicHeifPlaceholder()
            : widget.imageUrl != null && widget.imageUrl!.isNotEmpty
            ? _buildNetworkImage()
            : _buildDefaultPlaceholder(),
      ),
    );
  }
  
  /// Builds the network image with retry support
  Widget _buildNetworkImage() {
    // Show error UI if retries exhausted
    if (_loadState == _ImageLoadState.error) {
      return _buildErrorUIWithRetryButton();
    }
    
    return Image.network(
      widget.imageUrl!,
      key: ValueKey('${widget.imageUrl}_$_imageKey'),
      fit: BoxFit.cover,
      cacheWidth: 800,
      cacheHeight: 600,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          // Image loaded successfully
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onImageLoaded();
          });
          return child;
        }
        // Still loading
        return _buildLoadingIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        // Handle error with retry logic
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onImageError(error, stackTrace);
        });
        
        // Show loading during retry, error UI after exhausted
        if (_retryCount < _maxRetries - 1) {
          return _buildLoadingIndicator();
        }
        return _buildErrorUIWithRetryButton();
      },
    );
  }

  /// Fallback method to try isolate decoding when CachedNetworkImage fails
  Future<ui.Image?> _tryIsolateDecoding(String url) async {
    try {
      debugPrint("🔄 Attempting fallback image loading for: $url");
      
      // Download image bytes - use compute only for fetching, not for decoding on iOS
      Uint8List bytes;
      
      if (Platform.isIOS) {
        // On iOS, fetch directly without isolate to avoid issues
        bytes = await fetchImageBytes(url);
        // Decode on main thread for iOS to avoid isolate registry issues
        final image = await decodeImageOnMainThread(bytes);
        return image;
      } else {
        // On Android, use isolate for both fetching and decoding
        bytes = await compute(fetchImageBytes, url);
        final image = await compute(decodeImageInIsolate, bytes);
        return image;
      }
    } catch (e) {
      debugPrint("❌ Fallback image loading failed for $url: $e");
      return null;
    }
  }

  @override
  void dispose() {
    // Don't remove cached files on dispose as they might be used by other widgets
    // The cache manager will handle cleanup based on stalePeriod and maxNrOfCacheObjects
    super.dispose();
  }
}