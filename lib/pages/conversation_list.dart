import 'package:cometchat/cometchat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sdk_tutorial/Utils/custom_toast.dart';
import 'package:sdk_tutorial/Utils/loading_indicator.dart';
import 'package:sdk_tutorial/Utils/slide_menu.dart';
import 'package:sdk_tutorial/pages/messages/message_list.dart';
import 'package:badges/badges.dart';

import '../Utils/item_fetcher.dart';
import '../constants.dart';
import 'messages/message_receipts.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({Key? key}) : super(key: key);

  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList>
    with MessageListener {
  final List<Conversation> conversationList = [];
  final itemFetcher = ItemFetcher<Conversation>();

  bool isLoading = true;
  bool hasMoreItems = true;
  late ConversationsRequest conversationRequest;

  Set<int> typingIndicatorMap = {};
  @override
  void initState() {
    super.initState();

    conversationRequest = (ConversationsRequestBuilder()..limit = 30
        // ..tags = []
        // ..withUserAndGroupTags = true
        // ..conversationType = ConversationType.user
        )
        .build();

    CometChat.addMessageListener("ConversationIdListener", this);

    _loadMore();
  }

  //-----------Message Listeners------------------------------------------------
  @override
  void onTextMessageReceived(TextMessage textMessage) async {
    User? user = await CometChat.getLoggedInUser();
    if (user != null) {
      if (textMessage.sender!.uid == user.uid) {
        //await CometChat.markAsDelivered(textMessage, onSuccess: (_){}, onError: (_){});
      }
      refreshSingleConversation(textMessage, false);
    }
  }

  @override
  void onMediaMessageReceived(MediaMessage mediaMessage) async {
    User? user = await CometChat.getLoggedInUser();
    if (user != null) {
      if (mediaMessage.sender!.uid == user.uid) {
        await CometChat.markAsDelivered(mediaMessage,
            onSuccess: (_) {}, onError: (_) {});
      }
      refreshSingleConversation(mediaMessage, false);
    }
  }

  @override
  void onCustomMessageReceived(CustomMessage customMessage) async {
    User? user = await CometChat.getLoggedInUser();
    if (user != null) {
      if (customMessage.sender!.uid == user.uid) {
        await CometChat.markAsDelivered(customMessage,
            onSuccess: (_) {}, onError: (_) {});
      }
      refreshSingleConversation(customMessage, false);
    }
  }

  @override
  void onMessagesDelivered(MessageReceipt messageReceipt) {
    if (messageReceipt.receiverType == CometChatReceiverType.user) {
      setReceipts(messageReceipt);
    }
  }

  @override
  void onMessagesRead(MessageReceipt messageReceipt) {
    if (messageReceipt.receiverType == CometChatReceiverType.user) {
      setReceipts(messageReceipt);
    }
  }

  @override
  void onMessageEdited(BaseMessage message) {
    refreshSingleConversation(message, true);
  }

  @override
  void onMessageDeleted(BaseMessage message) {
    refreshSingleConversation(message, true);
  }

  @override
  void onTypingStarted(TypingIndicator typingIndicator) {
    setTypingIndicator(typingIndicator, true);
  }

  @override
  void onTypingEnded(TypingIndicator typingIndicator) {
    setTypingIndicator(typingIndicator, false);
  }

  //----------------Message Listeners end----------------------------------------------

  refreshSingleConversation(BaseMessage message, bool isActionMessage) async {
    await CometChat.getConversationFromMessage(message,
        onSuccess: (Conversation conversation) {
      if (message.metadata != null &&
          message.metadata!["incrementUnreadCount"] != null) {}
      update(conversation, isActionMessage);
    }, onError: (_) {});
  }

  ///Update the conversation with new conversation Object matched according to conversation id ,  if not matched inserted at top
  update(Conversation conversation, bool isActionMessage) {
    int matchingIndex = conversationList.indexWhere(
        (element) => (element.conversationId == conversation.conversationId));
    if (matchingIndex != -1) {
      Conversation oldConversation = conversationList[matchingIndex];
      Map<String, dynamic>? metaData = conversation.lastMessage!.metadata;
      bool incrementUnreadCount = false;
      bool isCategoryMessage =
          (conversation.lastMessage!.category == "message");
      if (metaData != null) {
        if (metaData.containsKey("incrementUnreadCount")) {
          incrementUnreadCount = metaData["incrementUnreadCount"] as bool;
        }
      }
      if (isActionMessage) {
        conversation.unreadMessageCount = oldConversation.unreadMessageCount;
      } else if (incrementUnreadCount || isCategoryMessage) {
        conversation.unreadMessageCount =
            (oldConversation.unreadMessageCount ?? 0) + 1;
      }
      conversationList.removeAt(matchingIndex);
      conversationList.insert(0, conversation);
    } else {
      conversationList.insert(0, conversation);
    }

    setState(() {});
  }

//Set Receipt for
  setReceipts(MessageReceipt receipt) {
    for (int i = 0; i < conversationList.length; i++) {
      Conversation conversation = conversationList[i];
      if (conversation.conversationType == CometChatReceiverType.user &&
          receipt.sender.uid == ((conversation.conversationWith as User).uid)) {
        BaseMessage? lastmessage = conversation.lastMessage;

        //Check if receipt type is delivered
        if (lastmessage != null &&
            lastmessage.deliveredAt == null &&
            receipt.receiptType == CometChatReceiptType.delivered &&
            receipt.messageId == lastmessage.id) {
          lastmessage.deliveredAt = receipt.deliveredAt;
          conversationList[i].lastMessage = lastmessage;
          setState(() {});
          break;
        } else if (lastmessage != null &&
            lastmessage.readAt == null &&
            receipt.receiptType == CometChatReceiptType.read &&
            receipt.messageId == lastmessage.id) {
          //if receipt type is read
          lastmessage.readAt = receipt.readAt;
          conversationList[i].lastMessage = lastmessage;
          setState(() {});

          break;
        }
      }
    }
  }

  setTypingIndicator(
      TypingIndicator typingIndicator, bool isTypingStarted) async {
    int matchingIndex = conversationList.indexWhere((element) =>
        ((element.conversationId!.contains(typingIndicator.receiverId) &&
            element.conversationId!.contains(typingIndicator.sender.uid))));

    if (isTypingStarted == true) {
      typingIndicatorMap.add(matchingIndex);
    } else {
      typingIndicatorMap.remove(matchingIndex);
    }
    setState(() {});
  }

  void deleteConversation(int index) async {
    showLoadingIndicatorDialog(context);
    late String conversationWith;
    late String conversationType;
    if (conversationList[index].conversationType.toLowerCase() ==
        ConversationType.group.toLowerCase()) {
      conversationWith =
          (conversationList[index].conversationWith as Group).guid;
      conversationType = ConversationType.group;
    } else {
      conversationWith = (conversationList[index].conversationWith as User).uid;

      conversationType = ConversationType.user;
    }

    await CometChat.deleteConversation(conversationWith, conversationType,
        onSuccess: (_) {
      showCustomToast(msg: "Chats Deleted");
      conversationList.removeAt(index);
    }, onError: (_) {});

    Navigator.pop(context);
    setState(() {});
  }

  //Function to load more conversations
  void _loadMore() {
    isLoading = true;
    itemFetcher
        .fetchNext(conversationRequest)
        .then((List<Conversation> fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          isLoading = false;
          hasMoreItems = false;
        });
      } else {
        setState(() {
          isLoading = false;
          conversationList.addAll(fetchedList);
        });
      }
    });
  }

  //----------- get last message text-----------
  Widget? getLastMessage(BaseMessage? message) {
    if (message == null) return null;

    CometChat.markAsDelivered(message, onSuccess: (String res) {
      debugPrint(res);
    }, onError: (CometChatException e) {
      debugPrint('$e');
    });

    return Row(
      children: [
        if (message.sender != null && message.sender!.uid == USERID)
          MessageReceipts(
            passedMessage: message,
            showTime: false,
          ),
        if (message.type != CometChatMessageType.text) Text(message.type),
        if (message.type == CometChatMessageType.text)
          Text((message as TextMessage).text),
      ],
    );
  }

  //----------- last message update time in short-----------
  String getLastMessageUpdateTime(DateTime? lastMessageTime) {
    var formatter = DateFormat("yyyy-MM-dd");

    if (lastMessageTime == null) return '';
    DateTime now = DateTime.now();
    if (now.difference(lastMessageTime).inSeconds < 60) {
      return 'Just Now';
    } else if (formatter.format(lastMessageTime) == formatter.format(now)) {
      return DateFormat("h:mma").format(lastMessageTime);
    } else if (now.difference(lastMessageTime).inDays == 1) {
      return "Yesterday";
    } else {
      return formatter.format(lastMessageTime);
    }
  }

  Widget getLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget getConversationListItem(int index, Conversation conversation) {
    String _name;
    String? _avatar;
    String unreadCount = '';

    //----------- user conversation -----------
    if (conversation.conversationWith is User) {
      final _user = conversation.conversationWith as User;
      _avatar = _user.avatar;
      _name = _user.name;
    }
    //----------- group conversation -----------
    else {
      final _group = conversation.conversationWith as Group;
      _avatar = _group.icon;
      _name = _group.name;
    }
    if (conversation.unreadMessageCount != null &&
        conversation.unreadMessageCount != 0) {
      unreadCount = conversation.unreadMessageCount.toString();
    }

    return SwipeMenu(
      menuItems: [
        GestureDetector(
          onTap: () {
            deleteConversation(index);
          },
          child: Container(
            color: Colors.redAccent,
            height: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 25,
                ),
                const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                )
              ],
            ),
          ),
        )
      ],
      child: Card(
        child: SizedBox(
          height: 72,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MessageList(
                                conversation: conversationList[index],
                              )));
                },
                leading: Hero(
                  tag: conversationList[index],
                  child: CircleAvatar(
                      child: _avatar != null && _avatar.trim() != ''
                          ? Image.network(
                              _avatar,
                            )
                          : Text(_name.substring(0, 2))),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(getLastMessageUpdateTime(
                        conversationList[index].updatedAt)),
                    if (unreadCount != '')
                      Badge(
                        toAnimate: false,
                        shape: BadgeShape.circle,
                        badgeColor: Colors.blue,
                        badgeContent: Text(unreadCount,
                            style: const TextStyle(color: Colors.white)),
                      )
                  ],
                ),
                title: Text(_name),
                subtitle: typingIndicatorMap.contains(index)
                    ? const Text(
                        'is typing...',
                        style: TextStyle(color: Colors.blue),
                      )
                    : getLastMessage(conversationList[index].lastMessage)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: Container(
        child: isLoading

            //-----------loading widget -----------
            ? getLoadingIndicator()

            //----------- empty list widget-----------
            : conversationList.isEmpty
                ? Center(
                    child: Text(
                      "No Chats yet",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff141414).withOpacity(0.34)),
                    ),
                  )

                //-----------list -----------
                : ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: hasMoreItems
                        ? conversationList.length + 1
                        : conversationList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= conversationList.length) {
                        _loadMore();
                        return getLoadingIndicator();
                      }

                      if (conversationList[index].conversationType ==
                              ConversationType.group ||
                          conversationList[index].conversationWith is User) {
                        return getConversationListItem(
                            index, conversationList[index]);
                      }
                      if (isLoading) {
                        return getLoadingIndicator();
                      }

                      return Container();
                    },
                  ),
      ),
    );
  }
}
