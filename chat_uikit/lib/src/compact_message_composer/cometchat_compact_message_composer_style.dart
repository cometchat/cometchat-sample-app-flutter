import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// [CometChatCompactMessageComposerStyle] is a data class that has styling-related properties
/// to customize the appearance of [CometChatCompactMessageComposer]
///
/// ```dart
/// CometChatCompactMessageComposerStyle(
///   composeBoxBackgroundColor: Colors.white,
///   composeBoxBorderRadius: BorderRadius.circular(24),
///   textStyle: TextStyle(fontSize: 16),
///   sendButtonIconColor: Colors.blue,
/// );
/// ```
class CometChatCompactMessageComposerStyle
    extends ThemeExtension<CometChatCompactMessageComposerStyle> {
  const CometChatCompactMessageComposerStyle({
    // Container styling
    this.backgroundColor,
    this.border,
    this.borderRadius,
    // Compose box styling
    this.composeBoxBackgroundColor,
    this.composeBoxBorderRadius,
    this.composeBoxBorder,
    // Text styling
    this.textStyle,
    this.textColor,
    this.placeholderTextStyle,
    this.placeholderTextColor,
    // Send button styling
    this.sendButtonIconColor,
    this.sendButtonBackgroundColor,
    this.sendButtonDisabledIconColor,
    this.sendButtonDisabledBackgroundColor,
    this.sendButtonBorderRadius,
    // Attachment button styling
    this.attachmentButtonIconColor,
    this.attachmentButtonBackgroundColor,
    this.attachmentButtonBorderRadius,
    // Voice recording button styling
    this.voiceRecordingButtonIconColor,
    this.voiceRecordingButtonBackgroundColor,
    this.voiceRecordingButtonBorderRadius,
    // Rich text toggle button styling
    this.richTextToggleIconColor,
    this.richTextToggleActiveIconColor,
    this.richTextToggleBackgroundColor,
    this.richTextToggleActiveBackgroundColor,
    this.richTextToggleBorderRadius,
    // Auxiliary button styling
    this.auxiliaryButtonIconColor,
    this.auxiliaryButtonBackgroundColor,
    this.auxiliaryButtonBorderRadius,
    // Divider styling
    this.dividerColor,
    this.dividerHeight,
    // Close icon styling
    this.closeIconTint,
    // Nested styles
    this.richTextToolbarStyle,
    this.richTextFormatterStyle,
    this.messagePreviewStyle,
    this.mentionsStyle,
    this.suggestionListStyle,
    this.mediaRecorderStyle,
    this.attachmentOptionSheetStyle,
  });

  /// [backgroundColor] sets the background color of the single line composer container
  final Color? backgroundColor;

  /// [border] sets the border of the single line composer container
  final BoxBorder? border;

  /// [borderRadius] sets the border radius of the single line composer container
  final BorderRadiusGeometry? borderRadius;

  /// [composeBoxBackgroundColor] sets the background color of the pill-shaped compose box
  final Color? composeBoxBackgroundColor;

  /// [composeBoxBorderRadius] sets the border radius of the compose box (default 24dp for pill shape)
  final BorderRadiusGeometry? composeBoxBorderRadius;

  /// [composeBoxBorder] sets the border of the compose box
  final BoxBorder? composeBoxBorder;

  /// [textStyle] sets the style of the input text
  final TextStyle? textStyle;

  /// [textColor] sets the color of the input text
  final Color? textColor;

  /// [placeholderTextStyle] sets the style of the placeholder text
  final TextStyle? placeholderTextStyle;

  /// [placeholderTextColor] sets the color of the placeholder text
  final Color? placeholderTextColor;

  /// [sendButtonIconColor] sets the color of the send button icon when enabled
  final Color? sendButtonIconColor;

  /// [sendButtonBackgroundColor] sets the background color of the send button when enabled
  final Color? sendButtonBackgroundColor;

  /// [sendButtonDisabledIconColor] sets the color of the send button icon when disabled
  final Color? sendButtonDisabledIconColor;

  /// [sendButtonDisabledBackgroundColor] sets the background color of the send button when disabled
  final Color? sendButtonDisabledBackgroundColor;

  /// [sendButtonBorderRadius] sets the border radius of the send button
  final BorderRadiusGeometry? sendButtonBorderRadius;

  /// [attachmentButtonIconColor] sets the color of the attachment button icon
  final Color? attachmentButtonIconColor;

  /// [attachmentButtonBackgroundColor] sets the background color of the attachment button
  final Color? attachmentButtonBackgroundColor;

  /// [attachmentButtonBorderRadius] sets the border radius of the attachment button
  final BorderRadiusGeometry? attachmentButtonBorderRadius;

  /// [voiceRecordingButtonIconColor] sets the color of the voice recording button icon
  final Color? voiceRecordingButtonIconColor;

  /// [voiceRecordingButtonBackgroundColor] sets the background color of the voice recording button
  final Color? voiceRecordingButtonBackgroundColor;

  /// [voiceRecordingButtonBorderRadius] sets the border radius of the voice recording button
  final BorderRadiusGeometry? voiceRecordingButtonBorderRadius;

  /// [richTextToggleIconColor] sets the color of the rich text toggle button icon when inactive
  final Color? richTextToggleIconColor;

  /// [richTextToggleActiveIconColor] sets the color of the rich text toggle button icon when active
  final Color? richTextToggleActiveIconColor;

  /// [richTextToggleBackgroundColor] sets the background color of the rich text toggle button when inactive
  final Color? richTextToggleBackgroundColor;

  /// [richTextToggleActiveBackgroundColor] sets the background color of the rich text toggle button when active
  final Color? richTextToggleActiveBackgroundColor;

  /// [richTextToggleBorderRadius] sets the border radius of the rich text toggle button
  final BorderRadiusGeometry? richTextToggleBorderRadius;

  /// [auxiliaryButtonIconColor] sets the color of auxiliary button icons (emoji, etc.)
  final Color? auxiliaryButtonIconColor;

  /// [auxiliaryButtonBackgroundColor] sets the background color of auxiliary buttons
  final Color? auxiliaryButtonBackgroundColor;

  /// [auxiliaryButtonBorderRadius] sets the border radius of auxiliary buttons
  final BorderRadiusGeometry? auxiliaryButtonBorderRadius;

  /// [dividerColor] sets the color of dividers
  final Color? dividerColor;

  /// [dividerHeight] sets the height of dividers
  final double? dividerHeight;

  /// [closeIconTint] provides color to the close icon/widget (used in preview banner)
  final Color? closeIconTint;

  /// [richTextToolbarStyle] provides style to the rich text formatting toolbar
  final CometChatRichTextToolbarStyle? richTextToolbarStyle;

  /// [richTextFormatterStyle] provides style to the rich text formatter for input field styling
  final CometChatRichTextFormatterStyle? richTextFormatterStyle;

  /// [messagePreviewStyle] provides style to the message preview (edit/reply banner)
  final CometChatMessagePreviewStyle? messagePreviewStyle;

  /// [mentionsStyle] provides style to the mentions
  final CometChatMentionsStyle? mentionsStyle;

  /// [suggestionListStyle] provides style to the suggestion list (mentions)
  final CometChatSuggestionListStyle? suggestionListStyle;

  /// [mediaRecorderStyle] provides style to the media recorder
  final CometChatMediaRecorderStyle? mediaRecorderStyle;

  /// [attachmentOptionSheetStyle] provides style to the attachment option sheet
  final CometChatAttachmentOptionSheetStyle? attachmentOptionSheetStyle;

  static CometChatCompactMessageComposerStyle of(BuildContext context) =>
      const CometChatCompactMessageComposerStyle();

  @override
  CometChatCompactMessageComposerStyle copyWith({
    Color? backgroundColor,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Color? composeBoxBackgroundColor,
    BorderRadiusGeometry? composeBoxBorderRadius,
    BoxBorder? composeBoxBorder,
    TextStyle? textStyle,
    Color? textColor,
    TextStyle? placeholderTextStyle,
    Color? placeholderTextColor,
    Color? sendButtonIconColor,
    Color? sendButtonBackgroundColor,
    Color? sendButtonDisabledIconColor,
    Color? sendButtonDisabledBackgroundColor,
    BorderRadiusGeometry? sendButtonBorderRadius,
    Color? attachmentButtonIconColor,
    Color? attachmentButtonBackgroundColor,
    BorderRadiusGeometry? attachmentButtonBorderRadius,
    Color? voiceRecordingButtonIconColor,
    Color? voiceRecordingButtonBackgroundColor,
    BorderRadiusGeometry? voiceRecordingButtonBorderRadius,
    Color? richTextToggleIconColor,
    Color? richTextToggleActiveIconColor,
    Color? richTextToggleBackgroundColor,
    Color? richTextToggleActiveBackgroundColor,
    BorderRadiusGeometry? richTextToggleBorderRadius,
    Color? auxiliaryButtonIconColor,
    Color? auxiliaryButtonBackgroundColor,
    BorderRadiusGeometry? auxiliaryButtonBorderRadius,
    Color? dividerColor,
    double? dividerHeight,
    Color? closeIconTint,
    CometChatRichTextToolbarStyle? richTextToolbarStyle,
    CometChatRichTextFormatterStyle? richTextFormatterStyle,
    CometChatMessagePreviewStyle? messagePreviewStyle,
    CometChatMentionsStyle? mentionsStyle,
    CometChatSuggestionListStyle? suggestionListStyle,
    CometChatMediaRecorderStyle? mediaRecorderStyle,
    CometChatAttachmentOptionSheetStyle? attachmentOptionSheetStyle,
  }) {
    return CometChatCompactMessageComposerStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      composeBoxBackgroundColor:
          composeBoxBackgroundColor ?? this.composeBoxBackgroundColor,
      composeBoxBorderRadius:
          composeBoxBorderRadius ?? this.composeBoxBorderRadius,
      composeBoxBorder: composeBoxBorder ?? this.composeBoxBorder,
      textStyle: textStyle ?? this.textStyle,
      textColor: textColor ?? this.textColor,
      placeholderTextStyle: placeholderTextStyle ?? this.placeholderTextStyle,
      placeholderTextColor: placeholderTextColor ?? this.placeholderTextColor,
      sendButtonIconColor: sendButtonIconColor ?? this.sendButtonIconColor,
      sendButtonBackgroundColor:
          sendButtonBackgroundColor ?? this.sendButtonBackgroundColor,
      sendButtonDisabledIconColor:
          sendButtonDisabledIconColor ?? this.sendButtonDisabledIconColor,
      sendButtonDisabledBackgroundColor:
          sendButtonDisabledBackgroundColor ??
          this.sendButtonDisabledBackgroundColor,
      sendButtonBorderRadius:
          sendButtonBorderRadius ?? this.sendButtonBorderRadius,
      attachmentButtonIconColor:
          attachmentButtonIconColor ?? this.attachmentButtonIconColor,
      attachmentButtonBackgroundColor:
          attachmentButtonBackgroundColor ??
          this.attachmentButtonBackgroundColor,
      attachmentButtonBorderRadius:
          attachmentButtonBorderRadius ?? this.attachmentButtonBorderRadius,
      voiceRecordingButtonIconColor:
          voiceRecordingButtonIconColor ?? this.voiceRecordingButtonIconColor,
      voiceRecordingButtonBackgroundColor:
          voiceRecordingButtonBackgroundColor ??
          this.voiceRecordingButtonBackgroundColor,
      voiceRecordingButtonBorderRadius:
          voiceRecordingButtonBorderRadius ??
          this.voiceRecordingButtonBorderRadius,
      richTextToggleIconColor:
          richTextToggleIconColor ?? this.richTextToggleIconColor,
      richTextToggleActiveIconColor:
          richTextToggleActiveIconColor ?? this.richTextToggleActiveIconColor,
      richTextToggleBackgroundColor:
          richTextToggleBackgroundColor ?? this.richTextToggleBackgroundColor,
      richTextToggleActiveBackgroundColor:
          richTextToggleActiveBackgroundColor ??
          this.richTextToggleActiveBackgroundColor,
      richTextToggleBorderRadius:
          richTextToggleBorderRadius ?? this.richTextToggleBorderRadius,
      auxiliaryButtonIconColor:
          auxiliaryButtonIconColor ?? this.auxiliaryButtonIconColor,
      auxiliaryButtonBackgroundColor:
          auxiliaryButtonBackgroundColor ?? this.auxiliaryButtonBackgroundColor,
      auxiliaryButtonBorderRadius:
          auxiliaryButtonBorderRadius ?? this.auxiliaryButtonBorderRadius,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerHeight: dividerHeight ?? this.dividerHeight,
      closeIconTint: closeIconTint ?? this.closeIconTint,
      richTextToolbarStyle: richTextToolbarStyle ?? this.richTextToolbarStyle,
      richTextFormatterStyle:
          richTextFormatterStyle ?? this.richTextFormatterStyle,
      messagePreviewStyle: messagePreviewStyle ?? this.messagePreviewStyle,
      mentionsStyle: mentionsStyle ?? this.mentionsStyle,
      suggestionListStyle: suggestionListStyle ?? this.suggestionListStyle,
      mediaRecorderStyle: mediaRecorderStyle ?? this.mediaRecorderStyle,
      attachmentOptionSheetStyle:
          attachmentOptionSheetStyle ?? this.attachmentOptionSheetStyle,
    );
  }

  CometChatCompactMessageComposerStyle merge(
    CometChatCompactMessageComposerStyle? style,
  ) {
    if (style == null) return this;
    return copyWith(
      backgroundColor: style.backgroundColor,
      border: style.border,
      borderRadius: style.borderRadius,
      composeBoxBackgroundColor: style.composeBoxBackgroundColor,
      composeBoxBorderRadius: style.composeBoxBorderRadius,
      composeBoxBorder: style.composeBoxBorder,
      textStyle: style.textStyle,
      textColor: style.textColor,
      placeholderTextStyle: style.placeholderTextStyle,
      placeholderTextColor: style.placeholderTextColor,
      sendButtonIconColor: style.sendButtonIconColor,
      sendButtonBackgroundColor: style.sendButtonBackgroundColor,
      sendButtonDisabledIconColor: style.sendButtonDisabledIconColor,
      sendButtonDisabledBackgroundColor:
          style.sendButtonDisabledBackgroundColor,
      sendButtonBorderRadius: style.sendButtonBorderRadius,
      attachmentButtonIconColor: style.attachmentButtonIconColor,
      attachmentButtonBackgroundColor: style.attachmentButtonBackgroundColor,
      attachmentButtonBorderRadius: style.attachmentButtonBorderRadius,
      voiceRecordingButtonIconColor: style.voiceRecordingButtonIconColor,
      voiceRecordingButtonBackgroundColor:
          style.voiceRecordingButtonBackgroundColor,
      voiceRecordingButtonBorderRadius: style.voiceRecordingButtonBorderRadius,
      richTextToggleIconColor: style.richTextToggleIconColor,
      richTextToggleActiveIconColor: style.richTextToggleActiveIconColor,
      richTextToggleBackgroundColor: style.richTextToggleBackgroundColor,
      richTextToggleActiveBackgroundColor:
          style.richTextToggleActiveBackgroundColor,
      richTextToggleBorderRadius: style.richTextToggleBorderRadius,
      auxiliaryButtonIconColor: style.auxiliaryButtonIconColor,
      auxiliaryButtonBackgroundColor: style.auxiliaryButtonBackgroundColor,
      auxiliaryButtonBorderRadius: style.auxiliaryButtonBorderRadius,
      dividerColor: style.dividerColor,
      dividerHeight: style.dividerHeight,
      closeIconTint: style.closeIconTint,
      richTextToolbarStyle: style.richTextToolbarStyle,
      richTextFormatterStyle: style.richTextFormatterStyle,
      messagePreviewStyle: style.messagePreviewStyle,
      mentionsStyle: style.mentionsStyle,
      suggestionListStyle: style.suggestionListStyle,
      mediaRecorderStyle: style.mediaRecorderStyle,
      attachmentOptionSheetStyle: style.attachmentOptionSheetStyle,
    );
  }

  @override
  CometChatCompactMessageComposerStyle lerp(
    ThemeExtension<CometChatCompactMessageComposerStyle>? other,
    double t,
  ) {
    if (other is! CometChatCompactMessageComposerStyle) {
      return this;
    }
    return CometChatCompactMessageComposerStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      border: BoxBorder.lerp(border, other.border, t),
      borderRadius: BorderRadiusGeometry.lerp(
        borderRadius,
        other.borderRadius,
        t,
      ),
      composeBoxBackgroundColor: Color.lerp(
        composeBoxBackgroundColor,
        other.composeBoxBackgroundColor,
        t,
      ),
      composeBoxBorderRadius: BorderRadiusGeometry.lerp(
        composeBoxBorderRadius,
        other.composeBoxBorderRadius,
        t,
      ),
      composeBoxBorder: BoxBorder.lerp(
        composeBoxBorder,
        other.composeBoxBorder,
        t,
      ),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      textColor: Color.lerp(textColor, other.textColor, t),
      placeholderTextStyle: TextStyle.lerp(
        placeholderTextStyle,
        other.placeholderTextStyle,
        t,
      ),
      placeholderTextColor: Color.lerp(
        placeholderTextColor,
        other.placeholderTextColor,
        t,
      ),
      sendButtonIconColor: Color.lerp(
        sendButtonIconColor,
        other.sendButtonIconColor,
        t,
      ),
      sendButtonBackgroundColor: Color.lerp(
        sendButtonBackgroundColor,
        other.sendButtonBackgroundColor,
        t,
      ),
      sendButtonDisabledIconColor: Color.lerp(
        sendButtonDisabledIconColor,
        other.sendButtonDisabledIconColor,
        t,
      ),
      sendButtonDisabledBackgroundColor: Color.lerp(
        sendButtonDisabledBackgroundColor,
        other.sendButtonDisabledBackgroundColor,
        t,
      ),
      sendButtonBorderRadius: BorderRadiusGeometry.lerp(
        sendButtonBorderRadius,
        other.sendButtonBorderRadius,
        t,
      ),
      attachmentButtonIconColor: Color.lerp(
        attachmentButtonIconColor,
        other.attachmentButtonIconColor,
        t,
      ),
      attachmentButtonBackgroundColor: Color.lerp(
        attachmentButtonBackgroundColor,
        other.attachmentButtonBackgroundColor,
        t,
      ),
      attachmentButtonBorderRadius: BorderRadiusGeometry.lerp(
        attachmentButtonBorderRadius,
        other.attachmentButtonBorderRadius,
        t,
      ),
      voiceRecordingButtonIconColor: Color.lerp(
        voiceRecordingButtonIconColor,
        other.voiceRecordingButtonIconColor,
        t,
      ),
      voiceRecordingButtonBackgroundColor: Color.lerp(
        voiceRecordingButtonBackgroundColor,
        other.voiceRecordingButtonBackgroundColor,
        t,
      ),
      voiceRecordingButtonBorderRadius: BorderRadiusGeometry.lerp(
        voiceRecordingButtonBorderRadius,
        other.voiceRecordingButtonBorderRadius,
        t,
      ),
      richTextToggleIconColor: Color.lerp(
        richTextToggleIconColor,
        other.richTextToggleIconColor,
        t,
      ),
      richTextToggleActiveIconColor: Color.lerp(
        richTextToggleActiveIconColor,
        other.richTextToggleActiveIconColor,
        t,
      ),
      richTextToggleBackgroundColor: Color.lerp(
        richTextToggleBackgroundColor,
        other.richTextToggleBackgroundColor,
        t,
      ),
      richTextToggleActiveBackgroundColor: Color.lerp(
        richTextToggleActiveBackgroundColor,
        other.richTextToggleActiveBackgroundColor,
        t,
      ),
      richTextToggleBorderRadius: BorderRadiusGeometry.lerp(
        richTextToggleBorderRadius,
        other.richTextToggleBorderRadius,
        t,
      ),
      auxiliaryButtonIconColor: Color.lerp(
        auxiliaryButtonIconColor,
        other.auxiliaryButtonIconColor,
        t,
      ),
      auxiliaryButtonBackgroundColor: Color.lerp(
        auxiliaryButtonBackgroundColor,
        other.auxiliaryButtonBackgroundColor,
        t,
      ),
      auxiliaryButtonBorderRadius: BorderRadiusGeometry.lerp(
        auxiliaryButtonBorderRadius,
        other.auxiliaryButtonBorderRadius,
        t,
      ),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      dividerHeight: lerpDouble(dividerHeight, other.dividerHeight, t),
      closeIconTint: Color.lerp(closeIconTint, other.closeIconTint, t),
      richTextToolbarStyle: richTextToolbarStyle?.lerp(
        other.richTextToolbarStyle,
        t,
      ),
      messagePreviewStyle: messagePreviewStyle?.lerp(
        other.messagePreviewStyle,
        t,
      ),
      mentionsStyle: mentionsStyle?.lerp(other.mentionsStyle, t),
      suggestionListStyle: suggestionListStyle?.lerp(
        other.suggestionListStyle,
        t,
      ),
      mediaRecorderStyle: mediaRecorderStyle?.lerp(other.mediaRecorderStyle, t),
      attachmentOptionSheetStyle: attachmentOptionSheetStyle?.lerp(
        other.attachmentOptionSheetStyle,
        t,
      ),
    );
  }
}
