import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';
import 'package:intl/intl.dart';

/// Call Log Details screen — shows call info with Participants, Recordings,
/// and History tabs.
class CallLogDetailsScreen extends StatefulWidget {
  final CallLog callLog;

  const CallLogDetailsScreen({super.key, required this.callLog});

  @override
  State<CallLogDetailsScreen> createState() => _CallLogDetailsScreenState();
}

class _CallLogDetailsScreenState extends State<CallLogDetailsScreen> {
  late CometChatColorPalette _colorPalette;
  late CometChatTypography _typography;
  late CometChatSpacing _spacing;

  User? _userObj;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _fetchUser() async {
    final receiverId = CallLogsUtils.returnReceiverId(
        CometChatUIKit.loggedInUser, widget.callLog);
    await CometChat.getUser(
      receiverId,
      onSuccess: (user) {
        _userObj = user;
        if (mounted) setState(() {});
      },
      onError: (_) {},
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    _typography = CometChatThemeHelper.getTypography(context);
    _spacing = CometChatThemeHelper.getSpacing(context);
  }

  // --- Helpers ---

  static String _formatDate(int? epochSeconds) {
    if (epochSeconds == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    return DateFormat('d MMMM, h:mm a').format(dt);
  }

  String _getCallType() {
    final loggedInUser = CometChatUIKit.loggedInUser;
    final isInitiator = CallUtils.callLogLoggedInUser(widget.callLog, loggedInUser);
    switch (widget.callLog.status) {
      case CallStatusConstants.initiated:
      case CallStatusConstants.ongoing:
      case CallStatusConstants.ended:
        return isInitiator ? 'Outgoing' : 'Incoming';
      case CallStatusConstants.unanswered:
      case CallStatusConstants.cancelled:
      case CallStatusConstants.rejected:
      case CallStatusConstants.busy:
        return isInitiator ? 'Outgoing' : 'Missed';
      default:
        return 'Unknown';
    }
  }

  static String _convertMinutesToHMS(double? minutes) {
    if (minutes == null) return '';
    int totalSeconds = (minutes * 60).round();
    int hours = totalSeconds ~/ 3600;
    int remainingMinutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    String formatted = '';
    if (hours > 0) formatted += '${hours}hr ';
    if (remainingMinutes > 0 || hours > 0) formatted += '${remainingMinutes}m ';
    formatted += '${seconds}s';
    return formatted.trim();
  }

  @override
  Widget build(BuildContext context) {
    return CometChatListBase(
      title: 'Call Detail',
      hideSearch: true,
      showBackButton: true,
      style: ListBaseStyle(
        background: _colorPalette.background1,
        titleStyle: TextStyle(
          color: _colorPalette.textPrimary,
          fontSize: _typography.heading1?.bold?.fontSize,
          fontWeight: _typography.heading1?.bold?.fontWeight,
          fontFamily: _typography.heading1?.bold?.fontFamily,
        ),
        backIconTint: _colorPalette.iconPrimary,
      ),
      container: Column(
        children: [
          Divider(color: _colorPalette.borderLight, height: 1),
          // User header
          Padding(
            padding: EdgeInsets.only(
              right: _spacing.padding4 ?? 16,
              top: _spacing.padding5 ?? 20,
              bottom: _spacing.padding5 ?? 20,
            ),
            child: _userObj == null
                ? _buildShimmerHeader()
                : CometChatMessageHeader(
                    user: _userObj,
                    showBackButton: false,
                    avatarHeight: 48,
                    avatarWidth: 48,
                    padding: EdgeInsets.zero,
                  ),
          ),
          // Call info tile
          _buildCallInfoTile(),
          // Tabs
          Expanded(child: _buildTabs()),
        ],
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return CometChatShimmerEffect(
      colorPalette: _colorPalette,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _spacing.padding4 ?? 0,
          vertical: _spacing.padding3 ?? 0,
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: _spacing.padding3 ?? 0),
              child: const CircleAvatar(
                  radius: 24, backgroundColor: Colors.grey),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 19,
                    width: MediaQuery.sizeOf(context).width * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius:
                          BorderRadius.circular(_spacing.radius2 ?? 0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius:
                          BorderRadius.circular(_spacing.radius2 ?? 0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallInfoTile() {
    return Container(
      decoration: BoxDecoration(
        color: _colorPalette.background2,
        border: Border.all(
          color: _colorPalette.borderLight ?? Colors.transparent,
        ),
      ),
      child: ListTile(
        enableFeedback: false,
        horizontalTitleGap: 0,
        minVerticalPadding: 0,
        minLeadingWidth: 0,
        minTileHeight: 0,
        contentPadding: EdgeInsets.only(
          top: _spacing.padding3 ?? 12,
          bottom: _spacing.padding3 ?? 12,
          left: _spacing.padding4 ?? 16,
          right: _spacing.padding6 ?? 24,
        ),
        leading: Padding(
          padding: EdgeInsets.only(right: _spacing.padding3 ?? 12),
          child: CallUtils.getCallIcon(
            context,
            widget.callLog,
            CometChatUIKit.loggedInUser,
            _colorPalette,
            _typography,
            _spacing,
            const CometChatCallLogsStyle(),
            incomingCallIcon: null,
            outgoingCallIcon: null,
            missedCallIcon: null,
          ),
        ),
        title: Text(
          _getCallType(),
          style: TextStyle(
            color: _colorPalette.textPrimary,
            fontSize: _typography.heading4?.medium?.fontSize,
            fontWeight: _typography.heading4?.medium?.fontWeight,
            fontFamily: _typography.heading4?.medium?.fontFamily,
          ),
        ),
        subtitle: CometChatDate(
          pattern: DateTimePattern.dayDateFormat,
          customDateString: _formatDate(widget.callLog.initiatedAt),
          padding: EdgeInsets.zero,
          style: CometChatDateStyle(
            backgroundColor: _colorPalette.transparent,
            textStyle: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: _colorPalette.textSecondary,
              fontSize: _typography.body?.regular?.fontSize,
              fontWeight: _typography.body?.regular?.fontWeight,
              fontFamily: _typography.body?.regular?.fontFamily,
            ),
            border: Border.all(
              width: 0,
              color: _colorPalette.transparent ?? Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        trailing: Text(
          _convertMinutesToHMS(widget.callLog.totalDurationInMinutes),
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: _colorPalette.textPrimary,
            fontSize: _typography.caption1?.medium?.fontSize,
            fontWeight: _typography.caption1?.medium?.fontWeight,
            fontFamily: _typography.caption1?.medium?.fontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _colorPalette.background1,
        appBar: AppBar(
          backgroundColor: _colorPalette.background1,
          toolbarHeight: 0,
          bottom: TabBar(
            indicatorPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.symmetric(
                horizontal: _spacing.padding2 ?? 8),
            labelStyle: TextStyle(
              color: _colorPalette.textHighlight,
              fontSize: _typography.heading4?.medium?.fontSize,
              fontWeight: _typography.heading4?.medium?.fontWeight,
              fontFamily: _typography.heading4?.medium?.fontFamily,
            ),
            unselectedLabelStyle: TextStyle(
              color: _colorPalette.textSecondary,
              fontSize: _typography.heading4?.medium?.fontSize,
              fontWeight: _typography.heading4?.medium?.fontWeight,
              fontFamily: _typography.heading4?.medium?.fontFamily,
            ),
            tabs: const [
              Tab(text: 'Participants'),
              Tab(text: 'Recording'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ParticipantsTab(callLog: widget.callLog),
            _RecordingsTab(callLog: widget.callLog),
            _HistoryTab(callLog: widget.callLog),
          ],
        ),
      ),
    );
  }
}


// --- Participants Tab ---

class _ParticipantsTab extends StatelessWidget {
  final CallLog callLog;
  const _ParticipantsTab({required this.callLog});

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final participants = callLog.participants;

    if (participants == null || participants.isEmpty) {
      return _EmptyCallView(
        colorPalette: colorPalette,
        typography: typography,
        spacing: spacing,
        title: 'No Call Participants',
        subtitle: 'Make or receive calls to see call participants listed here.',
      );
    }

    return ListView.builder(
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final p = participants[index];
        return CometChatListItem(
          hideSeparator: true,
          avatarURL: p.avatar,
          avatarName: p.name,
          title: p.name,
          style: ListItemStyle(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.padding4 ?? 16,
              vertical: spacing.padding3 ?? 12,
            ),
            titleStyle: TextStyle(
              color: colorPalette.textPrimary,
              fontSize: typography.heading4?.medium?.fontSize,
              fontWeight: typography.heading4?.medium?.fontWeight,
              fontFamily: typography.heading4?.medium?.fontFamily,
            ),
          ),
          subtitleView: CometChatDate(
            pattern: DateTimePattern.dayDateFormat,
            customDateString: _CallLogDetailsScreenState._formatDate(
                callLog.initiatedAt),
            padding: EdgeInsets.zero,
            style: CometChatDateStyle(
              backgroundColor: colorPalette.transparent,
              textStyle: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: colorPalette.textSecondary,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
              ),
              border: Border.all(
                width: 0,
                color: colorPalette.transparent ?? Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          tailView: Text(
            _CallLogDetailsScreenState._convertMinutesToHMS(
                p.totalDurationInMinutes),
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: colorPalette.textPrimary,
              fontSize: typography.caption1?.medium?.fontSize,
              fontWeight: typography.caption1?.medium?.fontWeight,
              fontFamily: typography.caption1?.medium?.fontFamily,
            ),
          ),
        );
      },
    );
  }
}

// --- Recordings Tab ---

class _RecordingsTab extends StatelessWidget {
  final CallLog callLog;
  const _RecordingsTab({required this.callLog});

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);
    final recordings = callLog.recordings;

    if (recordings == null || recordings.isEmpty) {
      return _EmptyCallView(
        colorPalette: colorPalette,
        typography: typography,
        spacing: spacing,
        title: 'No Call Recordings',
        subtitle: 'Record a call to see call recordings listed here.',
      );
    }

    return ListView.builder(
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final rec = recordings[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.padding4 ?? 16,
            vertical: spacing.padding3 ?? 12,
          ),
          title: Text(
            rec.rid ?? '',
            style: TextStyle(
              color: colorPalette.textPrimary,
              fontSize: typography.heading4?.medium?.fontSize,
              fontWeight: typography.heading4?.medium?.fontWeight,
              fontFamily: typography.heading4?.medium?.fontFamily,
            ),
          ),
          subtitle: CometChatDate(
            pattern: DateTimePattern.dayDateFormat,
            customDateString: _CallLogDetailsScreenState._formatDate(
                callLog.initiatedAt),
            padding: EdgeInsets.zero,
            style: CometChatDateStyle(
              backgroundColor: colorPalette.transparent,
              textStyle: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: colorPalette.textSecondary,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
              ),
              border: Border.all(
                width: 0,
                color: colorPalette.transparent ?? Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rec.recordingUrl != null && rec.recordingUrl!.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.play_arrow_outlined,
                      color: colorPalette.iconHighlight),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayer(
                          backIcon: colorPalette.primary,
                          fullScreenBackground: colorPalette.neutral50,
                          videoUrl: rec.recordingUrl!,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// --- History Tab ---

class _HistoryTab extends StatefulWidget {
  final CallLog callLog;
  const _HistoryTab({required this.callLog});

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  List<CallLog> _history = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      // Determine if user or group call
      CallUser? callUser;
      CallGroup? callGroup;
      final log = widget.callLog;
      if (CallLogsUtils.isUser(log)) {
        callUser = CallUser(
          name: CallLogsUtils.receiverName(CometChatUIKit.loggedInUser, log),
          uid: CallLogsUtils.returnReceiverId(
              CometChatUIKit.loggedInUser, log),
          avatar: CallLogsUtils.receiverAvatar(
              CometChatUIKit.loggedInUser, log),
        );
      } else if (log.receiver is CallGroup) {
        callGroup = log.receiver as CallGroup;
      }

      final builder = CallLogRequestBuilder()
        ..callCategory = CometChatCallsConstants.callCategoryCall;
      if (callUser != null) builder.uid = callUser.uid;
      if (callGroup != null) builder.guid = callGroup.guid;

      final request = builder.build();
      final logs = await request.fetchNext(
        onSuccess: (List<CallLog> logs) => logs,
        onError: (_) => <CallLog>[],
      );
      if (mounted) {
        setState(() {
          _history = logs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _hasError = true; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = CometChatThemeHelper.getColorPalette(context);
    final typography = CometChatThemeHelper.getTypography(context);
    final spacing = CometChatThemeHelper.getSpacing(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError || _history.isEmpty) {
      return _EmptyCallView(
        colorPalette: colorPalette,
        typography: typography,
        spacing: spacing,
        title: 'No Call History Yet',
        subtitle:
            'Make or receive calls to see your call history listed here.',
      );
    }

    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final log = _history[index];
        final isInitiator = CallUtils.callLogLoggedInUser(
            log, CometChatUIKit.loggedInUser);
        String callType;
        switch (log.status) {
          case CallStatusConstants.initiated:
          case CallStatusConstants.ongoing:
          case CallStatusConstants.ended:
            callType = isInitiator ? 'Outgoing' : 'Incoming';
            break;
          case CallStatusConstants.unanswered:
          case CallStatusConstants.cancelled:
          case CallStatusConstants.rejected:
          case CallStatusConstants.busy:
            callType = isInitiator ? 'Outgoing' : 'Missed';
            break;
          default:
            callType = 'Unknown';
        }

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CallLogDetailsScreen(callLog: log),
              ),
            );
          },
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.padding4 ?? 16,
            vertical: spacing.padding3 ?? 12,
          ),
          leading: Padding(
            padding: EdgeInsets.only(right: spacing.padding3 ?? 12),
            child: CallUtils.getCallIcon(
              context,
              log,
              CometChatUIKit.loggedInUser,
              colorPalette,
              typography,
              spacing,
              const CometChatCallLogsStyle(),
              incomingCallIcon: null,
              outgoingCallIcon: null,
              missedCallIcon: null,
            ),
          ),
          title: Text(
            callType,
            style: TextStyle(
              color: colorPalette.textPrimary,
              fontSize: typography.heading4?.medium?.fontSize,
              fontWeight: typography.heading4?.medium?.fontWeight,
              fontFamily: typography.heading4?.medium?.fontFamily,
            ),
          ),
          subtitle: CometChatDate(
            pattern: DateTimePattern.dayDateFormat,
            customDateString:
                _CallLogDetailsScreenState._formatDate(log.initiatedAt),
            padding: EdgeInsets.zero,
            style: CometChatDateStyle(
              backgroundColor: colorPalette.transparent,
              textStyle: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: colorPalette.textSecondary,
                fontSize: typography.body?.regular?.fontSize,
                fontWeight: typography.body?.regular?.fontWeight,
                fontFamily: typography.body?.regular?.fontFamily,
              ),
              border: Border.all(
                width: 0,
                color: colorPalette.transparent ?? Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          trailing: Text(
            _CallLogDetailsScreenState._convertMinutesToHMS(
                log.totalDurationInMinutes),
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: colorPalette.textPrimary,
              fontSize: typography.caption1?.medium?.fontSize,
              fontWeight: typography.caption1?.medium?.fontWeight,
              fontFamily: typography.caption1?.medium?.fontFamily,
            ),
          ),
        );
      },
    );
  }
}

// --- Shared Empty View ---

class _EmptyCallView extends StatelessWidget {
  final CometChatColorPalette colorPalette;
  final CometChatTypography typography;
  final CometChatSpacing spacing;
  final String title;
  final String subtitle;

  const _EmptyCallView({
    required this.colorPalette,
    required this.typography,
    required this.spacing,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call, color: colorPalette.neutral300, size: 100),
          Padding(
            padding: EdgeInsets.only(
              top: spacing.padding5 ?? 20,
              bottom: spacing.padding ?? 2,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorPalette.textPrimary,
                fontSize: typography.heading3?.bold?.fontSize,
                fontWeight: typography.heading3?.bold?.fontWeight,
                fontFamily: typography.heading3?.bold?.fontFamily,
              ),
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorPalette.textSecondary,
              fontSize: typography.heading3?.regular?.fontSize,
              fontWeight: typography.heading3?.regular?.fontWeight,
              fontFamily: typography.heading3?.regular?.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
