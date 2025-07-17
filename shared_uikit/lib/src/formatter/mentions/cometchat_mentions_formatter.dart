import 'package:cometchat_uikit_shared/cometchat_uikit_shared.dart';
import 'package:cometchat_uikit_shared/l10n/translations.dart' as cc;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///[CometChatMentionsFormatter] is a class which is used to format the mentions
///It extends the [CometChatTextFormatter]
///It has properties like [composerId], [onError], [suggestionListEventSink], [previousTextEventSink], [message], [mentionedUsersMap], [mentionCount], [mentionStartIndex], [mentionEndIndex], [lastCursorPos]
///It has methods like [handlePreMessageSend], [initializeFetchRequest], [fetchItems], [onMessageEdit], [resetMentionsTracker], [cursorInMentionTracker], [onChange], [onScrollToBottom]
///It has a constructor which takes [trackingCharacter], [pattern], [disableSuggestions], [showLoadingIndicator], [onSearch], [group], [composerId], [onError], [suggestionListEventSink], [previousTextEventSink], [theme], [message], [messageBubbleTextStyle], [groupMembersRequestBuilder], [usersRequestBuilder], [messageInputTextStyle] as a parameter
///It has a method [onMentionTap] which is used to handle the mention tap
///
/// ```dart
/// CometChatMentionsFormatter(
///  trackingCharacter: "@",
///  pattern: RegExp(RegexConstants.mentionRegexPattern),
///  showLoadingIndicator: false,
///  style: CometChatMentionsStyle(
///   mentionTextColor: Colors.blue,
///   mentionTextBackgroundColor: Colors.grey,
///  ),
///  );
///  ```
class CometChatMentionsFormatter extends CometChatTextFormatter {
  CometChatMentionsFormatter(
      {String? trackingCharacter,
      RegExp? pattern,
      super.showLoadingIndicator,
      super.onSearch,
      this.onError,
      super.message,
      super.messageBubbleTextStyle,
      super.messageInputTextStyle,
      super.composerId,
      super.suggestionListEventSink,
      super.previousTextEventSink,
      super.user,
      super.group,
      super.groupMembersRequestBuilder,
      super.usersRequestBuilder,
      this.mentionsType,
      this.onMentionTap,
      this.visibleIn,
      this.style})
      : super(
          trackingCharacter: trackingCharacter ?? "@",
          pattern: pattern ?? RegExp(RegexConstants.mentionRegexPattern),
        ) {
    trackingCharacter ??= "@";
    pattern ??= RegExp(RegexConstants.mentionRegexPattern);
  }

  ///[onError] callback triggered in case any error happens when fetching data
  final OnError? onError;

  ///[_request] is a dynamic type which is used to store the request
  dynamic _request;

  ///[_requestBuilder] is a dynamic type which is used to store the requestBuilder
  dynamic _requestBuilder;

  ///[onMentionTap] is a Function(String mention, User mentionedUser, {BaseMessage? message}) which is used to handle the mention tap
  Function(String mention, User mentionedUser, {BaseMessage? message})?
      onMentionTap;

  ///[mentionsType] is a [MentionsType] object which is used to store the mentions type
  MentionsType? mentionsType;

  ///[visibleIn] is a [MentionsVisibility] object which is used to store the mentions visibility
  MentionsVisibility? visibleIn;

  ///[style] is a [CometChatMentionsStyle] object which is used to store the mentions style
  CometChatMentionsStyle? style;

  String mentionTracker = "";
  Map<String, List<User?>> mentionedUsersMap = {};
  Set<String> mentionCount = {};
  int mentionStartIndex = 0;
  int mentionEndIndex = 0;
  int lastCursorPos = 0;
  int mentionsLimit = 10;

  @override
  void init() {
    trackingCharacter ??= "@";
    pattern ??= RegExp(RegexConstants.mentionRegexPattern);

    if (mentionsType == MentionsType.users || group == null) {
      _requestBuilder = usersRequestBuilder ?? UsersRequestBuilder();
    } else if (group != null) {
      _requestBuilder =
          groupMembersRequestBuilder ?? GroupMembersRequestBuilder(group!.guid);
    }
  }

  void updatePreviousText(String text) {
    if (previousTextEventSink != null) {
      previousTextEventSink!.add(text);
    }
  }

  ///[handlePreMessageSend] is a method which is used to handle the pre message send
  ///[context] is a [BuildContext] which is used to build the widget
  ///[message] is a [BaseMessage] which is used to send the message
  @override
  TextMessage handlePreMessageSend(BuildContext context, BaseMessage message) {
    String messagesText = (message as TextMessage).text;

    mentionedUsersMap.forEach((mention, mentionedUsers) {
      Iterable<RegExpMatch> matches = RegExp(mention).allMatches(messagesText);

      String newMessageText = "";
      int start = 0;
      int end = messagesText.length;

      for (int i = 0; i < matches.length; i++) {
        if (i >= mentionedUsers.length) break;
        if (mentionedUsers[i] != null) {
          newMessageText +=
              messagesText.substring(start, matches.elementAt(i).start);
          newMessageText += "<@uid:${mentionedUsers[i]!.uid}>";
        } else {
          newMessageText +=
              messagesText.substring(start, matches.elementAt(i).end);
        }

        start = matches.elementAt(i).end;
      }
      newMessageText += messagesText.substring(start, end);
      messagesText = newMessageText;
    });

    message.text = messagesText;
    message.mentionedUsers = getMentionedUsers(messagesText);
    mentionedUsersMap.clear();
    mentionCount.clear();
    if (mentionTracker.isNotEmpty) {
      resetMentionsTracker();
    }
    return message;
  }

