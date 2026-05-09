import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';
import 'package:sample_app/utils/feature_flags.dart';
import 'package:sample_app/utils/component_toggles.dart';
import 'package:sample_app/screens/messages_screen.dart';
import 'package:sample_app/screens/contacts_screen.dart';
import 'package:sample_app/screens/create_group_screen.dart';
import 'package:sample_app/screens/call_log_details_screen.dart';
import 'package:sample_app/screens/join_protected_group_screen.dart';
import 'package:sample_app/screens/login_screen.dart';
import 'package:sample_app/screens/thread_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _toggles = ComponentToggles.instance;
  late CometChatColorPalette _colorPalette;

  // UI event listener for mention tap → open chat navigation
  final String _uiListenerId = 'home_screen_ui_${DateTime.now().millisecondsSinceEpoch}';

  static const _tabTitlesMobile = ['Chats', 'Calls', 'Users', 'Groups'];
  static const _tabTitlesWeb = ['Chats', 'Users', 'Groups'];
  static List<String> get _tabTitles => kIsWeb ? _tabTitlesWeb : _tabTitlesMobile;

  @override
  void initState() {
    super.initState();

    // Listen for openChat UI events (e.g., mention tap → navigate to user's chat)
    CometChatUIEvents.addUiListener(_uiListenerId, _HomeScreenUIEventListener(
      onOpenChat: (user, group) {
        if (mounted) {
          _pushMessages(context, user: user, group: group);
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    return Scaffold(
      backgroundColor: _colorPalette.background1,
      appBar: AppBar(
        backgroundColor: _colorPalette.background1,
        title: Text(
          _tabTitles[_currentIndex],
          style: TextStyle(
            color: _colorPalette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Profile popup menu
          if (FeatureFlags.showProfileMenu)
            _buildProfileMenu(),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: _colorPalette.background1,
        selectedItemColor: _colorPalette.primary,
        unselectedItemColor: _colorPalette.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat_rounded),
            label: 'Chats',
          ),
          if (!kIsWeb)
            const BottomNavigationBarItem(
              icon: Icon(Icons.call_outlined),
              activeIcon: Icon(Icons.call_rounded),
              label: 'Calls',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Users',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: 'Groups',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    final loggedInUser = CometChatUIKit.loggedInUser;
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spacing.radius2 ?? 8),
        side: BorderSide(
          color: _colorPalette.borderLight ?? Colors.transparent,
          width: 1,
        ),
      ),
      color: _colorPalette.background1,
      elevation: 4,
      menuPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      icon: Padding(
        padding: EdgeInsets.only(
          left: spacing.padding3 ?? 0,
          right: spacing.padding4 ?? 0,
        ),
        child: CometChatAvatar(
          width: 40,
          height: 40,
          image: loggedInUser?.avatar ?? '',
          name: loggedInUser?.name ?? '',
        ),
      ),
      onSelected: (value) async {
        switch (value) {
          case '/create':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactsScreen()),
            );
            break;
          case '/ai-assistant':
            _openAiAssistantScreen();
            break;
          case '/logout':
            await CometChatUIKit.logout(
              onSuccess: (_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              onError: (e) {
                debugPrint('Logout error: ${e.message}');
              },
            );
            break;
        }
      },
      position: PopupMenuPosition.under,
      enableFeedback: false,
      itemBuilder: (BuildContext bc) => [
        PopupMenuItem(
          height: 44,
          padding: EdgeInsets.all(spacing.padding4 ?? 16),
          value: '/create',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: spacing.padding2 ?? 8),
                child: Icon(
                  Icons.add_comment_outlined,
                  color: _colorPalette.iconSecondary,
                  size: 24,
                ),
              ),
              Text(
                'Create Conversation',
                style: TextStyle(
                  fontSize: typography.body?.regular?.fontSize,
                  fontFamily: typography.body?.regular?.fontFamily,
                  fontWeight: typography.body?.regular?.fontWeight,
                  color: _colorPalette.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          height: 44,
          padding: EdgeInsets.all(spacing.padding4 ?? 16),
          value: '/ai-assistant',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: spacing.padding2 ?? 8),
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: _colorPalette.iconSecondary,
                  size: 24,
                ),
              ),
              Text(
                cc.Translations.of(context).agents,
                style: TextStyle(
                  fontSize: typography.body?.regular?.fontSize,
                  fontFamily: typography.body?.regular?.fontFamily,
                  fontWeight: typography.body?.regular?.fontWeight,
                  color: _colorPalette.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          height: 44,
          padding: EdgeInsets.all(spacing.padding4 ?? 16),
          enabled: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: spacing.padding2 ?? 8),
                child: Icon(
                  Icons.account_circle_outlined,
                  color: _colorPalette.iconSecondary,
                  size: 24,
                ),
              ),
              Text(
                loggedInUser?.name ?? '',
                style: TextStyle(
                  fontSize: typography.body?.regular?.fontSize,
                  fontFamily: typography.body?.regular?.fontFamily,
                  fontWeight: typography.body?.regular?.fontWeight,
                  color: _colorPalette.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          height: 44,
          padding: EdgeInsets.all(spacing.padding4 ?? 16),
          value: '/logout',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: spacing.padding2 ?? 8),
                child: Icon(
                  Icons.logout,
                  color: _colorPalette.error,
                  size: 24,
                ),
              ),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: typography.body?.regular?.fontSize,
                  fontFamily: typography.body?.regular?.fontFamily,
                  fontWeight: typography.body?.regular?.fontWeight,
                  color: _colorPalette.error,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          height: 44,
          padding: EdgeInsets.all(spacing.padding4 ?? 16),
          enabled: false,
          child: Text(
            'v6.0.0-beta3',
            style: TextStyle(
              fontSize: typography.caption1?.regular?.fontSize,
              fontFamily: typography.caption1?.regular?.fontFamily,
              fontWeight: typography.caption1?.regular?.fontWeight,
              color: _colorPalette.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    // On web: no Calls tab. Indices: 0=Chats, 1=Users, 2=Groups
    // On mobile: 0=Chats, 1=Calls, 2=Users, 3=Groups
    if (!kIsWeb && _currentIndex == 1) {
      return CometChatCallLogs(
        hideAppbar: true,
        onItemClick: (callLog) => _openCallLogDetails(context, callLog),
        onError: (Exception error) {
          final errorMessage = error is CometChatException 
              ? error.message 
              : error.toString();
          debugPrint('CallLogs error: $errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call logs error: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        },
        errorStateView: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: _colorPalette.iconSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load call logs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _colorPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your connection and try again',
                style: TextStyle(
                  fontSize: 14,
                  color: _colorPalette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Force rebuild to retry
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorPalette.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        emptyStateView: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.call_outlined,
                size: 64,
                color: _colorPalette.iconSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No call logs yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _colorPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Make or receive calls to see them here',
                style: TextStyle(
                  fontSize: 14,
                  color: _colorPalette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Wrap in ValueListenableBuilder so toggle changes rebuild tabs instantly
    // On web: 0=Chats, 1=Users, 2=Groups (no Calls offset)
    // On mobile: 0=Chats, 2=Users, 3=Groups → subtract 1 for Calls gap
    final int stackIndex;
    if (kIsWeb) {
      stackIndex = _currentIndex; // 0=Chats, 1=Users, 2=Groups
    } else {
      stackIndex = _currentIndex == 0 ? 0 : _currentIndex - 1;
    }
    return ValueListenableBuilder<int>(
      valueListenable: _toggles.revision,
      builder: (context, _, __) {
        return IndexedStack(
          index: stackIndex,
          children: [
            _buildConversationsTab(),
            _buildUsersTab(),
            _buildGroupsTab(),
          ],
        );
      },
    );
  }

  Widget _buildConversationsTab() {
    return CometChatConversations(
      hideAppbar: true,
      onItemTap: (conversation) => _openChat(context, conversation),
      textFormatters: [
        CometChatMentionsFormatter(),
        MarkdownTextFormatter(),
        CometChatUrlFormatter(),
        CometChatPhoneNumberFormatter(),
        CometChatEmailFormatter(),
      ],
      hideSearch: false,
      searchReadOnly: true,
      onSearchTap: () => _openSearch(context),
      receiptsVisibility: _toggles.receiptsVisibility.value,
      usersStatusVisibility: _toggles.usersStatusVisibility.value,
      deleteConversationOptionVisibility: _toggles.deleteConversationOption.value,
      groupTypeVisibility: _toggles.groupTypeVisibility.value,
      disableSoundForMessages: _toggles.disableSoundForMessages.value,
    );
  }

  Widget _buildUsersTab() {
    return CometChatUsers(
      hideAppbar: true,
      onItemTap: (_, user) => _openUserChat(context, user),
      hideSearch: _toggles.usersHideSearch.value,
      stickyHeaderVisibility: _toggles.usersStickyHeader.value,
    );
  }

  Widget _buildGroupsTab() {
    return Stack(
      children: [
        CometChatGroups(
          hideAppbar: true,
          onItemTap: (_, group) => _openGroupChat(context, group),
          hideSearch: _toggles.groupsHideSearch.value,
          groupTypeVisibility: _toggles.groupsGroupTypeVisibility.value,
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'create_group',
            backgroundColor: _colorPalette.primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              );
            },
            child: Icon(Icons.group_add, color: _colorPalette.white),
          ),
        ),
      ],
    );
  }

  void _openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CometChatSearch(
          onConversationClicked: (conversation) {
            Navigator.pop(context);
            _openChat(context, conversation);
          },
          onMessageClicked: (message) {
            // Push messages screen on top of search (don't pop search)
            final sender = message.sender;
            final receiverUid = message.receiverUid;
            final receiverType = message.receiverType;
            final messageId = message.id;

            // Thread reply → fetch parent and open ThreadScreen so the reply
            // isn't injected into the main conversation's message list.
            if (message.parentMessageId > 0) {
              CometChatHelper.getMessageDetails(
                message.parentMessageId,
                onSuccess: (parent) {
                  if (parent == null) return;
                  User? threadUser;
                  Group? threadGroup;
                  if (parent.receiverType == ReceiverTypeConstants.user) {
                    final loggedInUid = CometChatUIKit.loggedInUser?.uid;
                    threadUser = (parent.sender?.uid == loggedInUid)
                        ? parent.receiver as User?
                        : parent.sender;
                  } else {
                    threadGroup = parent.receiver as Group?;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThreadScreen(
                        user: threadUser,
                        group: threadGroup,
                        message: parent,
                        goToMessageId: messageId,
                      ),
                    ),
                  );
                },
                onError: (_) {},
              );
              return;
            }

            if (receiverType == ReceiverTypeConstants.user) {
              final loggedInUid = CometChatUIKit.loggedInUser?.uid;
              final otherUid =
                  (sender?.uid == loggedInUid) ? receiverUid : sender?.uid;
              if (otherUid != null) {
                CometChat.getUser(otherUid,
                    onSuccess: (user) =>
                        _pushMessages(context, user: user, scrollToMessageId: messageId),
                    onError: (_) {});
              }
            } else if (receiverType == ReceiverTypeConstants.group) {
              final guid = receiverUid;
              CometChat.getGroup(guid,
                  onSuccess: (group) =>
                      _pushMessages(context, group: group, scrollToMessageId: messageId),
                  onError: (_) {});
            }
          },
        ),
      ),
    );
  }

  void _openChat(BuildContext context, Conversation conversation) {
    final user = conversation.conversationType == 'user'
        ? conversation.conversationWith as User
        : null;
    final group = conversation.conversationType != 'user'
        ? conversation.conversationWith as Group
        : null;

    // Protected group that user hasn't joined → show password screen
    if (group != null &&
        !group.hasJoined &&
        group.type == GroupTypeConstants.password) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JoinProtectedGroupScreen(group: group),
        ),
      );
      return;
    }

    _pushMessages(context, user: user, group: group);
  }

  void _openCallLogDetails(BuildContext context, CallLog callLog) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallLogDetailsScreen(callLog: callLog),
      ),
    );
  }

  void _openUserChat(BuildContext context, User user) =>
      _pushMessages(context, user: user);

  void _openGroupChat(BuildContext context, Group group) {
    // Already a member → open chat
    if (group.hasJoined) {
      _pushMessages(context, group: group);
      return;
    }

    // Password-protected group → show password prompt
    if (group.type == GroupTypeConstants.password) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JoinProtectedGroupScreen(group: group),
        ),
      );
      return;
    }

    // Public group the user isn't in (e.g., previously kicked) → auto-rejoin
    if (group.type == GroupTypeConstants.public) {
      _joinPublicGroupAndOpen(context, group);
      return;
    }

    // Private group the user isn't in → cannot self-rejoin, needs admin invite
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text(
        'You are no longer a member of this group. Ask an admin to add you back.',
      ),
      backgroundColor: _colorPalette.error,
    ));
  }

  /// Attempts to (re)join a public group on tap and opens the chat on success.
  /// Used when a user taps a public group they're not a member of — for example,
  /// after being kicked (ENG-34445).
  void _joinPublicGroupAndOpen(BuildContext context, Group group) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _colorPalette.white ?? Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('Joining ${group.name}…'),
          ],
        ),
        duration: const Duration(seconds: 10),
      ),
    );

    CometChat.joinGroup(
      group.guid,
      GroupTypeConstants.public,
      onSuccess: (joinedGroup) async {
        if (!mounted) return;
        if (!joinedGroup.hasJoined) joinedGroup.hasJoined = true;
        final user = await CometChat.getLoggedInUser();
        if (user != null) {
          CometChatGroupEvents.ccGroupMemberJoined(user, joinedGroup);
        }
        if (!mounted) return;
        messenger.hideCurrentSnackBar();
        _pushMessages(context, group: joinedGroup);
      },
      onError: (CometChatException e) {
        if (!mounted) return;
        debugPrint('Auto-join public group failed: ${e.message}');
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          content: Text(
            e.message ?? 'Unable to join group. Please try again.',
          ),
          backgroundColor: _colorPalette.error,
        ));
      },
    );
  }

  void _openAiAssistantScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CometChatUsers(
          title: cc.Translations.of(context).agents,
          usersRequestBuilder: UsersRequestBuilder()
            ..roles = [AIConstants.aiRole],
          onItemTap: (ctx, user) => _pushMessages(ctx, user: user),
        ),
      ),
    );
  }

  void _pushMessages(BuildContext context, {User? user, Group? group, int? scrollToMessageId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'messages'),
        builder: (_) => MessagesScreen(user: user, group: group, goToMessageId: scrollToMessageId),
      ),
    );
  }

  @override
  void dispose() {
    CometChatUIEvents.removeUiListener(_uiListenerId);
    super.dispose();
  }
}

/// Listener for CometChat UI events in HomeScreen
class _HomeScreenUIEventListener with CometChatUIEventListener {
  final void Function(User? user, Group? group) onOpenChat;

  _HomeScreenUIEventListener({required this.onOpenChat});

  @override
  void openChat(User? user, Group? group) {
    onOpenChat(user, group);
  }
}
