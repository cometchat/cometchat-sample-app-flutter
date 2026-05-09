import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import '../utils/component_toggles.dart';
import 'thread_screen.dart';
import 'group_info_screen.dart';
import 'user_info_screen.dart';

class MessagesScreen extends StatefulWidget {
  final User? user;
  final Group? group;
  final int? goToMessageId;
  final BaseMessage? parentMessage;
  final bool isHistory;

  const MessagesScreen({
    super.key,
    this.user,
    this.group,
    this.goToMessageId,
    this.parentMessage,
    this.isHistory = false,
  }) : assert(user != null || group != null);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with
        UserListener,
        CometChatUserEventListener,
        GroupListener,
        CometChatGroupEventListener {
  // Mutable copies for tracking blocked / kicked state
  late User? _user;
  late Group? _group;
  bool _isUserBlocked = false;
  bool _kickedOrBanned = false;

  late final String _listenerId;

  final _toggles = ComponentToggles.instance;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _group = widget.group;
    _listenerId = DateTime.now().millisecondsSinceEpoch.toString();

    // Add listeners for blocked/kicked state
    if (_user != null) {
      CometChat.addUserListener('${_listenerId}_msg_user', this);
      CometChatUserEvents.addUsersListener('${_listenerId}_msg_user_ui', this);
      _isUserBlocked =
          _user!.blockedByMe == true || _user!.hasBlockedMe == true;
    }
    if (_group != null) {
      CometChat.addGroupListener('${_listenerId}_msg_group', this);
      CometChatGroupEvents.addGroupsListener(
          '${_listenerId}_msg_group_ui', this);
    }

  }

  @override
  void dispose() {
    if (_user != null) {
      CometChat.removeUserListener('${_listenerId}_msg_user');
      CometChatUserEvents.removeUsersListener('${_listenerId}_msg_user_ui');
    }
    if (_group != null) {
      CometChat.removeGroupListener('${_listenerId}_msg_group');
      CometChatGroupEvents.removeGroupsListener('${_listenerId}_msg_group_ui');
    }
    super.dispose();
  }

  // --- User Listeners (blocked state) ---

  @override
  void ccUserBlocked(User user) {
    if (_user != null && user.uid == _user!.uid) {
      _user!.blockedByMe = true;
      setState(() => _isUserBlocked = true);
    }
  }

  @override
  void ccUserUnblocked(User user) {
    if (_user != null && user.uid == _user!.uid) {
      _user!.blockedByMe = false;
      setState(() {
        _isUserBlocked =
            _user!.blockedByMe == true || _user!.hasBlockedMe == true;
      });
    }
  }

  @override
  void onUserOnline(User user) {
    if (_user != null && user.uid == _user!.uid) {
      _user = user; // Keep reference fresh; header BLoC handles its own UI update
    }
  }

  @override
  void onUserOffline(User user) {
    if (_user != null && user.uid == _user!.uid) {
      _user = user;
    }
  }

  // --- Group Listeners (kicked/banned state) ---

  @override
  void onGroupMemberKicked(
      cc.Action action, User kickedUser, User kickedBy, Group kickedFrom) {
    if (_group != null && kickedFrom.guid == _group!.guid) {
      final loggedInUid = CometChatUIKit.loggedInUser?.uid;
      if (kickedUser.uid == loggedInUid) {
        setState(() => _kickedOrBanned = true);
      } else {
        _group = kickedFrom;
        setState(() {});
      }
    }
  }

  @override
  void onGroupMemberBanned(
      cc.Action action, User bannedUser, User bannedBy, Group bannedFrom) {
    if (_group != null && bannedFrom.guid == _group!.guid) {
      final loggedInUid = CometChatUIKit.loggedInUser?.uid;
      if (bannedUser.uid == loggedInUid) {
        setState(() => _kickedOrBanned = true);
      } else {
        _group = bannedFrom;
        setState(() {});
      }
    }
  }

  @override
  void ccGroupMemberKicked(
      cc.Action message, User kickedUser, User kickedBy, Group kickedFrom) {
    if (_group != null && kickedFrom.guid == _group!.guid) {
      _group = kickedFrom;
      setState(() {});
    }
  }

  @override
  void ccGroupMemberBanned(
      cc.Action message, User bannedUser, User bannedBy, Group bannedFrom) {
    if (_group != null && bannedFrom.guid == _group!.guid) {
      _group = bannedFrom;
      setState(() {});
    }
  }

  @override
  void onGroupMemberLeft(cc.Action action, User leftUser, Group leftGroup) {
    if (_group != null && leftGroup.guid == _group!.guid) {
      _group = leftGroup;
      setState(() {});
    }
  }