  @override
  void onScrollToBottom(TextEditingController textEditingController) {
    fetchItems(textEditingController: textEditingController);
  }

  List<User> listItems = [];
  bool hasMore = true;

  ///[initializeFetchRequest] is a method which is used to initialize the fetch request
  void initializeFetchRequest(
      String? searchKeyword, TextEditingController textEditingController) {
    _request = (_requestBuilder
          ..limit = 10
          ..searchKeyword = searchKeyword)
        .build();

    fetchItems(
        firstTimeFetch: true,
        textEditingController: textEditingController,
        searchKeyword: searchKeyword);
  }

  ///[fetchItems] is a method which is used to fetch the items
  void fetchItems(
      {bool firstTimeFetch = false,
      required TextEditingController textEditingController,
      String? searchKeyword}) async {
    await _request.fetchNext(onSuccess: (users) {
      if (users.isEmpty) {
        if (suggestionListEventSink != null) {
          suggestionListEventSink?.add([]);
        }

        if (firstTimeFetch) {
          mentionTracker = "";
          mentionStartIndex = 0;
          mentionEndIndex = 0;
          if (onSearch != null) {
            onSearch!(null);
          }
          CometChatUIEvents.hidePanel(
              composerId, CustomUIPosition.composerPreview);
        }
      } else {
        if (listItems.isEmpty) {
          CometChatUIEvents.hidePanel(
              composerId, CustomUIPosition.composerPreview);
          listItems = users;
        } else {
          listItems.addAll(users);
        }

        if (suggestionListEventSink != null && users.isNotEmpty) {
          suggestionListEventSink?.add((users as List<User>)
              .map((user) => SuggestionListItem(
                  id: user.uid,
                  title: user.name,
                  avatarHeight: 30,
                  avatarWidth: 30,
                  avatarUrl: user.avatar,
                  avatarName: user.name,
                  onTap: () {
                    String mention = "@${user.name}";
                    int cursorPos = textEditingController.selection.base.offset;
                    int leftMatchesFound = RegExp(mention)
                        .allMatches(textEditingController.text
                            .substring(0, cursorPos - mentionTracker.length))
                        .length;

                    int rightMatchesFound = RegExp(mention)
                        .allMatches(
                            textEditingController.text.substring(cursorPos))
                        .length;

                    if (mentionedUsersMap.containsKey(mention)) {
                      while (mentionedUsersMap[mention]!.length <
                          leftMatchesFound + rightMatchesFound) {
                        mentionedUsersMap[mention]!
                            .insert(leftMatchesFound, null);
                      }

                      if (mentionTracker.trim() == mention) {
                        mentionedUsersMap[mention]![leftMatchesFound] = user;
                      } else if (conflictingIndex != null &&
                          conflictingIndex! <
                              mentionedUsersMap[mention]!.length) {
                        mentionedUsersMap[mention]?[conflictingIndex!] = user;

                        conflictingIndex = null;
                      } else {
                        mentionedUsersMap[mention]!
                            .insert(leftMatchesFound, user);
                      }
                      if (!mentionCount.contains(user.uid)) {
                        mentionCount.add(user.uid);
                      }
                    } else if (!mentionedUsersMap.containsKey(mention) &&
                        leftMatchesFound + rightMatchesFound > 0) {
                      mentionedUsersMap[mention] = [user];
                      if (!mentionCount.contains(user.uid)) {
                        mentionCount.add(user.uid);
                      }

                      while (mentionedUsersMap[mention]!.length <
                          leftMatchesFound + rightMatchesFound + 1) {
                        if (leftMatchesFound > rightMatchesFound) {
                          mentionedUsersMap[mention]!
                              .insert(leftMatchesFound - 1, null);
                        } else if (rightMatchesFound > leftMatchesFound) {
                          mentionedUsersMap[mention]!
                              .insert(rightMatchesFound - 1, null);
                        }
                      }
                    } else {
                      mentionedUsersMap[mention] = [user];
                      if (!mentionCount.contains(user.uid)) {
                        mentionCount.add(user.uid);
                      }
                    }

                    String textOnLeftOfMention = textEditingController.text
                        .substring(0, cursorPos - mentionTracker.length);
                    String textOnRightOfMention =
                        textEditingController.text.substring(cursorPos);

                    textEditingController.text =
                        "$textOnLeftOfMention$mention $textOnRightOfMention";

                    updatePreviousText(textEditingController.text);

                    textEditingController.selection = TextSelection(
                      baseOffset: cursorPos -
                          mentionTracker.length +
                          mention.length +
                          1,
                      extentOffset: cursorPos -
                          mentionTracker.length +
                          mention.length +
                          1,
                    );
                    lastCursorPos =
                        cursorPos - mentionTracker.length + mention.length + 1;
                    resetMentionsTracker();
                    CometChatUIEvents.hidePanel(
                        composerId, CustomUIPosition.composerPreview);
                  }))
              .toList());
        }
      }

      hasMore = !users.isEmpty;
    }, onError: (exception) {
      if (onError != null) {
        onError!(exception);
      }
    });
  }

