import 'package:flutter/material.dart';
import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';

///[DataSource] abstract class which every data source will implement inorder to provide any extension functionality

abstract class DataSource {
  ///override this to show options for messages of type [MessageTypeConstants.text]
  List<CometChatMessageOption> getTextMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations);

  ///override this to show options for messages of type [MessageTypeConstants.image]
  List<CometChatMessageOption> getImageMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations);

  ///override this to show options for messages of type [MessageTypeConstants.video]
  List<CometChatMessageOption> getVideoMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations);

  ///override this to show options for messages of type [MessageTypeConstants.audio]
  List<CometChatMessageOption> getAudioMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations);

  ///override this to show options for messages of type [MessageTypeConstants.file]
  List<CometChatMessageOption> getFileMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations);

  ///override this to change bottom view of every type of message
  Widget getBottomView(
      BaseMessage message, BuildContext context, BubbleAlignment alignment);

  ///override this to change content view for messages of type [MessageTypeConstants.text]
  Widget getTextMessageContentView(TextMessage message, BuildContext context,
      BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations});

  ///override this to change content view for messages of type [MessageTypeConstants.image]
  Widget getImageMessageContentView(MediaMessage message, BuildContext context,
      BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations});

  ///override this to change content view for messages of type [MessageTypeConstants.video]
  Widget getVideoMessageContentView(MediaMessage message, BuildContext context,
      BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations});

  ///override this to change content view for messages of type [MessageTypeConstants.file]
  Widget getFileMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations});

  ///override this to change content view for messages of type [MessageTypeConstants.audio]
  Widget getAudioMessageContentView(
      MediaMessage message, BuildContext context, BubbleAlignment alignment,
      {AdditionalConfigurations? additionalConfigurations});

  ///override this to change content view for messages of type [MessageTypeConstants.form]
  Widget getFormMessageContentView(FormMessage message, BuildContext context,
      BubbleAlignment alignment);

  ///override this to change content view for messages of type [MessageTypeConstants.form]
  Widget getCardMessageContentView(CardMessage message, BuildContext context,
      BubbleAlignment alignment);

  ///override this to change content view for messages of type [MessageTypeConstants.scheduler]
  Widget getSchedulerMessageContentView(SchedulerMessage message,
      BuildContext context, BubbleAlignment alignment);

  ///override this to alter template for messages of type [MessageTypeConstants.text]
  CometChatMessageTemplate getTextMessageTemplate();

  ///override this to alter template for messages of type [MessageTypeConstants.audio]
  CometChatMessageTemplate getAudioMessageTemplate();

  ///override this to alter template for messages of type [MessageTypeConstants.video]
  CometChatMessageTemplate getVideoMessageTemplate();

  ///override this to alter template for messages of type [MessageTypeConstants.image]
  CometChatMessageTemplate getImageMessageTemplate();

  ///override this to alter template for messages of category action
  CometChatMessageTemplate getGroupActionTemplate();

  ///override this to alter template for messages of type [MessageTypeConstants.file]
  CometChatMessageTemplate getFileMessageTemplate();

  ///override this to alter template for messages of type [MessageTypeConstants.form]
  CometChatMessageTemplate getFormMessageTemplate();

  ///override this to alter template for messages of type [MessageTypeConstants.card]
  CometChatMessageTemplate getCardMessageTemplate();

  ///override this to alter template for messages of type [MessageTypeConstants.scheduler]
  CometChatMessageTemplate getSchedulerMessageTemplate();

  ///override this to alter template of all type
  ///
  /// by default it uses method [getTextMessageTemplate] , [getAudioMessageTemplate] ,[getVideoMessageTemplate],
  /// [getImageMessageTemplate],[getGroupActionTemplate] and [getFileMessageTemplate]
  List<CometChatMessageTemplate> getAllMessageTemplates();

  ///override this to get messages of different template
  CometChatMessageTemplate? getMessageTemplate(
      {required String messageType,
      required String messageCategory});

  ///override this to alter options for messages of given type in [messageObject]
  List<CometChatMessageOption> getMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations);

  ///override this to alter options for messages of every type
  List<CometChatMessageOption> getCommonOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations);

  String getMessageTypeToSubtitle(String messageType, BuildContext context);

  ///override this to alter attachment options in `CometChatMessageComposer`
  List<CometChatMessageComposerAction> getAttachmentOptions(
    BuildContext context,
    Map<String, dynamic>? id,
    AdditionalConfigurations? additionalConfigurations,
  );

  ///override this to alter default messages types
  List<String> getAllMessageTypes();

  ///override this to alter default categories
  List<String> getAllMessageCategories();

  ///override this to alter default auxiliary options in `CometChatMessageComposer`
  Widget getAuxiliaryOptions(User? user, Group? group, BuildContext context,
      Map<String, dynamic>? id, Color? color,
      {AdditionalConfigurations? additionalConfigurations});

  ///override this to set id for different extensions, used when enabling extensions
  String getId();

  ///override this to change view of deleted message
  Widget getDeleteMessageBubble(
      BaseMessage messageObject, BuildContext context, CometChatDeletedBubbleStyle? style);

  ///override this to change view inside content view of message type [MessageTypeConstants.video]
  Widget getVideoMessageBubble(
      String? videoUrl,
      String? thumbnailUrl,
      MediaMessage message,
      Function()? onClick,
      BuildContext context,
      CometChatVideoBubbleStyle? style);

  ///override this to change view inside content view of message type [MessageTypeConstants.text]
  Widget getTextMessageBubble(
      String messageText,
      TextMessage message,
      BuildContext context,
      BubbleAlignment alignment,
      CometChatTextBubbleStyle? style,
      List<CometChatTextFormatter>? formatters);

  ///override this to change view inside content view of message type [MessageTypeConstants.image]
  Widget getImageMessageBubble(
      String? imageUrl,
      String? placeholderImage,
      String? caption,
      CometChatImageBubbleStyle? style,
      MediaMessage message,
      Function()? onClick,
      BuildContext context);

  ///override this to change view inside content view of message type [MessageTypeConstants.audio]
  Widget getAudioMessageBubble(
      String? audioUrl,
      String? title,
      CometChatAudioBubbleStyle? style,
      MediaMessage message,
      BuildContext context,
      BubbleAlignment alignment);

  ///override this to change view inside content view of message type [MessageTypeConstants.file]
  Widget getFileMessageBubble(
      String? fileUrl,
      String? fileMimeType,
      String? title,
      int? id,
      CometChatFileBubbleStyle? style,
      MediaMessage message,
      BubbleAlignment alignment);

  ///override this to change view inside content view of message type [MessageTypeConstants.file]
  Widget getFormMessageBubble({
    String? title,
    required FormMessage message,
  });

  ///override this to change view inside content view of message type [MessageTypeConstants.file]
  Widget getCardMessageBubble({
    CardBubbleStyle? cardBubbleStyle,
    required CardMessage message,
  });

  ///override this to change view inside content view of message type [MessageTypeConstants.scheduler]
  Widget getSchedulerMessageBubble({
    required SchedulerMessage message,
  });

  ///override this to change last message fetched in conversations
  String getLastConversationMessage(
      Conversation conversation, BuildContext context);

  ///override this to change last message icon
  Widget getLastConversationWidget(
    Conversation conversation,
    BuildContext context,
    Color? iconColor,
  );

  ///override this to change the widget shown for subtitle in conversations
  Widget getConversationSubtitle(Conversation conversation,
      BuildContext context, TextStyle? subtitleStyle, Color? iconColor,
      {AdditionalConfigurations? additionalConfigurations});

  /// Returns the auxiliary header menu view for the user or group.
  Widget? getAuxiliaryHeaderMenu(
      BuildContext context, User? user, Group? group,
      {AdditionalConfigurations? additionalConfigurations});

  ///override this to show options for messages of type [MessageTypeConstants.form]
  List<CometChatMessageOption> getFormMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      {AdditionalConfigurations? additionalConfigurations});

  ///override this to show options for messages of type [MessageTypeConstants.card]
  List<CometChatMessageOption> getCardMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations);

  ///override this to alter attachment options in `CometChatMessageComposer`
  List<CometChatMessageComposerAction> getAIOptions(
      User? user,
      Group? group,
      BuildContext context,
      Map<String, dynamic>? id,
      AIOptionsStyle? aiOptionStyle
      );

  ///override this to show options for messages of type [MessageTypeConstants.scheduler]
  List<CometChatMessageOption> getSchedulerMessageOptions(
      User loggedInUser,
      BaseMessage messageObject,
      BuildContext context,
      Group? group,
      AdditionalConfigurations? additionalConfigurations);

  ///override this to alter template for messages of type [MessageTypeConstants.text]
  List<CometChatTextFormatter> getDefaultTextFormatters();
}