  @override
  void onGroupMemberJoined(
      cc.Action action, User joinedUser, Group joinedGroup) {
    if (_group != null && joinedGroup.guid == _group!.guid) {
      _group = joinedGroup;
      setState(() {});
    }
  }

  @override
  void onMemberAddedToGroup(
      cc.Action action, User addedby, User userAdded, Group addedTo) {
    if (_group != null && addedTo.guid == _group!.guid) {
      _group = addedTo;
      setState(() {});
    }
  }

  @override
  void ccGroupMemberAdded(List<cc.Action> messages, List<User> usersAdded,
      Group groupAddedIn, User addedBy) {
    // UI event fires when the logged-in user adds members.
    // SDK onMemberAddedToGroup fires only for OTHER users in the group.
    if (_group != null && groupAddedIn.guid == _group!.guid) {
      _group = groupAddedIn;
      setState(() {});
    }
  }

  @override
  void onGroupMemberScopeChanged(cc.Action action, User updatedBy,
      User updatedUser, String scopeChangedTo, String scopeChangedFrom,
      Group group) {
    if (_group != null && group.guid == _group!.guid) {
      final loggedInUid = CometChatUIKit.loggedInUser?.uid;
      if (updatedUser.uid == loggedInUid) {
        _group!.scope = scopeChangedTo;
        setState(() {});
      }
    }
  }

  // --- Build ---

