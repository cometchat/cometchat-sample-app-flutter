import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[CometChatImageBubble] creates a widget that gives image bubble
///
///used by default  when the category and type of [MediaMessage] is message and [MessageTypeConstants.image] respectively
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
  const CometChatImageBubble(
      {super.key,
      this.imageUrl,
      this.style,
      this.placeholderImage,
      this.placeHolderImagePackageName,
      this.onClick,
      this.height,
      this.width,
      this.margin,
      this.padding,
      this.metadata
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
  Key imageKey = UniqueKey();

  late CometChatImageBubbleStyle imageBubbleStyle;
  late CometChatColorPalette colorPalette;
  late CometChatSpacing spacing;

  @override
  void didChangeDependencies() {
    imageBubbleStyle =
        CometChatThemeHelper.getTheme<CometChatImageBubbleStyle>(
            context: context, defaultTheme: CometChatImageBubbleStyle.of)
            .merge(widget.style);
    colorPalette = CometChatThemeHelper.getColorPalette(context);
    spacing = CometChatThemeHelper.getSpacing(context);
    super.didChangeDependencies();
  }


  Widget _buildImage() {
    final localPath = FileUtils.getLocalFilePath(widget.metadata) ?? '';
    if (FileUtils.isLocalFileAvailable(localPath)) {
      return _buildLocalImage(localPath);
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return _buildNetworkImage(widget.imageUrl!,0);
    }
    return _buildPlaceholderImage();
  }

  Widget _buildLocalImage(String localPath) {
    return Image.file(
      File(localPath ?? ''),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
          return _buildNetworkImage(widget.imageUrl!, 0);
        }
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildNetworkImage(String imageUrl, int retries) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(
            color: colorPalette.iconSecondary,
            backgroundColor: colorPalette.neutral300,
            strokeWidth: 2.0,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if(retries>2) {
          return _buildPlaceholderImage();
        } else {
          return _buildNetworkImage(imageUrl, retries++);
        }
      },
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
          )),
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: widget.onClick ??
          () {
            if (widget.imageUrl != null || widget.imageUrl!.isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImageViewer(
                            imageUrl: widget.imageUrl!,
                            placeholderImage: widget.placeholderImage,
                            placeHolderImagePackageName:
                                widget.placeHolderImagePackageName,
                          )));
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
            borderRadius: imageBubbleStyle.borderRadius ??  BorderRadius.circular(spacing.radius3 ?? 0),
            color: imageBubbleStyle.backgroundColor ?? colorPalette.background3
                ,
        ),
        child: _buildImage(),
      ),
    );
  }
}
