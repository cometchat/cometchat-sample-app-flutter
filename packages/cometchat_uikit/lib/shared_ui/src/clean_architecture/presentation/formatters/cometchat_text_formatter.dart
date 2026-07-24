import 'dart:async';
import 'package:flutter/material.dart';
import "package:cometchat_sdk/cometchat_sdk.dart" hide CardMessage;
import 'formatter.dart';
import 'attributed_text.dart';
import '../theme/theme.dart';
import '../../data/models/suggestion_list_item.dart';
import '../../../../cometchat_uikit_shared.dart'
    show BubbleAlignment, AssetConstants, UIConstants;

///[CometChatTextFormatter] is an abstract class which is used to format the text
///It has properties like [trackingCharacter], [pattern], [onSearch], [showLoadingIndicator], [messageBubbleTextStyle], [messageInputTextStyle]
///It has methods like [init], [handlePreMessageSend], [onScrollToBottom], [buildInputFieldText], [mergeAttributedText], [getAttributedText], [onChange], [getLoadingIndicator], [getMessageInputTextStyle], [getMessageBubbleTextStyle]
abstract class CometChatTextFormatter implements Formatter {
  CometChatTextFormatter({
    this.trackingCharacter,
    this.pattern,
    this.onSearch,
    this.showLoadingIndicator,
    this.messageBubbleTextStyle,
    this.messageInputTextStyle,
    this.message,
    this.composerId,
    this.suggestionListEventSink,
    this.previousTextEventSink,
    this.user,
    this.group,
    this.usersRequestBuilder,
    this.groupMembersRequestBuilder,
  });

  ///[showLoadingIndicator] is a boolean value which is used to show or hide the loading indicator
  bool? showLoadingIndicator;

  ///[trackingCharacter] is a string value which is used to track the character
  String? trackingCharacter;

  ///[pattern] is a regular expression which is used to match the pattern
  RegExp? pattern;

  ///[onSearch] is a function which is used to perform some action when the text is searched
  Function(String?)? onSearch;

