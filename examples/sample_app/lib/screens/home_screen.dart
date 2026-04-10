import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart' as cc;
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';
import 'package:sample_app/utils/feature_flags.dart';
import 'package:sample_app/utils/component_toggles.dart';
import 'package:sample_app/screens/messages_screen.dart';
import 'package:sample_app/screens/contacts_screen.dart';
import 'package:sample_app/screens/call_log_details_screen.dart';
import 'package:sample_app/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _toggles = ComponentToggles.instance;
  late CometChatColorPalette _colorPalette;

  static const _tabTitles = ['Chats', 'Calls', 'Users', 'Groups'];

  @override
  void initState() {
    super.initState();

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
          // New chat button
          if (FeatureFlags.showNewChatButton)
            IconButton(
              icon: Icon(Icons.edit_square,
                  color: _colorPalette.iconPrimary),
              tooltip: cc.Translations.of(context).newChat,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactsScreen()),
              ),
            ),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat_rounded),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_outlined),
            activeIcon: Icon(Icons.call_rounded),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
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
    return PopupMenuButton<String>(
      icon: CometChatAvatar(
        name: loggedInUser?.name ?? '',
        image: loggedInUser?.avatar ?? '',
        height: 32,
        width: 32,
      ),
      offset: const Offset(0, 48),
      color: _colorPalette.background1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _colorPalette.borderLight ?? Colors.transparent,
        ),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
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
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loggedInUser?.name ?? '',
                style: TextStyle(
                  color: _colorPalette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                loggedInUser?.uid ?? '',
                style: TextStyle(
                  color: _colorPalette.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: _colorPalette.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(color: _colorPalette.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    // Calls tab built on-demand with proper error handling
    if (_currentIndex == 1) {
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
    final stackIndex = _currentIndex == 0 ? 0 : _currentIndex - 1;
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
    return CometChatGroups(
      hideAppbar: true,
      onItemTap: (_, group) => _openGroupChat(context, group),
      hideSearch: _toggles.groupsHideSearch.value,
      groupTypeVisibility: _toggles.groupsGroupTypeVisibility.value,
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

  void _openGroupChat(BuildContext context, Group group) =>
      _pushMessages(context, group: group);

  void _pushMessages(BuildContext context, {User? user, Group? group, int? scrollToMessageId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'messages'),
        builder: (_) => MessagesScreen(user: user, group: group, goToMessageId: scrollToMessageId),
      ),
    );
  }

}
