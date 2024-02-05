import 'package:cometchat_flutter_sample_app/utils/widget_card.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

WidgetProps getFormBubbleContainer(BuildContext context) {
  return WidgetProps(
    leadingImageURL: "assets/icons/form_bubble.png",
    title: "Form Bubble",
    description:
        "CometChatFormBubble component is used to render a form within a chat bubble."
        "To learn more about this component tap here",
    onTap: () {
      FormMessage formMessage = FormMessage(
          formFields: [
            TextInputElement(
              elementId: "name",
              label: "name",
              optional: false,
            ),
            TextInputElement(
              elementId: "age",
              label: "Age",
              optional: false,
            ),
            SingleSelectElement(elementId: "gender", label: "Gender", options: [
              OptionElement(label: "Male", value: "male"),
              OptionElement(label: "Female", value: "female")
            ]),
            DropdownElement(elementId: "class", label: "Class", options: [
              OptionElement(label: "Class 1", value: "1"),
              OptionElement(label: "Class 2", value: "2")
            ]),
            DateTimeElement(
              elementId: "dobInput",
              label: "Date of Birth",
              formattedResponse: DateTime.now(),
            ),
          ],
          submitElement: ButtonElement(
              elementId: "button1",
              buttonText: "Accept",
              action: APIAction(
                  method: APIRequestTypeConstants.post,
                  url: "https/abc.com",
                  dataKey: "answers")),
          title: "Survey",
          receiverUid: "superhero2",
          receiverType: ReceiverTypeConstants.user,
          interactionGoal: InteractionGoal(
              type: InteractionGoalTypeConstants.anyAction,
              elementIds: ["button1"]));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.5,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CometChatFormBubble(
                  theme: cometChatTheme,
                  title: 'Form bubble',
                  formMessage: formMessage,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