  //-----------------------methods performing UI operations-----------------------------

  ///[onMessageEdit] is a method which is used to check the pattern matches
  ///[text] is a [String] which is used to store the text being typed
  ///[cursorPosition] is an [int] which is used to store the cursor position
  void onMessageEdit(TextEditingController textEditingController,
      {List<User> mentionedUsers = const []}) {
    if (mentionCount.length == mentionsLimit || listItems.isNotEmpty) {
      CometChatUIEvents.hidePanel(composerId, CustomUIPosition.composerTop);
    }
    mentionCount.clear();
    mentionedUsersMap.clear();
    resetMentionsTracker();

    String text = textEditingController.text;

    while (pattern!.hasMatch(text)) {
      var match = pattern!.firstMatch(text);
      if (match != null) {
        String uid = match.group(1)!;

        int index =
            mentionedUsers.indexWhere((userElement) => userElement.uid == uid);

        if (index != -1) {
          String mention = "@${mentionedUsers[index].name}";

          if (mentionedUsersMap.containsKey(mention)) {
            mentionedUsersMap[mention]!.add(mentionedUsers[index]);
          } else {
            mentionedUsersMap[mention] = [mentionedUsers[index]];
          }

          if (!mentionCount.contains(mentionedUsers[index].uid)) {
            mentionCount.add(mentionedUsers[index].uid);
          }

          text = text.replaceRange(match.start, match.end, mention);
        }
      }
    }

    textEditingController.text = text;
    updatePreviousText(textEditingController.text);
    textEditingController.selection = TextSelection(
      baseOffset: text.length,
      extentOffset: text.length,
    );
    lastCursorPos = text.length;
  }

  void resetMentionsTracker() {
    mentionTracker = "";
    mentionStartIndex = 0;
    mentionEndIndex = 0;

    interceptedMention = null;
    conflictingIndex = null;
    if (onSearch != null) {
      onSearch!(null);
    }
    listItems.clear();

    if (suggestionListEventSink != null) {
      suggestionListEventSink?.add([]);
    }
  }

  String? interceptedMention;

  void cursorInMentionTracker(int cursorPosition,
      TextEditingController textEditingController, String previousText) {
    // Make a copy of the mentionedUsersMap
    var mentionedUsersMapCopy =
        Map<String, List<User?>>.from(mentionedUsersMap);

    bool cursorAtEndOfMention = false;

    mentionedUsersMap.forEach((mention, users) {
      final matches = RegExp(mention).allMatches(previousText).toList();

      for (int i = 0; i < matches.length; i++) {
        final match = matches[i];

        // Check if we're deleting at the end of a mention
        if (previousText.length > textEditingController.text.length &&
            match.end == cursorPosition) {
          cursorAtEndOfMention = true;
          mentionTracker =
              textEditingController.text.substring(match.start, cursorPosition);
          searchOnActiveMention = true;
          return; // Use return instead of break to exit the forEach
        }
        // Check if cursor is inside a mention
        else if (match.start <= cursorPosition && match.end > cursorPosition) {
          if (i < users.length) {
            // Remove this specific mention occurrence
            final uidToRemove = users[i]?.uid;
            mentionedUsersMapCopy[mention]!.removeAt(i);

            if (uidToRemove != null) {
              mentionCount.remove(uidToRemove);
            }

            if (mentionedUsersMapCopy[mention]!.isEmpty) {
              mentionedUsersMapCopy.remove(mention);
            }

            mentionTracker = textEditingController.text
                .substring(match.start, cursorPosition);
            mentionStartIndex = match.start;
            mentionEndIndex = cursorPosition - 1;
          }
          return;
        }
      }
    });

    mentionedUsersMap = mentionedUsersMapCopy;

    if (!cursorAtEndOfMention) {
      // Existing logic for tracking new mentions
      int lastIndexOfTrackingChar = textEditingController.text
          .substring(0, cursorPosition)
          .lastIndexOf(trackingCharacter!);
      if (lastIndexOfTrackingChar != -1 &&
          (lastIndexOfTrackingChar == 0 ||
              (lastIndexOfTrackingChar > 1 &&
                  textEditingController.text[lastIndexOfTrackingChar - 1] ==
                      " "))) {
        String tempTracker = textEditingController.text
            .substring(lastIndexOfTrackingChar, cursorPosition);

        if (!tempTracker.contains("\n") && !tempTracker.contains("    ")) {
          mentionTracker = tempTracker;
          mentionStartIndex = lastIndexOfTrackingChar;
          mentionEndIndex = cursorPosition - 1;
        }
      }
    }
  }

  bool searchOnActiveMention = false;

