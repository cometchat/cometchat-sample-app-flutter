import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/services.dart';

///[CometChatVideoBubble] creates a widget that gives video bubble
///
///used by default  when the category and type of [MediaMessage] is message and [MessageTypeConstants.video] respectively
/// ```dart
///  CometChatVideoBubble(
///     videoUrl: 'url for video',
///     style: VideoBubbleStyle(
///     backgroundColor: Colors.white,
///     border: Border.all(color: Colors.red),
///      ),
/// );
/// ```
///
class CometChatVideoBubble extends StatelessWidget {
  const CometChatVideoBubble({
    super.key,
    this.style,
    this.videoUrl,
    this.thumbnailUrl,
    this.placeHolderImage,
    this.placeHolderImagePackageName,
    this.playIcon,
    this.onClick,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.metadata,
    this.placeHolder,
  });

  ///[videoUrl] if message object is not passed then video url should be passed
  final String? videoUrl;

  ///[thumbnailUrl] custom thumbnail for the video
  final String? thumbnailUrl;

  ///[style] video bubble styling properties
  final CometChatVideoBubbleStyle? style;

  ///[placeHolderImage] shows placeholder for video
  final String? placeHolderImage;

  ///[placeHolderImagePackageName] is package path for the custom placeholder image
  final String? placeHolderImagePackageName;

  ///[playIcon] video play pause icon
  final Icon? playIcon;

  ///[onClick] custom action on tapping the image
  final Function()? onClick;

  ///[width] width of the video bubble
  final double? width;

  ///[height] height of the video bubble
  final double? height;

  ///[padding] padding for the video bubble
  final EdgeInsetsGeometry? padding;

  ///[margin] margin for the video bubble
  final EdgeInsetsGeometry? margin;

  ///[metadata] metadata of the message object
  final Map<String, dynamic>? metadata;

  ///[placeHolder]
  final Widget? placeHolder;

  Widget _getImageWidget(
      String imageUrl, CometChatColorPalette colorPalette, int retries) {
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
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        if (retries > 2) {
          return const SizedBox();
        }
        return _getImageWidget(imageUrl, colorPalette, retries++);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoBubbleStyle =
        CometChatThemeHelper.getTheme<CometChatVideoBubbleStyle>(
                context: context, defaultTheme: CometChatVideoBubbleStyle.of)
            .merge(style);
    CometChatColorPalette colorPalette =
        CometChatThemeHelper.getColorPalette(context);
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);

    return GestureDetector(
      onTap: onClick ??
          () {
            final localPath = FileUtils.getLocalFilePath(metadata);

            String? videoUrl;
            bool playFromFile = FileUtils.isLocalFileAvailable(localPath ?? '');
            if (playFromFile) {
              videoUrl = localPath;
            } else {
              videoUrl = this.videoUrl;
            }

            if (videoUrl != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoPlayer(
                            backIcon: colorPalette.primary,
                            handleColor: colorPalette.borderLight,
                            playedColor: colorPalette.primary,
                            fullScreenBackground: colorPalette.black,
                            videoUrl: videoUrl ?? "",
                            playFromFile: playFromFile,
                          )));
            }
          },
      child: Container(
        height: height ?? 140,
        width: width ?? 232,
        clipBehavior: Clip.hardEdge,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          border: videoBubbleStyle.border,
          borderRadius: videoBubbleStyle.borderRadius ??
              BorderRadius.circular(spacing.radius3 ?? 0),
          color: videoBubbleStyle.backgroundColor ?? colorPalette.background3,
        ),
        alignment: Alignment.center,
        child: Stack(
          children: [
            thumbnailUrl != null && thumbnailUrl!.isNotEmpty
                ? Positioned.fill(
                    child: _getImageWidget(thumbnailUrl!, colorPalette, 0))
                : const SizedBox(),
            if (videoUrl != null && videoUrl!.isNotEmpty)
              placeHolder ??
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: videoBubbleStyle.playIconBackgroundColor ??
                            ((MediaQuery.of(context).platformBrightness ==
                                        Brightness.light
                                    ? colorPalette.neutral500
                                    : colorPalette.neutral900))
                                ?.withOpacity(.6),
                      ),
                      child: playIcon ??
                          Icon(
                            Icons.play_arrow,
                            size: 56.0,
                            color: videoBubbleStyle.playIconColor ??
                                (MediaQuery.of(context).platformBrightness ==
                                        Brightness.light
                                    ? colorPalette.neutral50
                                    : colorPalette.neutral900),
                          ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
