import "package:cometchat_sdk/cometchat_sdk.dart";
import '../../data/models/interactive_message/form_message.dart';
import '../../data/models/interactive_message/card_message.dart';
import '../../data/models/interactive_message/scheduler_message.dart';

class SDKMethods {
  static Future<FormMessage?> sendFormMessage(FormMessage message,
      {required Function(FormMessage message)? onSuccess,
      required Function(CometChatException excep)? onError}) async {
    InteractiveMessage interactiveMessage = message.toInteractiveMessage();
    FormMessage? formMessage;
    await CometChat.sendInteractiveMessage(interactiveMessage,
        onSuccess: (InteractiveMessage returnedMessage) {
      formMessage = FormMessage.fromInteractiveMessage(returnedMessage);
      if (onSuccess != null) {
        onSuccess(formMessage!);
      }
    }, onError: onError);
    return formMessage;
  }

  static Future<CardMessage?> sendCardMessage(CardMessage message,
      {required Function(CardMessage message)? onSuccess,
      required Function(CometChatException excep)? onError}) async {
    InteractiveMessage interactiveMessage = message.toInteractiveMessage();
    CardMessage? cardMessage;
    await CometChat.sendInteractiveMessage(interactiveMessage,
        onSuccess: (InteractiveMessage message) {
      cardMessage = CardMessage.fromInteractiveMessage(message);
      if (onSuccess != null) {
        onSuccess(cardMessage!);
      }
    }, onError: onError);
    return cardMessage;
  }

  static Future<SchedulerMessage?> sendSchedulerMessage(
      SchedulerMessage message,
      {required Function(SchedulerMessage message)? onSuccess,
      required Function(CometChatException excep)? onError}) async {
    InteractiveMessage interactiveMessage = message.toInteractiveMessage();
    SchedulerMessage? meetingMessage;
    await CometChat.sendInteractiveMessage(interactiveMessage,
        onSuccess: (InteractiveMessage returnedMessage) {
      meetingMessage = SchedulerMessage.fromInteractiveMessage(returnedMessage);
      if (onSuccess != null) {
        onSuccess(meetingMessage!);
      }
    }, onError: onError);
    return meetingMessage;
  }
}
