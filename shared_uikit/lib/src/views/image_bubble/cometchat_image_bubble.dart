import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatImageBubble] creates a widget that gives image bubble
///
///used by default when the category and type of [MediaMessage] is message and [MessageTypeConstants.image] respectively
/// ```dart
///             CometChatImageBubble(
///                  imageUrl:
///                      'image url',
///                  style: const ImageBubbleStyle(
///                    borderRadius: 8,
///                    backgroundColor: Colors.white,
///                  ),
///                );
/// ```
class CometChatImageBubble extends StatefulWidget {
  const CometChatImageBubble({
    super.key,
    this.imageUrl,
    this.style,
    this.placeholderImage,
    this.placeHolderImagePackageName,
    this.onClick,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.metadata,
  });

  ///[imageUrl] image url should be passed
  final String? imageUrl;

  ///[style] manages appearance of this widget
  final CometChatImageBubbleStyle? style;

  ///[placeholderImage] is shown temporarily for the duration when image is loading from url
  final String? placeholderImage;

  ///[placeHolderImagePackageName] is package path for the custom placeholder image
  final String? placeHolderImagePackageName;

  ///[onClick] custom action on tapping the image
  final Function()? onClick;

  ///[width] width of the image bubble
  final double? width;

  ///[height] height of the image bubble
  final double? height;

  ///[padding] padding for the image bubble
  final EdgeInsetsGeometry? padding;

  ///[margin] margin for the image bubble
  final EdgeInsetsGeometry? margin;

  ///[metadata] metadata of the message object
  final Map<String, dynamic>? metadata;

  @override
  State<CometChatImageBubble> createState() => _CometChatImageBubbleState();
}

class _CometChatImageBubbleState extends State<CometChatImageBubble> {
  late CometChatImageBubbleStyle imageBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageBubbleStyle =
        CometChatThemeHelper.getTheme<CometChatImageBubbleStyle>(
            context: context, defaultTheme: CometChatImageBubbleStyle.of)
            .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
  }

  /// Check if the image is HEIC/HEIF format
  bool _isHeicOrHeif(String? url) {
    if (url == null || url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.heic') || lowerUrl.endsWith('.heif');
  }

  /// Check if the image is SVG format
  bool _isSvg(String? url) {
    if (url == null || url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    // Check for .svg extension or /svg in path (e.g., dicebear URLs like /svg?seed=...)
    return lowerUrl.endsWith('.svg') || 
           lowerUrl.contains('/svg?') || 
           lowerUrl.contains('/svg/');
  }

  Widget _buildImage() {
    // Show placeholder for HEIC/HEIF images
    if (_isHeicOrHeif(widget.imageUrl)) {
      return _buildPlaceholderImage();
    }

    // Show placeholder for SVG images (not natively supported)
    if (_isSvg(widget.imageUrl)) {
      return _buildPlaceholderImage();
    }

    final localPath = FileUtils.getLocalFilePath(widget.metadata) ?? '';
    
    // Also check local path for HEIC/HEIF
    if (_isHeicOrHeif(localPath)) {
      return _buildPlaceholderImage();
    }

    // Also check local path for SVG
    if (_isSvg(localPath)) {
      return _buildPlaceholderImage();
    }

    if (FileUtils.isLocalFileAvailable(localPath)) {
      return _buildLocalImage(localPath);
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return _buildNetworkImage(widget.imageUrl!);
    }
    return _buildPlaceholderImage();
  }

  Widget _buildLocalImage(String localPath) {
    return Image(
      image: ResizeImage(
        FileImage(File(localPath)),
        width: 512,
        height: 512,
        policy: ResizeImagePolicy.fit,
      ),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildLoadingIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
          return _buildNetworkImage(widget.imageUrl!);
        }
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image(
      image: ResizeImage(
        NetworkImage(imageUrl),
        width: 512,
        height: 512,
        policy: ResizeImagePolicy.fit,
      ),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildLoadingIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image.network error: $error');
        debugPrint('Failed URL: $imageUrl');
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: imageBubbleStyle.backgroundColor ?? colorPalette.background3,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorPalette.iconSecondary,
        backgroundColor: colorPalette.neutral300,
        strokeWidth: 2.0,
      ),
    );
  }

  Widget _buildImageContent(ImageProvider imageProvider) {
    return Image(
      image: imageProvider,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
    );
  }

  Widget _buildPlaceholderImage() {
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

  /// Check if the image format is unsupported (should show placeholder)
  bool _isUnsupportedFormat() {
    final localPath = FileUtils.getLocalFilePath(widget.metadata) ?? '';
    return _isHeicOrHeif(widget.imageUrl) ||
        _isSvg(widget.imageUrl) ||
        _isHeicOrHeif(localPath) ||
        _isSvg(localPath);
  }

  @override
  Widget build(BuildContext context) {
    final bool showPlaceholder = _isUnsupportedFormat() ||
        (widget.imageUrl == null || widget.imageUrl!.isEmpty);

    return GestureDetector(
      onTap: showPlaceholder
          ? null
          : widget.onClick ??
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
              },
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
        child: _buildImage(),
      ),
    );
  }
}
