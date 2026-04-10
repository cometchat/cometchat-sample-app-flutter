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

  const MessagesScreen({
    super.key,
    this.user,
    this.group,
    this.goToMessageId,
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
  void onUserOnline(User user) {}

  @override
  void onUserOffline(User user) {}

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
    return CometChatMessageList(
      user: widget.user,
      group: widget.group,
      goToMessageId: widget.goToMessageId,
      showMarkAsUnreadOption: t.showMarkAsUnreadOption.value,
      startFromUnreadMessages: t.startFromUnreadMessages.value,
      hideDeletedMessages: t.hideDeletedMessages.value,
      disableReceipts: t.disableReceipts.value,
      avatarVisibility: t.avatarVisibility.value,
      hideDateSeparator: t.hideDateSeparator.value,
      hideStickyDate: t.hideStickyDate.value,
      disableReactions: t.disableReactions.value,
      enableSwipeToReply: t.enableSwipeToReply.value,
      hideGroupActionMessages: t.hideGroupActionMessages.value,
      enableSmartReplies: t.enableSmartReplies.value,
      enableConversationStarters: t.enableConversationStarters.value,
      hideCopyMessageOption: t.hideCopyMessageOption.value,
      hideDeleteMessageOption: t.hideDeleteMessageOption.value,
      hideEditMessageOption: t.hideEditMessageOption.value,
      hideMessageInfoOption: t.hideMessageInfoOption.value,
      hideReplyInThreadOption: t.hideReplyInThreadOption.value,
      hideReactionOption: t.hideReactionOption.value,
      hideTranslateMessageOption: t.hideTranslateMessageOption.value,
      hideShareMessageOption: t.hideShareMessageOption.value,
      textFormatters: [
        CometChatMentionsFormatter(user: widget.user, group: widget.group),
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
              user: widget.user,
              group: widget.group,
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
    return CometChatMessageComposer(
      user: widget.user,
      group: widget.group,
      disableTypingEvents: t.disableTypingEvents.value,
      hideVoiceRecordingButton: t.hideVoiceRecordingButton.value,
      hideSendButton: t.hideSendButton.value,
      hideAttachmentButton: t.hideAttachmentButton.value,
      hideStickersButton: t.hideStickersButton.value,
      disableMentions: t.disableMentions.value,
      hideBottomSafeArea: t.hideBottomSafeArea.value,
      textFormatters: [
        CometChatMentionsFormatter(user: widget.user, group: widget.group),
        MarkdownTextFormatter(),
        CometChatUrlFormatter(),
        CometChatPhoneNumberFormatter(),
        CometChatEmailFormatter(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    return Scaffold(
      backgroundColor: colorPalette.background1,
      resizeToAvoidBottomInset: false,
      appBar: CometChatMessageHeader(
        user: widget.user,
        group: widget.group,
        onBack: () => Navigator.pop(context),
        hideVideoCallButton: _toggles.hideVideoCallButton.value,
        hideVoiceCallButton: _toggles.hideVoiceCallButton.value,
        usersStatusVisibility: _toggles.headerUsersStatusVisibility.value,
        messageHeaderStyle: CometChatMessageHeaderStyle(
          backgroundColor: colorPalette.background1,
          border: Border(
            bottom: BorderSide(
              color: colorPalette.borderLight ?? Colors.transparent,
              width: 1.0,
            ),
          ),
        ),
        trailingView: (user, group, ctx) => [
          IconButton(
            icon: Icon(Icons.info_outline, color: colorPalette.iconPrimary),
            tooltip: widget.group != null ? 'Group Info' : 'User Info',
            onPressed: () {
              if (widget.group != null) {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => GroupInfoScreen(group: widget.group!),
                  ),
                );
              } else if (widget.user != null) {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => UserInfoScreen(user: widget.user!),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        color: colorPalette.background3,
        child: Column(
          children: [
            // Blocked user banner
            if (_isUserBlocked && _user != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: colorPalette.warning?.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    Icon(Icons.block, color: colorPalette.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _user!.blockedByMe == true
                            ? 'You have blocked this user.'
                            : 'This user has blocked you.',
                        style: TextStyle(
                          fontSize: typography.body?.regular?.fontSize,
                          color: colorPalette.textPrimary,
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
                color: colorPalette.error?.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    Icon(Icons.remove_circle_outline,
                        color: colorPalette.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have been removed from this group.',
                        style: TextStyle(
                          fontSize: typography.body?.regular?.fontSize,
                          color: colorPalette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: _toggles.revision,
                builder: (context, _, __) => _buildMessageList(),
              ),
            ),
            if (!_kickedOrBanned)
              ValueListenableBuilder<int>(
                valueListenable: _toggles.revision,
                builder: (context, _, __) => _buildComposer(),
              ),
          ],
        ),
      ),
    );
  }
}
