import '../../../cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

///[CometChatCollaborativeBubbleStyle] is a data class that has styling-related properties
///to customize the appearance of [CometChatCollaborativeBubble]
///
/// ```dart
/// CometChatCollaborativeBubbleStyle(
///   titleStyle: TextStyle(
///   color: Colors.white,
///   fontWeight: FontWeight.bold,
///   fontSize: 16),
///   subtitleStyle: TextStyle(
///   color: Colors.white,
///   fontSize: 14),
///   buttonTextStyle: TextStyle(
///   color: Colors.white,
///   fontSize: 14),
///   iconTint: Colors.white,
///   webViewTitleStyle: TextStyle(
///   color: Colors.white,
///   fontWeight: FontWeight.bold,
///   fontSize: 16),
///   webViewBackIconColor: Colors.white,
///   webViewAppBarColor: Colors.blueGrey,
///   backgroundColor: Colors.grey,
///   dividerColor: Colors.black,
///   );
///   ```
class CometChatCollaborativeBubbleStyle
    extends ThemeExtension<CometChatCollaborativeBubbleStyle> {
  ///Style Component for DocumentBubble
  const CometChatCollaborativeBubbleStyle({
    this.titleStyle,
    this.subtitleStyle,
    this.buttonTextStyle,
    this.webViewTitleStyle,
    this.webViewBackIconColor,
    this.webViewAppBarColor,
    this.iconTint,
    this.backgroundColor,
    this.dividerColor,
    this.border,
    this.borderRadius,
    this.messageBubbleAvatarStyle,
    this.messageBubbleDateStyle,
    this.messageBubbleBackgroundImage,
    this.threadedMessageIndicatorTextStyle,
    this.threadedMessageIndicatorIconColor,
    this.senderNameTextStyle,
    this.messageReceiptStyle,
  });

  ///[titleStyle] title text style
  final TextStyle? titleStyle;

  ///[subtitleStyle] subtitle text style
  final TextStyle? subtitleStyle;

  ///[buttonTextStyle] buttonText text style
  final TextStyle? buttonTextStyle;

  ///[iconTint] default document bubble icon
  final Color? iconTint;

  ///[webViewTitleStyle] webview title style
  final TextStyle? webViewTitleStyle;

  ///[webViewBackIconColor] webview back icon color
  final Color? webViewBackIconColor;

  ///[webViewAppBarColor] webview app bar color
  final Color? webViewAppBarColor;

  ///[backgroundColor] sets background color for the bubble
  final Color? backgroundColor;

  ///[dividerColor] sets background color for the bubble
  final Color? dividerColor;

  ///[border] provides border to the video bubble
  final BoxBorder? border;

  ///[borderRadius] provides border radius to the video bubble
  final BorderRadiusGeometry? borderRadius;

  ///[messageBubbleAvatarStyle] provides style to the avatar of the sender
  final CometChatAvatarStyle? messageBubbleAvatarStyle;

  ///[messageBubbleDateStyle] provides style to the date of the message bubble
  final CometChatDateStyle? messageBubbleDateStyle;

  ///[messageBubbleBackgroundImage] provides background image to the message bubble of the sent message
  final DecorationImage? messageBubbleBackgroundImage;

  ///[threadedMessageIndicatorTextStyle] provides text style to the threaded message indicator
  final TextStyle? threadedMessageIndicatorTextStyle;

  ///[threadedMessageIndicatorIconColor] provides color to the threaded message icon
  final Color? threadedMessageIndicatorIconColor;

  ///[senderNameTextStyle] provides style to the sender name of the message
  final TextStyle? senderNameTextStyle;

  ///[messageReceiptStyle] provides style to the message receipt
  final CometChatMessageReceiptStyle? messageReceiptStyle;

  @override
  CometChatCollaborativeBubbleStyle copyWith({
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? buttonTextStyle,
    TextStyle? webViewTitleStyle,
    Color? webViewBackIconColor,
    Color? webViewAppBarColor,
    Color? iconTint,
    Color? backgroundColor,
    Color? dividerColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    CometChatAvatarStyle? messageBubbleAvatarStyle,
    CometChatDateStyle? messageBubbleDateStyle,
    DecorationImage? messageBubbleBackgroundImage,
    TextStyle? threadedMessageIndicatorTextStyle,
    Color? threadedMessageIndicatorIconColor,
    TextStyle? senderNameTextStyle,
    CometChatMessageReceiptStyle? messageReceiptStyle,
  }) {
    return CometChatCollaborativeBubbleStyle(
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      webViewTitleStyle: webViewTitleStyle ?? this.webViewTitleStyle,
      webViewBackIconColor: webViewBackIconColor ?? this.webViewBackIconColor,
      webViewAppBarColor: webViewAppBarColor ?? this.webViewAppBarColor,
      iconTint: iconTint ?? this.iconTint,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      messageBubbleAvatarStyle:
          messageBubbleAvatarStyle ?? this.messageBubbleAvatarStyle,
      messageBubbleDateStyle:
          messageBubbleDateStyle ?? this.messageBubbleDateStyle,
      messageBubbleBackgroundImage:
          messageBubbleBackgroundImage ?? this.messageBubbleBackgroundImage,
      threadedMessageIndicatorTextStyle:
          threadedMessageIndicatorTextStyle ??
          this.threadedMessageIndicatorTextStyle,
      threadedMessageIndicatorIconColor:
          threadedMessageIndicatorIconColor ??
          this.threadedMessageIndicatorIconColor,
      senderNameTextStyle: senderNameTextStyle ?? this.senderNameTextStyle,
      messageReceiptStyle: messageReceiptStyle ?? this.messageReceiptStyle,
    );
  }

  CometChatCollaborativeBubbleStyle merge(
    CometChatCollaborativeBubbleStyle? other,
  ) {
    if (other == null) return this;
    return copyWith(
      titleStyle: other.titleStyle,
      subtitleStyle: other.subtitleStyle,
      buttonTextStyle: other.buttonTextStyle,
      webViewTitleStyle: other.webViewTitleStyle,
      webViewBackIconColor: other.webViewBackIconColor,
      webViewAppBarColor: other.webViewAppBarColor,
      iconTint: other.iconTint,
      backgroundColor: other.backgroundColor,
      dividerColor: other.dividerColor,
      border: other.border,
      borderRadius: other.borderRadius,
      messageBubbleAvatarStyle: other.messageBubbleAvatarStyle,
      messageBubbleDateStyle: other.messageBubbleDateStyle,
      messageBubbleBackgroundImage: other.messageBubbleBackgroundImage,
      messageReceiptStyle: other.messageReceiptStyle,
      senderNameTextStyle: other.senderNameTextStyle,
      threadedMessageIndicatorIconColor:
          other.threadedMessageIndicatorIconColor,
      threadedMessageIndicatorTextStyle:
          other.threadedMessageIndicatorTextStyle,
    );
  }

  @override
  CometChatCollaborativeBubbleStyle lerp(
    CometChatCollaborativeBubbleStyle? other,
    double t,
  ) {
    return CometChatCollaborativeBubbleStyle(
      titleStyle: TextStyle.lerp(titleStyle, other?.titleStyle, t),
      subtitleStyle: TextStyle.lerp(subtitleStyle, other?.subtitleStyle, t),
      buttonTextStyle: TextStyle.lerp(
        buttonTextStyle,
        other?.buttonTextStyle,
        t,
      ),
      webViewTitleStyle: TextStyle.lerp(
        webViewTitleStyle,
        other?.webViewTitleStyle,
        t,
      ),
      webViewBackIconColor: Color.lerp(
        webViewBackIconColor,
        other?.webViewBackIconColor,
        t,
      ),
      webViewAppBarColor: Color.lerp(
        webViewAppBarColor,
        other?.webViewAppBarColor,
        t,
      ),
      iconTint: Color.lerp(iconTint, other?.iconTint, t),
      backgroundColor: Color.lerp(backgroundColor, other?.backgroundColor, t),
      dividerColor: Color.lerp(dividerColor, other?.dividerColor, t),
      borderRadius: BorderRadiusGeometry.lerp(
        borderRadius,
        other?.borderRadius,
        t,
      ),
      border: BoxBorder.lerp(border, other?.border, t),
      messageBubbleAvatarStyle: messageBubbleAvatarStyle?.lerp(
        other?.messageBubbleAvatarStyle,
        t,
      ),
      messageBubbleDateStyle: messageBubbleDateStyle?.lerp(
        other?.messageBubbleDateStyle,
        t,
      ),
      messageBubbleBackgroundImage: DecorationImage.lerp(
        messageBubbleBackgroundImage,
        other?.messageBubbleBackgroundImage,
        t,
      ),
      messageReceiptStyle: messageReceiptStyle?.lerp(
        other?.messageReceiptStyle,
        t,
      ),
      senderNameTextStyle: TextStyle.lerp(
        senderNameTextStyle,
        other?.senderNameTextStyle,
        t,
      ),
      threadedMessageIndicatorIconColor: Color.lerp(
        threadedMessageIndicatorIconColor,
        other?.threadedMessageIndicatorIconColor,
        t,
      ),
      threadedMessageIndicatorTextStyle: TextStyle.lerp(
        threadedMessageIndicatorTextStyle,
        other?.threadedMessageIndicatorTextStyle,
        t,
      ),
    );
  }

  static CometChatCollaborativeBubbleStyle of(BuildContext context) {
    return const CometChatCollaborativeBubbleStyle();
  }
}