  ///[messageBubbleTextStyle] is a function which is used to style the message bubble text with formatting
  TextStyle Function(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool? forConversation,
  })?
  messageBubbleTextStyle;

  ///[messageBubbleTextStyle] is a function which is used to style the message composer input text with formatting
  TextStyle Function(BuildContext context)? messageInputTextStyle;

  ///[message] is a [BaseMessage] which is used to store the message
  BaseMessage? message;

  ///[composerId] is a [Map] which is used to store the composer id
  Map<String, dynamic>? composerId;

  ///[suggestionListEventSink] is a [StreamSink] which is used to store the suggestion list event sink
  StreamSink<List<SuggestionListItem>>? suggestionListEventSink;

  ///[previousTextEventSink] is a [StreamSink] which is used to store the previous text event sink
  StreamSink<String>? previousTextEventSink;

  ///sets [user] for the formatter
  User? user;

  ///set [group] for the formatter
  Group? group;

  ///[groupMembersRequestBuilder] is a [GroupMembersRequestBuilder] object which is used to get the group members
  GroupMembersRequestBuilder? groupMembersRequestBuilder;

  ///[usersRequestBuilder] is a [UsersRequestBuilder] object which is used to get the users
  UsersRequestBuilder? usersRequestBuilder;

  void init();

  ///[getMessageInputTextStyle] is a [TextStyle] object which is used to style the message input text
  TextStyle getMessageInputTextStyle(BuildContext context);

  ///[getMessageBubbleTextStyle] is a [TextStyle] object which is used to style the message bubble text
  TextStyle getMessageBubbleTextStyle(
    BuildContext context,
    BubbleAlignment? alignment, {
    bool forConversation = false,
  }) {
    if (messageBubbleTextStyle != null) {
      return messageBubbleTextStyle!(
        context,
        alignment,
        forConversation: forConversation,
      );
    } else {
      CometChatColorPalette colorPalette = CometChatThemeHelper.getColorPalette(
        context,
      );
      CometChatTypography typography = CometChatThemeHelper.getTypography(
        context,
      );
      return TextStyle(
        color: alignment == BubbleAlignment.right
            ? colorPalette.white
            : colorPalette.neutral900,
        fontWeight: typography.body?.regular?.fontWeight,
        fontSize: typography.body?.regular?.fontSize,
        fontFamily: typography.body?.regular?.fontFamily,
        decoration: TextDecoration.underline,
      );
    }
  }

  ///[handlePreMessageSend] is a function which is used to perform some action before sending the message
  void handlePreMessageSend(BuildContext context, BaseMessage baseMessage);

  ///[onScrollToBottom] is a function which is used to perform some action when the scroll reaches the bottom of the suggestion list
  void onScrollToBottom(TextEditingController textEditingController);

  ///[buildInputFieldText] is a function which is used to style the text in the input field in the message composer
  List<AttributedText> buildInputFieldText({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
    required String text,
    List<AttributedText>? existingAttributes,
  }) {
    return existingAttributes ?? [];
  }

  ///[mergeAttributedText] is a function which is used to merge the attributed text of various formatters
  List<AttributedText> mergeAttributedText(
    List<AttributedText> attributedTexts,
    List<AttributedText> existingAttributedTexts,
  ) {
    // Combine both lists into a single list
    List<AttributedText> combinedList = [
      ...attributedTexts,
      ...existingAttributedTexts,
    ];

    if (combinedList.isEmpty) return [];

    // Sort the combined list based on the start property
    combinedList.sort((a, b) => a.start.compareTo(b.start));

    // Merge overlapping elements with combined styles
    List<AttributedText> mergedList = [];

    for (var element in combinedList) {
      if (mergedList.isEmpty) {
        mergedList.add(element);
        continue;
      }

      // Check for overlap with the last element in merged list
      var lastElement = mergedList.last;

      if (element.start < lastElement.end) {
        // Overlapping - need to merge styles
        // Remove the last element and split into non-overlapping parts
        mergedList.removeLast();

        // Check if either element is a block element (code block, blockquote)
        // Block elements should not be split - they take precedence
        // Only use the isBlockElement flag — padding/backgroundColor are used
        // by inline elements like mentions and should NOT be treated as block.
        final lastIsBlock = lastElement.isBlockElement;
        final elementIsBlock = element.isBlockElement;

        if (lastIsBlock && !elementIsBlock) {
          // Last element is a block - keep it as-is, skip the overlapping inline element
          mergedList.add(lastElement);
          continue;
        } else if (elementIsBlock && !lastIsBlock) {
          // New element is a block - it takes precedence over inline formatting
          mergedList.add(element);
          continue;
        }

        // Both are inline elements - split and merge styles

        // Helper: compute the display text for a sub-range of lastElement.
        // If lastElement has underlyingText (e.g., bold stripped markers),
        // extract the corresponding portion. Otherwise use null (raw text).
        String? subUnderlyingText(int subStart, int subEnd) {
          if (lastElement.underlyingText == null) return null;
          // lastElement.underlyingText replaces raw range [lastElement.start, lastElement.end].
          // Map sub-range positions into the underlyingText string.
          final rawLen = lastElement.end - lastElement.start;
          final utLen = lastElement.underlyingText!.length;
          if (rawLen <= 0 || utLen <= 0) return '';
          // Compute marker lengths by comparing raw length vs underlyingText length.
          final totalMarkerLen = rawLen - utLen;
          final openingMarkerLen = totalMarkerLen > 0
              ? (totalMarkerLen ~/ 2)
              : 0;
          final utStart = (subStart - lastElement.start - openingMarkerLen)
              .clamp(0, utLen);
          final utEnd = (subEnd - lastElement.start - openingMarkerLen).clamp(
            0,
            utLen,
          );
          if (utEnd <= utStart) return '';
          return lastElement.underlyingText!.substring(utStart, utEnd);
        }

        // Part 1: Before overlap (only lastElement's style)
        if (element.start > lastElement.start) {
          mergedList.add(
            AttributedText(
              start: lastElement.start,
              end: element.start,
              style: lastElement.style,
              underlyingText: subUnderlyingText(
                lastElement.start,
                element.start,
              ),
              onTap: lastElement.onTap,
            ),
          );
        }

        // Part 2: Overlapping region (merged styles)
        final overlapStart = element.start > lastElement.start
            ? element.start
            : lastElement.start;
        final overlapEnd = element.end < lastElement.end
            ? element.end
            : lastElement.end;

        // Merge the styles
        final mergedStyle = _mergeTextStyles(lastElement.style, element.style);

        mergedList.add(
          AttributedText(
            start: overlapStart,
            end: overlapEnd,
            style: mergedStyle,
            // Use the innermost element's underlyingText (most specific/stripped)
            underlyingText:
                element.underlyingText ?? lastElement.underlyingText,
            onTap: element.onTap ?? lastElement.onTap,
            // Preserve container properties (backgroundColor, padding, etc.)
            // from whichever element has them (mentions, URLs, etc.)
            backgroundColor:
                element.backgroundColor ?? lastElement.backgroundColor,
            padding: element.padding ?? lastElement.padding,
            borderRadius: element.borderRadius ?? lastElement.borderRadius,
            border: element.border ?? lastElement.border,
          ),
        );

        // Part 3: After overlap from lastElement (only lastElement's style)
        if (lastElement.end > overlapEnd) {
          mergedList.add(
            AttributedText(
              start: overlapEnd,
              end: lastElement.end,
              style: lastElement.style,
              underlyingText: subUnderlyingText(overlapEnd, lastElement.end),
              onTap: lastElement.onTap,
            ),
          );
        }

        // Part 4: After overlap from element (only element's style)
        if (element.end > overlapEnd) {
          mergedList.add(
            AttributedText(
              start: overlapEnd,
              end: element.end,
              style: element.style,
              underlyingText: element.underlyingText,
              onTap: element.onTap,
              backgroundColor: element.backgroundColor,
              padding: element.padding,
              borderRadius: element.borderRadius,
              border: element.border,
            ),
          );
        }
      } else {
        // No overlap, add element as-is
        mergedList.add(element);
      }
    }

    return mergedList;
  }

  /// Merge two TextStyles, combining their properties
  TextStyle? _mergeTextStyles(TextStyle? style1, TextStyle? style2) {
    if (style1 == null) return style2;
    if (style2 == null) return style1;

    // Merge styles - style2 properties override style1, but we want to combine
    // font properties like bold + italic
    return TextStyle(
      color: style2.color ?? style1.color,
      backgroundColor: style2.backgroundColor ?? style1.backgroundColor,
      fontSize: style2.fontSize ?? style1.fontSize,
      fontWeight: style2.fontWeight ?? style1.fontWeight,
      fontStyle: style2.fontStyle ?? style1.fontStyle,
      letterSpacing: style2.letterSpacing ?? style1.letterSpacing,
      wordSpacing: style2.wordSpacing ?? style1.wordSpacing,
      textBaseline: style2.textBaseline ?? style1.textBaseline,
      height: style2.height ?? style1.height,
      leadingDistribution:
          style2.leadingDistribution ?? style1.leadingDistribution,
      locale: style2.locale ?? style1.locale,
      foreground: style2.foreground ?? style1.foreground,
      background: style2.background ?? style1.background,
      shadows: style2.shadows ?? style1.shadows,
      fontFeatures: style2.fontFeatures ?? style1.fontFeatures,
      fontVariations: style2.fontVariations ?? style1.fontVariations,
      decoration: _mergeDecorations(style1.decoration, style2.decoration),
      decorationColor: style2.decorationColor ?? style1.decorationColor,
      decorationStyle: style2.decorationStyle ?? style1.decorationStyle,
      decorationThickness:
          style2.decorationThickness ?? style1.decorationThickness,
      debugLabel: style2.debugLabel ?? style1.debugLabel,
      fontFamily: style2.fontFamily ?? style1.fontFamily,
      fontFamilyFallback:
          style2.fontFamilyFallback ?? style1.fontFamilyFallback,
      overflow: style2.overflow ?? style1.overflow,
    );
  }

  /// Merge text decorations (underline, strikethrough, etc.)
  TextDecoration? _mergeDecorations(TextDecoration? d1, TextDecoration? d2) {
    if (d1 == null) return d2;
    if (d2 == null) return d1;
    return TextDecoration.combine([d1, d2]);
  }

  // List<AttributedText> getAttributedText(String text, CometChatTheme theme, BubbleAlignment? alignment, {List<AttributedText>? existingAttributes});

  ///[getAttributedText] is a function which is used to get the attributed text which is used to style the text in the message bubble and conversation subtitle
  List<AttributedText> getAttributedText(
    String text,
    BuildContext context,
    BubbleAlignment? alignment, {
    List<AttributedText>? existingAttributes,
    Function(String)? onTap,
    bool forConversation = false,
  }) {
    List<AttributedText> attributedTexts = [];
    final matches = pattern!.allMatches(text);
    for (final match in matches) {
      // Skip matches that overlap with existing attributed text ranges
      // (e.g., URLs inside markdown link syntax already handled by MarkdownTextFormatter)
      final overlaps =
          existingAttributes?.any(
            (attr) => match.start < attr.end && match.end > attr.start,
          ) ??
          false;
      if (overlaps) continue;

      attributedTexts.add(
        AttributedText(
          start: match.start,
          end: match.end,
          style: getMessageBubbleTextStyle(
            context,
            alignment,
            forConversation: forConversation,
          ),
          onTap: onTap,
        ),
      );
    }
    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    } else {
      return attributedTexts;
    }
  }

  ///[onChange] is a function which is used to perform some action when the text is changed
  void onChange(
    TextEditingController textEditingController,
    String previousText,
  );

  ///[getLoadingIndicator] is a widget which is used to show the loading indicator
  Widget getLoadingIndicator(BuildContext context) {
    if (showLoadingIndicator != false) {
      return Container(
        alignment: Alignment.center,
        height: 48,
        child: Image.asset(
          AssetConstants.spinner,
          package: UIConstants.packageName,
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
