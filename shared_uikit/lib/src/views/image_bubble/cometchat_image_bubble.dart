import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class _CometChatImageBubbleState extends State<CometChatImageBubble> {
  bool _isHeicHeif = false; // Track if it's HEIC/HEIF format

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
            ? CachedNetworkImage(
          imageUrl: widget.imageUrl!,
          cacheManager: CometChatCacheManager.instance,
          fit: BoxFit.cover,
          memCacheWidth: 800,  // Limit memory cache size for iOS optimization
          memCacheHeight: 600,
          maxWidthDiskCache: 1200,  // Limit disk cache size
          maxHeightDiskCache: 900,
          placeholder: (context, url) => Container(
            color: imageBubbleStyle.backgroundColor ?? colorPalette.background3,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              color: colorPalette.primary,
              strokeWidth: 2.0,
            ),
          ),
          errorWidget: (context, url, error) {
            debugPrint("❌ CachedNetworkImage error for $url: $error");
            // Try to use isolate decoding as fallback
            return FutureBuilder<ui.Image?>(
              future: _tryIsolateDecoding(url),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: imageBubbleStyle.backgroundColor ?? colorPalette.background3,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: colorPalette.primary,
                      strokeWidth: 2.0,
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return RawImage(
                    image: snapshot.data,
                    fit: BoxFit.cover,
                  );
                }

                return Container(
                  color: imageBubbleStyle.backgroundColor ?? colorPalette.background3?.withValues(alpha: 0.5),
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
                    ],
                  ),
                );
              },
            );
          },
        )
            : _buildDefaultPlaceholder(),
      ),
    );
  }

  /// Fallback method to try isolate decoding when CachedNetworkImage fails
  Future<ui.Image?> _tryIsolateDecoding(String url) async {
    try {
      // Download image bytes using isolate
      final bytes = await compute(fetchImageBytes, url);

      // Decode using isolate with memory constraints
      final image = await compute(decodeImageInIsolate, bytes);

      return image;
    } catch (e) {
      debugPrint("❌ Isolate decoding failed for $url: $e");
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