  @override
  void onChange(
      TextEditingController textEditingController, String previousText) {
    if ((visibleIn == MentionsVisibility.usersConversationOnly &&
            group != null) ||
        (visibleIn == MentionsVisibility.groupConversationOnly &&
            group == null)) {
      return;
    } else {
      _onChange(textEditingController, previousText);
    }
  }

  void _onChange(
      TextEditingController textEditingController, String previousText) {
    // Get cursor current position
    var cursorPosition = textEditingController.selection.base.offset;

    // if text is empty then we will clear the listItems and hide the panel
    if (textEditingController.text.isEmpty) {
      if (listItems.isNotEmpty) {
        resetMentionsTracker();
        mentionedUsersMap.clear();
        mentionCount.clear();
        lastCursorPos = cursorPosition;
        CometChatUIEvents.hidePanel(
            composerId, CustomUIPosition.composerPreview);
      }
      return;
    }

    _removeMentionIfDeleted(textEditingController, previousText);
    //first we check if the current text has any part matching the regex pattern
    if (mentionCount.length < mentionsLimit) {
      // Add this condition to hide the panel when mentions drop below limit
      CometChatUIEvents.hidePanel(composerId, CustomUIPosition.composerTop);
    }

    //the following logic is for when copy paste is involved
    if (mentionedUsersMap.isNotEmpty &&
        textEditingController.text.length > previousText.length + 1) {
      int extraCharactersLength =
          textEditingController.text.length - previousText.length;
      if (listItems.isNotEmpty) {
        resetMentionsTracker();
        CometChatUIEvents.hidePanel(
            composerId, CustomUIPosition.composerPreview);
      }

      int extraCharactersStartIndex = cursorPosition - extraCharactersLength;
      String newText = textEditingController.text
          .substring(cursorPosition - extraCharactersLength, cursorPosition);

      if (extraCharactersStartIndex > -1 && newText.isNotEmpty) {
        String prev = previousText.substring(0, extraCharactersStartIndex);
        Map<String, List<User?>> mentionedUsersMapCopy = mentionedUsersMap;
        mentionedUsersMap.forEach(
          (key, value) {
            RegExp currentPattern = RegExp(key);
            if (currentPattern.hasMatch(newText)) {
              //@john @harry @john
              final oldMatchesCount = currentPattern.allMatches(prev).length;
              //@john @john @harry @john
              final newMatchesCount = currentPattern.allMatches(newText).length;

              mentionedUsersMapCopy[key]?.insertAll(
                  oldMatchesCount,
                  List<User?>.generate(newMatchesCount, (int index) => null,
                      growable: false));
            }
          },
        );
        mentionedUsersMap = mentionedUsersMapCopy;
      }
      lastCursorPos = cursorPosition;

      return;
    }

    //check if new text has same length as previous text
    if (previousText != textEditingController.text &&
        previousText.length > textEditingController.text.length) {
      //first check if the mentionTracker is not empty
      if (mentionTracker.isNotEmpty) {
        if (searchOnActiveMention && cursorPosition == lastCursorPos - 1) {
          //check if the user has triggered search by going back to the end of a mention
          cursorInMentionTracker(
              cursorPosition, textEditingController, previousText);
        } else if (cursorPosition == mentionStartIndex) {
          // if cursor position is at the start of the mentionTracker
          // it means the @ the tracking character is removed by the user
          resetMentionsTracker();
          CometChatUIEvents.hidePanel(
              composerId, CustomUIPosition.composerPreview);
        } else {
          //if the cursor position is between the start and end of the mentionTracker
          //it means the user is deleting the mentionTracker
          if (cursorPosition > mentionStartIndex &&
              cursorPosition <= mentionEndIndex) {
            mentionTracker =
                mentionTracker.substring(0, cursorPosition - mentionStartIndex);
            mentionEndIndex = cursorPosition - 1;
            if (mentionTracker.isEmpty && onSearch != null) {
              onSearch!(null);
            }
          } else if (cursorPosition < mentionStartIndex) {
            //if the cursor position is before the start of the mentionTracker
            //it means the user is deleting the mentionTracker
            mentionStartIndex = mentionStartIndex -
                (previousText.length - textEditingController.text.length);
            mentionEndIndex = mentionEndIndex -
                (previousText.length - textEditingController.text.length);
          }
        }
      } else {
        if (previousText[cursorPosition] == trackingCharacter) {
          cursorInMentionTracker(
              cursorPosition, textEditingController, previousText);
        } else {
          int lastIndexOfTrackingChar = textEditingController.text
              .substring(0, cursorPosition)
              .lastIndexOf(trackingCharacter!);
          if (lastIndexOfTrackingChar != -1 &&
              (lastIndexOfTrackingChar == 0 ||
                  lastIndexOfTrackingChar > 1 &&
                      textEditingController.text[lastIndexOfTrackingChar - 1] ==
                          " ")) {
            String tempTracker = textEditingController.text
                .substring(lastIndexOfTrackingChar, cursorPosition);

            if ((!tempTracker.contains("\n") &&
                    !tempTracker.contains("    ")) &&
                mentionedUsersMap.containsKey(tempTracker.trim())) {
              if (mentionedUsersMap.containsKey(tempTracker)) {
                cursorInMentionTracker(
                    cursorPosition, textEditingController, previousText);
              }
            } else if (cursorPosition < lastCursorPos - 1 ||
                cursorPosition > lastCursorPos) {
              //if there has been a jump in the cursor position
              //we reset the mentionTracker
              // we first hide the panel
              CometChatUIEvents.hidePanel(
                  composerId, CustomUIPosition.composerPreview);
              cursorInMentionTracker(
                  cursorPosition, textEditingController, previousText);
            } else if (!tempTracker.contains("\n") &&
                !tempTracker.contains(" ")) {
              mentionTracker = tempTracker;
              mentionStartIndex = lastIndexOfTrackingChar;
              mentionEndIndex = cursorPosition - 1;
            }
          }
        }
      }
    } else {
      String previousCharacter = cursorPosition == 0
          ? ""
          : textEditingController.text[cursorPosition - 1];

      bool isSpace = (cursorPosition == 1
          // &&( textEditingController.text.length<2  || ( textEditingController.text[1]==" " ))
          ) ||
          (textEditingController.text.length > 1 &&
              cursorPosition > 1 &&
              (textEditingController.text[cursorPosition - 2] == " " ||
                  textEditingController.text[cursorPosition - 2] == "\n"));

      if (previousCharacter == trackingCharacter && isSpace) {
        mentionTracker = trackingCharacter!;
        mentionStartIndex = cursorPosition - 1;
        checkIfTrackerPlacedCausesDuplication(
            cursorPosition - 1, textEditingController);
      } else if (previousCharacter == trackingCharacter &&
          !isSpace &&
          !searchOnActiveMention) {
        int lastIndexOfTrackingChar = textEditingController.text
            .substring(0, cursorPosition)
            .lastIndexOf(trackingCharacter!);
        if (lastIndexOfTrackingChar != -1 &&
            (lastIndexOfTrackingChar == 0 ||
                lastIndexOfTrackingChar > 1 &&
                    textEditingController.text[lastIndexOfTrackingChar - 1] ==
                        " ")) {
          String tempTracker = textEditingController.text
              .substring(lastIndexOfTrackingChar, cursorPosition);

          if ((!tempTracker.contains("\n") && !tempTracker.contains("    ")) &&
              mentionedUsersMap.containsKey(tempTracker.trim())) {
            cursorInMentionTracker(
                cursorPosition, textEditingController, previousText);
          }
        }
      } else if (searchOnActiveMention && cursorPosition == lastCursorPos + 1) {
        searchOnActiveMention = false;
        resetMentionsTracker();
      } else if (mentionTracker.isNotEmpty) {
        mentionTracker += previousCharacter;
        mentionEndIndex = cursorPosition - 1;
        //if the current text length is greater than the previous text length
        if (cursorPosition <= mentionStartIndex) {
          //if the cursor position is before the start of the mentionTracker
          //it means the user is adding text before the mentionTracker

          cursorInMentionTracker(
              cursorPosition, textEditingController, previousText);
        } else if (mentionStartIndex <= cursorPosition &&
            mentionEndIndex >= cursorPosition) {
          //if the cursor position is between the start and end of the mentionTracker
          //it means the user is adding text between the mentionTracker
          cursorInMentionTracker(
              cursorPosition, textEditingController, previousText);
          mentionEndIndex = mentionEndIndex +
              (textEditingController.text.length - previousText.length);
          mentionTracker = textEditingController.text
              .substring(mentionStartIndex, mentionEndIndex + 1);
        }
      } else {
        int lastIndexOfTrackingChar = textEditingController.text
            .substring(0, cursorPosition)
            .lastIndexOf(trackingCharacter!);
        if (lastIndexOfTrackingChar != -1 &&
            (lastIndexOfTrackingChar == 0 ||
                lastIndexOfTrackingChar > 1 &&
                    textEditingController.text[lastIndexOfTrackingChar - 1] ==
                        " ")) {
          String tempTracker = textEditingController.text
              .substring(lastIndexOfTrackingChar, cursorPosition);

          // if(tempTracker){}else
          if ((!tempTracker.contains("\n") && !tempTracker.contains("    "))
              // &&  (!mentionedUsersMap.containsKey(tempTracker.trim()) && textEditingController.text.length>1 && textEditingController.text[cursorPosition-2]!=" ")
              &&
              mentionedUsersMap.containsKey(tempTracker.trim())) {
            if (mentionedUsersMap.containsKey(tempTracker)) {
              cursorInMentionTracker(
                  cursorPosition, textEditingController, previousText);
            }
          } else if (cursorPosition < lastCursorPos ||
              cursorPosition > lastCursorPos + 1) {
            //if there has been a jump in the cursor position
            //we reset the mentionTracker
            // we first hide the panel
            CometChatUIEvents.hidePanel(
                composerId, CustomUIPosition.composerPreview);
            cursorInMentionTracker(
                cursorPosition, textEditingController, previousText);
          } else if (!tempTracker.contains("\n") &&
              !tempTracker.contains(" ")) {
            mentionTracker = tempTracker;
            mentionStartIndex = lastIndexOfTrackingChar;
            mentionEndIndex = cursorPosition - 1;
          }
        }
      }
    }

    /// if the mention tracker has four consecutive spaces then we will stop tracking the mention
    if ((mentionTracker.length > 1 &&
            mentionTracker[mentionTracker.length - 1] == "\n") ||
        mentionTracker.length > 4 &&
            mentionTracker
                .substring(mentionTracker.length - 4)
                .trim()
                .isEmpty) {
      String mention = mentionTracker;
      if (mentionedUsersMap.containsKey(mention)) {
        int matchesFound = textEditingController.text
            .substring(0, cursorPosition - mentionTracker.length)
            .allMatches(mention)
            .length;
        mentionedUsersMap[mention]!.insert(matchesFound, null);
      } else {
        mentionedUsersMap[mention] = [null];
      }
      mentionTracker = "";
      mentionStartIndex = 0;
      mentionEndIndex = 0;
      if (onSearch != null) {
        onSearch!(null);
      }

      CometChatUIEvents.hidePanel(composerId, CustomUIPosition.composerPreview);
    } else if (mentionTracker.isNotEmpty) {
      //if 10 users have been mentioned then we will show a message to the user
      //that the maximum limit of mentions has been reached'

      if (mentionCount.length >= mentionsLimit) {
        CometChatUIEvents.showPanel(composerId, CustomUIPosition.composerTop,
            (context) {
          final colorPalette = CometChatThemeHelper.getColorPalette(context);
          final spacing = CometChatThemeHelper.getSpacing(context);
          final typography = CometChatThemeHelper.getTypography(context);
          return Container(
            height: 40,
            color: colorPalette.error,
            padding: EdgeInsets.symmetric(horizontal: spacing.padding4 ?? 16),
            child: Row(
              children: [
                Image.asset(
                  AssetConstants.info,
                  package: UIConstants.packageName,
                  height: 16.18,
                ),
                Padding(
                  padding: EdgeInsets.only(left: spacing.padding2 ?? 8),
                  child: Text(
                    cc.Translations.of(context).mentionsMaxLimitHit,
                    style: TextStyle(
                      color: colorPalette.white,
                      fontSize: typography.button?.medium?.fontSize,
                      fontWeight: typography.button?.medium?.fontWeight,
                      fontFamily: typography.button?.medium?.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      } else {
        String searchKeyword = mentionTracker.substring(1);

        if ((mentionedUsersMap.containsKey(mentionTracker) &&
                !searchOnActiveMention) ||
            (interceptedMention != null &&
                (cursorPosition < textEditingController.text.length &&
                    mentionTracker.length < interceptedMention!.length) &&
                ((cursorPosition +
                            interceptedMention!.length -
                            mentionTracker.length <
                        textEditingController.text.length) &&
                    mentionTracker +
                            textEditingController.text.substring(
                                cursorPosition,
                                cursorPosition +
                                    interceptedMention!.length -
                                    mentionTracker.length) ==
                        interceptedMention))) {
          String key = interceptedMention ?? mentionTracker;

          int leftSideMatches = RegExp(key)
              .allMatches(textEditingController.text
                  .substring(0, cursorPosition - mentionTracker.length))
              .length;

          mentionedUsersMap[key]!.insert(leftSideMatches, null);
        }

        if (listItems.isEmpty) {
          CometChatUIEvents.showPanel(
              composerId,
              CustomUIPosition.composerPreview,
              (context) => getLoadingIndicator(context));
        }

        if (onSearch != null) {
          onSearch!(mentionTracker);
        }
        initializeFetchRequest(searchKeyword, textEditingController);
      }
    }
    lastCursorPos = cursorPosition;
  }

  int? conflictingIndex;

  void checkIfTrackerPlacedCausesDuplication(
      int start, TextEditingController textEditingController) {
    if (mentionedUsersMap.isNotEmpty) {
      mentionedUsersMap.forEach((key, value) {
        var matches = RegExp(key).allMatches(textEditingController.text);
        if (matches.length > value.length) {
          for (int i = 0; i < matches.length; i++) {
            if (matches.elementAt(i).start == start) {
              mentionedUsersMap[key]!.insert(i, null);

              conflictingIndex = i;
              break;
            }
          }
        }
      });
    }
  }

  List<User> getMentionedUsers(String text) {
    List<User> mentionedUsers = [];

    for (List<User?> users in mentionedUsersMap.values) {
      for (var user in users) {
        if (user != null &&
            mentionedUsers.indexWhere(
                  (element) => element.uid == user.uid,
                ) ==
                -1) {
          mentionedUsers.add(user);
        }
      }
    }

    return mentionedUsers;
  }

  @override
  List<AttributedText> buildInputFieldText(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing,
      required String text,
      List<AttributedText>? existingAttributes}) {
    List<AttributedText> attributedTexts = [];
    final mentionsStyle = CometChatThemeHelper.getTheme<CometChatMentionsStyle>(
            context: context, defaultTheme: CometChatMentionsStyle.of)
        .merge(this.style);
    CometChatColorPalette colorPalette =
        CometChatThemeHelper.getColorPalette(context);
    CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);
    mentionedUsersMap.forEach((username, userObjects) {
      final matches = RegExp(username).allMatches(text);

      List<AttributedText> currentAttributedTexts = [];

      for (int i = 0; i < matches.length; i++) {
        if (i >= userObjects.length) break;
        bool isLoggedInUser =
            userObjects[i]?.uid == CometChatUIKit.loggedInUser?.uid;
        try {
          if (userObjects[i] != null) {
            currentAttributedTexts.add(AttributedText(
              start: matches.elementAt(i).start,
              end: matches.elementAt(i).end,
              underlyingText: username,
              backgroundColor: (isLoggedInUser
                      ? mentionsStyle.mentionSelfTextBackgroundColor
                      : mentionsStyle.mentionTextBackgroundColor) ??
                  (isLoggedInUser ? colorPalette.warning : colorPalette.primary)
                      ?.withOpacity(.2) ??
                  Colors.transparent,
              borderRadius: mentionsStyle.borderRadius ?? spacing.radius ?? 0,
              padding: EdgeInsets.symmetric(
                  horizontal: spacing.padding ?? 0, vertical: 0),
              style: getMessageInputTextStyle(context,
                  isLoggedInUser: isLoggedInUser),
            ));
          }
        } catch (error) {
          if (kDebugMode) {
            print("error in mentions input $error");
          }
          break;
        }
      }

      attributedTexts.addAll(currentAttributedTexts);
    });

    return mergeAttributedText(attributedTexts, existingAttributes ?? []);
  }

  void setMentionedUsers(List<User> mentionedUsers) {
    for (var user in mentionedUsers) {
      String key = "@${user.name}";

      if (mentionedUsersMap.containsKey(key)) {
        mentionedUsersMap[key]!.add(user);
      } else {
        mentionedUsersMap[key] = [user];
      }
    }
  }

  static String getTextWithMentions(String text, List<User> mentionedUsers) {
    if (mentionedUsers.isNotEmpty) {
      for (var user in mentionedUsers) {
        text = text.replaceAll("<@uid:${user.uid}>", "@${user.name}");
      }
    }
    return text;
  }

  @override
  TextStyle getMessageBubbleTextStyle(
      BuildContext context, BubbleAlignment? alignment,
      {bool isLoggedInUser = false, bool forConversation = false}) {
    if (messageBubbleTextStyle != null) {
      return messageBubbleTextStyle!(context, alignment,
          forConversation: forConversation);
    } else {
      final mentionsStyle =
          CometChatThemeHelper.getTheme<CometChatMentionsStyle>(
                  context: context, defaultTheme: CometChatMentionsStyle.of)
              .merge(style);
      CometChatColorPalette colorPalette =
          CometChatThemeHelper.getColorPalette(context);
      CometChatTypography typography =
          CometChatThemeHelper.getTypography(context);

      //if user is logged in user then we will show the text in bold
      //if the message is for conversation then we will show the text in subtitle1 font size
      return TextStyle(
              color: (isLoggedInUser
                      ? mentionsStyle.mentionSelfTextColor
                      : mentionsStyle.mentionTextColor) ??
                  (alignment == BubbleAlignment.right
                      ? (isLoggedInUser
                          ? colorPalette.warning
                          : colorPalette.white)
                      : (isLoggedInUser
                          ? colorPalette.warning
                          : colorPalette.primary)),
              fontWeight: typography.body?.regular?.fontWeight,
              fontSize: typography.body?.regular?.fontSize,
              fontFamily: typography.body?.regular?.fontFamily,
              decoration: TextDecoration.none)
          .merge(isLoggedInUser
              ? mentionsStyle.mentionSelfTextStyle
              : mentionsStyle.mentionTextStyle)
          .copyWith(
              color: isLoggedInUser
                  ? mentionsStyle.mentionSelfTextColor
                  : mentionsStyle.mentionTextColor);
    }
  }

  @override
  TextStyle getMessageInputTextStyle(BuildContext context,
      {bool isLoggedInUser = false}) {
    if (messageInputTextStyle != null) {
      return messageInputTextStyle!(context);
    } else {
      final mentionsStyle =
          CometChatThemeHelper.getTheme<CometChatMentionsStyle>(
                  context: context, defaultTheme: CometChatMentionsStyle.of)
              .merge(style);
      CometChatColorPalette colorPalette =
          CometChatThemeHelper.getColorPalette(context);
      CometChatTypography typography =
          CometChatThemeHelper.getTypography(context);
      // if user is logged in user then we will show the text in bold
      return TextStyle(
              color:
                  isLoggedInUser ? colorPalette.warning : colorPalette.primary,
              fontWeight: isLoggedInUser
                  ? typography.body?.regular?.fontWeight
                  : typography.body?.regular?.fontWeight,
              fontSize: typography.body?.regular?.fontSize,
              fontFamily: typography.body?.regular?.fontFamily,
              decoration: TextDecoration.none)
          .merge(isLoggedInUser
              ? mentionsStyle.mentionSelfTextStyle
              : mentionsStyle.mentionTextStyle)
          .copyWith(
              color: isLoggedInUser
                  ? mentionsStyle.mentionSelfTextColor
                  : mentionsStyle.mentionTextColor);
    }
  }

  static String getMentionedUserName(String uid, BaseMessage message) {
    var mentionedUsers = message.mentionedUsers;
    int match = mentionedUsers.indexWhere((element) => element.uid == uid);

    return match != -1 ? mentionedUsers[match].name : "";
  }

  @override
  List<AttributedText> getAttributedText(
      String text, BuildContext context, BubbleAlignment? alignment,
      {List<AttributedText>? existingAttributes,
      Function(String)? onTap,
      bool forConversation = false}) {
    List<AttributedText> attributedTexts = [];
    final matches = pattern!.allMatches(text);
    List<User> mentionedUsers = message?.mentionedUsers ?? [];

    attributedTexts = matches.map((match) {
      int start = match.start;
      int end = match.end;
      int userIndex =
          mentionedUsers.indexWhere((element) => element.uid == match.group(1));

      String underlyingText = userIndex != -1
          ? "@${mentionedUsers[userIndex].name}"
          : match.group(0) ?? '';
      bool isLoggedInUser = userIndex != -1 &&
          mentionedUsers[userIndex].uid == CometChatUIKit.loggedInUser?.uid;

      final mentionsStyle =
          CometChatThemeHelper.getTheme<CometChatMentionsStyle>(
                  context: context, defaultTheme: CometChatMentionsStyle.of)
              .merge(style);
      CometChatColorPalette colorPalette =
          CometChatThemeHelper.getColorPalette(context);
      CometChatSpacing spacing = CometChatThemeHelper.getSpacing(context);

      return AttributedText(
          start: start,
          end: end,
          underlyingText: underlyingText,
          style: getMessageBubbleTextStyle(context, alignment,
              isLoggedInUser: isLoggedInUser, forConversation: forConversation),
          backgroundColor: (isLoggedInUser
                  ? mentionsStyle.mentionSelfTextBackgroundColor
                  : mentionsStyle.mentionTextBackgroundColor) ??
              (alignment == BubbleAlignment.right
                      ? (isLoggedInUser
                          ? colorPalette.warning
                          : colorPalette.white)
                      : (isLoggedInUser
                          ? colorPalette.warning
                          : colorPalette.primary))
                  ?.withOpacity(.2) ??
              Colors.transparent,
          borderRadius: mentionsStyle.borderRadius ?? spacing.radius ?? 0,
          padding: EdgeInsets.symmetric(
              horizontal: spacing.padding ?? 0, vertical: 0),
          onTap: (text) {
            if (onMentionTap != null) {
              onMentionTap!(text, mentionedUsers[userIndex], message: message);
            }
          });
    }).toList();

    if (existingAttributes != null && existingAttributes.isNotEmpty) {
      return mergeAttributedText(attributedTexts, existingAttributes);
    } else {
      return attributedTexts;
    }
  }

  void _removeMentionIfDeleted(TextEditingController? controller, String previousText) {
    if (controller == null || controller.text.isEmpty) return;

    String currentText = controller.text;
    int cursorPosition = controller.selection.baseOffset;

    // Create the mentions copy once
    final mentionsCopy = Map<String, List<User?>>.from(mentionedUsersMap);

    // Check backspace (text shortened by 1)
    if (previousText.length - currentText.length == 1) {
      final diffIndex = _findDiffIndex(previousText, currentText);
      if (diffIndex == null) return;

      for (final mention in mentionsCopy.keys) {
        final safeMention = RegExp.escape(mention);
        final matches = RegExp(safeMention).allMatches(previousText).toList();

        for (final match in matches) {
          final start = match.start;
          final end = match.end;

          if (diffIndex > start && diffIndex <= end) {
            // Replace full mention with ''
            final updated = previousText.replaceRange(start, end, '');
            controller.text = updated;
            controller.selection = TextSelection.collapsed(offset: start);

            // Remove user from map based on match index
            final users = mentionedUsersMap[mention];
            if (users != null && users.isNotEmpty) {
              final matchIndex = matches.indexOf(match);
              if (matchIndex < users.length) {
                users.removeAt(matchIndex);
              }
              if (users.isEmpty) mentionedUsersMap.remove(mention);
            }

            return;
          }
        }
      }
    }

    // Also handle when user moves cursor inside mention and deletes
    for (final mention in mentionsCopy.keys) {
      final safeMention = RegExp.escape(mention);
      final matches = RegExp(safeMention).allMatches(currentText).toList();

      for (int i = matches.length - 1; i >= 0; i--) {
        final match = matches[i];
        final start = match.start;
        final end = match.end;

        if (cursorPosition > start && cursorPosition <= end) {
          final newText = currentText.replaceRange(start, end, '');
          controller.text = newText;
          controller.selection = TextSelection.collapsed(offset: start);

          final users = mentionedUsersMap[mention];
          if (users != null && i < users.length) {
            users.removeAt(i);
            if (users.isEmpty) mentionedUsersMap.remove(mention);
          }

          return;
        }
      }
    }
  }

  int? _findDiffIndex(String oldText, String newText) {
    for (int i = 0; i < oldText.length; i++) {
      if (i >= newText.length || oldText[i] != newText[i]) {
        return i;
      }
    }
    return oldText.length == newText.length ? null : oldText.length - 1;
  }
}
