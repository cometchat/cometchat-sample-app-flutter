import 'package:flutter/material.dart';
import '../../../cometchat_uikit_shared.dart';

///[DataSourceDecorator] should be extended when creating any extension
abstract class DataSourceDecorator implements DataSource {
  DataSource dataSource;

  DataSourceDecorator(this.dataSource);

  @override
  List<CometChatMessageOption> getAudioMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getAudioMessageOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  Widget getAuxiliaryOptions(User? user, Group? group, BuildContext context,
      Map<String, dynamic>? id, Color? color,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getAuxiliaryOptions(user, group, context, id, color,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  Widget getBottomView(
      BaseMessage message, BuildContext context, BubbleAlignment alignment) {
    return dataSource.getBottomView(message, context, alignment);
  }

  @override
  List<CometChatMessageOption> getCommonOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getCommonOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  List<CometChatMessageComposerAction> getAttachmentOptions(
    BuildContext context,
    Map<String, dynamic>? id,
    AdditionalConfigurations? additionalConfigurations,
  ) {
    return dataSource.getAttachmentOptions(
      context,
      id,
      additionalConfigurations,
    );
  }

  @override
  CometChatMessageTemplate getAudioMessageTemplate() {
    return dataSource.getAudioMessageTemplate();
  }

  @override
  CometChatMessageTemplate getFileMessageTemplate() {
    return dataSource.getFileMessageTemplate();
  }

  @override
  CometChatMessageTemplate getGroupActionTemplate() {
    return dataSource.getGroupActionTemplate();
  }

  @override
  CometChatMessageTemplate getImageMessageTemplate() {
    return dataSource.getImageMessageTemplate();
  }

  @override
  List<String> getAllMessageCategories() {
    return dataSource.getAllMessageCategories();
  }

  @override
  List<CometChatMessageTemplate> getAllMessageTemplates() {
    return dataSource.getAllMessageTemplates();
  }

  @override
  List<String> getAllMessageTypes() {
    return dataSource.getAllMessageTypes();
  }

  @override
  CometChatMessageTemplate getVideoMessageTemplate() {
    return dataSource.getVideoMessageTemplate();
  }

  @override
  List<CometChatMessageOption> getFileMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getFileMessageOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  List<CometChatMessageOption> getImageMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getImageMessageOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  List<CometChatMessageOption> getMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getMessageOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  CometChatMessageTemplate? getMessageTemplate(
      {required String messageType, required String messageCategory}) {
    return dataSource.getMessageTemplate(
        messageType: messageType, messageCategory: messageCategory);
  }

  @override
  String getMessageTypeToSubtitle(String messageType, BuildContext context) {
    return dataSource.getMessageTypeToSubtitle(messageType, context);
  }

  @override
  CometChatMessageTemplate getTextMessageTemplate() {
    return dataSource.getTextMessageTemplate();
  }

  @override
  Widget getTextMessageContentView(
      TextMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getTextMessageContentView(message, context, alignment,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  List<CometChatMessageOption> getTextMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getTextMessageOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  List<CometChatMessageOption> getVideoMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getVideoMessageOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  Widget getAudioMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getAudioMessageContentView(message, context, alignment,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  Widget getFileMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getFileMessageContentView(message, context, alignment,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  Widget getImageMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getImageMessageContentView(message, context, alignment,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  Widget getVideoMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getVideoMessageContentView(message, context, alignment,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  Widget getDeleteMessageBubble(BaseMessage messageObject, BuildContext context,
      CometChatDeletedBubbleStyle? style) {
    return dataSource.getDeleteMessageBubble(messageObject, context, style);
  }

  @override
  Widget getVideoMessageBubble(
      String? videoUrl,
      String? thumbnailUrl,
      MediaMessage message,
      Function()? onClick,
      BuildContext context,
      CometChatVideoBubbleStyle? style) {
    return dataSource.getVideoMessageBubble(
        videoUrl, thumbnailUrl, message, onClick, context, style);
  }

  @override
  Widget getTextMessageBubble(
      String messageText,
      TextMessage message,
      BuildContext context,
      BubbleAlignment alignment,
      CometChatTextBubbleStyle? style,
      List<CometChatTextFormatter>? formatters) {
    return dataSource.getTextMessageBubble(
        messageText, message, context, alignment, style, formatters);
  }

  @override
  Widget getImageMessageBubble(
    String? imageUrl,
    String? placeholderImage,
    String? caption,
    CometChatImageBubbleStyle? style,
    MediaMessage message,
    Function()? onClick,
    BuildContext context,
  ) {
    return dataSource.getImageMessageBubble(
        imageUrl, placeholderImage, caption, style, message, onClick, context);
  }

  @override
  Widget getAudioMessageBubble(
      String? audioUrl,
      String? title,
      CometChatAudioBubbleStyle? style,
      MediaMessage message,
      BuildContext context,
      BubbleAlignment alignment) {
    return dataSource.getAudioMessageBubble(
        audioUrl, title, style, message, context, alignment);
  }

  @override
  Widget getFileMessageBubble(
      String? fileUrl,
      String? fileMimeType,
      String? title,
      int? id,
      CometChatFileBubbleStyle? style,
      MediaMessage message,
      BubbleAlignment alignment) {
    return dataSource.getFileMessageBubble(
        fileUrl, fileMimeType, title, id, style, message, alignment);
  }

  @override
  String getLastConversationMessage(
      Conversation conversation, BuildContext context) {
    return dataSource.getLastConversationMessage(conversation, context);
  }

  @override
  Widget getLastConversationWidget(
    Conversation conversation,
    BuildContext context,
    Color? iconColor,
  ) {
    return dataSource.getLastConversationWidget(
      conversation,
      context,
      iconColor,
    );
  }

  ///override this to change the widget shown for subtitle in conversations
  @override
  Widget getConversationSubtitle(Conversation conversation,
      BuildContext context, TextStyle? subtitleStyle, Color? iconColor,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getConversationSubtitle(
        conversation, context, subtitleStyle, iconColor,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  Widget? getAuxiliaryHeaderMenu(BuildContext context, User? user, Group? group,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getAuxiliaryHeaderMenu(context, user, group,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  Widget getFormMessageBubble({
    String? title,
    required FormMessage message,
  }) {
    return dataSource.getFormMessageBubble(title: title, message: message);
  }

  @override
  Widget getFormMessageContentView(
      FormMessage message, BuildContext context, BubbleAlignment alignment) {
    return dataSource.getFormMessageContentView(message, context, alignment);
  }

  @override
  CometChatMessageTemplate getFormMessageTemplate() {
    return dataSource.getFormMessageTemplate();
  }

  @override
  CometChatMessageTemplate getSchedulerMessageTemplate() {
    return dataSource.getSchedulerMessageTemplate();
  }

  @override
  CometChatMessageTemplate getCardMessageTemplate() {
    return dataSource.getCardMessageTemplate();
  }

  @override
  Widget getCardMessageContentView(
      CardMessage message, BuildContext context, BubbleAlignment alignment) {
    return dataSource.getCardMessageContentView(message, context, alignment);
  }

  @override
  Widget getSchedulerMessageContentView(SchedulerMessage message,
      BuildContext context, BubbleAlignment alignment) {
    return dataSource.getSchedulerMessageContentView(
        message, context, alignment);
  }

  @override
  Widget getCardMessageBubble({
    CardBubbleStyle? cardBubbleStyle,
    required CardMessage message,
  }) {
    return dataSource.getCardMessageBubble(
        message: message, cardBubbleStyle: cardBubbleStyle);
  }

  @override
  Widget getSchedulerMessageBubble({
    required SchedulerMessage message,
  }) {
    return dataSource.getSchedulerMessageBubble(message: message);
  }

  @override
  List<CometChatMessageOption> getFormMessageOptions(User loggedInUser,
      BaseMessage messageObject, BuildContext context, Group? group,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getFormMessageOptions(
        loggedInUser, messageObject, context, group,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  List<CometChatMessageOption> getCardMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getCardMessageOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  List<CometChatMessageOption> getSchedulerMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getSchedulerMessageOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  List<CometChatMessageComposerAction> getAIOptions(
    User? user,
    Group? group,
    BuildContext context,
    Map<String, dynamic>? id,
    AIOptionsStyle? aiOptionStyle,
  ) {
    return dataSource.getAIOptions(user, group, context, id, aiOptionStyle);
  }

  @override
  List<CometChatTextFormatter> getDefaultTextFormatters() {
    return dataSource.getDefaultTextFormatters();
  }

  @override
  CometChatMessageTemplate getAIAssistantMessageTemplate() {
    return dataSource.getAIAssistantMessageTemplate();
  }

  @override
  Widget getAIAssistantMessageContentView(AIAssistantMessage message,
      BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getAIAssistantMessageContentView(
        message, context, alignment,
        additionalConfigurations: additionalConfigurations);
  }

  @override
  Widget getAIAssistantMessageBubble({
    String? text,
    required AIAssistantMessage message,
    BubbleAlignment? alignment,
    CometChatAIAssistantBubbleStyle? style,
  }) {
    return dataSource.getAIAssistantMessageBubble(
        text: text, message: message, alignment: alignment, style: style);
  }

  @override
  List<CometChatMessageOption> getAIAssistantMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations) {
    return dataSource.getAIAssistantMessageOptions(
        loggedInUser, messageObject, context, group, additionalConfigurations);
  }

  @override
  Widget getAIAssistantMessageFooterView(AIAssistantMessage message,
      BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations}) {
    return dataSource.getAIAssistantMessageFooterView(message, context, alignment,
        additionalConfigurations: additionalConfigurations);
  }
}