  Widget _buildMessageList() {
    final t = _toggles;
    final isAIUser = _user?.role == 'ai' || _user?.role == '@agentic';

    // When coming from AI chat history, scope messages to the parent message
    MessagesRequestBuilder? requestBuilder;
    int? parentMessageId;
    if (widget.parentMessage != null && widget.isHistory) {
      parentMessageId = widget.parentMessage!.id;
      requestBuilder = MessagesRequestBuilder()
        ..parentMessageId = widget.parentMessage!.id
        ..withParent = true
        ..hideReplies = false; // Show all messages in the thread (user + AI)
    }

    return CometChatMessageList(
      user: _user,
      group: _group,
      goToMessageId: widget.goToMessageId,
      parentMessageId: parentMessageId,
      messagesRequestBuilder: requestBuilder,
      hideReplies: (widget.isHistory) ? false : true,
      showMarkAsUnreadOption: true,
      startFromUnreadMessages: true,
      hideDeletedMessages: t.hideDeletedMessages.value,
      disableReceipts: t.disableReceipts.value,
      avatarVisibility: t.avatarVisibility.value,
      hideDateSeparator: t.hideDateSeparator.value,
      hideStickyDate: t.hideStickyDate.value,
      disableReactions: isAIUser || t.disableReactions.value,
      enableSwipeToReply: isAIUser ? false : t.enableSwipeToReply.value,
      hideGroupActionMessages: t.hideGroupActionMessages.value,
      enableSmartReplies: isAIUser || t.enableSmartReplies.value,
      enableConversationStarters: isAIUser || t.enableConversationStarters.value,
      hideCopyMessageOption: t.hideCopyMessageOption.value,
      hideDeleteMessageOption: t.hideDeleteMessageOption.value,
      hideEditMessageOption: t.hideEditMessageOption.value,
      hideMessageInfoOption: t.hideMessageInfoOption.value,
      hideReplyInThreadOption: t.hideReplyInThreadOption.value,
      hideReactionOption: t.hideReactionOption.value,
      hideTranslateMessageOption: t.hideTranslateMessageOption.value,
      hideShareMessageOption: t.hideShareMessageOption.value,
      textFormatters: [
        CometChatMentionsFormatter(user: _user, group: _group),
        MarkdownTextFormatter(),
        CometChatUrlFormatter(),
        CometChatPhoneNumberFormatter(),
        CometChatEmailFormatter(),
      ],
      onThreadRepliesClick: (message, ctx, {template}) {
        if (!mounted) return;
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (_, animation, __) => ThreadScreen(
              user: _user,
              group: _group,
              message: message,
              template: template,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                    parent: animation, curve: Curves.easeOut),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    final t = _toggles;
    final isAI = _user?.role == 'ai' || _user?.role == '@agentic';
    return CometChatMessageComposer(
      user: _user,
      group: _group,
     
     parentMessageId: widget.parentMessage?.id ?? 0,
      placeholderText: isAI ? 'Ask anything...' : null,
      disableTypingEvents: isAI || t.disableTypingEvents.value,
      hideVoiceRecordingButton: isAI || t.hideVoiceRecordingButton.value,
      hideSendButton: t.hideSendButton.value,
      hideAttachmentButton: isAI || t.hideAttachmentButton.value,
      hideStickersButton: isAI || t.hideStickersButton.value,
      disableMentions: isAI || t.disableMentions.value,
      hideBottomSafeArea: t.hideBottomSafeArea.value,
      layout: cc.CometChatComposerLayout.singleLine,
      textFormatters: isAI
          ? [] // No formatters for AI chat
          : [
              CometChatMentionsFormatter(user: _user, group: _group),
              MarkdownTextFormatter(),
              CometChatUrlFormatter(),
              CometChatPhoneNumberFormatter(),
              CometChatEmailFormatter(),
            ],
      enableRichTextFormatting: !isAI,
      showRichTextFormattingOptions: !isAI,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _colorPalette = CometChatThemeHelper.getColorPalette(context);
    final _typography = CometChatThemeHelper.getTypography(context);
    final _isAI = _user?.role == 'ai' || _user?.role == '@agentic';
    return Scaffold(
      backgroundColor: _colorPalette.background1,
      appBar: CometChatMessageHeader(
        user: _user,
        group: _group,
        onBack: () => Navigator.pop(context),
        hideVideoCallButton: _isAI || _toggles.hideVideoCallButton.value,
        hideVoiceCallButton: _isAI || _toggles.hideVoiceCallButton.value,
        usersStatusVisibility: _toggles.headerUsersStatusVisibility.value,
        chatHistoryButtonClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CometChatAIAssistantChatHistory(
                user: _user,
                group: _group,
                onNewChatButtonClicked: () {
                  if (widget.isHistory) {
                    Navigator.of(context).pop();
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MessagesScreen(
                        user: _user,
                        group: _group,
                      ),
                    ),
                  );
                },
                onMessageClicked: (message) {
                  if (message != null) {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessagesScreen(
                          user: _user,
                          group: _group,
                          parentMessage: message,
                          isHistory: true,
                        ),
                      ),
                    );
                  }
                },
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
        messageHeaderStyle: CometChatMessageHeaderStyle(
          backgroundColor: _colorPalette.background1,
          border: Border(
            bottom: BorderSide(
              color: _colorPalette.borderLight ?? Colors.transparent,
              width: 1.0,
            ),
          ),
        ),
        trailingView: (user, group, ctx) => [
          if (user?.role == 'ai' || user?.role == '@agentic') ...[
            IconButton(
              icon: Icon(Icons.add, color: _colorPalette.iconPrimary),
              tooltip: 'New Chat',
              onPressed: () {
                Navigator.pushReplacement(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => MessagesScreen(
                      user: _user,
                      group: _group,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.history, color: _colorPalette.iconPrimary),
              tooltip: 'AI Chat History',
              onPressed: () {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => CometChatAIAssistantChatHistory(
                      user: _user,
                      group: _group,
                      onNewChatButtonClicked: () {
                        // Pop history, then replace current messages with fresh one
                        if (widget.isHistory) {
                          Navigator.of(ctx).pop();
                        }
                        Navigator.pushReplacement(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => MessagesScreen(
                              user: _user,
                              group: _group,
                            ),
                          ),
                        );
                      },
                      onMessageClicked: (message) {
                        if (message != null) {
                          Navigator.of(ctx)
                            ..pop()
                            ..pop();
                          Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => MessagesScreen(
                                user: _user,
                                group: _group,
                                parentMessage: message,
                                isHistory: true,
                              ),
                            ),
                          );
                        }
                      },
                      onClose: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                );
              },
            ),
          ], // end AI buttons spread
          if (!_isAI)
            IconButton(
              icon: Icon(Icons.info_outline, color: _colorPalette.iconPrimary),
              tooltip: _group != null ? 'Group Info' : 'User Info',
            onPressed: () {
              if (_group != null) {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => GroupInfoScreen(group: _group!),
                  ),
                );
              } else if (_user != null) {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => UserInfoScreen(user: _user!),
                  ),
                );
              }
            },
            ),
        ],
      ),
      body: SafeArea(
        bottom: false, // Scaffold's resizeToAvoidBottomInset handles bottom keyboard inset
        child: Container(
          color: _colorPalette.background3,
          child: Column(
            children: [
              // Blocked user banner
              if (_isUserBlocked && _user != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: _colorPalette.warning?.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: _colorPalette.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _user!.blockedByMe == true
                              ? 'You have blocked this user.'
                              : 'This user has blocked you.',
                          style: TextStyle(
                            fontSize: _typography.body?.regular?.fontSize,
                            color: _colorPalette.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Kicked/banned banner
              if (_kickedOrBanned && _group != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: _colorPalette.error?.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle_outline,
                          color: _colorPalette.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You have been removed from this group.',
                          style: TextStyle(
                            fontSize: _typography.body?.regular?.fontSize,
                            color: _colorPalette.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _buildMessageList(),
              ),
              if (!_kickedOrBanned)
                _buildComposer(),
            ],
          ),
        ),
      ),
    );
  }
}
