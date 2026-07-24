import '../../cometchat_uikit_shared.dart';
import '../clean_architecture/data/models/interactive_message/card_message.dart'
    as legacy;

class SDKMethods {
  static Future<FormMessage?> sendFormMessage(
    FormMessage message, {
    required Function(FormMessage message)? onSuccess,
    required Function(CometChatException excep)? onError,
  }) async {
    InteractiveMessage interactiveMessage = message.toInteractiveMessage();
    FormMessage? formMessage;
    await CometChat.sendInteractiveMessage(
      interactiveMessage,
      onSuccess: (InteractiveMessage returnedMessage) {
        formMessage = FormMessage.fromInteractiveMessage(returnedMessage);
        if (onSuccess != null) {
          onSuccess(formMessage!);
        }
      },
      onError: onError,
    );
    return formMessage;
  }

  static Future<legacy.CardMessage?> sendCardMessage(
    legacy.CardMessage message, {
    required Function(legacy.CardMessage message)? onSuccess,
    required Function(CometChatException excep)? onError,
  }) async {
    InteractiveMessage interactiveMessage = message.toInteractiveMessage();
    legacy.CardMessage? cardMessage;
    await CometChat.sendInteractiveMessage(
      interactiveMessage,
      onSuccess: (InteractiveMessage message) {
        cardMessage = legacy.CardMessage.fromInteractiveMessage(message);
        if (onSuccess != null) {
          onSuccess(cardMessage!);
        }
      },
      onError: onError,
    );
    return cardMessage;
  }

  static Future<SchedulerMessage?> sendSchedulerMessage(
    SchedulerMessage message, {
    required Function(SchedulerMessage message)? onSuccess,
    required Function(CometChatException excep)? onError,
  }) async {
    InteractiveMessage interactiveMessage = message.toInteractiveMessage();
    SchedulerMessage? meetingMessage;
    await CometChat.sendInteractiveMessage(
      interactiveMessage,
      onSuccess: (InteractiveMessage returnedMessage) {
        meetingMessage = SchedulerMessage.fromInteractiveMessage(
          returnedMessage,
        );
        if (onSuccess != null) {
          onSuccess(meetingMessage!);
        }
      },
      onError: onError,
    );
    return meetingMessage;
  }
}
