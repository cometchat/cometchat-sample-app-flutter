import 'package:cometchat_flutter_sample_app/shared/views/avatar_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/badge_container.dart';
import 'package:cometchat_flutter_sample_app/shared/resources/localization_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/card_bubble_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/form_bubble_conatainer.dart';
import 'package:cometchat_flutter_sample_app/shared/views/media_recorder_modal.dart';
import 'package:cometchat_flutter_sample_app/shared/views/message_receipt_container.dart';
import 'package:cometchat_flutter_sample_app/shared/resources/sound_manager_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/status_indicator_container.dart';
import 'package:cometchat_flutter_sample_app/shared/resources/theme_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/audio_bubble_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/cometchat_list_item_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/file_bubble_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/image_bubble_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/text_bubble_container.dart';
import 'package:cometchat_flutter_sample_app/shared/views/video_bubble_container.dart';
import 'package:cometchat_flutter_sample_app/utils/label.dart';
import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';

class SharedDashboard extends StatelessWidget {
  const SharedDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<WidgetProps> primaryModuleList = [
      WidgetProps(
        leadingImageURL: "assets/speakerwave2.png",
        title: "Sound Manager",
        description:
            "CometChatSoundManager allows you to play different types of audio which is required for incoming and outgoing events . To learn more about this component tap here",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SoundManagerContainer(),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/icons/colors.png",
        title: "Theme",
        description:
            "CometChatTheme is a style applied to every component and every view in the activity or component in the UI kit"
            ". To learn more about this component tap here",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ThemeContainer(),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/textformat.png",
        title: "Localize",
        description:
            "CometChatLocalize allows you to detect the language of your users based on their browser of "
            "device settings and set the language accordingly. To learn more about this component tap here . ",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LocalizationContainer(),
              ));
        },
      ),
    ];
/*
    final List<WidgetProps> sdkDerivedModuleList = [
      WidgetProps(
        leadingImageURL: "assets/sidebarleft.png",
        title: "Conversation List Item",
        description: "CometChatConversationListItem is a reusable component "
            "which is used to display the conversation list item in conversation list. "
            "To learn more about this component tap here",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ConversationListItemContainer(),
              ));
        },
      ),
      WidgetProps(
        leadingImageURL: "assets/macwindow.png",
        title: "Data Item",
        description:
            "CometChatDataItem is a reusable component which is used across multiple components in different variations such as User List "
            ", Group List as a list Item .",
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DataItemContainer(),
              ));
        },
      ),
    ];
    */

    List<WidgetProps> getViewModules(BuildContext context) {
      return [
        WidgetProps(
          leadingImageURL: "assets/person.png",
          title: "Avatar",
          description:
              "CometChatAvatar component displays an image or user/group avatar with fallback to the first two letters of the "
              "user name/group name .",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AvatarContainer(),
                ));
          },
        ),
        WidgetProps(
          leadingImageURL: "assets/rectanglebadge.png",
          title: "Badge Count",
          description:
              "CometChatBadgeCount is a custom component which is used to display the unread message count. "
              "It can be used in places like ConversationListItem , etc .",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BadgeContainer(),
                ));
          },
        ),
        WidgetProps(
          leadingImageURL: "assets/sidebarleft.png",
          title: "Message Receipt",
          description:
              "CometChatMessageReceipt component renders the receipts such as sending , sent ,"
              " delivered read and error state indicator of messages .",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MessageReceiptContainer(),
                ));
          },
        ),
        WidgetProps(
          leadingImageURL: "assets/status.png",
          title: "Status Indicator",
          description:
              "StatusIndicator component indicates whether a user is online or offline. ",
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatusIndicatorContainer(),
                ));
          },
        ),
        getTextBubbleContainer(context),
        getImageBubbleContainer(context),
        getVideoBubbleContainer(context),
        getAudioBubbleContainer(context),
        getFileBubbleContainer(context),
        //getDeleteMessageBubbleContainer(context),
        getCometChatListItemContainer(context),
        getMediaRecorderModal(context),
        getFormBubbleContainer(context),
        getCardBubbleContainer(context)
      ];
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 10, 2),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Shared",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Label(text: "Resources"),
              WidgetCard(
                widgets: primaryModuleList,
              ),
              const Label(text: "Views"),
              WidgetCard(
                widgets: getViewModules(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
