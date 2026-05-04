import 'package:cometchat_sdk/cometchat_sdk.dart';

class RequestBuilderConstants {
  static UsersRequestBuilder getDefaultUsersRequestBuilder() {
    UsersRequestBuilder usersRequestBuilder = UsersRequestBuilder()..limit = 30;
    return usersRequestBuilder;
  }

  static GroupsRequestBuilder getDefaultGroupsRequestBuilder() {
    GroupsRequestBuilder groupsRequestBuilder = GroupsRequestBuilder()
      ..limit = 30;
    return groupsRequestBuilder;
  }

  static MessagesRequestBuilder getDefaultMessagesRequestBuilder() {
    MessagesRequestBuilder messagesRequestBuilder = MessagesRequestBuilder()
      ..limit = 30
      ..hideReplies = true;
    return messagesRequestBuilder;
  }

  static ConversationsRequestBuilder getDefaultConversationsRequestBuilder() {
    ConversationsRequestBuilder conversationsRequestBuilder = ConversationsRequestBuilder()
      ..limit = 30;
    return conversationsRequestBuilder;
  }
  //TODO add all default Request Builders here and use it in code
}
