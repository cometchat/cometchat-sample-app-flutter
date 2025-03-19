import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CometChatReactionListController extends GetxController
    with CometChatMessageEventListener {
  Map<String, List<Reaction>> messageReactions = {};
  ReactionsRequestBuilder? reactionsRequestBuilder;
  int messageId;
  bool isLoading = false;
  String selectedReaction;
  int totalReactions = 0;
  CometChatException? error;
  bool hasError = false;
  BuildContext? context;

  late String dateStamp;
  late String _eventListenerKey;
  CometChatReactionListController(
      {required this.messageId,
      this.reactionsRequestBuilder,
      this.selectedReaction = ReactionConstants.allReactions,
      this.messageObject});
  BaseMessage? messageObject;
  //-------------------------LifeCycle Methods-----------------------------
  @override
  void onInit() {
    dateStamp = DateTime.now().microsecondsSinceEpoch.toString();
    _eventListenerKey = "${dateStamp}_CometChatReactionListController";
    CometChatMessageEvents.addMessagesListener(_eventListenerKey, this);
    initializeReactionList();
    super.onInit();
  }

  @override
  onClose() {
    CometChatMessageEvents.removeMessagesListener(_eventListenerKey);
    super.onClose();
  }

  void initializeReactionList() {
    createReactionsRequest();
    //first we are fetching all available reactions upto the limit of 10
    fetchReactions();
    if (selectedReaction != ReactionConstants.allReactions) {
      createReactionsRequest(selectedReaction);
      //next we are fetching selected reactions
      fetchReactions(selectedReaction);
    }
  }

  Map<String, ReactionsRequest> reactionsRequests = {};
  Map<String, bool> hasMoreReactions = {};

  bool canFetchReactions() {
    return hasMoreReactions.containsKey(selectedReaction) &&
        hasMoreReactions[selectedReaction] == true;
  }

  void createReactionsRequest(
      [String reaction = ReactionConstants.allReactions]) {
    ReactionsRequestBuilder? requestBuilder =
        reactionsRequestBuilder ?? ReactionsRequestBuilder();

    requestBuilder.messageId = messageId;
    if (reaction != ReactionConstants.allReactions) {
      requestBuilder.reaction = reaction;
    }
    reactionsRequests[reaction] = requestBuilder.build();
    hasMoreReactions[reaction] = true;
  }

  void fetchReactions([String reaction = ReactionConstants.allReactions]) {
    if (reactionsRequests.containsKey(reaction)) {
      ReactionsRequest? request = reactionsRequests[reaction];
      isLoading = true;
      request?.fetchPrevious(
        onSuccess: (messageReactionsList) {
          if (messageReactionsList.isEmpty) {
            hasMoreReactions[reaction] = false;
          } else {
            hasMoreReactions[reaction] = true;
            for (Reaction messageReaction in messageReactionsList) {
              addReactionInMap(messageReaction);
            }
          }
          update();
          isLoading = false;
        },
        onError: (excep) {
          error = excep;
          hasError = true;
          isLoading = false;
          update();
        },
      );
    }
  }

  void addReactionInMap(Reaction messageReaction) {
    if (messageReactions.containsKey(messageReaction.reaction)) {
      // we are only adding reaction to the list if it doesn't exist already
      if (messageReactions[messageReaction.reaction!]?.indexWhere((element) =>
              element.reaction == messageReaction.reaction &&
              element.reactedBy?.uid == messageReaction.reactedBy?.uid) ==
          -1) {
        messageReactions[messageReaction.reaction!]?.add(messageReaction);
        totalReactions++;
      }
    } else {
      messageReactions[messageReaction.reaction!] = [messageReaction];
      totalReactions++;
    }
  }

  List<Reaction> getReactionData() {
    List<Reaction> usersWhoReacted = [];
    if (messageReactions.containsKey(selectedReaction)) {
      usersWhoReacted = messageReactions[selectedReaction]!.cast<Reaction>();
    } else if (selectedReaction == ReactionConstants.allReactions) {
      messageReactions.forEach((key, value) {
        usersWhoReacted.addAll(value.cast<Reaction>());
      });
    }
    return usersWhoReacted;
  }

  void updateSelectedReaction(String reaction) {
    selectedReaction = reaction;
    if (!reactionsRequests.containsKey(reaction)) {
      createReactionsRequest(reaction);
    }
    update();
  }

  int getReactionCount(String reaction) {
    if (messageReactions.containsKey(reaction)) {
      return messageReactions[reaction]!.length;
    } else {
      return totalReactions;
    }
  }

  bool isReactedByMe(User user) {
    return user.uid == CometChatUIKit.loggedInUser?.uid;
  }

  bool isSelectedReaction(String reaction) {
    return selectedReaction == reaction;
  }

  String getReactionListItemTitle(Reaction reaction) {
    if (reaction.reactedBy?.uid == CometChatUIKit.loggedInUser?.uid) {
      return "You";
    } else {
      return reaction.reactedBy?.name ?? "";
    }
  }

  void onReactionTap(Reaction reaction) {
    if (isReactedByMe(reaction.reactedBy!)) {
      removeReactionFromMap(reaction);
      update();
      CometChat.removeReaction(reaction.messageId!, reaction.reaction!,
          onSuccess: (reactedMessage) {
        if (messageObject != null) {
          CometChatMessageEvents.ccMessageEdited(
              messageObject!..reactions = reactedMessage.reactions,
              MessageEditStatus.success);
        }
      }, onError: (exception) {
        error = exception;
        hasError = true;
        isLoading = false;
        addReactionInMap(reaction);
        update();
      });
    }
  }

  void removeReactionFromMap(Reaction reaction) {
    messageReactions[reaction.reaction!]?.removeWhere(
        (element) => reaction.uid == element.uid && reaction.id == element.id);
    totalReactions--;
    update();
    if (messageReactions[reaction.reaction!]?.isEmpty ?? false) {
      messageReactions.remove(reaction.reaction!);
      selectedReaction = ReactionConstants.allReactions;
    }
    if (messageReactions.isEmpty && context != null) {
      Navigator.pop(context!);
    }
  }

  @override
  void onMessageReactionAdded(ReactionEvent reactionEvent) {
    if (reactionEvent.reaction != null) {
      addReactionInMap(reactionEvent.reaction!);
      update();
    }
  }

  @override
  void onMessageReactionRemoved(ReactionEvent reactionEvent) {
    if (reactionEvent.reaction != null) {
      removeReactionFromMap(reactionEvent.reaction!);
      update();
    }
  }
}
