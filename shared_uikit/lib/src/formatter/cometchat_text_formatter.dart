import 'dart:async';

import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';

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
  TextStyle Function(BuildContext context, BubbleAlignment? alignment,
      {bool? forConversation})? messageBubbleTextStyle;

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
      BuildContext context, BubbleAlignment? alignment,
      {bool forConversation = false}) {
    if (messageBubbleTextStyle != null) {
      return messageBubbleTextStyle!(context, alignment,
          forConversation: forConversation);
    } else {
      CometChatColorPalette colorPalette = CometChatThemeHelper.getColorPalette(context);
      CometChatTypography typography = CometChatThemeHelper.getTypography(context);
      return TextStyle(
          color: alignment == BubbleAlignment.right
              ?colorPalette.white
              : colorPalette.neutral900,
          fontWeight: typography.body?.regular?.fontWeight,
          fontSize: typography.body?.regular?.fontSize,
          fontFamily: typography.body?.regular?.fontFamily,
          decoration: TextDecoration.underline);
    }
  }

  ///[handlePreMessageSend] is a function which is used to perform some action before sending the message
  void handlePreMessageSend(BuildContext context, BaseMessage baseMessage);

  ///[onScrollToBottom] is a function which is used to perform some action when the scroll reaches the bottom of the suggestion list
  void onScrollToBottom(TextEditingController textEditingController);

  ///[buildInputFieldText] is a function which is used to style the text in the input field in the message composer
  List<AttributedText> buildInputFieldText(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing,
      required String text,
      List<AttributedText>? existingAttributes}) {
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
      ...existingAttributedTexts
    ];

    // Sort the combined list based on the start property
    combinedList.sort((a, b) => a.start.compareTo(b.start));

    // Merge overlapping elements
    List<AttributedText> mergedList = [];
    AttributedText? currentElement;
    for (var element in combinedList) {
      if (currentElement == null) {
        currentElement = element;
        mergedList.add(element);
        continue;
      }

      // Check for overlap
      if (element.start >= currentElement.end) {
        // Update end if necessary
        //   currentElement.end =
        //       element.end > currentElement.end ? element.end : currentElement.end;
        // } else {
        // No overlap, add current element and start a new one
        currentElement = element;
        mergedList.add(element);
      }
    }

    return mergedList;
  }

  // List<AttributedText> getAttributedText(String text, CometChatTheme theme, BubbleAlignment? alignment, {List<AttributedText>? existingAttributes});

  ///[getAttributedText] is a function which is used to get the attributed text which is used to style the text in the message bubble and conversation subtitle
  List<AttributedText> getAttributedText(
      String text, BuildContext context, BubbleAlignment? alignment,
      {List<AttributedText>? existingAttributes,
      Function(String)? onTap,
      bool forConversation = false}) {
    List<AttributedText> attributedTexts = [];
    final matches = pattern!.allMatches(text);
    attributedTexts = matches.map((match) {
      int start = match.start;
      int end = match.end;

      return AttributedText(
          start: start,
          end: end,
          style: getMessageBubbleTextStyle(context, alignment,
              forConversation: forConversation),
          onTap: onTap);
    }).toList();
    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    } else {
      return attributedTexts;
    }
  }

  ///[onChange] is a function which is used to perform some action when the text is changed
  void onChange(
      TextEditingController textEditingController, String previousText);

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
